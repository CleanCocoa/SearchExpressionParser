# Iterative Push Negation Specification

## Purpose

Iterative two-phase implementation of De Morgan's law application (`pushNegation`) that normalizes expression trees to negation normal form with O(1) call stack depth and no depth limit.

## ADDED Requirements

### Requirement: Iterative pushNegation produces identical trees to recursive pushNegation

The iterative implementation SHALL produce the same normalized expression tree as the recursive implementation for all input trees.

#### Scenario: NOT(AND(a, b)) normalization

- **GIVEN** an expression `NOT(AND(ContainsNode("x"), ContainsNode("y")))`
- **WHEN** `normalizedEvaluable()` is called
- **THEN** the result SHALL be `OR(NOT(ContainsNode("x")), NOT(ContainsNode("y")))`

#### Scenario: NOT(OR(a, b)) normalization

- **GIVEN** an expression `NOT(OR(ContainsNode("x"), ContainsNode("y")))`
- **WHEN** `normalizedEvaluable()` is called
- **THEN** the result SHALL be `AND(NOT(ContainsNode("x")), NOT(ContainsNode("y")))`

#### Scenario: Multi-level De Morgan

- **GIVEN** an expression `NOT(AND(OR(ContainsNode("a"), ContainsNode("b")), ContainsNode("c")))`
- **WHEN** `normalizedEvaluable()` is called
- **THEN** the result SHALL be `OR(AND(NOT(ContainsNode("a")), NOT(ContainsNode("b"))), NOT(ContainsNode("c")))`

### Requirement: No depth limit

The iterative implementation SHALL handle arbitrarily deep expression trees without any recursion depth limit.

#### Scenario: Normalize 10,000-deep tree without error

- **GIVEN** a NOT-wrapped expression tree with 10,000 nested AND/OR nodes
- **WHEN** `normalizedEvaluable()` is called
- **THEN** normalization completes without throwing and without stack overflow

### Requirement: O(1) call stack depth for normalization

The iterative normalization SHALL use O(1) call stack depth regardless of expression tree depth. Heap memory usage SHALL be O(N) where N is the number of nodes.

#### Scenario: Normalize deep tree on 512KB stack

- **GIVEN** a deep expression tree
- **WHEN** `normalizedEvaluable()` is called on a background thread with a 512KB stack
- **THEN** normalization completes without stack overflow

### Requirement: Non-NOT nodes pass through unchanged

The iterative implementation SHALL return any expression that is not a `NotNode` (or does not contain `NotNode` wrappers around compound nodes) unchanged.

#### Scenario: Leaf node passthrough

- **GIVEN** a `ContainsNode("foo")`
- **WHEN** `normalizedEvaluable()` is called
- **THEN** the result SHALL be the same `ContainsNode("foo")`

#### Scenario: NOT wrapping leaf preserved

- **GIVEN** a `NotNode(ContainsNode("foo"))`
- **WHEN** `normalizedEvaluable()` is called
- **THEN** the result SHALL be `NotNode(ContainsNode("foo"))` unchanged
