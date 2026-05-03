## MODIFIED Requirements

### Requirement: Unary NOT/Bang Binds to Immediately Following Primary

The `!` and `NOT` unary operators SHALL negate only the immediately following primary expression (a single term or a parenthesized group), producing `.not(inner)`. The parser SHALL handle arbitrarily long chains of consecutive negation operators without stack overflow, using O(1) call stack depth.

#### Scenario: Bang before single phrase
- **GIVEN** the token list `[UnaryOperator.bang, Phrase("foo")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `.not(.contains("foo"))`

#### Scenario: NOT before single phrase
- **GIVEN** the token list `[UnaryOperator.not, Phrase("foo")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `.not(.contains("foo"))`

#### Scenario: NOT does not extend past immediate primary
- **GIVEN** the token list `[NOT, Phrase("a"), OR, Phrase("b"), Phrase("c")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `.or(.not(.contains("a")), .and(.contains("b"), .contains("c")))`

#### Scenario: Two negated phrases with implicit AND
- **GIVEN** the token list `[UnaryOperator.bang, Phrase("foo"), Phrase("bar")]`
- **WHEN** the parser produces an expression
- **THEN** the result SHALL be `.and(.not(.contains("foo")), .contains("bar"))`

#### Scenario: 10,000 chained bangs parse without stack overflow
- **WHEN** the parser receives 10,000 `UnaryOperator.bang` tokens followed by a single `Phrase`
- **THEN** parsing SHALL complete successfully

#### Scenario: Trailing negations at scale
- **WHEN** the parser receives 10,000 `UnaryOperator.bang` tokens with no following primary
- **THEN** parsing SHALL complete successfully, with the last `!` becoming `.contains("!")` and all preceding ones becoming `.not(...)` wrappers, without stack overflow

### Requirement: Unbalanced Parentheses Are Converted to Words

Before parsing, the `balanceParentheses` pre-processing step SHALL replace unmatched opening or closing parenthesis tokens with `Word` tokens containing the parenthesis character. Only balanced pairs remain as structural tokens. The `balanceParentheses` function SHALL process tokens iteratively using an explicit index stack, with O(1) call stack depth regardless of input length or nesting depth.

#### Scenario: Unmatched closing paren at root level
- **GIVEN** a closing parenthesis token with no preceding opener
- **WHEN** parenthesis balancing runs
- **THEN** the closing paren token SHALL be replaced with `Word(")")`

#### Scenario: Unmatched opening paren with no closer
- **GIVEN** an opening parenthesis token with no subsequent closer
- **WHEN** parenthesis balancing runs
- **THEN** the opening paren token SHALL be replaced with `Word("(")`

#### Scenario: 10,000 unmatched opening parens balance without stack overflow
- **WHEN** `balanceParentheses` receives 10,000 `OpeningParens` tokens with no closers
- **THEN** all 10,000 SHALL be converted to `Word("(")` tokens without stack overflow

#### Scenario: 10,000 balanced nested parens balance without stack overflow
- **WHEN** `balanceParentheses` receives 10,000 `OpeningParens` tokens followed by a word followed by 10,000 `ClosingParens` tokens
- **THEN** all pairs SHALL be preserved as structural tokens without stack overflow
