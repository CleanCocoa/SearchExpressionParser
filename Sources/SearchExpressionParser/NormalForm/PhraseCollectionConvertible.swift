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
        return iterativePhrases(self)
    }
}

extension OrNode: PhraseCollectionConvertible {
    public var phrases: [String] {
        return iterativePhrases(self)
    }
}

private func iterativePhrases(_ root: Expression) -> [String] {
    var result: [String] = []
    var stack: [Expression] = [root]
    while let expr = stack.popLast() {
        switch expr {
        case let c as ContainsNode:
            result.append(c.string)
        case let a as AndNode:
            stack.append(a.rhs)
            stack.append(a.lhs)
        case let o as OrNode:
            stack.append(o.rhs)
            stack.append(o.lhs)
        case is NotNode, is AnythingNode:
            break
        default:
            if let p = expr as? PhraseCollectionConvertible {
                result.append(contentsOf: p.phrases)
            }
        }
    }
    return result
}
