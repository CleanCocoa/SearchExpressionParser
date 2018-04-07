//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Parser {

    public let tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    public func expression() throws -> Expression {

        let tokenBuffer = TokenBuffer(tokens: tokens)

        if let phrase = tokenBuffer.popToken() as? Phrase {
            return ContainsNode(phrase.string)
        }

        return AnythingNode()
    }
}
