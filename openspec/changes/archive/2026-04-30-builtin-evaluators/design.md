## Context

v1 provided string containment via `isSatisfied(by:)` on expression nodes and phrase extraction via `ContainmentEvaluator.phrases()`. Both were removed in the expression-enum change. The evaluator-protocol change introduced `ExpressionEvaluator` as the generic evaluation mechanism. This change provides two concrete evaluators that restore the removed functionality.

## Goals / Non-Goals

**Goals:**
- Provide `StringContainmentEvaluator` as a drop-in replacement for v1's `isSatisfied(by:)` string containment
- Provide `PhraseExtractor` as a replacement for `ContainmentEvaluator.phrases()`
- Both evaluators work with `evaluate(_:with:)` from the evaluator-protocol change

**Non-Goals:**
- Locale-aware or custom matching strategies (callers can write their own evaluators)
- Automatic normalization before phrase extraction (callers call `normalize()` explicitly)

## Decisions

**StringContainmentEvaluator stores both String and CString haystack**: Mirrors v1's dual-path approach. The `evaluateContains` method uses `strstr(haystackCString, needle)` for performance. The `haystack` String is available for callers who wrap or extend the evaluator.

**StringContainmentEvaluator.evaluateKeyValue returns false**: Key-value nodes cannot be evaluated by string containment. Returning `false` is explicit: "this evaluator does not handle key-value predicates." Callers needing key-value support write their own evaluator.

**PhraseExtractor.evaluateNot returns empty array**: Negated terms are excluded from highlight phrases. This matches v1's `ContainmentEvaluator.phrases()` behavior after normalization. Callers should call `normalize()` before `PhraseExtractor` to push negations to leaves.

**PhraseExtractor.evaluateAnd/evaluateOr concatenate arrays**: Both AND and OR branches contribute candidate phrases. `x AND y` means both must match (both are highlight candidates). `x OR y` means either could match (both are highlight candidates). This matches v1 behavior.

## Risks / Trade-offs

**PhraseExtractor without normalize gives incomplete results**: If NOT wraps an AND/OR, the entire subtree's phrases are dropped. This is correct but callers must remember to normalize first. Documented in the type's doc comment.
