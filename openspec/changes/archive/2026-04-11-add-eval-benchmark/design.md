## Context

The iterative evaluation implementation is complete. PRD A.7 specifies two benchmark tests to validate <5ms performance at 1,000 tokens. `testPerformance_Parse1000Tokens` exists; `testPerformance_ParseAndEval1000Tokens` does not.

## Goals / Non-Goals

**Goals:**
- Add a `measure {}` benchmark test that parses 1,000 implicit-AND tokens and evaluates the tree via `isSatisfied(by:)`

**Non-Goals:**
- Changing the existing benchmark test
- Adding benchmarks for other operations (phrases, pushNegation)

## Decisions

- Place in `StackOverflowTests.swift` after the existing parse benchmark, before the eval vector section
- Reuse the existing `implicitANDWords(count:)` helper for input generation
- Use `"hello world"` as the satisfiable string (matches PRD pseudocode)
- Parse once outside `measure {}`, evaluate inside (isolates eval performance)

## Risks / Trade-offs

- XCTest `measure` baselines are machine-dependent; CI environments may have different absolute times. The test validates no regression, not an absolute threshold.
