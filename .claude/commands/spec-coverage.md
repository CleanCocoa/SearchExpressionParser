---
name: "Spec Coverage"
description: "Verify that OpenSpec scenarios are covered by annotated tests. Use when checking spec-to-test traceability, before merging spec or test changes, or when asked about test coverage gaps."
---

Verify spec-to-test coverage by running the enforcement script and presenting results.

**Input**: Optional arguments after `/spec-coverage`:
- (none) — run full coverage check
- `--fix` — run check, then offer to write missing tests for uncovered scenarios
- `--drift` — check for scenarios whose annotations may be stale (test function was deleted/renamed)

## Steps

1. **Run the coverage script**

   ```bash
   bash scripts/check-spec-coverage.sh
   ```

   Parse the output to extract:
   - Total scenario count and covered count
   - List of uncovered scenario slugs
   - List of orphaned annotations

2. **Present results**

   Show a summary table:

   ```
   ## Spec Coverage: N/M (X%)

   | Spec | Scenarios | Covered | Gaps |
   |------|-----------|---------|------|
   ```

   If all covered: congratulate and stop.

   If gaps exist: list each uncovered slug with its spec file location and the GIVEN/WHEN/THEN text from the spec. This context helps understand what test is missing.

   If orphaned annotations exist: list each with its test file location. These are `/// @spec` comments referencing scenarios that no longer exist in the specs — either the spec was updated or the annotation has a typo.

3. **If `--fix` was requested**

   For each uncovered scenario:
   - Read the scenario from the spec file
   - Read the corresponding test file to understand existing patterns
   - Identify the code path being tested (from the spec's Technical Notes)
   - Write a new test function with the `/// @spec` annotation
   - Follow the existing test style in that file (XCTest patterns, helper usage)

   After writing all tests:
   - Run `swift test` to verify they pass
   - Run `scripts/check-spec-coverage.sh` to confirm coverage improved

4. **If `--drift` was requested**

   For each `/// @spec` annotation found in test files:
   - Verify the referenced scenario still exists in the spec
   - Verify the test function still exists (hasn't been renamed/deleted)
   - Check if the test body still plausibly covers what the scenario describes (read the test and the scenario, flag obvious mismatches)

   Report any drift found.

## Annotation Format

Tests use `/// @spec <spec-name>/<requirement-slug>/<scenario-slug>` comments above test functions. Multiple annotations per test are allowed. Multiple tests per scenario are allowed.

Specs can exempt scenarios from coverage with `<!-- @nocover: reason -->` on the `#### Scenario:` line.

## Guardrails

- Never modify spec files
- When writing tests with `--fix`, follow existing test patterns exactly
- Run `swift test` after any test changes to verify they compile and pass
- If a test fails, investigate and fix before moving on
