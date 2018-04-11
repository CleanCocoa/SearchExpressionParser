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

    public struct RecursionTooDeepError: Error {
        public init() {}
    }

    public let evaluable: Evaluable
    public let maxRecursion: Int

    public init(evaluable: Evaluable, maxRecursion: Int = 50) {

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
        return try pushNegation(evaluable)
    }

    private func pushNegation(_ evaluable: Evaluable, level: Int = 0) throws -> Evaluable {

        guard level < maxRecursion else { throw RecursionTooDeepError() }
        guard let notNode = evaluable as? NotNode else { return evaluable }

        switch notNode.expression {
        case let andSubNode as AndNode:
            return OrNode(
                try pushNegation(NotNode(andSubNode.lhs), level: level + 1),
                try pushNegation(NotNode(andSubNode.rhs), level: level + 1))

        case let orSubNode as OrNode:
            return AndNode(
                try pushNegation(NotNode(orSubNode.lhs), level: level + 1),
                try pushNegation(NotNode(orSubNode.rhs), level: level + 1))

        default:
            return notNode
        }
    }
}
