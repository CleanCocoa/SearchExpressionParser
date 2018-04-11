//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// - warning: Works in negation normal form (`ContainmentEvaluator.normalizedEvaluable()`) only.
public protocol PhraseCollectionConvertible {
    var phrases: [String] { get }
}

extension AnythingNode: PhraseCollectionConvertible {
    public var phrases: [String] { return [] }
}

extension NotNode: PhraseCollectionConvertible {
    /// `NotNode` does not compute negation of terms but produces an empty array. Transform to negation formal form first.
    public var phrases: [String] { return [] }
}

extension ContainsNode: PhraseCollectionConvertible {
    public var phrases: [String] { return [string] }
}

extension AndNode: PhraseCollectionConvertible {
    public var phrases: [String] {
        return [
            (lhs as? PhraseCollectionConvertible)?.phrases ?? [],
            (rhs as? PhraseCollectionConvertible)?.phrases ?? []
            ].flatMap { $0 }
    }
}

extension OrNode: PhraseCollectionConvertible {
    public var phrases: [String] {
        return [
            (lhs as? PhraseCollectionConvertible)?.phrases ?? [],
            (rhs as? PhraseCollectionConvertible)?.phrases ?? []
            ].flatMap { $0 }
    }
}
