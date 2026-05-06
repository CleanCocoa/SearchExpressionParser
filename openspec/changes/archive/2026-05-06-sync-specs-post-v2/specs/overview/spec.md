## REMOVED Requirements

### Requirement: Public Entry Point

**Reason**: Fully described by `parsing/spec.md`'s "Parser return type" requirement, which specifies the `Parser.parse(searchString:)` static method signature.

**Migration**: See `parsing/spec.md`.

### Requirement: Tokenization

**Reason**: Fully described by `tokenization/spec.md` and the focused tokenization-cluster specs (`word-tokenization`, `quoted-phrases`, `operator-recognition`, `keyvalue-tokenization`, `whitespace-handling`).

**Migration**: See `tokenization/spec.md` for the umbrella, and the focused specs for token-type details.

### Requirement: Parentheses Balancing

**Reason**: Fully described by `parentheses-balancing/spec.md`.

**Migration**: See `parentheses-balancing/spec.md`.

### Requirement: Expression Tree Construction

**Reason**: The five-node-type list described here is factually stale (v2 has six cases on a single `Expression` enum, not five separate node structs). Tree construction is fully described by `parsing/spec.md` and `parsing-grammar/spec.md`; the data type is described by `expression-data-type/spec.md`.

**Migration**: See `parsing/spec.md`, `parsing-grammar/spec.md`, and `expression-data-type/spec.md`.

### Requirement: Expression Evaluation

**Reason**: This requirement describes the v1 `Expression` protocol with `isSatisfied(by:)` methods on each node. None of that exists in v2. The current evaluation contract is described by `expression-evaluator/spec.md` (the protocol and dispatch function) and `string-containment-evaluator/spec.md` (the canonical Boolean evaluator).

**Migration**: See `expression-evaluator/spec.md` and `string-containment-evaluator/spec.md`.

### Requirement: Phrase Extraction and Normalization

**Reason**: This requirement describes the v1 `ContainmentEvaluator` + `PhraseCollectionConvertible` model that no longer exists. v2 splits the concerns: normalization is `normalize(_:)` (described by `negation-normal-form/spec.md`); extraction is `evaluate(_:with: PhraseExtractor())` (described by `phrase-extractor/spec.md`). Composing them is the caller's responsibility.

**Migration**: See `negation-normal-form/spec.md` and `phrase-extractor/spec.md`. The composition pattern (call `normalize` first, then `evaluate(_:with: PhraseExtractor())`) is documented in `phrase-extractor/spec.md`'s "Full extraction via evaluate function" requirement.

## NOTE

This delta retires the entire `overview` capability. None of its content is lost — every requirement is fully covered by a focused capability spec that already exists. The `overview` capability was a spec-gen-generated catalog that became a duplicate surface to drift independently. README.md is the right place for narrative-level orientation; a capability spec is not. If a more substantial overview-style document is wanted in the future, it belongs in `docs/` (a plain markdown file), not as an OpenSpec capability.
