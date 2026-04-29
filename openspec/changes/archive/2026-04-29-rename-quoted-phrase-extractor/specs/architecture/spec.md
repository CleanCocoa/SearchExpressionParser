## MODIFIED Requirements

### Requirement: Tokenization Module

The Tokenizer SHALL convert a raw `String` into an array of `Token` values by iterating a `TokenCharacterBuffer` against a priority-ordered chain of `TokenExtractor` implementations.

#### Scenario: Character buffer consumption

- **GIVEN** a search string input
- **WHEN** the Tokenizer processes it
- **THEN** a `TokenCharacterBuffer` SHALL be created from the string, providing `peekNext`, `consume`, and `resetTo` operations over both original and lowercased character arrays

#### Scenario: Extractor chain ordering

- **GIVEN** the default extractor chain
- **WHEN** token extraction occurs
- **THEN** extractors SHALL be tried in priority order: `OpeningParensExtractor`, `ClosingParensExtractor`, `QuotedPhraseExtractor`, `BangExtractor`, `NotExtractor`, `AndExtractor`, `OrExtractor`, `WordExtractor` (wildcard, always last)

#### Scenario: Extractor selection

- **GIVEN** a buffer position and the extractor chain
- **WHEN** the Tokenizer calls `next(buffer:extractors:)`
- **THEN** each extractor's `matchesPreconditions(_:)` SHALL be checked first, and only matching extractors SHALL attempt `extract(_:)`. The first successful extraction SHALL be returned.

#### Scenario: Whitespace handling

- **GIVEN** whitespace characters between tokens
- **WHEN** the Tokenizer advances
- **THEN** whitespace SHALL be skipped before each extraction attempt
