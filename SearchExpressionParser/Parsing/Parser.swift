//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Parser {

    internal typealias Result = Either<Expression, ParseError>

    public let tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = balanceParentheses(tokens: tokens)
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

        case .some(UnaryOperator.bang),
             .some(UnaryOperator.not):
            return try parseNegation(tokenBuffer)

        case .some(_):
            return try parseContainsNode(tokenBuffer)
        }
    }

    private func parseNegation(_ tokenBuffer: TokenBuffer) throws -> Expression {

        guard let operatorToken = tokenBuffer.peekToken() as? UnaryOperator else {
            throw ParseError.expectedUnaryOperatorInNegation
        }

        tokenBuffer.consume()

        guard tokenBuffer.isNotAtEnd else { return ContainsNode(token: operatorToken) }
        let expression = try parsePrimary(tokenBuffer)
        return NotNode(expression)
    }

    private func parseContainsNode(_ tokenBuffer: TokenBuffer) throws -> Expression {

        guard let current = tokenBuffer.peekToken() else {
            throw ParseError.expectedTokenAtExpressionStart
        }
        tokenBuffer.consume()

        return ContainsNode(token: current)
    }

    private func parseBinaryOperator(_ tokenBuffer: TokenBuffer, lhs: Expression) throws -> Expression {
        guard let operatorToken = tokenBuffer.peekToken() else { return lhs }

        switch operatorToken {
        case BinaryOperator.and:
            tokenBuffer.consume()
            guard tokenBuffer.isNotAtEnd else { return AndNode(lhs, ContainsNode(token: operatorToken)) }
            let rhs = try parseExpression(tokenBuffer)
            return AndNode(lhs, rhs)

        case BinaryOperator.or:
            tokenBuffer.consume()
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
    case expectedUnaryOperatorInNegation
    case expectedTermAfterNegation
}

// MARK: - Clean up unbalanced parens

internal func balanceParentheses(tokens: [Token]) -> [Token] {
    switch balanceParentheses(tokens: tokens, start: 0) {
    case .closeCurrent(at: _):
        assertionFailure()
        return tokens

    case .end(tokens: let result):
        return result
    }
}

private enum Balance {
    case closeCurrent(at: Int)
    case end(tokens: [Token])
}

private func balanceParentheses(tokens: [Token], start: Int) -> Balance {

    let isRootLevel = (start == 0)
    var tokens = tokens
    var head = start
    while head < tokens.count {
        let token = tokens[head]
        if token is OpeningParens {
            let innerBalance = balanceParentheses(tokens: tokens, start: head + 1)
            switch innerBalance {
            case .closeCurrent(at: let occupied): head = occupied
            case .end(var replacement):
                replacement[head] = Word(token.string)
                tokens = replacement
            }
        } else if token is ClosingParens {
            if isRootLevel {
                // This is the root level, so it indicates this ")" had no opener.
                tokens[head] = Word(token.string)
            } else {
                // This is not the root level, so it's closing an open parens somewhere
                return .closeCurrent(at: head)
            }
        }
        head += 1
    }
    return .end(tokens: tokens)
}
