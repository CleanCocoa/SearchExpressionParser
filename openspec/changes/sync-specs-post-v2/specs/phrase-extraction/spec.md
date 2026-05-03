## REMOVED Requirements

### Requirement: ContainsNode contributes its string as a phrase

**Reason**: The capability `phrase-extraction` describes the v1 `PhraseCollectionConvertible` architecture, which was replaced by `phrase-extractor` in the `builtin-evaluators` change (archived 2026-04-30). The current code has one type, `PhraseExtractor: ExpressionEvaluator`, that fulfills this behavior; that contract is described by `phrase-extractor/spec.md`.

**Migration**: See `phrase-extractor/spec.md`, requirement "Phrase extractor evaluator". `evaluateContains` returns `[string]` for the single-leaf case.

### Requirement: AnythingNode contributes no phrases

**Reason**: Same as above — covered by `phrase-extractor/spec.md`.

**Migration**: See `phrase-extractor/spec.md`, requirement on `evaluateAnything` returning `[]`.

### Requirement: NotNode contributes no phrases

**Reason**: Same as above — covered by `phrase-extractor/spec.md`.

**Migration**: See `phrase-extractor/spec.md`, requirement on `evaluateNot` returning `[]`.

### Requirement: AndNode concatenates phrases from both children

**Reason**: Same as above — covered by `phrase-extractor/spec.md`. The O(1) call-stack-depth constraint that this requirement carried (originally folded in from `iterative-phrases`) is preserved by an ADDED requirement in this change's `phrase-extractor` delta that anchors the constraint on `evaluate(_:with:)`.

**Migration**: See `phrase-extractor/spec.md`, requirement on `evaluateAnd` returning `lhs + rhs`, plus the ADDED "O(1) call stack depth on evaluate(_:with:)" requirement.

### Requirement: OrNode concatenates phrases from both children

**Reason**: Same as above — covered by `phrase-extractor/spec.md`.

**Migration**: See `phrase-extractor/spec.md`, requirement on `evaluateOr` returning `lhs + rhs`, plus the ADDED "O(1) call stack depth on evaluate(_:with:)" requirement.

### Requirement: Runtime type casting for child nodes

**Reason**: This requirement describes a v1-only mechanism (`as? PhraseCollectionConvertible`) that no longer applies. `Expression` is now a six-case enum and the `ExpressionEvaluator` protocol dispatches exhaustively over those cases. There is no "non-conforming child" concept in v2.

**Migration**: None needed. The behavior — that nodes with no phrase contribution produce `[]` — is preserved structurally by `evaluateAnything` / `evaluateNot` / `evaluateKeyValue` returning `[]`.

### Requirement: ContainmentEvaluator normalizes before collecting phrases

**Reason**: `ContainmentEvaluator` no longer exists. Normalization is no longer baked into a phrase-extraction entry point; it is the caller's responsibility to call `normalize(_:)` before `evaluate(_:with: PhraseExtractor())` if NNF semantics are wanted.

**Migration**: Callers wanting NNF-then-extract semantics should call `normalize(expression)` (described in `negation-normal-form/spec.md`) and pass the result to `evaluate(_:with: PhraseExtractor())` (described in `phrase-extractor/spec.md`).
