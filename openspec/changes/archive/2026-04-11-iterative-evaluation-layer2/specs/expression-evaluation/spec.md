# Expression Evaluation — Delta Spec

## MODIFIED Requirements

### Requirement: AndNode Short-Circuit Evaluation

`AndNode` SHALL evaluate its `lhs` expression first. If `lhs` returns `false`, the result SHALL be `false` without evaluating `rhs`. If `lhs` returns `true`, it SHALL evaluate `rhs` and return that result. This applies to both evaluation paths. The implementation SHALL use O(1) call stack depth via iterative evaluation.

#### Scenario: Both true

- **GIVEN** an `AndNode` with truthy lhs and truthy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `true`

#### Scenario: Left false, right true

- **GIVEN** an `AndNode` with falsy lhs and truthy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `false`

#### Scenario: Left true, right false

- **GIVEN** an `AndNode` with truthy lhs and falsy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `false`

#### Scenario: Both false

- **GIVEN** an `AndNode` with falsy lhs and falsy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `false`

### Requirement: OrNode Short-Circuit Evaluation

`OrNode` SHALL evaluate its `lhs` expression first. If `lhs` returns `true`, the result SHALL be `true` without evaluating `rhs`. If `lhs` returns `false`, it SHALL evaluate `rhs` and return that result. This applies to both evaluation paths. The implementation SHALL use O(1) call stack depth via iterative evaluation.

#### Scenario: Both true

- **GIVEN** an `OrNode` with truthy lhs and truthy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `true`

#### Scenario: Left false, right true

- **GIVEN** an `OrNode` with falsy lhs and truthy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `true`

#### Scenario: Left true, right false

- **GIVEN** an `OrNode` with truthy lhs and falsy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `true`

#### Scenario: Both false

- **GIVEN** an `OrNode` with falsy lhs and falsy rhs
- **WHEN** evaluated
- **THEN** the result SHALL be `false`

### Requirement: NotNode Boolean Negation

`NotNode` SHALL return the boolean negation of its inner expression's evaluation result. This applies to both evaluation paths. The implementation SHALL use O(1) call stack depth via iterative evaluation.

#### Scenario: Negate true

- **GIVEN** a `NotNode` wrapping a truthy expression
- **WHEN** evaluated
- **THEN** the result SHALL be `false`

#### Scenario: Negate false

- **GIVEN** a `NotNode` wrapping a falsy expression
- **WHEN** evaluated
- **THEN** the result SHALL be `true`
