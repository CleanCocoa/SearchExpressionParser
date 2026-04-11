//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// Takes an `Expression` and returns an array of String objects that
/// represent the positive values, i.e. the search string parts that are
/// supposed to be part of the haystack.
///
/// Useful to highlight matches.
///
/// Example:
///
///     foo AND bar and NOT baz
///
/// Returns `["foo", "bar"]` because the NOT clause indicates that `"baz"` is
/// not supposed to be part of the haystack.
///
/// Performs normalization.
public struct ContainmentEvaluator {

    public typealias Evaluable = Expression & PhraseCollectionConvertible

    @available(*, deprecated, message: "This error is no longer thrown. pushNegation is now iterative with no depth limit.")
    public struct RecursionTooDeepError: Error {
        public init() {}
    }

    public let evaluable: Evaluable

    @available(*, deprecated, message: "maxRecursion is no longer used. The algorithm is iterative.")
    public let maxRecursion: Int

    public init(evaluable: Evaluable) {
        self.evaluable = evaluable
        self.maxRecursion = 50
    }

    @available(*, deprecated, message: "maxRecursion is no longer used. The algorithm is iterative.")
    public init(evaluable: Evaluable, maxRecursion: Int) {
        self.evaluable = evaluable
        self.maxRecursion = maxRecursion
    }

    /// Produces an array of sets of phrases that may be
    /// contained in the haystack when evaluating `expression`.
    ///
    /// These are not the actual phrases that _must_ be contained. These
    /// are phrases that _may_ be contained. `x OR y` will
    /// produce a collection of all candidates: `["x","y"]`.
    ///
    /// See: `normalizedExpression()`.
    ///
    /// - returns: Empty array if normalization of `expression` recurses too deep.
    public func phrases() -> [String] {
        do {
            let evaluable = try normalizedEvaluable()
            return evaluable.phrases
        } catch {
            return []
        }
    }

    /// Negation normal form.
    /// - throws: `RecursionTooDeepError` if recursion is too deep. See `maxRecursion` to limit the depth of expressions.
    public func normalizedEvaluable() throws -> Evaluable {
        return pushNegationIteratively(evaluable)
    }

    private enum Instruction {
        case leaf(Evaluable)
        case buildAnd
        case buildOr
    }

    private func pushNegationIteratively(_ root: Evaluable) -> Evaluable {
        var work: [(Evaluable, Bool)] = [(root, false)]
        var instructions: [Instruction] = []

        while let (expr, negated) = work.popLast() {
            if let notNode = expr as? NotNode {
                if let inner = notNode.expression as? Evaluable {
                    work.append((inner, !negated))
                } else {
                    instructions.append(.leaf(negated ? NotNode(notNode) : notNode))
                }
            } else if let andNode = expr as? AndNode, negated,
                      let lhs = andNode.lhs as? Evaluable,
                      let rhs = andNode.rhs as? Evaluable {
                instructions.append(.buildOr)
                work.append((rhs, true))
                work.append((lhs, true))
            } else if let orNode = expr as? OrNode, negated,
                      let lhs = orNode.lhs as? Evaluable,
                      let rhs = orNode.rhs as? Evaluable {
                instructions.append(.buildAnd)
                work.append((rhs, true))
                work.append((lhs, true))
            } else if let andNode = expr as? AndNode,
                      let lhs = andNode.lhs as? Evaluable,
                      let rhs = andNode.rhs as? Evaluable {
                instructions.append(.buildAnd)
                work.append((rhs, false))
                work.append((lhs, false))
            } else if let orNode = expr as? OrNode,
                      let lhs = orNode.lhs as? Evaluable,
                      let rhs = orNode.rhs as? Evaluable {
                instructions.append(.buildOr)
                work.append((rhs, false))
                work.append((lhs, false))
            } else if negated {
                instructions.append(.leaf(NotNode(expr)))
            } else {
                instructions.append(.leaf(expr))
            }
        }

        var results: [Evaluable] = []
        for instruction in instructions.reversed() {
            switch instruction {
            case .leaf(let e):
                results.append(e)
            case .buildAnd:
                let lhs = results.removeLast()
                let rhs = results.removeLast()
                results.append(AndNode(lhs, rhs))
            case .buildOr:
                let lhs = results.removeLast()
                let rhs = results.removeLast()
                results.append(OrNode(lhs, rhs))
            }
        }

        return results.last ?? root
    }
}
