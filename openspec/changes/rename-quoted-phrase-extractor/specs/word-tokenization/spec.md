## MODIFIED Requirements

### Requirement: Quotation Marks Break Word Boundaries

The system SHALL treat `"` as a word boundary delimiter. An unescaped quotation mark terminates the current word and begins phrase extraction via QuotedPhraseExtractor.

#### Scenario: Quoted phrase after words

- **GIVEN** the input string `called "  another "`
- **WHEN** the tokenizer processes the input
- **THEN** the word `called` is separate from the phrase, producing `[Word("called"), Phrase("  another ")]`

### Requirement: Fallback Extractor Ordering

The system SHALL try WordExtractor last in the extractor pipeline, after OpeningParensExtractor, ClosingParensExtractor, QuotedPhraseExtractor, BangExtractor, NotExtractor, AndExtractor, and OrExtractor. WordExtractor serves as the wildcard fallback.

#### Scenario: Extractor ordering <!-- @nocover: structural property, not runtime behavior -->

- **GIVEN** the default tokenizer configuration
- **WHEN** the extractor list is initialized
- **THEN** WordExtractor is the last entry in the list
