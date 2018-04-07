//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Parser {

    internal typealias Result = Either<Expression, ParseError>

    public let tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    public func expression() throws -> Expression {

        let tokenBuffer = TokenBuffer(tokens: tokens)
        return try parseExpression(tokenBuffer)
    }

    private func parseExpression(_ tokenBuffer: TokenBuffer) throws -> Expression {

        let node = try parsePrimary(tokenBuffer)
        return try parseBinaryOperator(tokenBuffer, lhs: node)
    }

    private func parsePrimary(_ tokenBuffer: TokenBuffer) throws -> Expression {

        switch tokenBuffer.peekToken() {
        case .none:
            return AnythingNode()

        default:
            return try parseContainsNode(tokenBuffer)
        }
    }

    private func parseContainsNode(_ tokenBuffer: TokenBuffer) throws -> Expression {

        guard let current = tokenBuffer.popToken() else {
            throw ParseError.expectedTokenAtExpressionStart
        }
        return ContainsNode(token: current)
    }

    private func parseBinaryOperator(_ tokenBuffer: TokenBuffer, lhs: Expression) throws -> Expression {
        guard let operatorToken = tokenBuffer.peekToken() else { return lhs }

        switch operatorToken {
        case BinaryOperator.and:
            _ = tokenBuffer.popToken()
            guard tokenBuffer.isNotAtEnd else { return AndNode(lhs, ContainsNode(token: operatorToken)) }
            let rhs = try parseExpression(tokenBuffer)
            return AndNode(lhs, rhs)

        case BinaryOperator.or:
            _ = tokenBuffer.popToken()
            guard tokenBuffer.isNotAtEnd else { return AndNode(lhs, ContainsNode(token: operatorToken)) }
            let rhs = try parseExpression(tokenBuffer)
            return OrNode(lhs, rhs)

        default:
            let rhs = try parseExpression(tokenBuffer)
            return AndNode(lhs, rhs)
        }
    }
}

internal enum ParseError: Error {
    case expectedTokenAtExpressionStart
}
