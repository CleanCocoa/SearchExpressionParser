## Why

v1 fuses data and evaluation: the `Expression` protocol requires every node struct to implement `isSatisfied(by:)`. This prevents adding leaf types (like key-value nodes) that cannot be evaluated by string containment. Replacing the protocol + struct hierarchy with a single `enum Expression` makes the tree pure data, enables exhaustive switch checking, automatic `Sendable`/`Equatable` conformance, and clears the path for external evaluators in subsequent changes.

## What Changes

- **BREAKING**: Remove `Expression` protocol, replace with `enum Expression` having cases: `.anything`, `.contains(string:cString:)`, `.not(Expression)`, `.and(Expression, Expression)`, `.or(Expression, Expression)`, `.keyValue(key: String, value: String)`.
- **BREAKING**: Remove `AnythingNode`, `ContainsNode`, `NotNode`, `AndNode`, `OrNode` structs.
- **BREAKING**: Remove `StringExpressionSatisfiable`, `CStringExpressionSatisfiable` protocols.
- **BREAKING**: Remove `isSatisfied(by:)` methods and `iterativeIsSatisfied` functions.
- **BREAKING**: Remove `PhraseCollectionConvertible` protocol and `ContainmentEvaluator` struct (will be re-introduced as evaluator-based types in later changes).
- Move `cStringFactory` to a static property on `Expression`. Retain `Expression.CString` typealias.
- Add `ExpressionEvaluator` protocol with `associatedtype Result` and six required methods: `evaluateContains(_:cString:)`, `evaluateKeyValue(key:value:)`, `evaluateAnything()`, `evaluateNot(_:)`, `evaluateAnd(_:_:)`, `evaluateOr(_:_:)`.
- Add protocol extension for `Result == Bool` with defaults for `evaluateNot`, `evaluateAnd`, `evaluateOr`, `evaluateAnything`.
- Add `evaluate(_:with:)` free function with iterative stack-based tree walk and Bool short-circuit.
- Add `StringContainmentEvaluator` struct (`Result == Bool`, strstr fast path).
- Update `Parser` to produce `Expression` enum values.
- Update all tests to use the new enum type.

## Capabilities

### New Capabilities
- `expression-data-type`: The `Expression` enum as pure data -- cases, `Sendable`/`Equatable` conformance, `CString` typealias, `cStringFactory` static property.
- `expression-evaluator`: The `ExpressionEvaluator` protocol, boolean defaults extension, and `evaluate(_:with:)` tree-walk function.
- `string-containment-evaluator`: `StringContainmentEvaluator` struct for full-text substring matching against a haystack string.

### Modified Capabilities
- `parsing`: Parser return type changes from `Expression` protocol to `Expression` enum. Same grammar, same tree shapes, different concrete type.
- `negation-normal-form`: `pushNegationIteratively` operates on `Expression` enum instead of protocol-typed nodes. Same rewrite rules.

## Impact

- All public API surface around expression types changes. Source-breaking for any downstream consumer.
- `Parser.parse(searchString:)` signature changes return type from protocol to enum.
- `ContainmentEvaluator` removed; `StringContainmentEvaluator` replaces the v1 `isSatisfied(by:)` path for simple callers.
- `String: StringExpressionSatisfiable` conformance removed.
- Test helpers (`XCTAssertEqual+Expression`, `AnyEquatable`, `Descriptions`) need rewrite or removal since enum `Equatable` replaces custom comparison.
- New public API surface: `ExpressionEvaluator` protocol, `evaluate(_:with:)` function, `StringContainmentEvaluator` struct.
