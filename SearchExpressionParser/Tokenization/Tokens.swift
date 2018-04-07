//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol Token {
    var string: String { get }
}

public struct Word: Token {
    public let string: String
    public init(string: String) {
        self.string = string
    }
}
