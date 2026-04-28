# Reviewer prompt skeletons

Spawn each reviewer via the Agent tool with `subagent_type: "general-purpose"` and `model: "haiku"`. All four go in the same message so they run concurrently.

The variable parts you need to fill in for every prompt:

- `<NAME>` — change name (e.g., `keyvalue-extraction`)
- `<SHAS>` — implementer commit SHAs in chronological order, comma-separated
- `<BASELINE>` — test count before this change
- `<NEW_TOTAL>` — test count after this change
- `<DELTA_FILES>` — list of paths under `openspec/changes/<name>/specs/` and the implementer's source/test files

The output format is the same for all four reviewers — bucket findings as **MUST FIX**, **SHOULD FIX**, or **NIT** and end with either "Ready to archive — no blockers." or a numbered list of blockers.

---

## 1. Spec drift reviewer

```
Audit OpenSpec change `<NAME>` for spec drift, scenario coverage, and validation. Do NOT implement — report only.

Implementation commits: <SHAS>. Test count went from <BASELINE> to <NEW_TOTAL>.

Steps:
1. Run `openspec validate <NAME> --strict` and `openspec validate <NAME> --strict --type spec`. Report failures.
2. Read every delta spec under `openspec/changes/<NAME>/specs/`. For each SHALL/MUST scenario, search the test files for an annotation or test name that hits it. Trace explicitly — name the test that covers the scenario.
3. Flag any SHALL with no test. Flag any test that asserts behavior the spec does not require.
4. Compare delta specs against the corresponding `openspec/specs/<capability>/spec.md` files (where they exist). Note what would change at sync time.
5. Verify the implementer did NOT modify any file under `openspec/specs/` or `openspec/changes/<NAME>/specs/` (those are read-only). Use `git show <SHA>` for each commit.

Bucket findings as MUST FIX / SHOULD FIX / NIT. End with "Ready to archive — no blockers." or a numbered blocker list. Under 400 words.
```

---

## 2. Code quality reviewer

```
Review code quality of OpenSpec change `<NAME>`. Do NOT implement — report only.

Implementation commits: <SHAS>. Use `git show <SHA>` to inspect each.

Look for:
1. Dead code, unused symbols, unreachable branches.
2. Comments that explain WHAT the code does (project rule: no comments unless asked — flag every one). WHY-comments for non-obvious constraints are fine.
3. Hacky patterns: parameter sprawl (functions growing many params instead of being restructured), copy-paste with slight variation, leaky abstractions, redundant state, stringly-typed code where an enum or constant would do, nested conditionals 3+ levels deep.
4. Files placed in surprising directories (check the existing project layout for the convention).
5. Public APIs that should be internal, or vice versa.
6. Force-unwraps, force-casts, `!` on optionals at non-boundary code.
7. New abstractions introduced for hypothetical future requirements rather than the task at hand.

Bucket findings as MUST FIX / SHOULD FIX / NIT. MUST FIX is reserved for code that is wrong (compiles but does the wrong thing) or violates an explicit project rule. End with "Ready to archive — no blockers." or a numbered blocker list. Under 400 words.
```

---

## 3. Test quality reviewer

```
Review test quality of OpenSpec change `<NAME>`. Do NOT implement — report only.

Implementation commits: <SHAS>. Test count went from <BASELINE> to <NEW_TOTAL>.

Steps:
1. Run `swift test` and confirm green. If red, that's an immediate MUST FIX.
2. For each new test in this change, judge:
   - Does it assert something meaningful, or just mirror the implementation?
   - Are edge cases covered (empty input, boundary values, error paths) — or only the happy path?
   - Are tests independent (no shared mutable state, no order dependencies)?
   - Are test names descriptive of the behavior, or just `test1`, `test2`?
3. Look for missing test categories: if the implementation handles a case the spec calls out, there should be a test for it.
4. Flag tests that pass trivially (e.g., asserting `true == true` after setup, or `XCTAssertNotNil` on a value that's always non-nil).
5. Flag duplicated test setup that should be a helper.

Bucket findings as MUST FIX / SHOULD FIX / NIT. Red tests are always MUST FIX. End with "Ready to archive — no blockers." or a numbered blocker list. Under 400 words.
```

---

## 4. Security reviewer

```
Review security of OpenSpec change `<NAME>`. Do NOT implement — report only.

Implementation commits: <SHAS>. Use `git show <SHA>` to inspect.

Look for:
1. Input that crosses a system boundary (file I/O, parsed strings from outside the process, command construction) without validation.
2. Unsafe APIs: `system()`-style shell invocation, raw pointer arithmetic without bounds checks, force-unwraps on attacker-controlled values, manual C-string handling that could buffer-overrun, regex with user input without anchoring/escaping.
3. Injection risks: SQL, shell, command, format-string, path traversal.
4. Memory safety in any `withUnsafe*` blocks — bounds, lifetimes, escaping pointers.
5. Sensitive data: hardcoded secrets, credentials, tokens, PII written to logs.
6. Concurrency hazards: data races on mutable shared state, missing synchronization on `nonisolated(unsafe)`.

Most OpenSpec changes will have nothing to flag. A clean report ("no findings") is a useful signal — say so plainly.

Bucket findings as MUST FIX / SHOULD FIX / NIT. End with "Ready to archive — no blockers." or a numbered blocker list. Under 300 words.
```
