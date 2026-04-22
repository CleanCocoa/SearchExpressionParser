## 1. Expression Enum Extension

- [x] 1.1 Update any exhaustive switches on `Expression` (evaluate function, etc.) for the `.keyValue` case added in expression-enum

## 2. Key-Value Token Type

- [x] 2.1 Write tests for `KeyValue` token: `key`, `value`, `string` properties
- [x] 2.2 Add `KeyValue` struct conforming to `Token`

## 3. Key-Value Tokenizer Extractor

- [x] 3.1 Write tokenizer tests for basic `key:value` recognition
- [x] 3.2 Write tokenizer tests for quoted value `key:"multi word"`
- [x] 3.3 Write tokenizer tests for escaped `\key:value` producing plain word
- [x] 3.4 Write tokenizer tests for `key :value` (space before colon) producing separate tokens
- [x] 3.5 Write tokenizer tests for multi-colon `a:b:c`
- [x] 3.6 Write tokenizer edge case tests: `key:` (no value), `key:""` (empty quoted), lone `:`, `123:value` (numeric key), `:value` (no key)
- [ ] 3.7 Implement `KeyValueExtractor` conforming to `TokenExtractor`
- [ ] 3.8 Register `KeyValueExtractor` in `Tokenizer` extractor chain before `WordExtractor`

## 4. Parser Key-Value Handling

- [ ] 4.1 Write parser tests for simple key-value: `tag:bar` -> `.keyValue`
- [ ] 4.2 Write parser tests for key-value in boolean expressions: NOT, OR, AND, parentheses
- [ ] 4.3 Write parser tests for escaped key-value: `\tag:bar` -> `.contains`
- [ ] 4.4 Write parser tests for backward compatibility: plain word queries unchanged
- [ ] 4.5 Update parser to handle `KeyValue` tokens as primary expressions producing `.keyValue`
