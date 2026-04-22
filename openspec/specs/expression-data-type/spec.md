# Expression Data Type Specification

> Synced from change expression-enum on 2026-04-22

## Purpose

`Expression` is the central enum type representing parsed search expressions. It provides a closed set of cases covering the full expression grammar, with compiler-derived `Equatable` and `Sendable` conformances. It also provides the `CString` typealias and factory for normalized C-string creation used in fast substring matching.

## Requirements

### Requirement: Expression enum type

The system SHALL represent parsed search expressions as a single `enum Expression` with cases: `.anything`, `.contains(string: String, cString: [CChar])`, `.not(Expression)`, `.and(Expression, Expression)`, `.or(Expression, Expression)`. The `.and` and `.or` cases SHALL be `indirect`. The enum SHALL conform to `Sendable` and `Equatable` with compiler-derived conformances.

#### Scenario: Enum cases are exhaustive for current node types

- **WHEN** a consumer switches on an `Expression` value
- **THEN** the compiler SHALL require handling `.anything`, `.contains`, `.not`, `.and`, and `.or`

#### Scenario: Equatable comparison of identical trees

- **WHEN** two `Expression` values represent the same tree structure with the same leaf values
- **THEN** they SHALL compare as equal via `==`

#### Scenario: Equatable comparison of different trees

- **WHEN** two `Expression` values differ in structure or leaf values
- **THEN** they SHALL compare as not equal via `==`

#### Scenario: Sendable conformance

- **WHEN** an `Expression` value is passed across actor or concurrency boundaries
- **THEN** the compiler SHALL accept it without warnings

### Requirement: CString typealias

The `Expression` enum SHALL expose a `typealias CString = [CChar]` for use in the `.contains` case and by consumers.

#### Scenario: CString type alias resolves

- **WHEN** a consumer references `Expression.CString`
- **THEN** it SHALL resolve to `[CChar]`

### Requirement: CString factory

The `Expression` enum SHALL expose a `static var cStringFactory: (String) -> CString` property. The default factory SHALL apply `precomposedStringWithCanonicalMapping`, then `lowercased()`, then encode as UTF-8 via `cString(using: .utf8)`, falling back to an empty array on encoding failure. Consumers MAY replace `cStringFactory` to customize CString creation.

#### Scenario: Default CString creation

- **WHEN** `Expression.cStringFactory` is called with a string
- **THEN** the result SHALL be the lowercased, precomposed canonical mapping of that string encoded as UTF-8

#### Scenario: Custom CString factory

- **WHEN** a consumer assigns a custom closure to `Expression.cStringFactory`
- **THEN** subsequent `.contains` case construction using the factory SHALL use the custom closure

### Requirement: Contains convenience initializer

The `Expression` enum SHALL provide a static factory `Expression.contains(_ string: String) -> Expression` that creates a `.contains` case using `cStringFactory` to compute the `cString` value.

#### Scenario: Factory creates contains with computed cString

- **WHEN** `Expression.contains("hello")` is called
- **THEN** the result SHALL be `.contains(string: "hello", cString: Expression.cStringFactory("hello"))`

## Technical Notes
- **Implementation**: `Sources/SearchExpressionParser/Expression.swift`
- **Dependencies**: None (leaf type)
