## MODIFIED Requirements

### Requirement: Extractor Priority Order

The system MUST attempt extractors in this fixed order: parens, phrase, bang, NOT, AND, OR, key-value, word. The first extractor whose preconditions match and whose extraction succeeds produces the token. The word extractor acts as a fallback and MUST be attempted last. The key-value extractor sits between OR and word so that bare words like `tag:bar` are recognized as `KeyValueToken` rather than as a `Word("tag:bar")`.

#### Scenario: Ambiguous input resolved by priority

- **GIVEN** the input `!word`
- **WHEN** the tokenizer processes the `!` character
- **THEN** the bang extractor (higher priority than word) matches first, producing `UnaryOperator.bang` followed by `Word("word")`

#### Scenario: key-value sits before word

- **GIVEN** the input `tag:bar`
- **WHEN** the tokenizer processes the input
- **THEN** the key-value extractor matches first (higher priority than word), producing a single `KeyValueToken` with key `"tag"` and value `"bar"`, rather than a `Word("tag:bar")`
