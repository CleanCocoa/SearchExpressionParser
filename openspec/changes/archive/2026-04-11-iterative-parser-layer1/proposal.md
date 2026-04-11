## Why

The recursive descent parser crashes with SIGSEGV (stack overflow) on long search inputs. Each token adds a stack frame during parsing via mutual recursion between `parseExpression` and `parseBinaryOperator`. On a background thread with a 512KB stack (common on iOS), this crashes with as few as 200-300 tokens — reachable by pasting a paragraph into a search field. `balanceParentheses` and `parseNegation` have the same unbounded recursion problem.

## What Changes

- `balanceParentheses` rewired from recursive to iterative using an explicit stack of `(` positions. Same output, O(1) call stack.
- `parseExpression`/`parseBinaryOperator` merged into a single iterative method that collects operands and operators in a while loop, then folds right to build the identical right-leaning tree.
- `parseNegation` eliminated. Consecutive `!`/`NOT` tokens collected iteratively in `parsePrimary`, then wrapped as `NotNode` layers.
- Paren nesting depth bounded (defense-in-depth). `parseOpeningParens` receives a `depth` parameter; exceeding the limit throws `ParseError.parenNestingTooDeep`.

## Capabilities

### New Capabilities

- `iterative-parsing`: The parser builds expression trees iteratively with O(1) call stack depth, handling arbitrarily long token sequences without stack overflow. Covers: iterative binary operator collection and right-fold, iterative negation collection, iterative parenthesis balancing, and bounded paren nesting depth.

### Modified Capabilities

- `parentheses-balancing`: Implementation changes from recursive to iterative. All existing requirements preserved. Adds requirement that the algorithm uses O(1) call stack depth.
- `parsing-grammar`: Implementation changes from recursive to iterative. All existing requirements preserved. Adds requirement that parsing uses O(1) call stack depth for binary operators and negation, and bounded depth for parenthesized groups.

## Impact

- **Code**: `Sources/.../Parsing/Parser.swift` — rewrite of `balanceParentheses`, `parseExpression`, `parseBinaryOperator`, `parseNegation`, `parseOpeningParens`. `parseBinaryOperator` and `parseNegation` deleted as separate methods.
- **Internal API**: `ParseError` gains a new case `.parenNestingTooDeep`. This enum is `internal`, so non-breaking.
- **Public API**: No changes. `Parser.parse(searchString:)`, `Parser.init(tokens:)`, `Parser.expression()` signatures unchanged. Tree output identical for all inputs within the paren depth limit.
- **Tests**: All 117 existing tests must pass unchanged. `StackOverflowTests` (parsing vectors) must pass at 10,000 tokens.
