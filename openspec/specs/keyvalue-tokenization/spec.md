# KeyValue Tokenization Specification

> Synced from change keyvalue-tokenization-parsing on 2026-04-23

## Purpose

The tokenizer recognizes `key:value` patterns and emits a dedicated `KeyValue` token type. Key-value tokens carry a `key` and a `value` string, support quoted values (including escaped quotes), and interoperate with the existing word/phrase/operator tokens. Backslash-escaped patterns and patterns with whitespace before the colon fall back to plain word tokens.

## Requirements

### Requirement: KeyValue token type

The system SHALL provide a `KeyValue` token type conforming to `Token` with `key: String` and `value: String` properties.

#### Scenario: KeyValue token string representation

- **WHEN** a `KeyValue` token has key `"tag"` and value `"bar"`
- **THEN** its `string` property SHALL be `"tag:bar"`

### Requirement: Basic key-value recognition

The tokenizer SHALL recognize `key:value` patterns where the key is one or more word characters followed immediately by `:` and the value is one or more word characters.

#### Scenario: Simple key-value

- **WHEN** tokenizing `"tag:bar"`
- **THEN** the result SHALL be a single `KeyValue` token with key `"tag"` and value `"bar"`

#### Scenario: Key-value in expression

- **WHEN** tokenizing `"foo tag:bar"`
- **THEN** the result SHALL be a `Word("foo")` token followed by a `KeyValue` token with key `"tag"` and value `"bar"`

### Requirement: Quoted key-value recognition

The tokenizer SHALL recognize `key:"quoted value"` patterns where the value is a quoted phrase.

#### Scenario: Quoted value

- **WHEN** tokenizing `tag:"hello world"`
- **THEN** the result SHALL be a single `KeyValue` token with key `"tag"` and value `"hello world"`

#### Scenario: Quoted value with escape

- **WHEN** tokenizing `tag:"hello \"world\""`
- **THEN** the result SHALL be a single `KeyValue` token with key `"tag"` and value `hello "world"`

### Requirement: Escaped key-value produces word

The tokenizer SHALL treat `\key:value` (backslash before the key) as a plain word token containing `key:value`.

#### Scenario: Backslash-escaped key-value

- **WHEN** tokenizing `\tag:bar`
- **THEN** the result SHALL be a single `Word` token with string `"tag:bar"`

### Requirement: Space before colon produces separate tokens

The tokenizer SHALL treat `key :value` (space before colon) as two separate tokens, not a key-value token.

#### Scenario: Space before colon

- **WHEN** tokenizing `"key :value"`
- **THEN** the result SHALL be a `Word("key")` token followed by a `Word(":value")` token

### Requirement: Multi-colon key-value

The tokenizer SHALL treat multi-colon patterns like `a:b:c` as key `"a"` and value `"b:c"` -- the key is everything before the first colon.

#### Scenario: Multiple colons

- **WHEN** tokenizing `"url:http://example.com"`
- **THEN** the result SHALL be a `KeyValue` token with key `"url"` and value `"http://example.com"`

## Technical Notes

- **Implementation**: `Sources/SearchExpressionParser/Tokenization/`
- **Dependencies**: Tokenizer pipeline, TokenCharacterBuffer, TokenExtractor protocol
