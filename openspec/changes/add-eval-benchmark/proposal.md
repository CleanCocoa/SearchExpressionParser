## Why

PRD section A.7 requires two benchmark tests to validate the <5ms performance target for 1,000 tokens. Only `testPerformance_Parse1000Tokens` exists. The full pipeline benchmark (`testPerformance_ParseAndEval1000Tokens`) is missing.

## What Changes

- Add `testPerformance_ParseAndEval1000Tokens` to `StackOverflowTests.swift` that benchmarks parsing 1,000 tokens and evaluating the resulting expression tree via `isSatisfied(by:)`.

## Capabilities

### New Capabilities

- `eval-benchmark`: Performance benchmark test for the full parse+evaluate pipeline at 1,000 tokens

### Modified Capabilities

## Impact

- `Tests/SearchExpressionParserTests/StackOverflowTests.swift`: one new test method added
