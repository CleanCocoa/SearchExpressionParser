# Phrase Extractor Specification

> Synced from change builtin-evaluators on 2026-04-30
> Synced from change sync-specs-post-v2 on 2026-05-06

## Purpose

Provides a public `PhraseExtractor` struct conforming to `ExpressionEvaluator` that folds an expression tree into the list of positive containment phrases suitable for highlight extraction. It replaces v1's `ContainmentEvaluator.phrases()` using the `ExpressionEvaluator` protocol. `evaluateContains` returns a single-element phrase array; `evaluateKeyValue`, `evaluateAnything`, and `evaluateNot` return empty arrays (negated and non-containment nodes do not contribute highlight phrases); `evaluateAnd` and `evaluateOr` concatenate both branches. Best results when the expression is passed through `normalize()` first so negations are pushed to leaves before extraction.

## Requirements

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

### Requirement: O(1) call stack depth on evaluate(_:with:)

`evaluate(_:with: PhraseExtractor())` SHALL traverse the expression tree iteratively with O(1) call stack depth, regardless of tree depth, preventing stack overflow on arbitrarily deep expression trees. This constraint anchors on the iterative machinery in `evaluate(_:with:)` (described in `expression-evaluator/spec.md`); `PhraseExtractor` itself is a stateless struct.

#### Scenario: Extract phrases from 10,000-deep tree without stack overflow

- **GIVEN** a parsed expression of 10,000 implicit-AND words
- **WHEN** `evaluate(expression, with: PhraseExtractor())` is called
- **THEN** extraction SHALL complete without stack overflow and return all 10,000 phrases in left-to-right order

## Technical Notes

- **Implementation**: `Sources/SearchExpressionParser/PhraseExtractor.swift`
- **Dependencies**: `Expression` enum, `ExpressionEvaluator` protocol (expression-enum and evaluator-protocol changes)
