# KeyValue Extraction Specification

> Synced from change keyvalue-extraction on 2026-04-28

## Purpose

Provides a public inspection function `keyValueNodes(in:)` that collects all `.keyValue` leaves from an `Expression` tree. Callers use this to discover which keys are referenced in a parsed query before evaluation (for example, to determine which indices to prepare), without performing a full evaluation pass. The function traverses through composite nodes (`.and`, `.or`, `.not`) and preserves duplicate occurrences.

## Requirements

### Requirement: keyValueNodes extraction function

The system SHALL provide a public free function `keyValueNodes(in expression: Expression) -> [(key: String, value: String)]` that collects all `.keyValue` leaves from the expression tree.

#### Scenario: Single key-value

- **WHEN** `keyValueNodes(in: .keyValue(key: "tag", value: "bar"))` is called
- **THEN** the result SHALL be `[("tag", "bar")]`

#### Scenario: No key-value nodes

- **WHEN** `keyValueNodes(in: .contains("hello"))` is called
- **THEN** the result SHALL be `[]`

#### Scenario: Anything node

- **WHEN** `keyValueNodes(in: .anything)` is called
- **THEN** the result SHALL be `[]`

### Requirement: Traverses composite nodes

The function SHALL traverse through `.and`, `.or`, and `.not` nodes to find `.keyValue` leaves at any depth.

#### Scenario: Key-value in AND

- **WHEN** `keyValueNodes(in: .and(.contains("foo"), .keyValue(key: "tag", value: "bar")))` is called
- **THEN** the result SHALL be `[("tag", "bar")]`

#### Scenario: Key-value in OR

- **WHEN** `keyValueNodes(in: .or(.keyValue(key: "tag", value: "a"), .keyValue(key: "tag", value: "b")))` is called
- **THEN** the result SHALL contain `("tag", "a")` and `("tag", "b")`

#### Scenario: Key-value in NOT

- **WHEN** `keyValueNodes(in: .not(.keyValue(key: "tag", value: "bar")))` is called
- **THEN** the result SHALL be `[("tag", "bar")]`

#### Scenario: Deeply nested key-values

- **WHEN** `keyValueNodes(in: .and(.or(.keyValue(key: "tag", value: "a"), .contains("x")), .not(.keyValue(key: "title", value: "b"))))` is called
- **THEN** the result SHALL contain `("tag", "a")` and `("title", "b")`

### Requirement: Preserves duplicates

The function SHALL return all occurrences of key-value nodes including duplicates.

#### Scenario: Duplicate key-value pairs

- **WHEN** `keyValueNodes(in: .and(.keyValue(key: "tag", value: "a"), .keyValue(key: "tag", value: "a")))` is called
- **THEN** the result SHALL contain two entries: `[("tag", "a"), ("tag", "a")]`

## Technical Notes

- **Implementation**: `Sources/SearchExpressionParser/Inspection/KeyValueNodes.swift`
- **Dependencies**: `Expression` enum (`.keyValue` case), `ExpressionEvaluator` (used internally as a fold over the tree)
