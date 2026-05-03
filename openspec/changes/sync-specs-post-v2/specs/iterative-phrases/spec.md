## REMOVED Requirements

### Requirement: Iterative phrases produces identical output to recursive phrases

**Reason**: Historical framing — compares the iterative implementation to the now-removed recursive implementation. The recursive code is gone; the comparison is no longer meaningful.

**Migration**: See `phrase-extractor/spec.md` for the live phrase-extraction contract.

### Requirement: Left-to-right phrase ordering

**Reason**: Implied by `phrase-extractor/spec.md`'s `evaluateAnd`/`evaluateOr` requirements, which return `lhs + rhs` (Swift array concatenation, left-to-right by definition). The scenarios under those requirements verify the resulting order.

**Migration**: See `phrase-extractor/spec.md`, `evaluateAnd` and `evaluateOr` requirements and their AND/OR composition scenarios.

### Requirement: O(1) call stack depth for phrase extraction

**Reason**: This is the one live constraint from `iterative-phrases`. It is folded forward as an ADDED requirement in this change's `phrase-extractor` delta, anchored on `evaluate(_:with:)` (the iterative machinery in `ExpressionEvaluator.swift`) rather than on the `PhraseExtractor` struct.

**Migration**: See this change's `phrase-extractor` delta — the ADDED "O(1) call stack depth on evaluate(_:with:)" requirement and the 10,000-node stress scenario.

### Requirement: NotNode subtrees produce no phrases

**Reason**: Already covered by `phrase-extractor/spec.md`'s requirement that `evaluateNot` returns `[]`, with a corresponding scenario.

**Migration**: See `phrase-extractor/spec.md`, requirement on `evaluateNot` returning `[]`.
