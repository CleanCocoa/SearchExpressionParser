//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Parser {

    public let tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    public func expression() throws -> Expression {

        let tokenBuffer = TokenBuffer(tokens: tokens)

        guard let first = tokenBuffer.popToken() else { return AnythingNode() }

        if let next = tokenBuffer.popToken() {
            return AndNode(ContainsNode(token: first), ContainsNode(token: next))
        }

        return ContainsNode(token: first)
    }
}
