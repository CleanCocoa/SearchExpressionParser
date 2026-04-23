## Why

The Archive v2's search needs structured queries like `tag:bar` and `title:"hello world"` that dispatch to specific indices (tag index, title index) rather than full-text search. The tokenizer and parser must recognize `key:value` patterns and produce `.keyValue` expression nodes so the evaluator layer can dispatch them appropriately.

## What Changes

- Add `KeyValue` token type to the tokenization layer.
- Add `KeyValueExtractor` to the tokenizer that recognizes `key:value` and `key:"quoted value"` patterns.
- Backslash-escaped `\key:value` produces a regular word token containing `key:value` (not a key-value token).
- `key :value` (space before colon) remains two separate tokens (word + word).
- Parser produces `.keyValue(key:value:)` for key-value tokens.
- All existing v1 queries produce identical expression trees.

## Capabilities

### New Capabilities
- `keyvalue-tokenization`: Token recognition for `key:value` patterns including quoted values and escape handling.
- `keyvalue-parsing`: Parser production of `.keyValue(key:value:)` expression nodes from key-value tokens.

### Modified Capabilities
- `expression-data-type`: Update exhaustive switches to handle the `.keyValue` case (case added in expression-enum change).

## Impact

- `Expression` enum gains a new case. Existing exhaustive switches in consumer code will get compiler errors (intentional for 2.0).
- Tokenizer gains a new extractor that runs before `WordExtractor` to intercept `key:value` patterns.
- Parser gains handling for `KeyValue` tokens as primary expressions.
- No existing query behavior changes.
