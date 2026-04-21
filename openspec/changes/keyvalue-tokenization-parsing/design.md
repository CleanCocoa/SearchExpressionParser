## Context

The tokenizer uses a chain of `TokenExtractor` implementations tried in order. The `WordExtractor` currently consumes any non-whitespace, non-parens, non-quote characters as a word, including colons. A new `KeyValueExtractor` must run before `WordExtractor` to intercept `key:value` patterns before they are consumed as plain words.

The existing escape mechanism (`\` before a character) is handled in `WordExtractor` by skipping the backslash and consuming the next character. The same mechanism handles `\key:value` -- the backslash before a word character prevents key-value recognition.

## Goals / Non-Goals

**Goals:**
- Recognize `key:value` as a key-value token
- Recognize `key:"multi word"` as a key-value token with quoted value
- Produce `\key:value` as a plain word `key:value`
- Keep `key :value` as two separate tokens
- Add `.keyValue` case to `Expression` enum
- Parser produces `.keyValue` nodes that compose with AND/OR/NOT/parentheses

**Non-Goals:**
- Hardcoding known keys (all `key:value` patterns are treated uniformly)
- Evaluating key-value nodes (handled by evaluators)
- Nested key-value syntax or multi-colon patterns like `a:b:c`

## Decisions

**KeyValueExtractor runs before WordExtractor**: The extractor checks for `word_chars + : + (word_chars | quoted_string)` pattern. If the pattern does not match (e.g., lone `:` or `:value` without key), the extractor returns no match and `WordExtractor` handles it as before.

**KeyValue token type**: A new `KeyValue` struct conforming to `Token` with `key: String` and `value: String` properties. The `string` property returns `"\(key):\(value)"` for display.

**Colon is not a word-break for plain words**: Existing behavior where `foo:bar` is consumed as a single word by `WordExtractor` is replaced by `KeyValueExtractor` intercepting it. For patterns that look like key-value but where the extractor passes (e.g., the extractor could fail on edge cases), `WordExtractor` still consumes the whole thing as a word. But by design, `KeyValueExtractor` handles all `word:word` and `word:"phrase"` patterns.

**Multi-colon handling**: `a:b:c` is recognized as key `a`, value `b:c` -- the key is everything before the first colon, the value is everything after. This follows standard URI/HTTP header conventions.

**Test strategy**: Tokenizer tests verify token types for key-value, escaped, and edge cases. Parser tests verify `.keyValue` nodes in boolean expressions.

## Risks / Trade-offs

**Existing queries with colons change behavior**: A v1 query `foo:bar` previously produced `ContainsNode("foo:bar")`. In v2 it produces `.keyValue(key: "foo", value: "bar")`. This is intentional and breaking (2.0). Users who want literal `foo:bar` containment use `\foo:bar`.
