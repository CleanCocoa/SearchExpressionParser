## ADDED Requirements

### Requirement: Parser produces keyValue nodes

The parser SHALL produce `.keyValue(key:value:)` expression nodes for `KeyValue` tokens.

#### Scenario: Simple key-value parses to keyValue node

- **WHEN** `Parser.parse(searchString: "tag:bar")` is called
- **THEN** the result SHALL be `.keyValue(key: "tag", value: "bar")`

#### Scenario: Key-value with quoted value

- **WHEN** `Parser.parse(searchString: "title:\"hello world\"")` is called
- **THEN** the result SHALL be `.keyValue(key: "title", value: "hello world")`

### Requirement: Key-value in boolean expressions

Key-value nodes SHALL compose with all existing operators.

#### Scenario: NOT key-value

- **WHEN** `Parser.parse(searchString: "NOT tag:bar")` is called
- **THEN** the result SHALL be `.not(.keyValue(key: "tag", value: "bar"))`

#### Scenario: Key-value OR key-value

- **WHEN** `Parser.parse(searchString: "tag:foo OR tag:bar")` is called
- **THEN** the result SHALL be `.or(.keyValue(key: "tag", value: "foo"), .keyValue(key: "tag", value: "bar"))`

#### Scenario: Mixed contains and key-value with AND

- **WHEN** `Parser.parse(searchString: "hello tag:bar")` is called
- **THEN** the result SHALL be `.and(.contains("hello"), .keyValue(key: "tag", value: "bar"))`

#### Scenario: Parenthesized key-value

- **WHEN** `Parser.parse(searchString: "hello (tag:a AND tag:b)")` is called
- **THEN** the result SHALL be `.and(.contains("hello"), .and(.keyValue(key: "tag", value: "a"), .keyValue(key: "tag", value: "b")))`

### Requirement: Escaped key-value produces contains

The parser SHALL produce `.contains` for backslash-escaped key-value patterns.

#### Scenario: Escaped key-value

- **WHEN** `Parser.parse(searchString: "\\tag:bar")` is called
- **THEN** the result SHALL be `.contains("tag:bar")`

### Requirement: Backward compatibility

All v1 queries without colons SHALL produce identical expression trees.

#### Scenario: Plain words unchanged

- **WHEN** `Parser.parse(searchString: "foo bar")` is called
- **THEN** the result SHALL be `.and(.contains("foo"), .contains("bar"))` (same as v1)

#### Scenario: Operators unchanged

- **WHEN** `Parser.parse(searchString: "foo AND bar OR baz")` is called
- **THEN** the result SHALL match the v1 tree structure
