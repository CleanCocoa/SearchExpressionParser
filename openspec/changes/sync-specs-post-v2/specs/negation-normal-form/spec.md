## MODIFIED Requirements

### Requirement: NOT over AND applies De Morgan's law

The `normalize` function SHALL transform `.not(.and(a, b))` into `.or(.not(a), .not(b))`, applying the same rule to each operand transitively until no transformable `.not` nodes remain.

#### Scenario: NOT wrapping an AND of two leaf nodes

- **GIVEN** an expression `.not(.and(.contains("x"), .contains("y")))`
- **WHEN** `normalize` is called
- **THEN** the result is `.or(.not(.contains("x")), .not(.contains("y")))`

### Requirement: NOT over OR applies De Morgan's law

The `normalize` function SHALL transform `.not(.or(a, b))` into `.and(.not(a), .not(b))`, applying the same rule to each operand transitively until no transformable `.not` nodes remain.

#### Scenario: NOT wrapping an OR of two leaf nodes

- **GIVEN** an expression `.not(.or(.contains("x"), .contains("y")))`
- **WHEN** `normalize` is called
- **THEN** the result is `.and(.not(.contains("x")), .not(.contains("y")))`

### Requirement: Multi-level normalization through arbitrary nesting

The `normalize` function SHALL apply De Morgan's laws transitively through multiple levels of nesting until all negations reach leaf nodes. The implementation SHALL use iterative processing (a two-phase work-stack and instruction-stack reversal) so that arbitrarily deep trees normalize without recursion.

#### Scenario: Two levels of nesting

- **GIVEN** an expression `.not(.and(.or(.contains("a"), .contains("b")), .and(.contains("c"), .contains("d"))))`
- **WHEN** `normalize` is called
- **THEN** the result is `.or(.and(.not(.contains("a")), .not(.contains("b"))), .or(.not(.contains("c")), .not(.contains("d"))))`

## ADDED Requirements

### Requirement: O(1) call stack depth on normalize

The `normalize` function SHALL use O(1) call stack depth regardless of expression tree depth, using an explicit work stack on the heap rather than recursion. Heap memory usage SHALL be O(N) where N is the number of nodes in the input tree. This makes `normalize` safe for arbitrarily deep trees with no depth limit.

#### Scenario: Normalize 10,000-deep tree without stack overflow

- **GIVEN** an expression tree wrapping 10,000 nested AND/OR nodes inside a top-level `.not`
- **WHEN** `normalize` is called
- **THEN** normalization SHALL complete without stack overflow and produce a fully NNF-transformed tree with all negations at the leaves
