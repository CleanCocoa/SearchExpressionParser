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

public enum Operator: Token {
    case and
    case bang
    case or
    case not

    public var string: String {
        switch self {
        case .and: return "AND"
        case .bang: return "!"
        case .or: return "OR"
        case .not: return "NOT"
        }
    }
}
