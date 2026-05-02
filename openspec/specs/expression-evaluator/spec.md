# Expression Evaluator Specification

> Synced from change expression-enum on 2026-04-22

## Purpose

`ExpressionEvaluator` is the protocol for evaluating `Expression` trees into any result type. A free `evaluate(_:with:)` function performs an iterative stack-based tree walk and dispatches each node to the appropriate evaluator method. Boolean short-circuit evaluation is built in for `Bool`-typed evaluators.

## Requirements

### Requirement: ExpressionEvaluator protocol

The system SHALL provide a public `ExpressionEvaluator` protocol with `associatedtype Result` and six required methods: `evaluateContains(_ string: String, cString: Expression.CString) -> Result`, `evaluateKeyValue(key: String, value: String) -> Result`, `evaluateAnything() -> Result`, `evaluateNot(_ inner: Result) -> Result`, `evaluateAnd(_ lhs: Result, _ rhs: Result) -> Result`, `evaluateOr(_ lhs: Result, _ rhs: Result) -> Result`.

#### Scenario: Protocol requires all six methods

- **WHEN** a type conforms to `ExpressionEvaluator` without implementing all six methods
- **THEN** the compiler SHALL emit an error for each missing method

### Requirement: Boolean defaults extension

The system SHALL provide a protocol extension for `ExpressionEvaluator where Result == Bool` with default implementations: `evaluateNot(_ inner: Bool) -> Bool` returns `!inner`, `evaluateAnd(_ lhs: Bool, _ rhs: Bool) -> Bool` returns `lhs && rhs`, `evaluateOr(_ lhs: Bool, _ rhs: Bool) -> Bool` returns `lhs || rhs`, `evaluateAnything() -> Bool` returns `true`. No default SHALL be provided for `evaluateContains` or `evaluateKeyValue`.

#### Scenario: Bool evaluator only needs leaf methods

- **WHEN** a type conforms to `ExpressionEvaluator` with `Result == Bool` and implements only `evaluateContains` and `evaluateKeyValue`
- **THEN** the compiler SHALL accept the conformance using extension defaults for not/and/or/anything

#### Scenario: evaluateNot negates

- **WHEN** `evaluateNot(true)` is called using the default
- **THEN** the result SHALL be `false`

#### Scenario: evaluateAnd conjuncts

- **WHEN** `evaluateAnd(true, false)` is called using the default
- **THEN** the result SHALL be `false`

#### Scenario: evaluateOr disjuncts

- **WHEN** `evaluateOr(false, true)` is called using the default
- **THEN** the result SHALL be `true`

#### Scenario: evaluateAnything returns true

- **WHEN** `evaluateAnything()` is called using the default
- **THEN** the result SHALL be `true`

### Requirement: Evaluate function

The system SHALL provide a public free function `evaluate<E: ExpressionEvaluator>(_ expression: Expression, with evaluator: E) -> E.Result` that performs an iterative stack-based tree walk over the expression, dispatching each node to the corresponding evaluator method.

#### Scenario: Leaf node dispatch

- **WHEN** `evaluate(.anything, with: evaluator)` is called
- **THEN** the evaluator's `evaluateAnything()` SHALL be called and its result returned

#### Scenario: Contains node dispatch

- **WHEN** `evaluate(.contains(string: "x", cString: cstring), with: evaluator)` is called
- **THEN** the evaluator's `evaluateContains("x", cString: cstring)` SHALL be called and its result returned

#### Scenario: NOT node dispatch

- **WHEN** `evaluate(.not(.anything), with: evaluator)` is called
- **THEN** the evaluator SHALL first evaluate the inner expression, then pass the result to `evaluateNot`

#### Scenario: AND node dispatch

- **WHEN** `evaluate(.and(lhs, rhs), with: evaluator)` is called
- **THEN** the evaluator SHALL evaluate both branches and pass results to `evaluateAnd`

#### Scenario: OR node dispatch

- **WHEN** `evaluate(.or(lhs, rhs), with: evaluator)` is called
- **THEN** the evaluator SHALL evaluate both branches and pass results to `evaluateOr`

### Requirement: AND short-circuit for Bool

The `evaluate` function SHALL short-circuit `.and` evaluation when `Result == Bool`: if the left branch evaluates to `false`, the right branch SHALL NOT be evaluated and the result SHALL be `false`.

#### Scenario: AND short-circuits on false left

- **WHEN** `evaluate(.and(falseExpr, rhs), with: boolEvaluator)` is called where `falseExpr` evaluates to `false`
- **THEN** the result SHALL be `false` and `rhs` SHALL NOT be evaluated

### Requirement: OR short-circuit for Bool

The `evaluate` function SHALL short-circuit `.or` evaluation when `Result == Bool`: if the left branch evaluates to `true`, the right branch SHALL NOT be evaluated and the result SHALL be `true`.

#### Scenario: OR short-circuits on true left

- **WHEN** `evaluate(.or(trueExpr, rhs), with: boolEvaluator)` is called where `trueExpr` evaluates to `true`
- **THEN** the result SHALL be `true` and `rhs` SHALL NOT be evaluated

### Requirement: Iterative traversal

The `evaluate` function SHALL use O(1) call stack depth regardless of expression tree depth. The implementation SHALL use an explicit stack data structure.

#### Scenario: Deep tree does not overflow call stack

- **WHEN** `evaluate` is called with an expression tree of depth 10,000
- **THEN** evaluation SHALL complete without stack overflow

## Technical Notes
- **Implementation**: `Sources/SearchExpressionParser/ExpressionEvaluator.swift`
- **Dependencies**: `Expression` enum
