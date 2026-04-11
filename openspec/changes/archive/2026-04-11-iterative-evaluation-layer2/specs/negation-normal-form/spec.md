# Negation Normal Form — Delta Spec

## MODIFIED Requirements

### Requirement: Recursion depth guard

The system SHALL soft-deprecate the recursion depth guard. `maxRecursion` SHALL be accepted but ignored. `RecursionTooDeepError` SHALL be marked as deprecated and never thrown. `normalizedEvaluable()` SHALL remain `throws` for source compatibility but SHALL NOT throw.

#### Scenario: Default initialization no longer enforces limit

- **GIVEN** a `ContainmentEvaluator` initialized with default parameters
- **WHEN** the expression tree depth exceeds 50 levels during normalization
- **THEN** normalization SHALL complete successfully without throwing

#### Scenario: Custom recursion limit ignored

- **GIVEN** a `ContainmentEvaluator` initialized with `maxRecursion: 5`
- **WHEN** the expression tree depth exceeds 5 during normalization
- **THEN** normalization SHALL complete successfully without throwing

### Requirement: ContainmentEvaluator normalizes before collecting phrases

The system SHALL normalize the expression to negation normal form before collecting phrases. `ContainmentEvaluator.phrases()` calls `normalizedEvaluable()` (which pushes negations inward via De Morgan's laws iteratively) and then collects phrases from the result.

#### Scenario: Negated AND expression

- **GIVEN** `NOT(x AND y)` as input to `ContainmentEvaluator`
- **WHEN** `phrases()` is called
- **THEN** normalization produces `NOT(x) OR NOT(y)`, and phrases returns `[]`

## REMOVED Requirements

### Requirement: ContainmentEvaluator returns empty array on recursion overflow

**Reason**: `pushNegation` is now iterative with no depth limit. `RecursionTooDeepError` is never thrown. The do/catch in `phrases()` is kept for source compatibility but the catch path is unreachable.

**Migration**: Remove `try`/`catch` around `normalizedEvaluable()` calls. The method still `throws` for source compatibility but never actually throws.
