## Why

After the v2.0.0 release, an audit found that several `openspec/specs/` capabilities had drifted from the code: they referenced types and protocols that no longer exist (`ContainmentEvaluator`, `PhraseCollectionConvertible`, `StringExpressionSatisfiable`), described retired functions (`pushNegation`), claimed an obsolete platform floor (macOS 10.13 / Swift 5.5), and kept refactoring-epoch capabilities (`iterative-*`) that are now indistinguishable from their host capability's normal description. The mechanical name-level drift (v1 `*Node` types → `Expression` enum cases, `KeyValue` → `KeyValueToken`, `[CChar]` → `Expression.CString`) already landed as direct-edit commits. This change handles the remaining structural drift through the OpenSpec workflow so each affected capability gets a focused per-capability review and an audit trail records that the post-v2 sync happened.

## What Changes

- **Retire 8 capabilities** whose subject matter is now fully described elsewhere or whose underlying API has been removed:
  - `phrase-extraction` — superseded by `phrase-extractor` since the `builtin-evaluators` change.
  - `iterative-parsing` — refactor has landed; properties belong in the host capabilities.
  - `iterative-evaluation` — same.
  - `iterative-phrases` — same.
  - `iterative-push-negation` — `pushNegation()` no longer exists; `normalize()` is the only entry point.
  - `expression-evaluation` — describes the v1 `isSatisfied` / `*Satisfiable` protocol model that no longer exists; v2 evaluation is fully covered by `expression-evaluator`, `string-containment-evaluator`, and `expression-data-type`.
  - `architecture` — spec-gen-generated catalog of requirements that the focused capability specs already describe with current truth. Becomes a duplicate surface to drift. README.md is the right place for navigational orientation.
  - `overview` — same problem. Retire; if a narrative-level overview is wanted later, it belongs in `docs/`, not as a capability spec.
- **Fold-forward live constraints** from the retired capabilities into their hosts:
  - Trailing-negations-at-scale scenario and `balanceParentheses` O(1) call-stack constraint → `parsing-grammar`.
  - O(1) call-stack constraint on `evaluate(_:with:)` with a 10k-node stress scenario → `phrase-extractor`.
- **Targeted corrections** in three capabilities (requirement-level changes only; preamble cleanup handled by direct edit alongside this change):
  - `operator-recognition` — insert `KeyValueExtractor` into the priority-ordered extractor list (Tokenizer.swift currently places it between `OrExtractor` and `WordExtractor`).
  - `negation-normal-form` — fix the "recursively" wording in three requirements that contradicts the iterative implementation, and add an O(1) call-stack-depth requirement folded forward from the retired `iterative-push-negation`.
  - `parentheses-balancing` — Technical Notes drift only ("private recursive helper with `Balance` enum" no longer accurate); fixed via direct edit since OpenSpec deltas only operate on Requirements, not preamble.

This is a spec-text-only change. No code changes, no test changes, no API changes. The library shipped 2.0.0 already; the specs are catching up.

## Capabilities

### New Capabilities

None. Every v2 capability already has a spec (`keyvalue-tokenization`, `keyvalue-parsing`, `keyvalue-extraction`, `phrase-extractor`).

### Modified Capabilities

- `phrase-extraction`: REMOVED — fully covered by `phrase-extractor`.
- `iterative-parsing`: REMOVED — refactor landed; constraints fold into `parsing-grammar`.
- `iterative-evaluation`: REMOVED — fully covered by `expression-evaluator`.
- `iterative-phrases`: REMOVED — refactor landed; constraints fold into `phrase-extractor`.
- `iterative-push-negation`: REMOVED — function no longer exists.
- `expression-evaluation`: REMOVED — v1 protocol model; covered by `expression-evaluator` + `string-containment-evaluator` + `expression-data-type`.
- `architecture`: REMOVED — duplicates focused capability specs; navigation belongs in README.md.
- `overview`: REMOVED — same as `architecture`; narrative orientation belongs in README.md or `docs/`.
- `phrase-extractor`: ADD O(1) call-stack-depth requirement on `evaluate(_:with:)` with 10k-node stress scenario.
- `parsing-grammar`: ADD trailing-negations-at-scale scenario; ADD `balanceParentheses` O(1) constraint with two stress scenarios.
- `negation-normal-form`: MODIFY three requirements to correct "recursively" wording; ADD O(1) call-stack-depth requirement.
- `operator-recognition`: MODIFY Extractor Priority Order to include `KeyValueExtractor`.

## Impact

- **Specs**: 12 capability specs touched (8 removed, 4 modified). No new capabilities.
- **Code, tests, public API**: unchanged.
- **Audit trail**: this proposal records the post-v2 sync moment; future readers can trace which specs were rewritten and why.
- **Risk**: low. The change adds no requirement that the code doesn't already meet (verified via the implementation audit: every retained requirement maps to live code; every retired requirement maps to retired code).
