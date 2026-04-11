## ADDED Requirements

### Requirement: Parse-and-evaluate benchmark at 1,000 tokens
The test suite SHALL include a performance benchmark that parses 1,000 implicit-AND tokens and evaluates the resulting expression tree via `isSatisfied(by:)`.

#### Scenario: Benchmark completes without crash
- **WHEN** `testPerformance_ParseAndEval1000Tokens` runs with 1,000 implicit-AND words
- **THEN** the parse and evaluate pipeline completes within the XCTest `measure` block without crash or timeout
