## 1. Baseline

- [x] 1.1 Run `swift build` and `swift test`; record green baseline (expect 241/241 passing).

## 2. Rename type and file

- [x] 2.1 ~~Write a failing test~~ — N/A: pure rename, behavior unchanged. Existing tokenizer tests already cover the type's behavior under its old name and remain the regression net.
- [x] 2.2 `git mv Sources/SearchExpressionParser/Tokenization/TokenExtractor/PhraseExtractor.swift Sources/SearchExpressionParser/Tokenization/TokenExtractor/QuotedPhraseExtractor.swift`.
- [x] 2.3 In the renamed file, change `internal struct PhraseExtractor: TokenExtractor` to `internal struct QuotedPhraseExtractor: TokenExtractor`.
- [x] 2.4 Update the call site in `Sources/SearchExpressionParser/Tokenization/Tokenizer.swift` extractor priority list: `PhraseExtractor()` → `QuotedPhraseExtractor()`.
- [x] 2.5 Update `SearchExpressionParser.xcodeproj/project.pbxproj` to reference the new filename and type identifier.
- [x] 2.6 Run `rg PhraseExtractor` repo-wide and confirm remaining hits are only: (a) inside `openspec/specs/**` Technical Notes / spec-gen headers (out of scope), (b) inside `openspec/changes/**` (proposals / specs / tasks), (c) inside `docs/**` historical documents.
- [x] 2.7 `swift build` clean. `swift test` reports 241/241 green. Commit: `refactor: rename internal PhraseExtractor to QuotedPhraseExtractor`.

## 3. Verify

- [x] 3.1 Run `openspec validate rename-quoted-phrase-extractor --strict`; expect "is valid".
- [x] 3.2 Final `swift test` confirming 241/241 still green.
