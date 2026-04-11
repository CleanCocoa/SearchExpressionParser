# Iterative Phrases Specification

## Purpose

Iterative tree walker for phrase extraction that collects `ContainsNode` string values with O(1) call stack depth, replacing recursive `lhs.phrases + rhs.phrases`.

## ADDED Requirements

### Requirement: Iterative phrases produces identical output to recursive phrases

The iterative `phrases` implementation SHALL return the same `[String]` array as the recursive implementation for all expression trees, preserving element order.

#### Scenario: Deep AND tree phrase extraction

- **GIVEN** a parsed expression tree from 10,000 implicit-AND words
- **WHEN** `phrases` is accessed
- **THEN** the result SHALL contain all 10,000 words in left-to-right order

#### Scenario: Mixed AND/OR tree preserves order

- **GIVEN** an expression `AndNode(AndNode(ContainsNode("a"), ContainsNode("b")), ContainsNode("c"))`
- **WHEN** `phrases` is accessed
- **THEN** the result SHALL be `["a", "b", "c"]`

### Requirement: Left-to-right phrase ordering

The iterative walker SHALL produce phrases in left-to-right tree traversal order, matching the recursive version's concatenation of `lhs.phrases + rhs.phrases`.

#### Scenario: Nested OR preserves order

- **GIVEN** an expression `OrNode(ContainsNode("x"), OrNode(ContainsNode("y"), ContainsNode("z")))`
- **WHEN** `phrases` is accessed
- **THEN** the result SHALL be `["x", "y", "z"]`

### Requirement: O(1) call stack depth for phrase extraction

The iterative phrase extraction SHALL use O(1) call stack depth regardless of expression tree depth.

#### Scenario: Extract phrases from 10,000-node tree without stack overflow

- **GIVEN** a parsed expression from 10,000 implicit-AND words
- **WHEN** `phrases` is accessed
- **THEN** extraction completes without stack overflow

### Requirement: NotNode subtrees produce no phrases

The iterative walker SHALL skip `NotNode` subtrees entirely, producing no phrases for negated branches.

#### Scenario: Negated subtree skipped

- **GIVEN** an `AndNode` with `ContainsNode("keep")` and `NotNode(ContainsNode("skip"))`
- **WHEN** `phrases` is accessed
- **THEN** the result SHALL be `["keep"]`
