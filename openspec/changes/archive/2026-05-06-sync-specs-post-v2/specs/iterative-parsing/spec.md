## REMOVED Requirements

### Requirement: Binary Operator Parsing Uses O(1) Call Stack

**Reason**: The iterative-parsing capability tracked the recursion-removal refactoring epic. That epic has fully landed; the parser is iterative. The properties this requirement asserted are already captured in `parsing-grammar/spec.md` — both the prose constraint ("SHALL handle arbitrarily long sequences of adjacent terms without stack overflow, using O(1) call stack depth") and the 10,000-token stress scenarios live in `parsing-grammar`'s "Implicit AND for Adjacent Terms" requirement.

**Migration**: See `parsing-grammar/spec.md`, "Implicit AND for Adjacent Terms" and adjacent operator requirements.

### Requirement: Negation Parsing Uses O(1) Call Stack

**Reason**: The 10,000-chained-bangs scenario is already in `parsing-grammar/spec.md` under "Unary NOT/Bang Binds to Immediately Following Primary". This change additionally folds in the trailing-negations-at-scale scenario from this requirement (as an ADDED scenario in `parsing-grammar`).

**Migration**: See `parsing-grammar/spec.md`, "Unary NOT/Bang Binds to Immediately Following Primary", plus the ADDED "Trailing negations at scale" scenario in this change's `parsing-grammar` delta.

### Requirement: Parenthesis Balancing Uses O(1) Call Stack

**Reason**: This is the only iterative-parsing requirement whose constraint is not redundant with `parsing-grammar`. The change folds it forward as an ADDED constraint and two ADDED stress scenarios on `parsing-grammar`'s "Unbalanced Parentheses Are Converted to Words" requirement.

**Migration**: See this change's `parsing-grammar` delta — the ADDED "balanceParentheses uses O(1) call stack" prose constraint and the two ADDED stress scenarios.

### Requirement: Parenthesized Group Parsing Has Bounded Recursion Depth

**Reason**: Already covered verbatim in `parsing-grammar/spec.md`'s "Paren Nesting Depth Limit" requirement, including the within-limit and exceeds-limit scenarios.

**Migration**: See `parsing-grammar/spec.md`, "Paren Nesting Depth Limit".

### Requirement: Right-Fold Produces Identical Trees

**Reason**: Historical framing — describes the iterative implementation as producing identical trees to the now-removed recursive parser. The recursive parser is gone; "identical to the recursive version" is no longer a meaningful comparison. The right-associativity and operator-semantics behaviors are captured in `parsing-grammar/spec.md`'s explicit AND/OR and trailing-operator requirements.

**Migration**: See `parsing-grammar/spec.md`, requirements on right-associativity and operator semantics.
