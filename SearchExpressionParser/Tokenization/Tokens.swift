//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol Token {
    var string: String { get }
}

public struct Word: Token {
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
