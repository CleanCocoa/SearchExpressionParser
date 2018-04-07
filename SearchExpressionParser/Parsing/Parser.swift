//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Parser {

    internal typealias Result = Either<Expression, ParseError>

    public let tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    public func expression() throws -> Expression {

        let tokenBuffer = TokenBuffer(tokens: tokens)

        guard let next = parseExpression(tokenBuffer: tokenBuffer) else { return AnythingNode() }

        switch next {
        case .error(let error):
            throw error
        case .value(let expression):
            return expression
        }
    }

    private func parseExpression(tokenBuffer: TokenBuffer) -> Result? {

        guard let current = tokenBuffer.popToken() else { return nil }
        guard let next = parseExpression(tokenBuffer: tokenBuffer) else { return .value(ContainsNode(token: current)) }

        switch next {
        case .error(_):
            return next
        case .value(let nextExpression):
            return .value(AndNode(ContainsNode(token: current), nextExpression))
        }
    }
}

internal enum ParseError: Error {
    case expectedTokenAtExpressionStart
}
