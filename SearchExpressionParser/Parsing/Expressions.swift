//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol Expression { }

/// Wildcard that is satisfied by any string.
public struct AnythingNode: Expression { }

public struct ContainsNode: Expression {
    public let string: String

    public init(_ string: String) {
        self.string = string
    }

    public init(token: Token) {
        self.init(token.string)
    }
}

public struct AndNode: Expression {
    public let lhs: Expression
    public let rhs: Expression

    public init(_ lhs: Expression, _ rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }
}

public struct OrNode: Expression {
    public let lhs: Expression
    public let rhs: Expression

    public init(_ lhs: Expression, _ rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }
}
