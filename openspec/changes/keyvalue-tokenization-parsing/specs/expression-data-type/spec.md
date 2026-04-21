## MODIFIED Requirements

### Requirement: Expression enum type

The `Expression` enum SHALL include a `.keyValue(key: String, value: String)` case in addition to the existing `.anything`, `.contains`, `.not`, `.and`, `.or` cases.

#### Scenario: Exhaustive switch includes keyValue

- **WHEN** a consumer switches on an `Expression` value
- **THEN** the compiler SHALL require handling `.keyValue` alongside all other cases

#### Scenario: KeyValue equality

- **WHEN** two `.keyValue` expressions have the same key and value
- **THEN** they SHALL compare as equal via `==`

#### Scenario: KeyValue with different keys

- **WHEN** two `.keyValue` expressions have different keys
- **THEN** they SHALL compare as not equal via `==`
