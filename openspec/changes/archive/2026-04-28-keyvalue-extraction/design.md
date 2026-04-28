## Context

After parsing, callers like The Archive v2's NoteDiscoveryFeature need to know which keys appear in a query to determine which indices to prepare. This is a pre-flight inspection step that runs before evaluation.

## Goals / Non-Goals

**Goals:**
- Provide a simple function to extract all key-value pairs from any expression tree
- Handle all tree shapes: nested AND/OR/NOT, duplicates, deeply nested trees

**Non-Goals:**
- Deduplication of key-value pairs (callers can deduplicate if needed)
- Filtering by specific keys (callers filter the returned array)

## Decisions

**Implemented as a fold using ExpressionEvaluator**: The function can be implemented internally using a private evaluator with `Result == [(key: String, value: String)]`. `evaluateKeyValue` returns a single-element array, `evaluateContains`/`evaluateAnything` return `[]`, `evaluateNot` passes through, `evaluateAnd`/`evaluateOr` concatenate. This reuses the iterative tree walk from `evaluate(_:with:)` and avoids a separate traversal implementation.

**Returns all occurrences including duplicates**: `tag:foo AND tag:foo` returns two entries. Callers decide whether to deduplicate. This preserves positional information and keeps the function simple.

**Traverses through NOT**: `NOT tag:foo` still returns `("tag", "foo")`. The caller needs to know the key is referenced even if negated, to prepare the tag index for evaluation.

## Risks / Trade-offs

**No structural context**: The returned array loses information about whether a key-value was negated or which branch of an OR it appeared in. This is acceptable for the intended use case (index preparation).
