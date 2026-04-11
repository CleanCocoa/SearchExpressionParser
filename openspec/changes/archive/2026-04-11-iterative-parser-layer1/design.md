## Context

The parser in `Parser.swift` uses textbook recursive descent. Each token adds a stack frame via mutual recursion between `parseExpression` and `parseBinaryOperator`. The tree output is right-leaning: `a b c` becomes `AndNode(a, AndNode(b, c))` with depth N-1. On iOS background threads (512KB stack), this crashes at ~200-300 tokens. Users can reach this by pasting text into a search field.

The tokenizer is already iterative. Only `Parser.swift` needs changes for Layer 1. The expression tree shape and all public API signatures remain identical.

## Goals / Non-Goals

**Goals:**
- O(1) call stack depth for binary operators, negation, and parenthesis balancing
- Bounded call stack depth for parenthesized grouping (paren nesting depth only)
- Identical tree output for all inputs (verified by 117 existing tests)
- All StackOverflow stress tests pass at 10,000 tokens

**Non-Goals:**
- Changing tree shape (right-leaning stays right-leaning)
- Changing public API surface
- Iterative tree evaluation (`isSatisfied`, `phrases`) — that's Layer 2
- Iterative normalization (`pushNegation`) — that's Layer 3
- Performance optimization beyond preventing crashes

## Decisions

### D1: Collect-and-fold-right for binary operators

**Choice:** Replace the `parseExpression` <-> `parseBinaryOperator` mutual recursion with a while loop that collects `(expression, followingOperator)` pairs, then folds right to build the tree.

**Why:** The current grammar is fully right-associative with no precedence distinction between AND and OR. A simple fold-right over a flat list reproduces the identical tree. The operator AFTER a term determines the node type (OR -> OrNode, AND/nil -> AndNode).

**Alternative considered:** Pratt parser with precedence climbing. Rejected — adds complexity for no benefit since AND and OR share the same precedence.

**Alternative considered:** Iterative left-to-right tree building. Rejected — would produce left-leaning trees, breaking all existing test expectations.

### D2: Iterative negation via collection in parsePrimary

**Choice:** Eliminate `parseNegation` as a separate method. When `parsePrimary` sees unary operators, collect all consecutive `!`/`NOT` tokens in a loop, parse the base primary, then wrap in `NotNode` layers.

**Why:** The current `parseNegation` -> `parsePrimary` -> `parseNegation` chain recurses once per negation token. Collecting them flat and wrapping after eliminates all recursion.

**Edge case — trailing negation (`! !`):** Pop the last operator as `ContainsNode(token:)`, wrap the rest as `NotNode` layers. Matches current behavior exactly.

**Edge case — `! ( a OR b )`:** After collecting the `!`, `parsePrimary` dispatches to `parseOpeningParens` which parses the full parenthesized group. The `NotNode` wrapping then covers the entire group. Correct by construction.

### D3: Iterative balanceParentheses with index stack

**Choice:** Replace the recursive `balanceParentheses(tokens:start:)` with a single linear pass using a stack of integer indices.

**Why:** The recursive version recurses once per `OpeningParens`. The iterative version walks left-to-right, pushing `(` indices onto a stack, popping on `)`. Unmatched tokens are replaced with `Word` at the end. Same output, O(N) time, O(1) call stack.

**Alternative considered:** Two-pass approach (first pass to find unmatched, second to replace). Rejected — single pass with stack is simpler and sufficient.

### D4: Paren nesting depth limit via thrown error

**Choice:** Thread a `depth` parameter through `parseExpression` -> `parsePrimary` -> `parseOpeningParens`. When depth exceeds 100, throw `ParseError.parenNestingTooDeep`.

**Why:** After D1 and D2, the only remaining recursion is paren nesting (`parseOpeningParens` -> `parseExpression`). Real users never type 100 nested parens. Throwing is better than silently converting to `Word("(")` because it's explicit — callers already handle `throws` from `Parser.parse()`.

**Alternative considered:** Convert deep `(` to literal `Word`. Rejected by adversarial review — silently changes tree semantics.

**Alternative considered:** No limit at all. Rejected — defense-in-depth matters. 100 nested parens is generous.

### D5: Merge parseBinaryOperator into parseExpression

**Choice:** After D1 eliminates the mutual recursion, `parseBinaryOperator` no longer exists as a separate method. Its logic becomes the while-loop body inside `parseExpression`. The `parseNegation` method is also eliminated (absorbed into `parsePrimary`).

**Why:** Reduces method count, makes the iterative flow explicit. Three methods (`parseBinaryOperator`, `parseNegation`, and the recursive `balanceParentheses(tokens:start:)`) are deleted. The private `Balance` enum is also deleted.

## Risks / Trade-offs

**[Behavioral equivalence risk]** The fold-right algorithm must produce identical trees for all inputs. → Mitigation: 117 existing tests cover all grammar constructs. The PRD traces through every test case.

**[Temporary array allocation]** The collect step allocates an array of N terms before folding. → Mitigation: For typical live-typing (10-50 tokens), this is <500 bytes. For 10,000 tokens (paste), ~80KB. Acceptable trade-off vs stack overflow.

**[Paren depth limit is a behavior change]** Inputs with >100 nested parens now throw instead of parsing (or crashing). → Mitigation: No real user types 100 nested parens. The limit is internal and adjustable. `ParseError` is `internal`.

**[parseOpeningParens still recurses]** Paren nesting still uses the call stack, bounded by actual `(` depth. → Mitigation: Depth limit of 100. After D1/D2, only paren nesting adds stack frames. 100 frames is ~50KB of stack, safe on any thread.
