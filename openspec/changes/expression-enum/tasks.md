## 1. Expression Enum

- [x] 1.1 Write tests for `Expression` enum: cases, `Equatable`, `Sendable`, `CString` typealias
- [x] 1.2 Create `enum Expression` with cases `.anything`, `.contains(string:cString:)`, `.not(Expression)`, `indirect case .and(Expression, Expression)`, `indirect case .or(Expression, Expression)`, `.keyValue(key: String, value: String)` conforming to `Sendable`, `Equatable`
- [x] 1.3 Write tests for `Expression.cStringFactory` default behavior
- [x] 1.4 Add `static var cStringFactory` and `typealias CString = [CChar]` to `Expression`
- [x] 1.5 Write tests for `Expression.contains(_:)` convenience factory
- [x] 1.6 Add `static func contains(_ string: String) -> Expression` factory method

## 2. ExpressionEvaluator Protocol

- [x] 2.1 Write tests for `ExpressionEvaluator` protocol: verify a test evaluator with `Result == String` must implement all six methods
- [x] 2.2 Create `ExpressionEvaluator` protocol with `associatedtype Result` and six required methods

## 3. Boolean Defaults Extension

- [x] 3.1 Write tests for Bool extension defaults: `evaluateNot`, `evaluateAnd`, `evaluateOr`, `evaluateAnything`
- [x] 3.2 Add protocol extension for `Result == Bool` with defaults for `evaluateNot`, `evaluateAnd`, `evaluateOr`, `evaluateAnything`
- [x] 3.3 Write test verifying a Bool evaluator compiles with only `evaluateContains` and `evaluateKeyValue`

## 4. Evaluate Function

- [x] 4.1 Write tests for `evaluate(_:with:)` dispatching leaf nodes: `.anything`, `.contains`
- [x] 4.2 Write tests for `evaluate(_:with:)` dispatching composite nodes: `.not`, `.and`, `.or`
- [x] 4.3 Implement `evaluate(_:with:)` with iterative stack-based tree walk
- [x] 4.4 Write tests for AND short-circuit: false left branch skips right evaluation
- [x] 4.5 Write tests for OR short-circuit: true left branch skips right evaluation
- [x] 4.6 Implement short-circuit logic for `Result == Bool`
- [x] 4.7 Write test for deep tree (depth 10,000) completing without stack overflow — covered by `StackOverflowTests.swift` `testEvalImplicitAND_10000` + `testNormalizePushNegation_10000`

## 5. StringContainmentEvaluator

- [x] 5.1 Write tests for `StringContainmentEvaluator` initialization: haystack and haystackCString storage
- [x] 5.2 Write tests for `evaluateContains`: substring found, not found, empty needle
- [x] 5.3 Write tests for `evaluateKeyValue` returning false
- [x] 5.4 Implement `StringContainmentEvaluator` struct with `evaluateContains` (strstr fast path) and `evaluateKeyValue` (returns false)
- [x] 5.5 Write integration tests: full tree evaluation via `evaluate(_:with:)` with AND, OR, NOT expressions

## 6. Remove Old Expression Types

- [x] 6.1 Remove `Expression` protocol, `StringExpressionSatisfiable`, `CStringExpressionSatisfiable` protocols
- [x] 6.2 Remove `AnythingNode`, `ContainsNode`, `NotNode`, `AndNode`, `OrNode` structs
- [x] 6.3 Remove `iterativeIsSatisfied` functions and `EvalFrame` enum
- [x] 6.4 Remove `PhraseCollectionConvertible` protocol
- [x] 6.5 Remove `ContainmentEvaluator` struct
- [x] ~~Remove `AnyEquatable`~~ (kept — load-bearing for Token array equality assertions in `XCTAssertEqual+Token.swift`, used by 54 call sites in `TokenizerTests`)
- [x] 6.7 Remove `ExpressionTests` and `ContainmentEvaluatorTests` that test removed types
- [x] 6.8 Remove `PhraseCollectionConvertibleTests`

## 7. Update Parser

- [x] 7.1 Update `Parser` internals to produce `Expression` enum values instead of node structs
- [x] 7.2 Update `Parser.parse(searchString:)` return type to `Expression` enum
- [x] 7.3 Update `ParserTests` to assert on `Expression` enum values

## 8. Update Normalize

- [x] 8.1 Write tests for `normalize(_:)` free function using `Expression` enum
- [x] 8.2 Convert `pushNegationIteratively` to a public `normalize(_: Expression) -> Expression` free function using enum pattern matching
- [x] 8.3 Remove old `ContainmentEvaluator.normalizedEvaluable()` method (if not already removed in step 6.5)
- [x] 8.4 Write test verifying `normalize(_:)` passes `.keyValue` through unchanged

## 9. CustomStringConvertible

- [x] 9.1 Write tests for `Expression: CustomStringConvertible` covering all cases
- [x] 9.2 Add `CustomStringConvertible` conformance on `Expression` enum, omitting `cString` from output

## 10. Cleanup

- [x] 10.1 Update `TokenizerTests` and `StackOverflowTests` for any `Expression` type references
- [x] 10.2 Verify all tests pass
