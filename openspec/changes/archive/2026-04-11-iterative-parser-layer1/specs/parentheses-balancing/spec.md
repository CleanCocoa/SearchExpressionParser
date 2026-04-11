## MODIFIED Requirements

### Requirement: Pre-Parse Transformation

The system SHALL apply parentheses balancing to the token array during `Parser.init`, before any parsing occurs. The `balanceParentheses` function receives the raw token array and returns a transformed array where all remaining `OpeningParens`/`ClosingParens` tokens are guaranteed to be properly paired. The implementation SHALL use O(1) call stack depth regardless of input size or nesting depth.

#### Scenario: Non-Parenthesis Tokens Pass Through Unchanged

- **GIVEN** a token array containing only non-parenthesis tokens (e.g., `[Phrase("asd"), Phrase("def")]`)
- **WHEN** balanceParentheses is applied
- **THEN** the token array is returned unchanged

#### Scenario: Empty Input

- **GIVEN** an empty token array
- **WHEN** balanceParentheses is applied
- **THEN** an empty token array is returned

### Requirement: Nested Balanced Parens

The system SHALL support nested balanced parentheses at arbitrary depth, using O(1) call stack depth regardless of nesting depth.

#### Scenario: Two Levels of Nesting

- **GIVEN** the token array `[OpeningParens, OpeningParens, ClosingParens, ClosingParens]`
- **WHEN** balanceParentheses is applied
- **THEN** all tokens are returned unchanged

#### Scenario: Complex Nested Structure

- **GIVEN** the token array `[OpeningParens, OpeningParens, Word("a"), ClosingParens, Word("b"), OpeningParens, Word("c"), ClosingParens, ClosingParens]`
- **WHEN** balanceParentheses is applied
- **THEN** all tokens are returned unchanged, preserving the outer group containing two inner groups

#### Scenario: Deep nesting does not overflow

- **GIVEN** a token array with 10,000 nested `OpeningParens` followed by a word followed by 10,000 `ClosingParens`
- **WHEN** balanceParentheses is applied
- **THEN** all pairs are preserved without stack overflow
