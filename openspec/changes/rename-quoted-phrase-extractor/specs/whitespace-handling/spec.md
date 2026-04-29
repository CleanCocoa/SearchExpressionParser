## MODIFIED Requirements

### Requirement: Whitespace Inside Quoted Phrases Is Preserved

Whitespace within quotation marks SHALL NOT be stripped or collapsed. The `QuotedPhraseExtractor` preserves all characters (including whitespace) between opening and closing quotation marks verbatim.

#### Scenario: Quoted phrase with internal whitespace

- **GIVEN** an input string `"\"  fair   play \""`
- **WHEN** the tokenizer produces tokens
- **THEN** the result SHALL be `[Phrase("  fair   play ")]` with internal whitespace preserved
