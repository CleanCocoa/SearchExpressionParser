//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol ExpressionSatisfiable {
    func contains(phrase: String) -> Bool
}

extension String: ExpressionSatisfiable {
    public func contains(phrase: String) -> Bool {
        return self.contains(phrase)
    }
}

public protocol Expression {
    func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool
}

/// Wildcard that is satisfied by any string.
public struct AnythingNode: Expression {
    public func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool {
        return true
    }
}

public struct ContainsNode: Expression {
    public let string: String

    public init(_ string: String) {
        self.string = string
    }

    public init(token: Token) {
        self.init(token.string)
    }

    public func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool {
        return satisfiable.contains(phrase: string)
    }
}

public struct NotNode: Expression {
    public let expression: Expression

    public init(_ expression: Expression) {
        self.expression = expression
    }

    public func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool {
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

    public func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool {
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

    public func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool {
        return lhs.isSatisfied(by: satisfiable) || rhs.isSatisfied(by: satisfiable)
    }
}
