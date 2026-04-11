## 1. Iterative `isSatisfied` evaluation

- [x] 1.1 Add private `EvalFrame` enum and `iterativeIsSatisfied` function for `StringExpressionSatisfiable` in `Expressions.swift`, using explicit frame stack and value stack with short-circuit semantics
- [x] 1.2 Add matching `iterativeIsSatisfied` overload for `CStringExpressionSatisfiable`
- [x] 1.3 Delegate each node's `isSatisfied(by: StringExpressionSatisfiable)` to the iterative function with `self` as root
- [x] 1.4 Delegate each node's `isSatisfied(by: CStringExpressionSatisfiable)` to the iterative function with `self` as root
- [x] 1.5 Verify all existing `ExpressionTests` pass unchanged
- [x] 1.6 Verify `testEvalImplicitAND_10000` stress test passes (vector 7)

## 2. Iterative `phrases` extraction

- [x] 2.1 Add private `iterativePhrases` function in `PhraseCollectionConvertible.swift` using explicit `[Expression]` stack with rhs-first push order for left-to-right output
- [x] 2.2 Delegate `AndNode.phrases` and `OrNode.phrases` to the iterative function with `self` as root
- [x] 2.3 Verify all existing `ContainmentEvaluatorTests` and phrase-related tests pass unchanged
- [x] 2.4 Verify `testPhrasesImplicitAND_10000` stress test passes (vector 8)
- [x] 2.5 Add phrase ordering tests: nested AND produces `["a", "b", "c"]`, nested OR produces `["x", "y", "z"]`

## 3. Iterative `pushNegation`

- [x] 3.1 Add private `Instruction` enum and `pushNegationIteratively` function in `ContainmentEvaluator.swift` using two-phase decompose/reconstruct with `(Evaluable, isNegated)` work stack
- [x] 3.2 Replace recursive `pushNegation(_:level:)` call in `normalizedEvaluable()` with `pushNegationIteratively`
- [x] 3.3 Delete the recursive `pushNegation(_:level:)` method
- [x] 3.4 Verify all existing `ContainmentEvaluatorTests` pass unchanged (2 expected failures from deprecated RecursionTooDeepError — addressed in group 4)
- [x] 3.5 Add stress test: `normalizedEvaluable()` on a NOT-wrapped 10,000-deep AND chain completes without error

## 4. Soft-deprecate `maxRecursion` and `RecursionTooDeepError`

- [x] 4.1 Split `init(evaluable:maxRecursion:)` into non-deprecated `init(evaluable:)` and deprecated `init(evaluable:maxRecursion:)` that ignores the parameter
- [x] 4.2 Add `@available(*, deprecated)` annotation to `RecursionTooDeepError`
- [x] 4.3 Add `@available(*, deprecated)` annotation to `maxRecursion` property
- [x] 4.4 Verify existing tests that use `maxRecursion` still compile (with deprecation warnings)
- [x] 4.5 Update tests that assert `RecursionTooDeepError` is thrown: they should now assert successful completion

## 5. Final verification

- [x] 5.1 Run full test suite (`swift test`) — all 178 tests pass
- [x] 5.2 Run all StackOverflow stress tests — vectors 7, 8, and 10 pass at 10,000 nodes
- [x] 5.3 Verify benchmark test still completes within performance bounds
