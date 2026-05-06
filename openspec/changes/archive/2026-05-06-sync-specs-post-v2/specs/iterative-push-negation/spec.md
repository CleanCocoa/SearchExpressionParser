## REMOVED Requirements

### Requirement: Iterative pushNegation produces identical trees to recursive pushNegation

**Reason**: The function `pushNegation` no longer exists. The only NNF entry point is `normalize(_ expression: Expression) -> Expression` in `Sources/SearchExpressionParser/NormalForm/Normalize.swift`. This requirement compares two implementations that have both been retired in favor of the current `normalize` function.

**Migration**: See `negation-normal-form/spec.md` (rewritten by this change to describe the actual two-phase iterative algorithm in `Normalize.swift`).

### Requirement: No depth limit

**Reason**: The "no depth limit" claim about `pushNegation` referred to a function that is gone. The replacement function `normalize(_:)` likewise has no depth limit; `negation-normal-form/spec.md` carries the depth-limit-free property.

**Migration**: See `negation-normal-form/spec.md`, requirements on iterative normalization.

### Requirement: O(1) call stack depth for normalization

**Reason**: The constraint applies to a function (`pushNegation` / `normalizedEvaluable`) that no longer exists. The replacement `normalize(_:)` is also iterative with O(1) call stack depth; that property belongs in `negation-normal-form/spec.md`.

**Migration**: See `negation-normal-form/spec.md`, requirements on iterative normalization. The 512KB-stack scenario is no longer reproduced — it described thread-local-stack behavior of a removed function and is not a contract this library makes.

### Requirement: Non-NOT nodes pass through unchanged

**Reason**: This is a structural property of any NNF transform and applies equally to `normalize(_:)`. The leaf-passthrough and NOT-on-leaf-preserved behaviors are part of `negation-normal-form/spec.md`'s contract.

**Migration**: See `negation-normal-form/spec.md`, requirements on NNF semantics.
