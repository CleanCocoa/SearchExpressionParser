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

    private func parseExpression(_ tokenBuffer: TokenBuffer, depth: Int = 0) throws -> Expression {

        let first = try parsePrimary(tokenBuffer, depth: depth)

        guard tokenBuffer.isNotAtEnd else { return first }

        if tokenBuffer.peekToken() is ClosingParens {
            tokenBuffer.consume()
            return first
        }

        var exprs: [SearchExpressionParser.Expression] = [first]
        var ops: [BinaryOperator?] = []

        while tokenBuffer.isNotAtEnd && !(tokenBuffer.peekToken() is ClosingParens) {
            var op: BinaryOperator? = nil
            if let binOp = tokenBuffer.peekToken() as? BinaryOperator {
                op = binOp
                tokenBuffer.consume()

                guard tokenBuffer.isNotAtEnd else {
                    ops.append(nil)
                    exprs.append(ContainsNode(token: binOp))
                    break
                }
            }

            ops.append(op)
            exprs.append(try parsePrimary(tokenBuffer, depth: depth))
        }

        if tokenBuffer.peekToken() is ClosingParens {
            tokenBuffer.consume()
        }

        var result = exprs[exprs.count - 1]
        for i in stride(from: exprs.count - 2, through: 0, by: -1) {
            switch ops[i] {
            case .or:
                result = OrNode(exprs[i], result)
            case .and, nil:
                result = AndNode(exprs[i], result)
            }
        }

        return result
    }

    private func parsePrimary(_ tokenBuffer: TokenBuffer, depth: Int = 0) throws -> SearchExpressionParser.Expression {

        var negations: [UnaryOperator] = []
        while let op = tokenBuffer.peekToken() as? UnaryOperator {
            negations.append(op)
            tokenBuffer.consume()
        }

        if !negations.isEmpty {
            guard tokenBuffer.isNotAtEnd else {
                let literal = ContainsNode(token: negations.removeLast())
                var expr: SearchExpressionParser.Expression = literal
                for _ in negations { expr = NotNode(expr) }
                return expr
            }

            let base: SearchExpressionParser.Expression
            if tokenBuffer.peekToken() is OpeningParens {
                base = try parseOpeningParens(tokenBuffer, depth: depth)
            } else {
                base = try parseContainsNode(tokenBuffer)
            }

            var expr = base
            for _ in negations { expr = NotNode(expr) }
            return expr
        }

        switch tokenBuffer.peekToken() {
        case .none:
            return AnythingNode()

        case .some(is OpeningParens):
            return try parseOpeningParens(tokenBuffer, depth: depth)

        case .some(_):
            return try parseContainsNode(tokenBuffer)
        }
    }

    private func parseContainsNode(_ tokenBuffer: TokenBuffer) throws -> SearchExpressionParser.Expression {

        guard let current = tokenBuffer.peekToken() else {
            throw ParseError.expectedTokenAtExpressionStart
        }
        tokenBuffer.consume()

        return ContainsNode(token: current)
    }

    private func parseOpeningParens(_ tokenBuffer: TokenBuffer, depth: Int = 0) throws -> SearchExpressionParser.Expression {

        guard depth <= 100 else {
            throw ParseError.parenNestingTooDeep
        }

        guard let openingParensToken = tokenBuffer.peekToken() as? OpeningParens else {
            throw ParseError.expectedOpeningParens
        }

        tokenBuffer.consume()

        if let closingParensToken = tokenBuffer.peekToken() as? ClosingParens {
            tokenBuffer.consume()
            return AndNode(
                ContainsNode(openingParensToken.string),
                ContainsNode(closingParensToken.string))
        }

        return try parseExpression(tokenBuffer, depth: depth + 1)
    }
}

internal enum ParseError: Error {
    case expectedTokenAtExpressionStart
    case expectedUnaryOperatorInNegation
    case expectedTermAfterNegation
    case expectedOpeningParens
    case parenNestingTooDeep
}

// MARK: - Clean up unbalanced parens

internal func balanceParentheses(tokens: [Token]) -> [Token] {
    var result = tokens
    var openStack: [Int] = []

    for i in 0..<result.count {
        if result[i] is OpeningParens {
            openStack.append(i)
        } else if result[i] is ClosingParens {
            if openStack.isEmpty {
                result[i] = Word(result[i].string)
            } else {
                openStack.removeLast()
            }
        }
    }

    for i in openStack {
        result[i] = Word(result[i].string)
    }

    return result
}
