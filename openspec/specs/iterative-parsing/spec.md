# Iterative Parsing Specification

> Synced from change iterative-parser-layer1 on 2026-04-11

## Purpose

The parser builds expression trees iteratively with O(1) call stack depth, handling arbitrarily long token sequences without stack overflow. This covers iterative binary operator collection and right-fold, iterative negation collection, iterative parenthesis balancing, and bounded paren nesting depth.

## Requirements

### Requirement: Binary Operator Parsing Uses O(1) Call Stack

The parser SHALL parse sequences of binary operators (explicit AND, explicit OR, implicit AND) using iterative collection and right-fold, without recursive function calls between `parseExpression` and `parseBinaryOperator`. The call stack depth SHALL NOT grow with the number of tokens.

#### Scenario: 10,000 implicit AND tokens parse without stack overflow
- **WHEN** the parser receives 10,000 single-character word tokens separated by spaces
- **THEN** parsing SHALL complete successfully producing a right-leaning `AndNode` tree of depth 9,999

#### Scenario: 10,000 explicit AND tokens parse without stack overflow
- **WHEN** the parser receives 10,000 word tokens joined by `BinaryOperator.and`
- **THEN** parsing SHALL complete successfully producing a right-leaning `AndNode` tree

#### Scenario: 10,000 explicit OR tokens parse without stack overflow
- **WHEN** the parser receives 10,000 word tokens joined by `BinaryOperator.or`
- **THEN** parsing SHALL complete successfully producing a right-leaning `OrNode` tree

#### Scenario: Mixed operators at scale
- **WHEN** the parser receives 10,000 tokens with alternating AND and OR operators
- **THEN** parsing SHALL complete successfully with the same tree shape as the recursive parser would produce

### Requirement: Negation Parsing Uses O(1) Call Stack

The parser SHALL parse sequences of consecutive unary negation operators (`!`, `NOT`) iteratively, without recursive calls between `parseNegation` and `parsePrimary`. The call stack depth SHALL NOT grow with the number of consecutive negation operators.

#### Scenario: 10,000 chained bang operators parse without stack overflow
- **WHEN** the parser receives 10,000 `UnaryOperator.bang` tokens followed by a single `Phrase`
- **THEN** parsing SHALL complete successfully producing 10,000 nested `NotNode` layers wrapping one `ContainsNode`

#### Scenario: Trailing negations at scale
- **WHEN** the parser receives 10,000 `UnaryOperator.bang` tokens with no following primary
- **THEN** parsing SHALL complete successfully, with the last `!` becoming `ContainsNode("!")` and all preceding ones becoming `NotNode` wrappers

### Requirement: Parenthesis Balancing Uses O(1) Call Stack

The `balanceParentheses` function SHALL process parenthesis tokens iteratively using an explicit stack data structure, without recursive function calls. The call stack depth SHALL NOT grow with the number or nesting depth of parenthesis tokens.

#### Scenario: 10,000 nested opening parens balance without stack overflow
- **WHEN** `balanceParentheses` receives a token array with 10,000 `OpeningParens` tokens and no `ClosingParens`
- **THEN** all 10,000 SHALL be converted to `Phrase("(")` tokens without stack overflow

#### Scenario: 10,000 balanced nested parens balance without stack overflow
- **WHEN** `balanceParentheses` receives 10,000 `OpeningParens` followed by a word followed by 10,000 `ClosingParens`
- **THEN** all pairs SHALL be preserved as `OpeningParens`/`ClosingParens` without stack overflow

### Requirement: Parenthesized Group Parsing Has Bounded Recursion Depth

The parser SHALL limit the nesting depth of parenthesized groups. When a parenthesized expression exceeds the depth limit, the parser SHALL throw `ParseError.parenNestingTooDeep`.

#### Scenario: Moderate nesting within limit
- **WHEN** the parser receives an expression with 50 levels of nested parentheses
- **THEN** parsing SHALL complete successfully

#### Scenario: Excessive nesting exceeds limit
- **WHEN** the parser receives an expression with 200 levels of nested parentheses
- **THEN** the parser SHALL throw `ParseError.parenNestingTooDeep`

### Requirement: Right-Fold Produces Identical Trees

The iterative collect-and-fold-right algorithm SHALL produce expression trees identical to those produced by the recursive descent parser for all inputs. The operator following a term determines the node type: `BinaryOperator.or` produces `OrNode`, all other cases (explicit AND, implicit AND, nil) produce `AndNode`.

#### Scenario: Fold preserves right-associativity
- **WHEN** the parser receives `[Phrase("a"), Phrase("b"), Phrase("c")]`
- **THEN** the result SHALL be `AndNode(a, AndNode(b, c))`, not `AndNode(AndNode(a, b), c)`

#### Scenario: Fold preserves operator semantics
- **WHEN** the parser receives `[Phrase("a"), OR, Phrase("b"), AND, Phrase("c")]`
- **THEN** the result SHALL be `OrNode(a, AndNode(b, c))`

#### Scenario: Fold handles trailing operator
- **WHEN** the parser receives `[Phrase("a"), BinaryOperator.and]`
- **THEN** the result SHALL be `AndNode(ContainsNode("a"), ContainsNode("AND"))`

## Technical Notes
- **Implementation**: `Sources/SearchExpressionParser/Parsing/Parser.swift`
- **Dependencies**: Tokenization domain (Token protocol, all token types)
