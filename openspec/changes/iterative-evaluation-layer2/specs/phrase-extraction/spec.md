# Phrase Extraction — Delta Spec

## MODIFIED Requirements

### Requirement: AndNode concatenates phrases from both children

The system SHALL return the concatenation of phrases from the left-hand side followed by phrases from the right-hand side when collecting phrases from an `AndNode`. The implementation SHALL use O(1) call stack depth via iterative tree walking.

#### Scenario: Two positive terms

- **GIVEN** an `AndNode` with `ContainsNode("foo")` and `ContainsNode("bar")`
- **WHEN** phrases are collected
- **THEN** the result is `["foo", "bar"]`

#### Scenario: One negated child

- **GIVEN** an `AndNode` with `NotNode(ContainsNode("foo"))` and `ContainsNode("bar")`
- **WHEN** phrases are collected via `ContainmentEvaluator`
- **THEN** the result is `["bar"]`

### Requirement: OrNode concatenates phrases from both children

The system SHALL return the concatenation of phrases from both branches of an `OrNode`. Phrases are "may contain" candidates, not "must contain", so OR branches contribute all alternatives. The implementation SHALL use O(1) call stack depth via iterative tree walking.

#### Scenario: Two alternative terms

- **GIVEN** an `OrNode` with `ContainsNode("foo")` and `ContainsNode("bar")`
- **WHEN** phrases are collected
- **THEN** the result is `["foo", "bar"]`

#### Scenario: One negated alternative

- **GIVEN** an `OrNode` with `ContainsNode("foo")` and `NotNode(ContainsNode("bar"))`
- **WHEN** phrases are collected via `ContainmentEvaluator`
- **THEN** the result is `["foo"]`
