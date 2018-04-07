//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Tokenizer {
    public let searchString: String

    public init(searchString: String) {
        self.searchString = searchString
    }

    public func tokens() -> [Token] {
        return []
    }
}

public protocol Token: Equatable {
    var string: String { get }
}

public struct Word: Token {
    public let string: String
    public init(string: String) {
        self.string = string
    }
}
