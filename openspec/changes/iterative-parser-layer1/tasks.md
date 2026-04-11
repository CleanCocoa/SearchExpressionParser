## 1. Iterative `balanceParentheses`

- [x] 1.1 Replace recursive `balanceParentheses(tokens:start:)` and `Balance` enum with iterative single-pass using index stack. Keep internal function signature `balanceParentheses(tokens: [Token]) -> [Token]` unchanged.
- [x] 1.2 Verify all 12 `BalanceParenthesesTests` pass with identical output
- [x] 1.3 Verify `testNestedParens_10000` stress test passes (previously crashed during balancing)

## 2. Iterative binary operator parsing

- [x] 2.1 Rewrite `parseExpression` to collect `(expression, followingOperator)` pairs in a while loop instead of recursing into `parseBinaryOperator`
- [x] 2.2 Implement `foldRight` to build the right-leaning tree from collected terms, mapping `BinaryOperator.or` -> `OrNode`, all else -> `AndNode`
- [x] 2.3 Handle trailing operator edge case: when operator consumed but `tokenBuffer` is at end, append `ContainsNode(token: operator)` as final term
- [x] 2.4 Handle `ClosingParens` boundary: stop collection when next token is `)`, consume it, then fold
- [x] 2.5 Delete `parseBinaryOperator` method (logic absorbed into `parseExpression` loop)
- [x] 2.6 Verify all 31 `ParserTests` pass with identical tree output
- [x] 2.7 Verify `testImplicitAND_10000`, `testExplicitAND_10000`, `testExplicitOR_10000` stress tests pass

## 3. Iterative negation parsing

- [x] 3.1 In `parsePrimary`, replace `parseNegation` dispatch with a while loop collecting consecutive `UnaryOperator` tokens
- [x] 3.2 After collecting negations, parse the base primary (parens or contains node) and wrap in `NotNode` layers
- [x] 3.3 Handle trailing negation edge case: if no tokens remain after collecting, pop last operator as `ContainsNode(token:)`, wrap rest as `NotNode`
- [x] 3.4 Delete `parseNegation` method (logic absorbed into `parsePrimary`)
- [x] 3.5 Verify all negation-related `ParserTests` pass (bang, NOT, trailing, lone, combined with parens)
- [x] 3.6 Verify `testChainedBangs_10000` stress test passes

## 4. Paren nesting depth limit

- [x] 4.1 Add `ParseError.parenNestingTooDeep` case to the internal `ParseError` enum
- [x] 4.2 Thread `depth` parameter through `parseExpression` -> `parsePrimary` -> `parseOpeningParens` -> `parseExpression(depth: depth + 1)`
- [x] 4.3 In `parseOpeningParens`, throw `.parenNestingTooDeep` when `depth > 100`
- [x] 4.4 Verify `testNestedParens_100` (within limit) still passes
- [x] 4.5 Verify `testNestedParensAND_5000` now throws instead of crashing
- [x] 4.6 Update `StackOverflowTests` for nested parens vectors: deep nesting should throw, not crash

## 5. Final verification

- [x] 5.1 Run full test suite (`swift test` excluding stack overflow crash tests) — all 127 original tests pass
- [x] 5.2 Run all passing StackOverflow stress tests — parsing vectors at 10,000 tokens pass
- [x] 5.3 Add benchmark test: parse + fold 1,000 implicit-AND tokens, verify <5ms in `measure {}` block
