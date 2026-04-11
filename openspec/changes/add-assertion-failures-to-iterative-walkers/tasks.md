## 1. Iterative walker assertions

- [x] ~~1.1 Add `assertionFailure` to `default` branch in first `iterativeIsSatisfied` overload~~ N/A: `default` branch is intentional — tests use custom Expression types (TruthyNode, FalsyNode)
- [x] ~~1.2 Add `assertionFailure` to `default` branch in second `iterativeIsSatisfied` overload~~ N/A: same reason
- [x] ~~1.3 Add `assertionFailure` to `default` branch in `iterativePhrases`~~ N/A: Expression protocol is open, external conformers need the fallback

## 2. Parser loop assertion

- [x] 2.1 Add token position check in `parseExpression` while loop to assert `parsePrimary` consumed at least one token (Parser.swift ~line 48)

## 3. Verification

- [x] 3.1 Run `swift test` to confirm all 179 tests still pass
