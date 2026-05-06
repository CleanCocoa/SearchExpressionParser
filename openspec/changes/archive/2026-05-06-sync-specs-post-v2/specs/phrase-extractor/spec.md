## ADDED Requirements

### Requirement: O(1) call stack depth on evaluate(_:with:)

`evaluate(_:with: PhraseExtractor())` SHALL traverse the expression tree iteratively with O(1) call stack depth, regardless of tree depth, preventing stack overflow on arbitrarily deep expression trees. This constraint anchors on the iterative machinery in `evaluate(_:with:)` (described in `expression-evaluator/spec.md`); `PhraseExtractor` itself is a stateless struct.

#### Scenario: Extract phrases from 10,000-deep tree without stack overflow

- **GIVEN** a parsed expression of 10,000 implicit-AND words
- **WHEN** `evaluate(expression, with: PhraseExtractor())` is called
- **THEN** extraction SHALL complete without stack overflow and return all 10,000 phrases in left-to-right order
