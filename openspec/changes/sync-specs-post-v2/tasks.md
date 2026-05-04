## 1. Sanity-check the deltas before archive

- [x] 1.1 Run `openspec validate sync-specs-post-v2 --strict`; resolve any reported issues
- [x] 1.2 Diff each MODIFIED requirement block against the current `openspec/specs/<capability>/spec.md` to confirm the modification copies the *full* original block (no silent dropping of scenarios or sub-bullets); see `phrase-extractor`, `parsing-grammar`, `negation-normal-form`, `operator-recognition`
- [x] 1.3 Cross-check each REMOVED requirement's **Migration** pointer: open the cited destination spec and confirm the contract is actually present there (not just claimed to be)

## 2. Direct-edit cleanup of preamble drift not covered by deltas

OpenSpec deltas only operate on Requirements; Purpose / Source files / Technical Notes preamble must be patched separately. These edits land alongside the OpenSpec change as `docs(specs):` direct-edit commits.

- [x] 2.1 `parentheses-balancing/spec.md` Technical Notes line 109: replace "private recursive helper with `Balance` enum" with the actual iterative-stack description (Parser.swift:146-167 uses an explicit `[Int]` index stack)
- [x] 2.2 `negation-normal-form/spec.md` Purpose line 9: confirm wording is consistent with the MODIFIED requirements landed by this change ("iterative processing with no recursion limit" is fine; verify nothing else contradicts it)
- [x] 2.3 Do a final `rg` pass across `openspec/specs/` for any remaining `ContainsNode|AndNode|OrNode|NotNode|AnythingNode|isSatisfied|StringExpressionSatisfiable|CStringExpressionSatisfiable|PhraseCollectionConvertible|ContainmentEvaluator|pushNegation|normalizedEvaluable` references; fix any survivors via direct edit (these should be empty after archive completes the REMOVED capabilities and applies the MODIFIED deltas, but a sweep catches anything missed)

## 3. Archive

- [ ] 3.1 Confirm all delta files are present: `openspec/changes/sync-specs-post-v2/specs/{phrase-extraction,iterative-parsing,iterative-evaluation,iterative-phrases,iterative-push-negation,expression-evaluation,architecture,overview,phrase-extractor,parsing-grammar,negation-normal-form,operator-recognition}/spec.md`
- [ ] 3.2 Run `openspec validate sync-specs-post-v2 --strict` one more time
- [ ] 3.3 Run the test suite (`swift test`) — should be unchanged (no code touched), but a green run rules out any incidental regression in the working tree
- [ ] 3.4 Invoke `/opsx:archive` (or `openspec-archive-change` skill) for `sync-specs-post-v2`. Expected effect: the 8 retired capability directories are removed from `openspec/specs/`; the 4 modified capabilities have their requirement blocks rewritten per the deltas
- [ ] 3.5 After archive, verify `openspec/specs/` no longer contains `phrase-extraction/`, `iterative-parsing/`, `iterative-evaluation/`, `iterative-phrases/`, `iterative-push-negation/`, `expression-evaluation/`, `architecture/`, `overview/`
- [ ] 3.6 After archive, verify the 4 modified capability specs reflect the delta content

## 4. Follow-up considerations

- [ ] 4.1 Check whether README.md sufficiently covers the navigational role that `architecture` and `overview` previously played; if not, propose a small `docs/architecture.md` (a plain markdown file, NOT an OpenSpec capability)
- [ ] 4.2 ~~Add tests for the new stress scenarios (10k bangs at trailing position, 10k unmatched/balanced parens, 10k-deep tree on `evaluate(_:with: PhraseExtractor())`, 10k-deep tree on `normalize`)~~ — not in this change. The stress scenarios in the new requirements describe behavior the implementation already exhibits; whether matching tests exist is out of scope here. If `spec-coverage` flags gaps, file a follow-up `add-coverage-stress-scenarios` change.
