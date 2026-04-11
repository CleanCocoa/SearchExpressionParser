## 1. Iterative walker assertions

- [ ] 1.1 Add `assertionFailure` to `default` branch in first `iterativeIsSatisfied` overload (Expressions.swift ~line 153)
- [ ] 1.2 Add `assertionFailure` to `default` branch in second `iterativeIsSatisfied` overload (Expressions.swift ~line 198)
- [ ] 1.3 Add `assertionFailure` to `default` branch in `iterativePhrases` (PhraseCollectionConvertible.swift ~line 48)

## 2. Parser loop assertion

- [ ] 2.1 Add token position check in `parseExpression` while loop to assert `parsePrimary` consumed at least one token (Parser.swift ~line 47)

## 3. Verification

- [ ] 3.1 Run `swift test` to confirm all 179 tests still pass
