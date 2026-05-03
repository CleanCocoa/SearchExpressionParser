## REMOVED Requirements

### Requirement: Dual Evaluation Paths

**Reason**: The `StringExpressionSatisfiable` and `CStringExpressionSatisfiable` protocols no longer exist. v2 collapsed both representations into a single `evaluateContains(_ string: String, cString: Expression.CString) -> Result` method on the `ExpressionEvaluator` protocol; concrete evaluators choose which representation to use.

**Migration**: See `expression-evaluator/spec.md`, requirement on the `ExpressionEvaluator` protocol's six methods. See also `string-containment-evaluator/spec.md` for the canonical `Bool`-typed evaluator that uses the C-string representation via `strstr`.

### Requirement: AnythingNode Always Matches

**Reason**: `AnythingNode` was replaced by the `Expression.anything` enum case. Matching is no longer a method on the expression itself; it is delegated to the evaluator.

**Migration**: See `expression-evaluator/spec.md` for `evaluateAnything()` dispatch. See `string-containment-evaluator/spec.md` (Boolean defaults extension returns `true`) for the equivalent always-match behavior.

### Requirement: ContainsNode Substring Match

**Reason**: `ContainsNode` was replaced by the `Expression.contains(string:cString:)` enum case. Substring matching moves to evaluators.

**Migration**: See `string-containment-evaluator/spec.md`, requirement "evaluateContains uses strstr fast path".

### Requirement: ContainsNode Empty String Behavior

**Reason**: Behavior on empty strings is a property of the concrete evaluator, not of the expression data type. The current `string-containment-evaluator/spec.md` "Empty needle" scenario specifies the equivalent contract.

**Migration**: See `string-containment-evaluator/spec.md`, "Empty needle" scenario under `evaluateContains uses strstr fast path`.

### Requirement: ContainsNode CString Factory

**Reason**: This requirement belongs with the data type itself, not with evaluation. It is captured in `expression-data-type/spec.md` (the `cStringFactory` factory and the lowercased-precomposed-UTF-8 default).

**Migration**: See `expression-data-type/spec.md`, the requirement on `Expression.contains` factory and `cStringFactory`.

### Requirement: AndNode Short-Circuit Evaluation

**Reason**: `AndNode` was replaced by `Expression.and`. Short-circuit semantics moved to the `evaluate(_:with:)` function for `Result == Bool`.

**Migration**: See `expression-evaluator/spec.md`, requirement "AND short-circuit for Bool".

### Requirement: OrNode Short-Circuit Evaluation

**Reason**: `OrNode` was replaced by `Expression.or`. Short-circuit semantics moved to the `evaluate(_:with:)` function for `Result == Bool`.

**Migration**: See `expression-evaluator/spec.md`, requirement "OR short-circuit for Bool".

### Requirement: NotNode Boolean Negation

**Reason**: `NotNode` was replaced by `Expression.not`. Negation moved to the evaluator (default Boolean implementation returns `!inner`).

**Migration**: See `expression-evaluator/spec.md`, requirement "Boolean defaults extension", scenario "evaluateNot negates".

## NOTE

This delta retires the entire `expression-evaluation` capability. Every requirement it carried is fully described elsewhere in the v2 capabilities (`expression-evaluator`, `string-containment-evaluator`, `expression-data-type`). The capability itself is a v1-architecture artifact: it described `Expression` as a protocol with `isSatisfied(by:)` methods on each node, which is no longer how v2 works.
