## Context

SearchExpressionParser shipped 2.0.0 on 2026-04-30. Several refactors had landed in v2 (`Expression` enum collapse, `ExpressionEvaluator` protocol replacing `isSatisfied`, iterative tree walks replacing recursive ones, key-value tokens) and each landed via the OpenSpec workflow. But the broader cross-capability cleanup never happened: `architecture`, `overview`, and `expression-evaluation` describe v1 protocol-and-`*Node`-types; `phrase-extraction` was left in place when `phrase-extractor` superseded it; the four `iterative-*` capabilities were tracked separately during the recursion-removal epic but are now indistinguishable from the host capabilities they augment.

A drift audit (parallel review across tokenization, parsing, evaluation, normal-form, and architecture clusters) confirmed: every drift is in spec text, not in code. The library does what these specs *should* describe; the specs just describe an earlier version. Pure-rename drift (v1 type names, platform numbers) was already handled in four direct-edit commits before this proposal. What remains is structural: capability retirements, full rewrites, and targeted requirement-level corrections — work that benefits from being recorded as an explicit change.

## Goals / Non-Goals

**Goals:**
- Bring `openspec/specs/` into agreement with the current code.
- Retire capabilities whose content is fully described elsewhere or whose underlying API has been removed, so future readers don't have to triangulate between three overlapping specs.
- Fold any live constraints from retired capabilities into the host capability that owns the relevant code.
- Leave an audit trail (this change) so the post-v2 sync moment is recorded.

**Non-Goals:**
- No code changes. The library is unchanged.
- No new capabilities. Every v2 feature already has a spec.
- No relitigating of previous design decisions (e.g. enum-vs-protocol, recursive-vs-iterative). Those landed; this is bookkeeping.
- No expansion of test coverage. The new "fold-forward" stress scenarios (10k bangs, 10k unmatched parens) describe behavior whose existence we need to assert in spec; whether matching tests already exist or need to be added is a separate concern handled in the test-coverage pass, not in this change.

## Decisions

### Decision 1: Use OpenSpec for the structural drift but not for the rename-only drift

The mechanical Class A renames (v1 `*Node` types → enum cases, `KeyValue` → `KeyValueToken`, `[CChar]` → `Expression.CString`, test-file path) landed as four direct-edit commits before this proposal. **Rationale**: an OpenSpec MODIFIED-Requirement delta for a pure name swap is high ceremony (an entire requirement block reproduced verbatim with one token changed) and contributes nothing to the audit trail beyond what `git log` already provides. The structural changes here — capability retirements, vocabulary migrations, full rewrites — *do* benefit from per-capability review, so they go through OpenSpec.

**Alternative considered**: a single mega-change covering everything. Rejected because the rename deltas would dwarf the structural deltas and bury the actually-informative content.

**Alternative considered**: many small focused changes (one per refactor). Rejected because the structural changes are tightly coupled (`expression-evaluation` rewrite implies `architecture` rewrite implies `overview` rewrite), and the change-proposal ceremony of three or four parallel changes would outweigh the benefit.

### Decision 2: Retire `iterative-*` capabilities entirely; fold live constraints into host capabilities

The `iterative-*` capabilities were introduced to track the recursion-removal refactoring epic. Now that the refactor has fully landed, three options exist: (a) keep them as architectural-property capabilities ("the parser SHALL be iterative"), (b) merge each into its host capability so the property attaches to the relevant requirement, (c) delete them. Investigation (sonnet subagents on each) confirmed: most of their content is either redundant with the host capability or is historical "iterative replaces recursive" framing that's worthless once the refactor has landed. The few live constraints — O(1) call-stack on `evaluate(_:with:)`, trailing-negations-at-scale, `balanceParentheses` O(1) — fold cleanly into `phrase-extractor` and `parsing-grammar`.

**Rationale for (b) over (a)**: an "iterative-evaluation" capability that says "the parser is iterative" gets stale fast and isn't a meaningful contract; the property is a quality of the implementation, attached to its behavior. Putting "uses O(1) call stack depth" inside the requirement that talks about parsing N tokens is more discoverable and harder to drift away from.

### Decision 3: Retire `phrase-extraction` rather than keep both

`phrase-extraction` describes the v1 `PhraseCollectionConvertible` + `ContainmentEvaluator.phrases()` architecture. `phrase-extractor` describes the v2 `PhraseExtractor: ExpressionEvaluator` + `evaluate(_:with:)` model. The two specs were never simultaneously correct — `phrase-extraction` became drift the moment the `builtin-evaluators` change landed. Code-mapping confirmed: there is one file (`PhraseExtractor.swift`, 29 lines) doing what both specs claim to describe.

The only `phrase-extraction`-exclusive substance is "O(1) call stack depth via iterative tree walking" on AND/OR. That constraint actually originated in `iterative-phrases` and is fold-forwarded into `phrase-extractor` from there.

### Decision 4: Retire `architecture`, `overview`, `expression-evaluation` rather than rewrite them

These three specs were spec-gen-generated catalogs whose requirements duplicate what the focused capability specs already describe — but lagging on drift. The original sketch of this change called for rewriting them; on closer reading, every requirement they carry is fully covered by a focused capability spec (`tokenization`, `parsing`, `parsing-grammar`, `expression-data-type`, `expression-evaluator`, `string-containment-evaluator`, `phrase-extractor`, `negation-normal-form`, `parentheses-balancing`, etc.). Keeping a parallel `architecture` or `overview` capability creates a second surface to drift independently every time the focused specs evolve.

**Decision**: REMOVE all three. Each retired requirement's delta points the reader at the focused capability that owns the contract.

**Where navigation goes**: README.md is the right place for cross-capability orientation (the pipeline at-a-glance view, the public entry point). If a more substantial overview is wanted later, it belongs in `docs/` as a plain markdown file — not as an OpenSpec capability spec.

**Alternatives considered**: a slim "architecture" spec keeping only "Three-Stage Pipeline" and "Module Dependency Flow" as genuine cross-capability statements. Rejected because both are already implicit in the per-capability specs (parsing depends on tokenization's `Token` types; phrase-extractor depends on expression-evaluator's protocol) and the implicit form is less likely to drift than a restated form.

## Risks / Trade-offs

- **Risk**: a retained-but-modified spec's MODIFIED block omits a sub-bullet from the original, silently losing detail at archive time → **Mitigation**: each MODIFIED requirement reproduces the full original block first, then applies edits in place. Diff against the original spec before committing.
- **Risk**: a "live constraint" fold-forward into a host capability creates a duplicate of something already implied by the host's existing requirements → **Mitigation**: the per-capability investigations already classified each iterative-* requirement as REDUNDANT / HISTORICAL / LIVE; only LIVE constraints are folded. The `phrase-extractor` O(1) constraint and the `parsing-grammar` `balanceParentheses` constraint are confirmed not present in their host capabilities today.
- **Risk**: archived changes (`openspec/changes/archive/2026-04-11-iterative-*`) link to the now-retired capability names → **Mitigation**: archives are historical records, not live links. Validation does not traverse the archive. Future readers see the archived proposal still calling the capability "iterative-parsing"; that's accurate as a historical statement.
- **Trade-off**: this proposal doesn't relitigate whether `phrase-extractor` is a better name than `phrase-extraction`. The `builtin-evaluators` proposal already chose `phrase-extractor`; we keep that decision rather than reopening it.

## Test Strategy

No code or test changes. The new stress scenarios in `parsing-grammar` (10k bangs, 10k unmatched parens, 10k balanced nests) and the new O(1) scenario in `phrase-extractor` describe behavior the implementation already exhibits — but verifying that *tests* exist for each scenario is a separate concern handled by the `spec-coverage` skill against the post-archive specs. If coverage gaps surface, they get filed as a follow-up `add-coverage-*` change.
