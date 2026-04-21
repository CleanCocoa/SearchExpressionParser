## Context

The current `Expression` protocol + struct hierarchy (`AnythingNode`, `ContainsNode`, `NotNode`, `AndNode`, `OrNode`) couples data representation with evaluation via `isSatisfied(by:)`. This prevents adding new leaf types that need different evaluation strategies. The v2 design replaces this with a pure data enum, separating expression representation from evaluation entirely.

The existing iterative tree walker (`iterativeIsSatisfied`) provides the pattern for the future `evaluate(_:with:)` function, but that function is out of scope for this change.

## Goals / Non-Goals

**Goals:**
- Replace protocol + structs with `enum Expression` carrying the same cases
- Derive `Sendable` and `Equatable` automatically
- Retain `cStringFactory` customization on the `Expression` type
- Keep `Parser.parse(searchString:)` producing valid expression trees
- Keep `normalize` (negation normal form rewrite) working on the new type
- Remove all evaluation code (`isSatisfied`, `iterativeIsSatisfied`, satisfiable protocols)
- Remove `ContainmentEvaluator`, `PhraseCollectionConvertible` (re-introduced later as evaluator-based)

**Non-Goals:**
- Adding `.keyValue` case (separate change)
- Adding `ExpressionEvaluator` protocol or `evaluate(_:with:)` (separate change)
- Adding `StringContainmentEvaluator` or `PhraseExtractor` (separate changes)
- Maintaining backward compatibility (this is a 2.0 breaking change)

## Decisions

**Enum with indirect cases for binary nodes**: `.and` and `.or` use `indirect case` since they hold two `Expression` values. `.not` holds one `Expression` and also needs `indirect` (or the entire enum is marked `indirect`, but per-case is more precise and avoids overhead on leaf cases).

**CString factory stays as static property**: `Expression.cStringFactory` mirrors the current `ContainsNode.cStringFactory`. This keeps the customization point accessible and avoids introducing a configuration struct for this change alone.

**Normalize becomes a free function on Expression enum**: `normalize(_: Expression) -> Expression` replaces the `ContainmentEvaluator.normalizedEvaluable()` method. The rewrite logic uses pattern matching on enum cases instead of `as?` casts, eliminating runtime type checking failures.

**Remove ContainmentEvaluator and PhraseCollectionConvertible now**: These depend on `isSatisfied` semantics and protocol-typed nodes. They will be re-introduced as `PhraseExtractor: ExpressionEvaluator` in a later change. Removing them now keeps this change clean.

**Test strategy**: Tests transition from protocol-based equality helpers (`AnyEquatable`, custom `XCTAssertEqual+Expression`) to direct enum `==` comparison. Parser tests assert on `Expression` enum values. Normalization tests assert on `Expression` enum values. Evaluation tests are removed (no evaluation code remains).

## Risks / Trade-offs

**Temporary loss of evaluation and phrase extraction**: Between this change and the evaluator changes, the library cannot evaluate expressions or extract phrases. Acceptable because this is a coordinated v2 rollout, not an incremental release.

**All downstream consumers break**: Every `case let node as ContainsNode` pattern match breaks. Intentional for a major version bump.

**`nonisolated(unsafe)` on cStringFactory**: The mutable static property needs the same concurrency annotation as v1. This is a known trade-off carried forward; a future change could use a configuration struct instead.
