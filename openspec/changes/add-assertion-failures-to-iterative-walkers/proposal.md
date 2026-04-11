## Why

The iterative walkers (`iterativeIsSatisfied`, `iterativePhrases`) have `default` branches that silently fall back to recursive protocol dispatch for unknown Expression types. If a new Expression type is added without updating the iterative walkers, the stack overflow protection is silently bypassed. `assertionFailure` in these branches turns a future silent regression into a loud failure during development.

Similarly, the `parseExpression` while loop depends on `parsePrimary` always consuming at least one token. If a future edit breaks that invariant, the loop hangs silently. An assertion after `parsePrimary` can guard against this.

## What Changes

- Replace `default` fallback-to-recursion branches in `iterativeIsSatisfied` (both overloads) and `iterativePhrases` with `assertionFailure` + the existing fallback
- Add a token-consumption assertion in the `parseExpression` while loop to detect non-progress

## Capabilities

### New Capabilities

- `iterative-walker-assertions`: assertionFailure guards in iterative tree walkers and parser loop

### Modified Capabilities

## Impact

- `Sources/.../Parsing/Expressions.swift`: both `iterativeIsSatisfied` overloads, `default` case
- `Sources/.../NormalForm/PhraseCollectionConvertible.swift`: `iterativePhrases`, `default` case
- `Sources/.../Parsing/Parser.swift`: `parseExpression` while loop, token consumption guard
