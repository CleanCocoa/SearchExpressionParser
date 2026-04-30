## ADDED Requirements

### Requirement: PhraseExtractor struct

The system SHALL provide a public `struct PhraseExtractor: ExpressionEvaluator` with `Result == [String]`.

#### Scenario: PhraseExtractor conforms to ExpressionEvaluator

- **WHEN** `PhraseExtractor()` is created
- **THEN** it SHALL conform to `ExpressionEvaluator` with `Result == [String]`

### Requirement: evaluateContains returns phrase array

`evaluateContains` SHALL return `[string]` -- a single-element array containing the original string.

#### Scenario: Contains produces single phrase

- **WHEN** `evaluateContains("hello", cString: cstring)` is called
- **THEN** the result SHALL be `["hello"]`

### Requirement: evaluateKeyValue returns empty array

`evaluateKeyValue` SHALL return `[]`. Key-value predicates do not contribute to highlight phrases.

#### Scenario: Key-value produces no phrases

- **WHEN** `evaluateKeyValue(key: "tag", value: "bar")` is called
- **THEN** the result SHALL be `[]`

### Requirement: evaluateAnything returns empty array

`evaluateAnything` SHALL return `[]`. The wildcard does not contribute to highlight phrases.

#### Scenario: Anything produces no phrases

- **WHEN** `evaluateAnything()` is called
- **THEN** the result SHALL be `[]`

### Requirement: evaluateNot returns empty array

`evaluateNot` SHALL return `[]`. Negated terms are excluded from highlight phrases.

#### Scenario: NOT drops inner phrases

- **WHEN** `evaluateNot(["hello"])` is called
- **THEN** the result SHALL be `[]`

### Requirement: evaluateAnd concatenates phrase arrays

`evaluateAnd` SHALL return `lhs + rhs`, concatenating the phrase arrays from both branches.

#### Scenario: AND combines phrases

- **WHEN** `evaluateAnd(["hello"], ["world"])` is called
- **THEN** the result SHALL be `["hello", "world"]`

### Requirement: evaluateOr concatenates phrase arrays

`evaluateOr` SHALL return `lhs + rhs`, concatenating the phrase arrays from both branches.

#### Scenario: OR combines phrases

- **WHEN** `evaluateOr(["hello"], ["world"])` is called
- **THEN** the result SHALL be `["hello", "world"]`

### Requirement: Full extraction via evaluate function

`PhraseExtractor` SHALL work with `evaluate(_:with:)` to extract phrases from complete expression trees. Best results when used after `normalize()`.

#### Scenario: AND with negated term after normalization

- **GIVEN** an expression `normalize(.and(.contains("foo"), .not(.contains("bar"))))`
- **WHEN** `evaluate(normalized, with: PhraseExtractor())` is called
- **THEN** the result SHALL be `["foo"]`

#### Scenario: OR collects all candidates

- **WHEN** `evaluate(.or(.contains("foo"), .contains("bar")), with: PhraseExtractor())` is called
- **THEN** the result SHALL be `["foo", "bar"]`
