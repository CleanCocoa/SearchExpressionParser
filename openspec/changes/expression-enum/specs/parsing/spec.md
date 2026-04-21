## MODIFIED Requirements

### Requirement: Parser return type

`Parser.parse(searchString:)` SHALL return `Expression` (the enum type) instead of the former `Expression` protocol existential. The method signature becomes `static func parse(searchString: String) throws -> Expression`. The grammar, tokenization, and tree shapes are unchanged.

#### Scenario: Single word produces contains

- **WHEN** `Parser.parse(searchString: "hello")` is called
- **THEN** the result SHALL be `Expression.contains("hello")`

#### Scenario: Empty input produces anything

- **WHEN** `Parser.parse(searchString: "")` is called
- **THEN** the result SHALL be `Expression.anything`

#### Scenario: AND expression

- **WHEN** `Parser.parse(searchString: "foo AND bar")` is called
- **THEN** the result SHALL be `.and(.contains("foo"), .contains("bar"))`

#### Scenario: OR expression

- **WHEN** `Parser.parse(searchString: "foo OR bar")` is called
- **THEN** the result SHALL be `.or(.contains("foo"), .contains("bar"))`

#### Scenario: NOT expression

- **WHEN** `Parser.parse(searchString: "NOT foo")` is called
- **THEN** the result SHALL be `.not(.contains("foo"))`

## REMOVED Requirements

### Requirement: Dual Evaluation Paths
**Reason**: Evaluation is separated from expression data. `isSatisfied(by:)` methods removed from expression types.
**Migration**: Use the `ExpressionEvaluator` protocol and `evaluate(_:with:)` function (introduced in a subsequent change).

### Requirement: AnythingNode Always Matches
**Reason**: `AnythingNode` struct replaced by `Expression.anything` case. Matching behavior moves to evaluators.
**Migration**: `Expression.anything` represents the same concept. Evaluation via `ExpressionEvaluator.evaluateAnything()`.

### Requirement: ContainsNode Substring Match
**Reason**: `ContainsNode` struct replaced by `Expression.contains(string:cString:)` case. Matching behavior moves to evaluators.
**Migration**: `Expression.contains` represents the same data. Evaluation via `ExpressionEvaluator.evaluateContains(_:cString:)`.

### Requirement: ContainsNode Empty String Behavior
**Reason**: Evaluation behavior removed from expression types.
**Migration**: Evaluator implementations define matching semantics.

### Requirement: AndNode Short-Circuit Evaluation
**Reason**: `AndNode` struct replaced by `Expression.and` case. Short-circuit evaluation moves to the `evaluate(_:with:)` function.
**Migration**: `Expression.and` represents the same structure. Short-circuit behavior preserved in the evaluate function (subsequent change).

### Requirement: OrNode Short-Circuit Evaluation
**Reason**: `OrNode` struct replaced by `Expression.or` case. Short-circuit evaluation moves to the `evaluate(_:with:)` function.
**Migration**: `Expression.or` represents the same structure. Short-circuit behavior preserved in the evaluate function (subsequent change).

### Requirement: NotNode Boolean Negation
**Reason**: `NotNode` struct replaced by `Expression.not` case. Negation logic moves to evaluators.
**Migration**: `Expression.not` represents the same structure. Negation via `ExpressionEvaluator.evaluateNot(_:)`.
