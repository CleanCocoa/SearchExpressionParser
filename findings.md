# Stack Overflow Findings

## Summary

The recursive descent parser builds right-leaning expression trees with depth O(N) for N tokens. Every subsequent operation (parsing, evaluation, phrase extraction) recurses through that tree with no depth limit, causing stack overflow on sufficiently long inputs.

## Crash Thresholds (CLI test runner, ~8MB stack)

| Vector | 5,000 | 10,000 | Crash site |
|--------|-------|--------|------------|
| Implicit AND (`a b c d ...`) | pass | CRASH | `parseBinaryOperator` -> `parseExpression` |
| Explicit AND (`a AND b AND ...`) | pass | CRASH | `parseBinaryOperator` -> `parseExpression` |
| Explicit OR (`a OR b OR ...`) | pass | CRASH | `parseBinaryOperator` -> `parseExpression` |
| Chained bangs (`! ! ! ... a`) | pass | CRASH | `parseNegation` -> `parsePrimary` |
| Nested parens (`(((a)))`) | pass | CRASH | `balanceParentheses` + `parseOpeningParens` |
| Nested parens+AND (`(a AND (b AND ...))`) | CRASH | CRASH | compounds paren + operator recursion |
| Eval deep tree (`isSatisfied`) | pass | CRASH | recursive `isSatisfied(by:)` on deep tree |
| Phrases deep tree | pass | CRASH | recursive `phrases` property on deep tree |

On iOS non-main threads (512KB-1MB stack), expect crashes at a few hundred tokens.

## Vulnerable Call Chains

### 1. Parser: binary operators (Parser.swift:73-93)

`parseExpression` -> `parseBinaryOperator` -> `parseExpression` (lines 80, 86, 90). Each token in a sequence like `a b c d` adds one stack frame via the default case (implicit AND, line 90). Explicit `AND`/`OR` operators follow the same pattern.

### 2. Parser: parentheses (Parser.swift:95-111, 139-166)

`balanceParentheses` recurses at line 147 for each opening paren. Then `parseOpeningParens` -> `parseExpression` recurses at line 110. Input `(((a)))` with N levels hits both.

### 3. Parser: negation (Parser.swift:50-61)

`parseNegation` -> `parsePrimary` -> `parseNegation` chain (line 59). Input `! ! ! ... a` with N bangs creates N stack frames.

### 4. Evaluation: isSatisfied (Expressions.swift:79-121)

`NotNode.isSatisfied` (line 80), `AndNode.isSatisfied` (line 98), `OrNode.isSatisfied` (line 116) all recurse through the full tree depth with no limit.

### 5. Phrase extraction (PhraseCollectionConvertible.swift:21-37)

`AndNode.phrases` and `OrNode.phrases` recurse through both `lhs` and `rhs` with no depth limit.

### 6. Normalization (ContainmentEvaluator.swift:59-78)

`pushNegation` has a depth limit (`maxRecursion = 50`) but this only protects the normalization step, not the tree walking that follows it.

## Root Cause

The parser is a textbook recursive descent parser with right-associative binary operators. `a b c d` produces `AndNode(a, AndNode(b, AndNode(c, d)))` -- a linked list with depth N-1. All tree operations then recurse through this full depth. Swift does not optimize mutual/protocol-dispatch recursion into tail calls.

## Reproducing

```
swift test --filter StackOverflow
```

The `StackOverflowTests.swift` file exercises each vector at sizes 100 through 10,000. Tests at 10,000 (and 5,000 for combined parens+AND) crash with signal 11 (SIGSEGV).

---

# Battle Plan: Stack Overflow Inoculation

## Threat Model for Live Typing

In a live-typing search field, the parser runs on every keystroke. The realistic threat is not `(((((a)))))` 500 levels deep -- no one types that. The real threat is:

1. **Many words** -- a user pastes or types a long phrase like `meeting notes from the project review with the team about the budget for next quarter ...`. Each space-separated word is a token; 50+ words is common in paste scenarios. On a background thread with a 512KB stack, this could overflow at ~200-300 tokens.
2. **Moderate nesting with operators** -- power users writing `(a OR b) AND (c OR d) AND ...` with 20-30 groups. Combined with implicit AND, this compounds recursion.
3. **Copy-pasted text** -- users paste paragraphs into search fields. A 500-word paragraph is 500 tokens and a tree of depth 499.

Chained bangs (`! ! ! ! a`) and deep paren nesting (`(((a)))`) are not realistic user inputs but should still be hardened against.

## Strategy: Iterative Everything

The fix has three layers, ordered by priority. Each layer is independently shippable.

### Layer 1: Iterative Parser (eliminates overflow during parsing)

**Files:** `Parser.swift`

**1a. Iterative `parseBinaryOperator`** -- the #1 threat.

Current: right-recursive, each token adds a stack frame.
```
parseExpression -> parseBinaryOperator -> parseExpression -> parseBinaryOperator -> ...
```

Fix: collect operands and operators in a while loop, then fold into a tree. This produces the identical right-leaning tree shape (preserving all existing test expectations) but uses O(1) stack depth.

```swift
// Pseudocode
private func parseExpression(_ tokenBuffer: TokenBuffer) throws -> Expression {
    var node = try parsePrimary(tokenBuffer)
    while tokenBuffer.isNotAtEnd {
        if tokenBuffer.peekToken() is ClosingParens {
            tokenBuffer.consume()
            return node
        }
        node = try parseBinaryOperatorIterative(tokenBuffer, lhs: node)
    }
    return node
}

private func parseBinaryOperatorIterative(_ tokenBuffer: TokenBuffer, lhs: Expression) throws -> Expression {
    // Collect all terms and operators at this precedence level
    var terms: [(op: Token?, expr: Expression)] = [(nil, lhs)]
    while tokenBuffer.isNotAtEnd, !(tokenBuffer.peekToken() is ClosingParens) {
        let op = tokenBuffer.peekToken()
        if op is BinaryOperator { tokenBuffer.consume() }
        // handle trailing operator with no RHS
        guard tokenBuffer.isNotAtEnd else {
            terms.append((op, ContainsNode(token: op!)))
            break
        }
        let rhs = try parsePrimary(tokenBuffer)
        terms.append((op, rhs))
    }
    // Fold right to produce identical tree shape
    return foldRight(terms)
}
```

The key insight: `parsePrimary` never recurses into `parseExpression` except through `parseOpeningParens`, which is bounded by paren depth (handled in 1c). So once `parseBinaryOperator` is iterative, the main recursion chain is broken.

**1b. Iterative `balanceParentheses`** -- use an explicit stack instead of recursive calls.

Current: recurses at line 147 for each opening paren.

Fix: maintain a stack of paren positions. Walk tokens linearly, push on `(`, pop on `)`. Replace unmatched parens with Word tokens. O(N) time, O(depth) space on the explicit stack, O(1) call stack.

**1c. Bounded paren recursion** -- `parseOpeningParens` still recurses into `parseExpression`, but after 1a, `parseExpression` no longer recurses for binary operators. The only remaining recursion is paren nesting, which is bounded by actual `(` depth in the input. For defense-in-depth, add a `depth` parameter and bail at a reasonable limit (e.g., 100). No user will type 100 nested parens.

**1d. Iterative negation** -- `parseNegation` -> `parsePrimary` -> `parseNegation` chain. Collect consecutive `!`/`NOT` tokens in a loop, parse one primary, then wrap in the appropriate number of `NotNode` layers. O(1) stack depth.

### Layer 2: Iterative Tree Walking (eliminates overflow during evaluation)

**Files:** `Expressions.swift`, `PhraseCollectionConvertible.swift`

Even with an iterative parser, the tree is still right-leaning with depth O(N). Walking it recursively via `isSatisfied` or `phrases` will overflow.

Two options, in order of preference:

**Option A: Iterative evaluation with explicit stack.** Add free functions or static methods that walk the expression tree iteratively:

```swift
func evaluate(_ expression: Expression, with satisfiable: StringExpressionSatisfiable) -> Bool {
    var stack: [(Expression, Bool)] = [(expression, false)]
    // iterative DFS with short-circuit support
    ...
}
```

This replaces recursive `isSatisfied` dispatch. The Expression protocol methods can delegate to the iterative walker. Tree shape doesn't change; only traversal does.

**Option B: Flatten the tree shape.** Change `AndNode`/`OrNode` to hold `[Expression]` arrays instead of binary `lhs`/`rhs`. A flat `AndNode([a, b, c, d])` has depth 1 regardless of term count. This is the cleanest long-term fix but changes the public API and requires updating all tests.

Recommendation: **Option A first** (non-breaking), Option B later if desired.

### Layer 3: Normalization (defense-in-depth)

**Files:** `ContainmentEvaluator.swift`

`pushNegation` already has a depth limit (default 50), but:
- The limit is too low for legitimate complex expressions
- `phrases` has no limit at all after normalization

Fix: make `pushNegation` iterative (same explicit-stack pattern). Remove the `maxRecursion` parameter -- it becomes unnecessary. The `phrases` property gets the same iterative treatment as part of Layer 2.

## Live Typing Performance Considerations

- **Iterative is faster than recursive** for the same work -- no function call overhead per token, better cache locality from stack locality.
- **Tokenization is already iterative** and proportional to input length. No changes needed.
- **Parsing with Layer 1** becomes O(N) time with O(1) call stack. Each keystroke re-parses the full string, but tokenization + iterative parsing of even 1000 tokens takes <1ms (measured in tests: 5000 tokens parsed in ~26ms, so 100 tokens in <1ms).
- **Evaluation with Layer 2** becomes O(N) time with O(1) call stack. The iterative walker avoids protocol dispatch overhead per node.
- **No incremental parsing needed** at these input sizes. Full re-parse on each keystroke is fast enough. Incremental parsing would add complexity for negligible gain.

## Execution Order

1. **Layer 1a** -- iterative `parseBinaryOperator`. Fixes the most likely crash vector (many words). All existing parser tests must still pass with identical tree output.
2. **Layer 1b** -- iterative `balanceParentheses`. Small isolated change.
3. **Layer 1d** -- iterative negation collection. Small isolated change.
4. **Layer 1c** -- depth limit on paren recursion. Safety net.
5. **Layer 2** -- iterative `isSatisfied` and `phrases`. Fixes evaluation overflow.
6. **Layer 3** -- iterative `pushNegation`. Removes the `maxRecursion` workaround.

After each layer, run `swift test` (all 117 original tests) plus the StackOverflow stress tests. The stress tests that previously crashed should pass.

## Success Criteria

- All StackOverflow stress tests pass at 10,000 tokens (all vectors).
- All 117 existing tests pass unchanged (identical tree shapes).
- No new public API surface (Option A approach).
- Parsing 1000 tokens completes in <5ms (live typing budget).
