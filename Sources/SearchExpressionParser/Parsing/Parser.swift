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

        var exprs: [Expression] = [first]
        var ops: [BinaryOperator?] = []

        while tokenBuffer.isNotAtEnd && !(tokenBuffer.peekToken() is ClosingParens) {
            var op: BinaryOperator? = nil
            if let binOp = tokenBuffer.peekToken() as? BinaryOperator {
                op = binOp
                tokenBuffer.consume()

                guard tokenBuffer.isNotAtEnd else {
                    ops.append(nil)
                    exprs.append(.contains(binOp.string))
                    break
                }
            }

            ops.append(op)
            let indexBefore = tokenBuffer.currentIndex
            exprs.append(try parsePrimary(tokenBuffer, depth: depth))
            assert(tokenBuffer.currentIndex > indexBefore, "parsePrimary did not consume any tokens")
        }

        if tokenBuffer.peekToken() is ClosingParens {
            tokenBuffer.consume()
        }

        var result = exprs[exprs.count - 1]
        for i in stride(from: exprs.count - 2, through: 0, by: -1) {
            switch ops[i] {
            case .or:
                result = .or(exprs[i], result)
            case .and, nil:
                result = .and(exprs[i], result)
            }
        }

        return result
    }

    private func parsePrimary(_ tokenBuffer: TokenBuffer, depth: Int = 0) throws -> Expression {

        var negations: [UnaryOperator] = []
        while let op = tokenBuffer.peekToken() as? UnaryOperator {
            negations.append(op)
            tokenBuffer.consume()
        }

        if !negations.isEmpty {
            guard tokenBuffer.isNotAtEnd else {
                let literal = Expression.contains(negations.removeLast().string)
                var expr: Expression = literal
                for _ in negations { expr = .not(expr) }
                return expr
            }

            let base: Expression
            if tokenBuffer.peekToken() is OpeningParens {
                base = try parseOpeningParens(tokenBuffer, depth: depth)
            } else {
                base = try parseContainsExpr(tokenBuffer)
            }

            var expr = base
            for _ in negations { expr = .not(expr) }
            return expr
        }

        switch tokenBuffer.peekToken() {
        case .none:
            return .anything

        case .some(is OpeningParens):
            return try parseOpeningParens(tokenBuffer, depth: depth)

        case .some(_):
            return try parseContainsExpr(tokenBuffer)
        }
    }

    private func parseContainsExpr(_ tokenBuffer: TokenBuffer) throws -> Expression {
        guard let current = tokenBuffer.peekToken() else {
            throw ParseError.expectedTokenAtExpressionStart
        }
        tokenBuffer.consume()
        return .contains(current.string)
    }

    private func parseOpeningParens(_ tokenBuffer: TokenBuffer, depth: Int = 0) throws -> Expression {

        guard depth <= 100 else {
            throw ParseError.parenNestingTooDeep
        }

        guard let openingParensToken = tokenBuffer.peekToken() as? OpeningParens else {
            throw ParseError.expectedOpeningParens
        }

        tokenBuffer.consume()

        if let closingParensToken = tokenBuffer.peekToken() as? ClosingParens {
            tokenBuffer.consume()
            return .and(.contains(openingParensToken.string), .contains(closingParensToken.string))
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
