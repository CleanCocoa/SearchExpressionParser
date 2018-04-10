//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// Literal string matching.
public protocol StringExpressionSatisfiable {
    func contains(phrase: String) -> Bool
}

/// The fastest search on earch is `strstr(haystack, needle)` with lowercased string.
/// This provides the needle as UTF-8, lowercased, precomposed string with canonical mapping.
public protocol CStringExpressionSatisfiable {
    func matches(needle: ContainsNode.CString) -> Bool
}

extension String: StringExpressionSatisfiable {
    public func contains(phrase: String) -> Bool {
        return self.contains(phrase)
    }
}

public protocol Expression {
    func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool
    func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool
}

/// Wildcard that is satisfied by any string.
public struct AnythingNode: Expression {
    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return true
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return true
    }
}

public struct ContainsNode: Expression {
    public typealias CString = [CChar]
    public let string: String
    public let cString: CString

    public static var cStringFactory: (String) -> CString = ContainsNode.cString(string:)

    public static func cString(string: String) -> CString {
        return string.precomposedStringWithCanonicalMapping
            .lowercased()
            .cString(using: .utf8) ?? []
    }

    public init(_ string: String) {
        self.string = string
        self.cString = ContainsNode.cStringFactory(string)
    }

    public init(token: Token) {
        self.init(token.string)
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return satisfiable.contains(phrase: string)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return satisfiable.matches(needle: cString)
    }
}

public struct NotNode: Expression {
    public let expression: Expression

    public init(_ expression: Expression) {
        self.expression = expression
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return !expression.isSatisfied(by: satisfiable)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return !expression.isSatisfied(by: satisfiable)
    }
}

public struct AndNode: Expression {
    public let lhs: Expression
    public let rhs: Expression

    public init(_ lhs: Expression, _ rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return lhs.isSatisfied(by: satisfiable) && rhs.isSatisfied(by: satisfiable)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return lhs.isSatisfied(by: satisfiable) && rhs.isSatisfied(by: satisfiable)
    }
}

public struct OrNode: Expression {
    public let lhs: Expression
    public let rhs: Expression

    public init(_ lhs: Expression, _ rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return lhs.isSatisfied(by: satisfiable) || rhs.isSatisfied(by: satisfiable)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return lhs.isSatisfied(by: satisfiable) || rhs.isSatisfied(by: satisfiable)
    }
}
