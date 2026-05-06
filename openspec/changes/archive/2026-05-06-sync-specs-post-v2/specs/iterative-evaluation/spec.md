## REMOVED Requirements

### Requirement: Iterative evaluation produces identical results to recursive evaluation

**Reason**: Historical framing — compares the iterative implementation to the now-removed recursive implementation. The recursive code is gone; the comparison is no longer meaningful. The behavior on deep trees is preserved by `expression-evaluator/spec.md`'s "Stack-based iterative evaluation" requirement and its 10,000-node stress scenario.

**Migration**: See `expression-evaluator/spec.md`, requirement on stack-based iterative evaluation.

### Requirement: Short-circuit evaluation preserved

**Reason**: Already captured verbatim in `expression-evaluator/spec.md`'s "Boolean short-circuit AND" and "Boolean short-circuit OR" requirements, including the AND-on-false and OR-on-true scenarios.

**Migration**: See `expression-evaluator/spec.md`, requirements on Boolean short-circuit AND/OR.

### Requirement: O(1) call stack depth for evaluation

**Reason**: Already captured in `expression-evaluator/spec.md`: "the implementation SHALL use O(1) call stack depth regardless of expression tree depth. The implementation SHALL use an explicit stack data structure." The 10,000-node stress scenario is also already there.

**Migration**: See `expression-evaluator/spec.md`, requirement on stack-based iterative evaluation.

### Requirement: Both evaluation paths supported

**Reason**: The dual-path concept (`StringExpressionSatisfiable` + `CStringExpressionSatisfiable`) belongs to v1. v2 collapsed both paths into a single `evaluateContains(_:cString:)` method on the `ExpressionEvaluator` protocol that receives both representations together; concrete evaluators choose which to use. That protocol is described by `expression-evaluator/spec.md`.

**Migration**: See `expression-evaluator/spec.md`, requirement on the `ExpressionEvaluator` protocol's six methods, including `evaluateContains(_ string: String, cString: Expression.CString)`.
