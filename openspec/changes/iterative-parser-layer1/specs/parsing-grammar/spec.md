## ADDED Requirements

### Requirement: Paren Nesting Depth Limit

The parser SHALL enforce a maximum depth for nested parenthesized groups. When the nesting depth exceeds the limit, the parser SHALL throw `ParseError.parenNestingTooDeep`. The limit SHALL be at least 100 levels.

#### Scenario: Within depth limit
- **WHEN** the parser receives an expression with 50 levels of nested parentheses containing a single term
- **THEN** parsing SHALL complete successfully producing a valid expression tree

#### Scenario: Exceeds depth limit
- **WHEN** the parser receives an expression with nesting depth exceeding the limit
- **THEN** the parser SHALL throw `ParseError.parenNestingTooDeep`

## MODIFIED Requirements

### Requirement: Implicit AND for Adjacent Terms

The parser SHALL produce an `AndNode` joining two terms when they appear adjacently with no explicit operator between them. The parser SHALL handle arbitrarily long sequences of adjacent terms without stack overflow, using O(1) call stack depth.

#### Scenario: Two adjacent phrases
- **GIVEN** the token list `[Phrase("foo"), Phrase("bar")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `AndNode(ContainsNode("foo"), ContainsNode("bar"))`

#### Scenario: Three adjacent phrases are right-associative
- **GIVEN** the token list `[Phrase("foo"), Phrase("bar"), Phrase("baz")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `AndNode(ContainsNode("foo"), AndNode(ContainsNode("bar"), ContainsNode("baz")))`

#### Scenario: Six adjacent phrases produce right-leaning tree
- **GIVEN** the token list `[Phrase("1"), Phrase("2"), Phrase("3"), Phrase("4"), Phrase("5"), Phrase("6")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `AndNode(ContainsNode("1"), AndNode(ContainsNode("2"), AndNode(ContainsNode("3"), AndNode(ContainsNode("4"), AndNode(ContainsNode("5"), ContainsNode("6"))))))`

#### Scenario: 10,000 adjacent phrases parse without stack overflow
- **WHEN** the parser receives 10,000 single-character word tokens
- **THEN** parsing SHALL complete successfully producing a right-leaning `AndNode` tree

### Requirement: Unary NOT/Bang Binds to Immediately Following Primary

The `!` and `NOT` unary operators SHALL negate only the immediately following primary expression (a single term or a parenthesized group), producing a `NotNode`. The parser SHALL handle arbitrarily long chains of consecutive negation operators without stack overflow, using O(1) call stack depth.

#### Scenario: Bang before single phrase
- **GIVEN** the token list `[UnaryOperator.bang, Phrase("foo")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `NotNode(ContainsNode("foo"))`

#### Scenario: NOT before single phrase
- **GIVEN** the token list `[UnaryOperator.not, Phrase("foo")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `NotNode(ContainsNode("foo"))`

#### Scenario: NOT does not extend past immediate primary
- **GIVEN** the token list `[NOT, Phrase("a"), OR, Phrase("b"), Phrase("c")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `OrNode(NotNode(ContainsNode("a")), AndNode(ContainsNode("b"), ContainsNode("c")))`

#### Scenario: Two negated phrases with implicit AND
- **GIVEN** the token list `[UnaryOperator.bang, Phrase("foo"), Phrase("bar")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `AndNode(NotNode(ContainsNode("foo")), ContainsNode("bar"))`

#### Scenario: 10,000 chained bangs parse without stack overflow
- **WHEN** the parser receives 10,000 `UnaryOperator.bang` tokens followed by a single `Phrase`
- **THEN** parsing SHALL complete successfully
