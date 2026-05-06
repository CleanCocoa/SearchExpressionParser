## REMOVED Requirements

### Requirement: Three-Stage Pipeline

**Reason**: The pipeline shape (Tokenization → Parsing → Evaluation/Normalization) is the natural cross-capability arrangement implied by the existence of the focused capability specs themselves. Restating it in an `architecture` capability creates a second surface to drift independently. README.md serves as the navigational entry point.

**Migration**: See `tokenization/spec.md`, `parsing/spec.md`, `expression-evaluator/spec.md`, and `negation-normal-form/spec.md` for the per-stage contracts. README.md describes the pipeline at a glance.

### Requirement: Tokenization Module

**Reason**: Fully described by `tokenization/spec.md`.

**Migration**: See `tokenization/spec.md`.

### Requirement: TokenExtractor Protocol

**Reason**: Fully described by `tokenization/spec.md` (and `operator-recognition/spec.md` for priority ordering).

**Migration**: See `tokenization/spec.md` and `operator-recognition/spec.md`.

### Requirement: Token Types

**Reason**: Fully described by `tokenization/spec.md`, `quoted-phrases/spec.md`, `word-tokenization/spec.md`, `operator-recognition/spec.md`, `keyvalue-tokenization/spec.md`, and `parentheses-balancing/spec.md`.

**Migration**: See the focused tokenization-cluster specs listed above.

### Requirement: Either Monad for Error Handling

**Reason**: This is an internal implementation detail (`Either<T, E>` is used inside the tokenizer for extractor results) rather than an externally-observable capability. If retained anywhere, it belongs as part of `tokenization/spec.md`'s implementation notes — not as a freestanding requirement.

**Migration**: None required. The `Either` type remains in `Sources/SearchExpressionParser/Either.swift` as internal infrastructure.

### Requirement: Parenthesis Balancing

**Reason**: Fully described by `parentheses-balancing/spec.md`.

**Migration**: See `parentheses-balancing/spec.md`.

### Requirement: Recursive Descent Parser

**Reason**: Fully described by `parsing/spec.md` and `parsing-grammar/spec.md`. Note: the description in this requirement (which talks about `AnythingNode`/`AndNode`/`NotNode` and recursive descent) is also factually stale post-v2; the v2 capability specs are the current truth.

**Migration**: See `parsing/spec.md` and `parsing-grammar/spec.md`.

### Requirement: TokenBuffer Abstraction

**Reason**: Internal implementation detail of the parser, not an externally-observable capability. Documented by `Parsing/TokenBuffer.swift` itself.

**Migration**: None required. `TokenBuffer` remains an internal type used by `Parser`.

### Requirement: Expression Tree Nodes

**Reason**: Fully described by `expression-data-type/spec.md`. The list in this requirement is also factually stale (refers to five `*Node` structs conforming to an `Expression` protocol; the actual code has a six-case `Expression` enum including `.keyValue`).

**Migration**: See `expression-data-type/spec.md`.

### Requirement: Negation Normal Form

**Reason**: Fully described by `negation-normal-form/spec.md`. The description here references `ContainmentEvaluator.normalizedEvaluable()`, which no longer exists; `normalize(_:)` is the current entry point.

**Migration**: See `negation-normal-form/spec.md`.

### Requirement: Phrase Extraction

**Reason**: Fully described by `phrase-extractor/spec.md`. The description here references `PhraseCollectionConvertible`, which no longer exists.

**Migration**: See `phrase-extractor/spec.md`.

### Requirement: Module Dependency Flow

**Reason**: The dependency-flow assertion is implicit in the per-capability specs (e.g. `parsing` depends on `tokenization`'s `Token` types; `phrase-extractor` depends on `expression-evaluator`'s protocol). Documenting it here as a separate requirement creates duplication that drifts independently.

**Migration**: None required for the contract — the implicit dependencies are visible in the focused capability specs and in the Swift module structure. If a navigational diagram is wanted, it belongs in README.md or `docs/`, not in a capability spec.

## NOTE

This delta retires the entire `architecture` capability. None of its content is lost — every requirement is fully covered by a focused capability spec that already exists. The `architecture` capability was a spec-gen-generated catalog of requirements that became a duplicate surface to drift independently from the focused specs. The current code's architecture is documented at the right level by the per-capability specs and at the navigational level by README.md; an architecture capability spec sits awkwardly between the two and adds no contract not already established elsewhere.
