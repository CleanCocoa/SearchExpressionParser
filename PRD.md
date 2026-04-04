# PRD: Eliminate Stack Overflows in SearchExpressionParser

## Problem

The parser crashes with SIGSEGV (stack overflow) on long search inputs. The recursive descent parser produces right-leaning binary trees with depth O(N) for N tokens, and every operation -- parsing, evaluation, phrase extraction, normalization -- recurses through the full tree depth. On a background thread with a 512KB stack (common on iOS), this can crash with as few as 200-300 tokens. A user pasting a paragraph of text into a search field is enough to trigger it.

See `findings.md` for crash thresholds and reproduction steps.

## Goal

Make all operations safe for arbitrarily long inputs using O(1) call stack depth, while preserving the existing public API and tree semantics. Optimize for the live-typing use case where the full pipeline (tokenize -> parse -> evaluate) runs on every keystroke.

## Non-Goals

- Changing the public `Expression` protocol or node type APIs
- Incremental/differential parsing (full re-parse is fast enough)
- Changing tree shape from right-leaning to balanced (a future optimization, not required now)
- Modifying the tokenizer (already iterative and safe)

## Architecture Overview

```
User input string
    |
    v
Tokenizer (iterative, safe -- no changes needed)
    |
    v
[Token] array
    |
    v
balanceParentheses() --> CHANGE 1: make iterative
    |
    v
[Token] array (balanced)
    |
    v
Parser.parseExpression() --> CHANGE 2: make iterative
    |
    v
Expression tree (right-leaning, depth = N-1)
    |
    +---> isSatisfied(by:) --> CHANGE 3: make iterative
    |
    +---> ContainmentEvaluator.normalizedEvaluable() --> CHANGE 4: make iterative
    |         |
    |         v
    |     .phrases --> CHANGE 5: make iterative
    v
Result
```

## Source Files Inventory

### Files to modify

| File | What changes | Why |
|------|-------------|-----|
| `Sources/.../Parsing/Parser.swift` | Rewrite `parseBinaryOperator`, `balanceParentheses`, negation handling, add paren depth limit | Eliminates stack overflow during parsing |
| `Sources/.../Parsing/Expressions.swift` | Add iterative `isSatisfied` evaluation | Eliminates stack overflow during tree evaluation |
| `Sources/.../NormalForm/PhraseCollectionConvertible.swift` | Add iterative `phrases` computation | Eliminates stack overflow during phrase extraction |
| `Sources/.../NormalForm/ContainmentEvaluator.swift` | Rewrite `pushNegation` iteratively, remove `maxRecursion` | Eliminates stack overflow during normalization; removes artificial limit |

### Files that must NOT change

| File | Why |
|------|-----|
| `Sources/.../Parsing/TokenBuffer.swift` | Already correct; provides `peekToken`/`consume`/`isNotAtEnd` |
| `Sources/.../Tokenization/Tokenizer.swift` | Already iterative, O(1) stack |
| `Sources/.../Tokenization/Tokens.swift` | Token types are correct as-is |
| `Sources/.../Either.swift` | Utility, unrelated |
| All files under `Tokenization/TokenExtractor/` | Non-recursive extractors, unrelated |
| `Sources/.../SearchExpressionParser.swift` | Public entry point, correct as-is |

### Test files

| File | Role |
|------|------|
| `Tests/.../StackOverflowTests.swift` | Stress tests at escalating sizes (already created). Must all pass after changes. |
| All other test files | 117 existing tests. Must all pass unchanged to prove behavioral equivalence. |

---

## Change 1: Iterative `balanceParentheses`

**File:** `Parser.swift`, lines 123-166

**Current behavior:** The free function `balanceParentheses(tokens:start:)` recurses at line 147 for each `OpeningParens` token, with recursion depth equal to paren nesting depth.

**Required behavior:** Same output (identical `[Token]` array), but iterative.

**Approach:** Replace the recursive function with a single linear pass using an explicit stack of `(` positions.

```
Algorithm:
1. Walk tokens left to right.
2. On OpeningParens: push index onto stack.
3. On ClosingParens:
   - If stack is non-empty: pop (matched pair, keep both tokens).
   - If stack is empty: replace with Word(")") (unmatched closer).
4. After walk: replace all remaining stacked OpeningParens indices with Word("(") (unmatched openers).
```

**Constraints:**
- The function signature `balanceParentheses(tokens: [Token]) -> [Token]` is `internal`, so it can change freely.
- The private `Balance` enum and `balanceParentheses(tokens:start:)` overload are deleted entirely.
- Existing `BalanceParenthesesTests` (13 tests) must all pass.

**Edge cases to preserve:**
- Empty token array -> empty result.
- No parens -> tokens unchanged.
- `()` (empty parens) -> kept as-is (the parser later handles this in `parseOpeningParens`).
- `)(` -> both replaced with Words.
- `(((a)))` -> kept as-is.
- `((a)` -> outer `(` replaced with Word, inner `(a)` kept.

---

## Change 2: Iterative Parser

**File:** `Parser.swift`, lines 19-111

This is the largest and most critical change. It has four sub-parts.

### 2a. Iterative binary operator / expression loop

**Current behavior:** `parseExpression` (line 19) calls `parseBinaryOperator` (line 73), which calls `parseExpression` again (lines 80, 86, 90). This mutual recursion repeats once per token.

**Required behavior:** Same tree output, but the `parseExpression` <-> `parseBinaryOperator` loop is a `while` loop, not recursion.

**Approach:** Rewrite `parseExpression` to:
1. Call `parsePrimary` to get the first operand.
2. Enter a `while` loop that continues as long as `tokenBuffer.isNotAtEnd` and the next token is not `ClosingParens`.
3. Inside the loop: consume the operator (if present), call `parsePrimary` for the next operand, and record the `(operator, operand)` pair.
4. After the loop: if the next token is `ClosingParens`, consume it.
5. Fold the collected `[(operator?, Expression)]` array into a right-leaning tree by iterating from the end.

**Folding to preserve right-associativity:**

The current parser is right-associative: `a b c` -> `AndNode(a, AndNode(b, c))`. To reproduce this from a flat list `[a, b, c]`:

```swift
// terms = [(nil, a), (nil, b), (nil, c)]
// Walk backwards:
var result = terms.last!.expr
for i in stride(from: terms.count - 2, through: 0, by: -1) {
    let nextOp = terms[i + 1].op
    switch nextOp {
    case BinaryOperator.or:  result = OrNode(terms[i].expr, result)
    default:                 result = AndNode(terms[i].expr, result)
    }
}
```

Wait -- the current grammar associates the operator with the _preceding_ operand's right side. Need to examine the exact semantics:

Current code, line 73-93:
```swift
parseBinaryOperator(_ tokenBuffer, lhs: node)
    guard let operatorToken = tokenBuffer.peekToken() else { return lhs }
    switch operatorToken {
    case BinaryOperator.and:
        consume; rhs = parseExpression(); return AndNode(lhs, rhs)
    case BinaryOperator.or:
        consume; rhs = parseExpression(); return OrNode(lhs, rhs)
    default:
        rhs = parseExpression(); return AndNode(lhs, rhs)  // implicit AND
    }
```

So the operator token sits _between_ lhs and rhs. For `a OR b AND c`:
- Parse `a` as primary.
- See `OR`, consume it, parse `b AND c` as rhs expression.
  - Parse `b` as primary.
  - See `AND`, consume it, parse `c` as rhs expression.
    - Parse `c` as primary. No more tokens. Return `c`.
  - Return `AndNode(b, c)`.
- Return `OrNode(a, AndNode(b, c))`.

So the operator _after_ a term determines how that term connects to the rest. The terms list should be:

```
[(expr: a, followingOp: OR), (expr: b, followingOp: AND), (expr: c, followingOp: nil)]
```

Fold right:
```
result = c
result = AndNode(b, result)  // because b's followingOp is AND
result = OrNode(a, result)   // because a's followingOp is OR
```

For implicit AND (`a b c` with no operator tokens):
```
[(expr: a, followingOp: nil), (expr: b, followingOp: nil), (expr: c, followingOp: nil)]
```
Fold right with `nil` -> `AndNode` (the default case):
```
result = c
result = AndNode(b, result)
result = AndNode(a, result)
```
Produces `AndNode(a, AndNode(b, c))`. Correct.

**Trailing operator edge case** (e.g., `foo AND`):
- Current behavior (line 79): if `tokenBuffer.isNotAtEnd` is false after consuming AND, returns `AndNode(lhs, ContainsNode("AND"))`.
- The iterative version must handle this: if after consuming an operator there are no more tokens, append `ContainsNode(token: operator)` as the final term and treat the connection as AND.

**Important detail about OR precedence:**
The current parser gives OR _lower_ precedence than AND through the recursion structure. `a OR b c` parses as `OrNode(a, AndNode(b, c))` because after consuming OR, `parseExpression` parses the entire remaining `b c` as a single expression. This must be preserved in the iterative version.

This means we cannot simply collect all terms flat -- OR splits the expression into two halves. The iterative approach needs to handle this.

**Revised approach for OR precedence:**

Collect terms at the AND/implicit level, then handle OR as a separator between groups:

```
Parse sequence of (primary, operator?) pairs in a while loop.
When we encounter OR:
  - Everything collected so far is the LHS of the OrNode.
  - Everything after is parsed as a new expression (which we also collect iteratively).

Actually, the simpler realization: the current recursion for OR already parses the entire rest as rhs. The iterative version should do the same: when we see OR, fold everything collected so far into the LHS, then continue collecting for the RHS.
```

Actually, re-examining: the current code does NOT have different precedence levels. Both AND and OR call `parseExpression` for the RHS, which re-enters the same function. The only precedence difference is that OR appears in the grammar at the same level as AND. Let me re-trace `a b OR c d`:

1. `parseExpression`: parse primary -> `a`
2. `parseBinaryOperator(lhs: a)`: next is `b` (not a binary op), default case -> `rhs = parseExpression()`
3.   `parseExpression`: parse primary -> `b`
4.   `parseBinaryOperator(lhs: b)`: next is `OR`, consume -> `rhs = parseExpression()`
5.     `parseExpression`: parse primary -> `c`
6.     `parseBinaryOperator(lhs: c)`: next is `d` (not binary op), default -> `rhs = parseExpression()`
7.       `parseExpression`: parse primary -> `d`
8.       `parseBinaryOperator(lhs: d)`: no more tokens -> return `d`
9.     return `AndNode(c, d)`
10.   return `OrNode(b, AndNode(c, d))`
11. return `AndNode(a, OrNode(b, AndNode(c, d)))`

So `a b OR c d` -> `AndNode(a, OrNode(b, AndNode(c, d)))`. The first implicit AND between `a` and `b` has higher precedence than OR because it binds tighter to the left. But actually it's just right-to-left: each operator binds to everything to its right.

This means the flat collect-and-fold-right approach works perfectly:

```
terms: [(a, implicit), (b, OR), (c, implicit), (d, end)]
Fold right:
  result = d
  result = AndNode(c, result)    // implicit -> AND
  result = OrNode(b, result)     // OR
  result = AndNode(a, result)    // implicit -> AND
= AndNode(a, OrNode(b, AndNode(c, d)))
```

This matches. The simple fold-right works because the current parser is fully right-associative with no precedence distinction.

### 2b. Iterative negation

**Current behavior:** `parseNegation` (line 50) consumes one `!`/`NOT`, then calls `parsePrimary` (line 59), which may detect another `!`/`NOT` and call `parseNegation` again. Chains of N negations create N stack frames.

**Required behavior:** Same tree output. `! ! a` -> `NotNode(NotNode(ContainsNode("a")))`.

**Approach:** In `parsePrimary`, when we see a unary operator, collect all consecutive unary operators in a `while` loop, then parse one primary, then wrap it in `NotNode` layers from inside out.

```swift
// In parsePrimary, instead of calling parseNegation:
var negations: [UnaryOperator] = []
while let op = tokenBuffer.peekToken() as? UnaryOperator {
    negations.append(op)
    tokenBuffer.consume()
}
if negations.isEmpty { /* handle other cases */ }
guard tokenBuffer.isNotAtEnd else {
    // trailing operator with no operand
    return foldTrailingNegations(negations)
}
var expr = try parsePrimary(tokenBuffer)  // parse the actual primary (non-negation)
for _ in negations {
    expr = NotNode(expr)
}
return expr
```

Wait, this changes `parsePrimary` to potentially call itself. Better: make `parsePrimary` handle the negation loop internally without recursing.

**Revised approach:** Split `parsePrimary` into two concerns:
1. Consume and count leading negation operators.
2. Parse the base primary (parens or contains node).
3. Wrap in NotNode layers.

This eliminates the `parseNegation` method entirely.

**Edge case -- trailing negation (`foo !`):**
- Current behavior: `parsePrimary` sees `!`, calls `parseNegation`, which consumes `!`, then `tokenBuffer.isNotAtEnd` is false, returns `ContainsNode("!")`.
- Iterative version: after collecting negations, if no more tokens remain, the last negation becomes `ContainsNode(token:)` and all preceding ones wrap it in `NotNode`.
  - Actually, current code: only the single `!` becomes `ContainsNode("!")`. If input were `! !`, the first calls `parseNegation`, which consumes `!`, then calls `parsePrimary`, which sees another `!`, calls `parseNegation`, which consumes `!`, then `isNotAtEnd` is false, returns `ContainsNode("!")`. Then first wraps: `NotNode(ContainsNode("!"))`.
  - So `! !` -> `NotNode(ContainsNode("!"))`. The last one becomes literal, all preceding ones negate.
  - Iterative version must replicate: collect all negation ops, if no primary follows, pop the last as `ContainsNode`, wrap the rest as `NotNode` layers.

### 2c. Bounded paren recursion

**Current behavior:** `parseOpeningParens` (line 95) calls `parseExpression` (line 110), which is now iterative (after 2a). The only remaining recursion is paren nesting: `((a))` -> `parseOpeningParens` -> iterative `parseExpression` -> `parsePrimary` -> `parseOpeningParens` -> ...

After changes 2a and 2b, the recursion depth equals paren nesting depth only. Deep paren nesting from real users is extremely unlikely (max ~5-10 levels), but for defense-in-depth:

**Approach:** Thread a `depth` parameter through `parseExpression` -> `parsePrimary` -> `parseOpeningParens` -> `parseExpression(depth: depth + 1)`. If `depth > 100`, treat the `(` as a literal `Word("(")` instead of a grouping operator. This matches the existing behavior for unbalanced parens.

### 2d. Merge `parseExpression` and `parseBinaryOperator`

After 2a makes the binary operator loop iterative, `parseBinaryOperator` is no longer a separate recursive function. It merges into `parseExpression` as the body of the while loop. The final `parseExpression` method is:

```swift
private func parseExpression(_ tokenBuffer: TokenBuffer, depth: Int = 0) throws -> Expression {
    // 1. Parse first primary (handles negation iteratively per 2b)
    // 2. While loop collecting (operator, primary) pairs
    // 3. Fold right into tree
    // 4. Handle ClosingParens
}
```

`parseBinaryOperator` and `parseNegation` are deleted as separate methods.

---

## Change 3: Iterative `isSatisfied`

**File:** `Expressions.swift`, lines 79-121

**Current behavior:** `NotNode.isSatisfied` calls `expression.isSatisfied`, `AndNode.isSatisfied` calls `lhs.isSatisfied` and `rhs.isSatisfied`, etc. Protocol dispatch prevents tail-call optimization.

**Required behavior:** Same boolean result, but O(1) call stack depth.

**Approach:** Add a private iterative evaluation function. Have each node's `isSatisfied` delegate to it.

The tricky part is short-circuit evaluation: `AndNode` should not evaluate `rhs` if `lhs` is false, and `OrNode` should not evaluate `rhs` if `lhs` is true. An explicit stack with a continuation-passing style handles this:

```swift
private enum EvalFrame {
    case evaluate(Expression)
    case applyAnd(Expression)   // "if top of value stack is true, evaluate this; else keep false"
    case applyOr(Expression)    // "if top of value stack is false, evaluate this; else keep true"
    case applyNot
}

func iterativeIsSatisfied(_ root: Expression, by satisfiable: ...) -> Bool {
    var stack: [EvalFrame] = [.evaluate(root)]
    var values: [Bool] = []

    while let frame = stack.popLast() {
        switch frame {
        case .evaluate(let expr):
            switch expr {
            case is AnythingNode:
                values.append(true)
            case let c as ContainsNode:
                values.append(satisfiable.contains(phrase: c.string))
            case let n as NotNode:
                stack.append(.applyNot)
                stack.append(.evaluate(n.expression))
            case let a as AndNode:
                stack.append(.applyAnd(a.rhs))
                stack.append(.evaluate(a.lhs))
            case let o as OrNode:
                stack.append(.applyOr(o.rhs))
                stack.append(.evaluate(o.lhs))
            default:
                values.append(false)
            }
        case .applyNot:
            values.append(!values.removeLast())
        case .applyAnd(let rhs):
            if values.last == false {
                // short-circuit: already false, skip rhs
            } else {
                values.removeLast()
                stack.append(.evaluate(rhs))
            }
        case .applyOr(let rhs):
            if values.last == true {
                // short-circuit: already true, skip rhs
            } else {
                values.removeLast()
                stack.append(.evaluate(rhs))
            }
        }
    }
    return values.last ?? true
}
```

**Two overloads needed:** One for `StringExpressionSatisfiable`, one for `CStringExpressionSatisfiable`. These can be generic over a closure, or duplicated (the body is small).

**Integration:** Each node's `isSatisfied(by:)` method calls the iterative function with `self` as root. Alternatively, the iterative function can be internal and called from the public `isSatisfied` methods. The protocol contract stays the same.

---

## Change 4: Iterative `phrases`

**File:** `PhraseCollectionConvertible.swift`, lines 21-37

**Current behavior:** `AndNode.phrases` and `OrNode.phrases` recursively access `lhs.phrases` and `rhs.phrases`.

**Required behavior:** Same `[String]` result, O(1) call stack.

**Approach:** Iterative tree walk collecting `ContainsNode.string` values, skipping `NotNode` subtrees:

```swift
private func iterativePhrases(_ root: Expression) -> [String] {
    var result: [String] = []
    var stack: [Expression] = [root]
    while let expr = stack.popLast() {
        switch expr {
        case let c as ContainsNode:
            result.append(c.string)
        case let a as AndNode:
            // Push rhs first so lhs is processed first (LIFO)
            stack.append(a.rhs)
            stack.append(a.lhs)
        case let o as OrNode:
            stack.append(o.rhs)
            stack.append(o.lhs)
        case is NotNode, is AnythingNode:
            break  // NotNode produces no phrases; AnythingNode is empty
        default:
            break
        }
    }
    return result
}
```

**Integration:** `AndNode.phrases` and `OrNode.phrases` delegate to this function with `self` as root. Or the protocol extensions call it directly.

---

## Change 5: Iterative `pushNegation`

**File:** `ContainmentEvaluator.swift`, lines 59-78

**Current behavior:** Recursive De Morgan's law application. `NOT(AND(a, b))` -> `OR(NOT(a), NOT(b))`. Depth-limited to `maxRecursion = 50`.

**Required behavior:** Same normalized tree, no depth limit, O(1) call stack.

**Approach:** Use an explicit work stack. Each work item is an expression that may need negation pushed down:

```swift
private func pushNegationIteratively(_ root: Evaluable) -> Evaluable {
    // Process bottom-up using a post-order traversal with an explicit stack.
    // Each node in the stack is tagged with whether it's under a NOT.
    ...
}
```

This is the most complex iterative transformation because `pushNegation` both traverses and rebuilds the tree. A two-pass approach may be simpler:

1. Walk the tree iteratively, collecting nodes in post-order.
2. Rebuild bottom-up, applying De Morgan when a NOT wraps an AND/OR.

**`maxRecursion` parameter:** Once `pushNegation` is iterative, the `maxRecursion` parameter and `RecursionTooDeepError` are no longer needed. However, removing them is a **public API change** (`ContainmentEvaluator.init(evaluable:maxRecursion:)` and `RecursionTooDeepError` are both public). Two options:
- **Soft deprecation:** Keep the parameter but ignore it. Mark it `@available(*, deprecated)`.
- **Remove it:** Breaking change. Acceptable if this is a major version bump.

Recommendation: soft-deprecate for now.

---

## Execution Order and Verification

Each change is a standalone commit. After each commit, run:

```bash
swift test                          # all 117 original tests
swift test --filter StackOverflow   # stress tests
```

| Step | Change | Crash vectors fixed | Commit message |
|------|--------|-------------------|----------------|
| 1 | Iterative `balanceParentheses` | nested parens during balancing | `make balanceParentheses iterative` |
| 2 | Iterative `parseExpression` (2a + 2d) | implicit AND, explicit AND, explicit OR | `make expression parsing iterative` |
| 3 | Iterative negation (2b) | chained bangs/NOT | `make negation parsing iterative` |
| 4 | Bounded paren depth (2c) | pathological nested parens | `add depth limit to paren parsing` |
| 5 | Iterative `isSatisfied` (Change 3) | eval of deep trees | `make isSatisfied evaluation iterative` |
| 6 | Iterative `phrases` (Change 4) | phrase extraction on deep trees | `make phrases extraction iterative` |
| 7 | Iterative `pushNegation` (Change 5) | normalization of deep trees | `make pushNegation iterative` |

## Success Criteria

- All `StackOverflowTests` pass at 10,000 tokens across all vectors.
- All 117 existing tests pass unchanged.
- No public API additions or removals (soft-deprecation only).
- Parsing + evaluating 1,000 tokens completes in <5ms (validated by benchmark -- see Appendix A).

---

## Appendix A: Adversarial Review Resolutions

Three independent adversarial reviewers (correctness, API/scope, performance) reviewed this PRD. Below are all issues raised and their resolutions.

### A.1 Fold-right loop structure needs explicit pseudocode

**Issue (correctness, API):** The collect-and-fold loop jumps from prose to fold without showing the exact while loop. The operator association is ambiguous.

**Resolution:** The correct loop structure is:

```swift
private func parseExpression(_ tokenBuffer: TokenBuffer, depth: Int = 0) throws -> Expression {
    // Step 1: parse first operand (with iterative negation, see 2b)
    let first = try parsePrimaryIterative(tokenBuffer, depth: depth)

    // Step 2: collect remaining (followingOp, expression) pairs
    struct Term {
        let expr: Expression
        let followingOp: BinaryOperator?  // operator AFTER this term
    }
    var terms: [Term] = []
    var currentExpr = first

    while tokenBuffer.isNotAtEnd && !(tokenBuffer.peekToken() is ClosingParens) {
        // Check for explicit operator
        var op: BinaryOperator? = nil
        if let binOp = tokenBuffer.peekToken() as? BinaryOperator {
            op = binOp
            tokenBuffer.consume()

            // Trailing operator with no RHS: treat operator as literal word
            guard tokenBuffer.isNotAtEnd else {
                terms.append(Term(expr: currentExpr, followingOp: nil))
                terms.append(Term(expr: ContainsNode(token: binOp), followingOp: nil))
                return foldRight(terms)
            }
        }
        // Record current term with its following operator
        terms.append(Term(expr: currentExpr, followingOp: op))
        // Parse next operand
        currentExpr = try parsePrimaryIterative(tokenBuffer, depth: depth)
    }
    // Record final term (no following operator)
    terms.append(Term(expr: currentExpr, followingOp: nil))

    // Step 3: consume closing paren if present
    if tokenBuffer.peekToken() is ClosingParens {
        tokenBuffer.consume()
    }

    // Step 4: fold right to build tree
    return foldRight(terms)
}

private func foldRight(_ terms: [Term]) -> Expression {
    guard !terms.isEmpty else { return AnythingNode() }
    var result = terms.last!.expr
    for i in stride(from: terms.count - 2, through: 0, by: -1) {
        // Use the operator FOLLOWING term[i] to decide node type
        switch terms[i].followingOp {
        case .or:
            result = OrNode(terms[i].expr, result)
        case .and, nil:
            // explicit AND and implicit AND (nil) both produce AndNode
            result = AndNode(terms[i].expr, result)
        }
    }
    return result
}
```

**Trailing operator semantics preserved:** For `a OR` (trailing OR with no RHS):
- terms = `[(expr: a, followingOp: nil), (expr: ContainsNode("OR"), followingOp: nil)]`
- fold: `result = ContainsNode("OR")`, then `result = AndNode(a, result)` (nil -> AND)
- Produces `AndNode(a, ContainsNode("OR"))` -- matches current behavior.

### A.2 Iterative negation: `! ( a OR b )` must negate the parenthesized group

**Issue (correctness):** The PRD proposes collecting consecutive `!`/`NOT` tokens then parsing one primary. But what if the primary is a parenthesized group? The collected negations must wrap the entire group.

**Resolution:** This works correctly as written. After collecting negations, `parsePrimaryIterative` is called to get the base expression. If the next token is `(`, it calls `parseOpeningParens`, which parses the full parenthesized group as a single expression. The negation wrapping then applies to that entire group:

```swift
private func parsePrimaryIterative(_ tokenBuffer: TokenBuffer, depth: Int) throws -> Expression {
    // Collect consecutive negations
    var negationOps: [UnaryOperator] = []
    while let op = tokenBuffer.peekToken() as? UnaryOperator {
        negationOps.append(op)
        tokenBuffer.consume()
    }

    // Parse base expression
    let base: Expression
    if negationOps.isEmpty {
        // No negations: parse parens, contains, or end-of-input
        switch tokenBuffer.peekToken() {
        case .none:
            return AnythingNode()
        case .some(is OpeningParens):
            base = try parseOpeningParens(tokenBuffer, depth: depth)
        case .some(_):
            base = try parseContainsNode(tokenBuffer)
        }
    } else if !tokenBuffer.isNotAtEnd {
        // Trailing negation(s) with no operand:
        // Last negation becomes literal, rest wrap as NotNode
        let literal = ContainsNode(token: negationOps.removeLast())
        var expr: Expression = literal
        for _ in negationOps { expr = NotNode(expr) }
        return expr
    } else {
        // Parse base (parens or contains)
        switch tokenBuffer.peekToken() {
        case .some(is OpeningParens):
            base = try parseOpeningParens(tokenBuffer, depth: depth)
        default:
            base = try parseContainsNode(tokenBuffer)
        }
    }

    // Wrap in NotNode layers (innermost first)
    var result = base
    for _ in negationOps { result = NotNode(result) }
    return result
}
```

For `! ( a OR b )`:
1. Collect negations: `[!]`
2. Parse base: sees `(`, calls `parseOpeningParens` -> `OrNode(a, b)`
3. Wrap: `NotNode(OrNode(a, b))`

Correct.

### A.3 `RecursionTooDeepError` and `maxRecursion` deprecation strategy

**Issue (API, BLOCKING):** Once `pushNegation` is iterative, `RecursionTooDeepError` is never thrown and `maxRecursion` is ignored. The PRD must be explicit about the deprecation strategy.

**Resolution:** Soft-deprecate both. The exact annotations:

```swift
public struct ContainmentEvaluator {

    public typealias Evaluable = Expression & PhraseCollectionConvertible

    @available(*, deprecated, message: "This error is no longer thrown. pushNegation is now iterative with no depth limit.")
    public struct RecursionTooDeepError: Error {
        public init() {}
    }

    public let evaluable: Evaluable

    @available(*, deprecated, message: "maxRecursion is no longer used. The algorithm is iterative.")
    public let maxRecursion: Int

    public init(evaluable: Evaluable) {
        self.evaluable = evaluable
        self.maxRecursion = 50
    }

    @available(*, deprecated, message: "maxRecursion is no longer used. The algorithm is iterative.")
    public init(evaluable: Evaluable, maxRecursion: Int) {
        self.evaluable = evaluable
        self.maxRecursion = maxRecursion
    }
```

The existing `init(evaluable:maxRecursion:)` with default value splits into two: the preferred `init(evaluable:)` (non-deprecated) and the deprecated `init(evaluable:maxRecursion:)` (explicit parameter). This gives callers a clear migration path without breaking existing code.

`normalizedEvaluable()` remains `throws` for source compatibility -- callers may have `try` at call sites. It just never actually throws. The `phrases()` method keeps its do/catch as defensive code; it is harmless and avoids a signature change.

### A.4 Paren depth limit (depth=100) behavior change

**Issue (API, IMPORTANT):** The depth=100 limit silently changes parsing of deeply nested parens from "crash" to "literal word." Should it throw instead?

**Resolution:** Throwing is better. Add a new case to the internal `ParseError` enum:

```swift
internal enum ParseError: Error {
    case expectedTokenAtExpressionStart
    case expectedUnaryOperatorInNegation
    case expectedTermAfterNegation
    case expectedOpeningParens
    case parenNestingTooDeep  // NEW
}
```

`ParseError` is `internal`, so adding a case is non-breaking. When depth > 100, `parseOpeningParens` throws `.parenNestingTooDeep`. This propagates up through `Parser.parse(searchString:)` which already `throws`.

Callers already handle thrown errors (the docstring says "Consider these to be framework errors"). This is safer than silently producing a different tree.

Why 100: no user types 100 nested parens. Even complex boolean queries in legal/academic search rarely exceed 5-10 levels. 100 is generous defense-in-depth. The limit is internal and can be adjusted without API changes.

### A.5 Iterative `phrases` output order

**Issue (performance, BLOCKING test risk):** The iterative phrases walker uses a LIFO stack. If children are pushed in the wrong order, phrase output order changes. Existing tests check exact order (`["foo", "bar"]` not `["bar", "foo"]`).

**Resolution:** The pseudocode already handles this correctly: push `rhs` first, then `lhs`, so `lhs` is popped first (LIFO). This produces left-to-right order matching the recursive version. To be safe, add explicit ordering tests:

```swift
// Add to StackOverflowTests or a new test file:
func testPhrasesOrder_NestedAnd() {
    let tree = AndNode(AndNode(ContainsNode("a"), ContainsNode("b")), ContainsNode("c"))
    XCTAssertEqual((tree as ContainmentEvaluator.Evaluable).phrases, ["a", "b", "c"])
}

func testPhrasesOrder_NestedOr() {
    let tree = OrNode(ContainsNode("x"), OrNode(ContainsNode("y"), ContainsNode("z")))
    XCTAssertEqual((tree as ContainmentEvaluator.Evaluable).phrases, ["x", "y", "z"])
}
```

### A.6 Iterative `pushNegation` needs concrete pseudocode

**Issue (correctness, IMPORTANT):** The PRD only sketches the approach for iterative `pushNegation`. Implementers need concrete pseudocode.

**Resolution:** The algorithm processes the tree top-down, tracking whether each node is under a negation:

```swift
private func pushNegationIteratively(_ root: Evaluable) -> Evaluable {
    // Work item: (expression, isNegated)
    // Result stack: completed sub-expressions
    var work: [(Evaluable, Bool)] = [(root, false)]
    var results: [Evaluable] = []
    // Instructions for reconstruction
    enum Instruction {
        case leaf(Evaluable)
        case buildAnd   // pop 2 results, build AndNode
        case buildOr    // pop 2 results, build OrNode
        case buildNot   // pop 1 result, build NotNode
    }
    var instructions: [Instruction] = []

    // Phase 1: decompose into instructions (top-down)
    while let (expr, negated) = work.popLast() {
        if let notNode = expr as? NotNode {
            // NOT flips the negation flag
            if let inner = notNode.expression as? Evaluable {
                work.append((inner, !negated))
            } else {
                // Inner expression doesn't conform to Evaluable; keep as-is
                instructions.append(.leaf(negated ? notNode : notNode))
            }
        } else if let andNode = expr as? AndNode, negated {
            // De Morgan: NOT(AND(a, b)) -> OR(NOT(a), NOT(b))
            instructions.append(.buildOr)
            // Push rhs first so lhs is processed first
            if let rhs = andNode.rhs as? Evaluable { work.append((rhs, true)) }
            if let lhs = andNode.lhs as? Evaluable { work.append((lhs, true)) }
        } else if let orNode = expr as? OrNode, negated {
            // De Morgan: NOT(OR(a, b)) -> AND(NOT(a), NOT(b))
            instructions.append(.buildAnd)
            if let rhs = orNode.rhs as? Evaluable { work.append((rhs, true)) }
            if let lhs = orNode.lhs as? Evaluable { work.append((lhs, true)) }
        } else if negated {
            // Leaf under negation: wrap in NOT
            instructions.append(.leaf(NotNode(expr)))
        } else {
            // Not negated, not a compound: keep as-is
            instructions.append(.leaf(expr))
        }
    }

    // Phase 2: reconstruct (bottom-up through instructions)
    for instruction in instructions.reversed() {
        switch instruction {
        case .leaf(let e):
            results.append(e)
        case .buildAnd:
            let lhs = results.removeLast()
            let rhs = results.removeLast()
            results.append(AndNode(lhs, rhs))
        case .buildOr:
            let lhs = results.removeLast()
            let rhs = results.removeLast()
            results.append(OrNode(lhs, rhs))
        case .buildNot:
            let inner = results.removeLast()
            results.append(NotNode(inner))
        }
    }

    return results.last ?? root
}
```

This is O(N) time and O(N) heap space where N is the number of nodes. No call stack usage beyond O(1).

### A.7 Performance validation: benchmark requirement

**Issue (performance, BLOCKING):** The <5ms claim is unverified. The iterative approach adds temporary array allocations (fold-right terms array, eval stack, values array) that don't exist in the recursive version.

**Resolution:** Add a benchmark test to validate. Run after each change:

```swift
func testPerformance_Parse1000Tokens() {
    let input = (0..<1000).map { String(UnicodeScalar(97 + ($0 % 26))!) }.joined(separator: " ")
    measure {
        _ = try! Parser.parse(searchString: input)
    }
}

func testPerformance_ParseAndEval1000Tokens() {
    let input = (0..<1000).map { String(UnicodeScalar(97 + ($0 % 26))!) }.joined(separator: " ")
    let expr = try! Parser.parse(searchString: input)
    measure {
        _ = expr.isSatisfied(by: "hello world")
    }
}
```

The temporary array for 1000 terms is ~8KB (1000 x pointer+optional). This is negligible. For typical live typing (10-50 tokens), the array is <500 bytes.

The existing stress tests already show 5000 tokens parse in ~26ms, so 1000 tokens should be well under 5ms. Benchmark tests will confirm.

**Regarding iterative vs recursive overhead for small trees (5-50 nodes):** The enum-based stack machine has marginally higher constant overhead than recursive dispatch (heap allocation vs stack frames). For trees this small, both approaches complete in microseconds. The difference is unmeasurable. A hybrid approach (recursive for small, iterative for large) adds complexity for no practical gain. Recommendation: iterative for all sizes, validate with benchmarks.

### A.8 Thread safety

**Issue (API, IMPORTANT):** The PRD mentions live typing on background threads but doesn't document thread safety.

**Resolution:** The library is thread-safe by design:
- `Parser` is a `struct` with value semantics. Each call creates its own `TokenBuffer` (a class, but never shared across threads).
- All expression nodes are `struct`s with `let` properties (immutable).
- `ContainmentEvaluator` is a `struct` with `let` properties.
- The iterative versions use only local variables (stack arrays, result arrays).

No changes needed. Add to the PRD's Non-Goals: "Thread safety changes (already safe by design: value types, no shared mutable state)."

### A.9 `phrases` type-matching vs protocol cast

**Issue (correctness, IMPORTANT):** The iterative `phrases` uses `as AndNode` pattern matching instead of `as? PhraseCollectionConvertible`. If a future Expression type conforms to `PhraseCollectionConvertible`, the iterative version silently ignores it.

**Resolution:** Acceptable trade-off. The `PhraseCollectionConvertible` doc says "Works in negation normal form only," and normalization only produces the five known types. The iterative version covers all five. A `default` case with `(expr as? PhraseCollectionConvertible)?.phrases` fallback would re-introduce recursion for unknown types, defeating the purpose.

If new Expression types are added in the future, they must be added to the iterative walker. This is a maintenance cost, but a small one — adding a new Expression type already requires changes throughout the codebase.

### A.10 Change 5 (iterative pushNegation) could be deferred

**Issue (scope, MINOR):** `pushNegation` already has a depth limit of 50. It won't crash on realistic inputs. Could defer to a follow-up.

**Resolution:** Agreed that it's lower priority, but include it because:
1. The existing `maxRecursion = 50` is too low for legitimate complex expressions.
2. It's the only remaining recursive code path after Changes 1-4.
3. The implementation is straightforward with the pseudocode in A.6.

Keep it as Step 7 (last), so it can be dropped from the PR if time is short without compromising the other fixes.
