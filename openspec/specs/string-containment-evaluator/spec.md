# String Containment Evaluator Specification

> Synced from change expression-enum on 2026-04-22

## Purpose

`StringContainmentEvaluator` is a concrete `ExpressionEvaluator` for matching expression trees against a haystack string. It uses precomputed lowercased C-strings for fast case-insensitive substring search via `strstr`.

## Requirements

### Requirement: StringContainmentEvaluator struct

The system SHALL provide a public `struct StringContainmentEvaluator: ExpressionEvaluator` with `Result == Bool`. It SHALL store `haystack: String` and `haystackCString: [CChar]`. The initializer `init(_ haystack: String)` SHALL compute `haystackCString` as the lowercased, precomposed canonical mapping of the haystack encoded as UTF-8.

#### Scenario: Initialization computes CString haystack

- **WHEN** `StringContainmentEvaluator("Hello World")` is created
- **THEN** `haystack` SHALL be `"Hello World"` and `haystackCString` SHALL be the lowercased precomposed UTF-8 encoding

### Requirement: evaluateContains uses strstr fast path

`evaluateContains` SHALL return `true` when the needle's `cString` is found within `haystackCString` using C-string comparison, and `false` otherwise.

#### Scenario: Substring found

- **WHEN** `evaluateContains("world", cString: cstring)` is called on an evaluator with haystack `"Hello World"`
- **THEN** the result SHALL be `true` (case-insensitive via precomputed lowercased CStrings)

#### Scenario: Substring not found

- **WHEN** `evaluateContains("missing", cString: cstring)` is called on an evaluator with haystack `"Hello World"`
- **THEN** the result SHALL be `false`

#### Scenario: Empty needle

- **WHEN** `evaluateContains("", cString: cstring)` is called
- **THEN** the result SHALL be `false`

### Requirement: evaluateKeyValue returns false

`evaluateKeyValue` SHALL always return `false`. Key-value predicates cannot be evaluated by string containment.

#### Scenario: Any key-value returns false

- **WHEN** `evaluateKeyValue(key: "tag", value: "bar")` is called
- **THEN** the result SHALL be `false`

### Requirement: Full evaluation via evaluate function

`StringContainmentEvaluator` SHALL work with the `evaluate(_:with:)` function to evaluate complete expression trees against a haystack string.

#### Scenario: AND expression with both terms present

- **WHEN** `evaluate(.and(.contains("hello"), .contains("world")), with: StringContainmentEvaluator("hello world"))` is called
- **THEN** the result SHALL be `true`

#### Scenario: AND expression with one term missing

- **WHEN** `evaluate(.and(.contains("hello"), .contains("missing")), with: StringContainmentEvaluator("hello world"))` is called
- **THEN** the result SHALL be `false`

#### Scenario: NOT expression

- **WHEN** `evaluate(.not(.contains("missing")), with: StringContainmentEvaluator("hello world"))` is called
- **THEN** the result SHALL be `true`

## Technical Notes
- **Implementation**: `Sources/SearchExpressionParser/StringContainmentEvaluator.swift`
- **Dependencies**: `ExpressionEvaluator` protocol, `Expression` enum
