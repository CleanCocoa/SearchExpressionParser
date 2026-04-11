## Context

Layer 1 (archived as `2026-04-11-iterative-parser-layer1`) made parsing iterative. Three post-parse operations remain recursive and crash on deep trees:

1. `isSatisfied(by:)` in `Expressions.swift` — recursive via protocol dispatch through `AndNode`, `OrNode`, `NotNode`
2. `phrases` in `PhraseCollectionConvertible.swift` — recursive via `lhs.phrases + rhs.phrases`
3. `pushNegation` in `ContainmentEvaluator.swift` — recursive De Morgan transformation, depth-limited to 50

All three share the same shape: recursive tree walks over right-leaning binary trees of depth O(N).

## Goals / Non-Goals

**Goals:**
- O(1) call stack depth for all three operations
- Preserve identical observable behavior (same boolean results, same phrase arrays in same order, same normalized trees)
- Preserve short-circuit evaluation semantics in `isSatisfied`
- Soft-deprecate `maxRecursion` and `RecursionTooDeepError` without breaking source compatibility

**Non-Goals:**
- Changing the `Expression` protocol or node type APIs
- Optimizing tree shape (balanced trees are a future concern)
- Removing the deprecated symbols (that's a future semver-major change)

## Decisions

### D1: Iterative `isSatisfied` via enum-based stack machine

Replace recursive protocol dispatch with a private `iterativeIsSatisfied` function using an explicit frame stack (`[EvalFrame]`) and a value stack (`[Bool]`).

Frame types: `.evaluate(Expression)`, `.applyAnd(Expression)`, `.applyOr(Expression)`, `.applyNot`.

Short-circuit: `.applyAnd` checks if the top value is `false` — if so, skips RHS evaluation. `.applyOr` checks if `true` — if so, skips RHS. This preserves the `&&`/`||` semantics of the current recursive implementation.

Two overloads needed: one closing over `StringExpressionSatisfiable`, one over `CStringExpressionSatisfiable`. Both share the same control flow, differing only in the leaf evaluation call.

**Alternative considered:** Generic function parameterized on a closure. Rejected because the two protocols have different method signatures (`contains(phrase:)` vs `matches(needle:)`) and ContainsNode exposes different properties for each path (`string` vs `cString`). A closure abstraction would obscure the type-safe dispatch.

**Integration:** Each node's `isSatisfied(by:)` delegates to the iterative function with `self` as root. The protocol contract is unchanged.

### D2: Iterative `phrases` via DFS with explicit stack

Replace recursive `lhs.phrases + rhs.phrases` with a single `iterativePhrases` function that walks the tree using an `[Expression]` stack.

Push order: `rhs` first, then `lhs` (LIFO), so `lhs` is processed first — preserving left-to-right output order matching the recursive version.

`NotNode` subtrees produce no phrases (skip entirely). `AnythingNode` produces none. `ContainsNode` appends its string.

**Alternative considered:** Keep recursive `phrases` and only make `pushNegation` iterative (since `phrases` is called on the normalized tree, which is typically shallow). Rejected because the input tree before normalization can still be arbitrarily deep, and `phrases` is exposed as a public protocol property that can be called directly on un-normalized trees.

### D3: Iterative `pushNegation` via two-phase decompose/reconstruct

Phase 1 (top-down): Walk the tree with a work stack of `(Evaluable, isNegated: Bool)` pairs. Each `NotNode` flips the negation flag. When `isNegated` and the node is `AndNode`/`OrNode`, apply De Morgan (swap to `OrNode`/`AndNode`, propagate negation to children). Emit `Instruction` items (`.leaf`, `.buildAnd`, `.buildOr`).

Phase 2 (bottom-up): Replay instructions in reverse, reconstructing the tree from a results stack.

This is O(N) time, O(N) heap, O(1) call stack.

**Alternative considered:** Single-pass iterative with continuation stack. More complex to get right for tree reconstruction. The two-phase approach is easier to verify against the recursive version.

### D4: Soft-deprecation of `maxRecursion` and `RecursionTooDeepError`

Split `init(evaluable:maxRecursion:)` into two initializers:
- `init(evaluable:)` — preferred, non-deprecated
- `init(evaluable:maxRecursion:)` — deprecated, ignores parameter

Mark `RecursionTooDeepError` as deprecated. Keep `normalizedEvaluable()` as `throws` for source compatibility (callers may have `try`). It just never throws.

`phrases()` keeps its do/catch — harmless and avoids a signature change.

## Risks / Trade-offs

- **Constant overhead for small trees:** The stack machine has marginally higher overhead than recursive dispatch for trees of 5–50 nodes (heap allocation vs stack frames). Both complete in microseconds. No practical impact. → Validate with existing benchmark test.
- **Maintenance cost of type-matching in iterative walkers:** Adding a new `Expression` node type requires updating iterative walkers (isSatisfied, phrases, pushNegation). → Same cost exists with the recursive version; the switch/case makes it explicit rather than hidden behind protocol dispatch.
- **Deprecation warnings for downstream consumers:** Callers using `maxRecursion` will see deprecation warnings. → Intentional migration signal. Non-breaking.
