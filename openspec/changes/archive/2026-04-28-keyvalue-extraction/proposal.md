## Why

Callers need to inspect parsed expression trees before evaluation to determine which indices are needed (e.g., if a query contains `tag:foo`, the tag index must be consulted). A dedicated inspection function extracts all key-value pairs from the tree without requiring a full evaluation pass.

## What Changes

- Add a public free function `keyValueNodes(in expression: Expression) -> [(key: String, value: String)]` that collects all `.keyValue` leaves from an expression tree, traversing through `.and`, `.or`, and `.not` nodes.

## Capabilities

### New Capabilities
- `keyvalue-extraction`: The `keyValueNodes(in:)` inspection function for extracting key-value pairs from expression trees.

### Modified Capabilities

## Impact

- New public API: `keyValueNodes(in:)` free function.
- Depends on `Expression` enum with `.keyValue` case (from expression-enum and keyvalue-tokenization-parsing changes).
- May internally use `ExpressionEvaluator` as an implementation detail, or use direct recursion/iteration.
