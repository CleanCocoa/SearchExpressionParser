## Why

Layer 1 made parsing iterative, but the three post-parse operations — `isSatisfied(by:)`, `phrases()`, and `pushNegation()` — still recurse through the full expression tree depth. On a 512KB background thread stack, a 10,000-token input produces a tree ~10,000 nodes deep, which crashes these operations. This is the remaining half of the stack overflow elimination from the PRD (Changes 3–5).

## What Changes

- Replace recursive `isSatisfied(by:)` evaluation in expression nodes with an iterative stack machine that preserves short-circuit semantics for both `StringExpressionSatisfiable` and `CStringExpressionSatisfiable` paths
- Replace recursive `phrases` property in `AndNode`/`OrNode` with an iterative tree walker that preserves left-to-right output order
- Replace recursive `pushNegation` in `ContainmentEvaluator` with an iterative two-phase decompose/reconstruct algorithm, removing the `maxRecursion` depth limit
- **Soft-deprecate** `ContainmentEvaluator.init(evaluable:maxRecursion:)` and `RecursionTooDeepError` (kept for source compatibility, but no longer functionally used)

## Capabilities

### New Capabilities

- `iterative-evaluation`: Iterative stack-machine implementation of `isSatisfied(by:)` for O(1) call stack depth
- `iterative-phrases`: Iterative tree walker for phrase extraction at O(1) call stack depth
- `iterative-push-negation`: Iterative De Morgan's law application for negation normal form at O(1) call stack depth, replacing the depth-limited recursive version

### Modified Capabilities

- `expression-evaluation`: `isSatisfied(by:)` implementation changes from recursive to iterative; behavior unchanged
- `phrase-extraction`: `phrases` implementation changes from recursive to iterative; behavior unchanged
- `negation-normal-form`: `pushNegation` becomes iterative with no depth limit; `RecursionTooDeepError` is soft-deprecated and never thrown; `maxRecursion` parameter is soft-deprecated and ignored

## Impact

- `Sources/SearchExpressionParser/Parsing/Expressions.swift` — iterative `isSatisfied` added
- `Sources/SearchExpressionParser/NormalForm/PhraseCollectionConvertible.swift` — iterative `phrases` added
- `Sources/SearchExpressionParser/NormalForm/ContainmentEvaluator.swift` — iterative `pushNegation`, deprecation annotations on `maxRecursion` and `RecursionTooDeepError`
- Existing stress tests (vectors 7–8) validate eval and phrases at 10,000 tokens
- New stress test vector needed for `pushNegation` at scale
