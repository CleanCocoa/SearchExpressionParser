## Why

The upcoming `builtin-evaluators` change introduces a public `struct PhraseExtractor: ExpressionEvaluator` that returns `[String]` (highlight phrase candidates from a parsed expression tree). The codebase already has an `internal struct PhraseExtractor: TokenExtractor` under `Tokenization/TokenExtractor/` that pulls a quoted phrase out of a character buffer during tokenization. Two top-level types with the same name in the same Swift module is a compile error, so one must be renamed before the new evaluator can land. The tokenizer is the older, narrower component and lives in a directory whose other members already use specific prefixes (`AndExtractor`, `OrExtractor`, `BangExtractor`, etc.); `QuotedPhraseExtractor` describes its actual job (extracting a `"..."` literal from input) and frees the bare name `PhraseExtractor` for the cross-tree highlight role.

## What Changes

- Rename internal type `Sources/SearchExpressionParser/Tokenization/TokenExtractor/PhraseExtractor` → `QuotedPhraseExtractor`.
- Rename file `Sources/SearchExpressionParser/Tokenization/TokenExtractor/PhraseExtractor.swift` → `QuotedPhraseExtractor.swift`.
- Update the only call site (`Tokenization/Tokenizer.swift` — extractor priority list) and the Xcode project file references.
- Update spec text in the four affected capability specs that name the type or its file path so they stay in sync with the code.

No behavior changes. No public API surface changes (the renamed type is `internal`). No test changes beyond identifier updates.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `whitespace-handling`: `PhraseExtractor` named inside requirement *Whitespace Inside Quoted Phrases Is Preserved* → `QuotedPhraseExtractor`.
- `word-tokenization`: `PhraseExtractor` named inside requirements *Quotation Marks Break Word Boundaries* and *Fallback Extractor Ordering* → `QuotedPhraseExtractor`.
- `architecture`: `PhraseExtractor` named inside the *Tokenization Module* requirement's extractor priority list → `QuotedPhraseExtractor`.

## Impact

- Affected code: one renamed file plus its call site in `Tokenization/Tokenizer.swift`, plus Xcode project metadata.
- No public API impact (type is `internal`).
- No test behavior change; existing tokenizer tests continue to exercise the renamed type.
- Two main specs (`quoted-phrases/spec.md`, `overview/spec.md`) reference the old file path only in their auto-generated header / Technical Notes — non-requirement metadata. Not addressed by this change's delta specs; will resolve at the next `spec-gen` regeneration cycle.
- Unblocks `builtin-evaluators`, which can then add the new public `PhraseExtractor: ExpressionEvaluator` without a name collision.
