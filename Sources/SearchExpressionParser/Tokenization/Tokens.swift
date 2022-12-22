//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol Token {
    var string: String { get }
}

public typealias Word = Phrase

public struct Phrase: Token {
    public let string: String
    public init(_ string: String) {
        self.string = string
    }
}

public struct OpeningParens: Token {
    public let string = "("
}

public struct ClosingParens: Token {
    public let string = ")"
}

public enum BinaryOperator: Token {
    case and
    case or

    public var string: String {
        switch self {
        case .and: return "AND"
        case .or: return "OR"
        }
    }
}

public enum UnaryOperator: Token {
    case bang
    case not

    public var string: String {
        switch self {
        case .bang: return "!"
        case .not: return "NOT"
        }
    }
}
