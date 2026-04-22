# Parsing Specification

> Synced from change expression-enum on 2026-04-22

## Purpose

The `Parser` builds `Expression` enum values from search strings. The method signature returns the `Expression` enum type directly. Grammar, tokenization, and tree shapes are unchanged from previous iterations; evaluation has been separated out into `ExpressionEvaluator`.

## Requirements

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

## Technical Notes
- **Implementation**: `Sources/SearchExpressionParser/Parsing/Parser.swift`
- **Dependencies**: Tokenization domain, `Expression` enum
- **Removed**: `isSatisfied(by:)` evaluation methods on expression types (use `ExpressionEvaluator` protocol instead); `AnythingNode`, `ContainsNode`, `AndNode`, `OrNode`, `NotNode` structs replaced by `Expression` enum cases
