## Why

The `ExpressionEvaluator` protocol and `StringContainmentEvaluator` ship with the expression-enum change, but callers of v1 also relied on `ContainmentEvaluator.phrases()` for highlight extraction -- removed in the expression-enum change. `PhraseExtractor` restores this functionality using the new protocol.

## What Changes

- Add `PhraseExtractor: ExpressionEvaluator` with `Result == [String]`. Collects positive containment strings from expression trees. Returns `[string]` for `evaluateContains`, `[]` for `evaluateKeyValue`/`evaluateAnything`/`evaluateNot`, `lhs + rhs` for `evaluateAnd`/`evaluateOr`.

## Capabilities

### New Capabilities
- `phrase-extractor`: `PhraseExtractor` struct for collecting positive containment phrases from an expression tree.

### Modified Capabilities

## Impact

- New public API: `PhraseExtractor` struct.
- Depends on `Expression` enum and `ExpressionEvaluator` protocol (expression-enum change).
- `PhraseExtractor` replaces `ContainmentEvaluator.phrases()` when used after `normalize()`.
