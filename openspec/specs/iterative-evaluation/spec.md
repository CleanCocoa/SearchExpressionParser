# Iterative Evaluation Specification

## Purpose

Iterative stack-machine implementation of `isSatisfied(by:)` that evaluates expression trees with O(1) call stack depth, replacing recursive protocol dispatch.

## ADDED Requirements

### Requirement: Iterative evaluation produces identical results to recursive evaluation

The iterative `isSatisfied(by:)` implementation SHALL produce the same boolean result as the recursive implementation for all expression trees and all inputs, for both `StringExpressionSatisfiable` and `CStringExpressionSatisfiable` paths.

#### Scenario: Deep implicit-AND tree evaluates correctly

- **GIVEN** a parsed expression tree from 10,000 implicit-AND words
- **WHEN** `isSatisfied(by:)` is called with a string input
- **THEN** the result SHALL be the same as evaluating each `ContainsNode` individually and ANDing the results

#### Scenario: Deep OR tree evaluates correctly

- **GIVEN** a parsed expression tree from 10,000 OR-chained words
- **WHEN** `isSatisfied(by:)` is called with a string that contains one of the words
- **THEN** the result SHALL be `true`

### Requirement: Short-circuit evaluation preserved

The iterative implementation SHALL preserve short-circuit semantics: `AndNode` SHALL NOT evaluate its RHS when LHS is `false`; `OrNode` SHALL NOT evaluate its RHS when LHS is `true`.

#### Scenario: AND short-circuits on false LHS

- **GIVEN** an `AndNode` with a `false`-evaluating LHS and any RHS
- **WHEN** `isSatisfied(by:)` is called
- **THEN** the result SHALL be `false` without evaluating RHS

#### Scenario: OR short-circuits on true LHS

- **GIVEN** an `OrNode` with a `true`-evaluating LHS and any RHS
- **WHEN** `isSatisfied(by:)` is called
- **THEN** the result SHALL be `true` without evaluating RHS

### Requirement: O(1) call stack depth for evaluation

The iterative evaluation SHALL use O(1) call stack depth regardless of expression tree depth. Heap memory usage SHALL be O(N) where N is the number of nodes.

#### Scenario: Evaluate 10,000-node tree without stack overflow

- **GIVEN** a parsed expression from 10,000 implicit-AND words
- **WHEN** `isSatisfied(by:)` is called
- **THEN** evaluation completes without stack overflow

### Requirement: Both evaluation paths supported

The iterative implementation SHALL support both `StringExpressionSatisfiable` and `CStringExpressionSatisfiable` evaluation paths.

#### Scenario: String path evaluation

- **GIVEN** any expression tree
- **WHEN** `isSatisfied(by:)` is called with a `StringExpressionSatisfiable` value
- **THEN** evaluation SHALL use `contains(phrase:)` for leaf nodes

#### Scenario: CString path evaluation

- **GIVEN** any expression tree
- **WHEN** `isSatisfied(by:)` is called with a `CStringExpressionSatisfiable` value
- **THEN** evaluation SHALL use `matches(needle:)` for leaf nodes
