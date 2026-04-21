public func normalize(_ expression: Expression) -> Expression {
    var work: [(Expression, Bool)] = [(expression, false)]
    var instructions: [Instruction] = []

    while let (expr, negated) = work.popLast() {
        switch expr {
        case .not(let inner):
            work.append((inner, !negated))
        case .and(let lhs, let rhs) where negated:
            instructions.append(.buildOr)
            work.append((rhs, true))
            work.append((lhs, true))
        case .or(let lhs, let rhs) where negated:
            instructions.append(.buildAnd)
            work.append((rhs, true))
            work.append((lhs, true))
        case .and(let lhs, let rhs):
            instructions.append(.buildAnd)
            work.append((rhs, false))
            work.append((lhs, false))
        case .or(let lhs, let rhs):
            instructions.append(.buildOr)
            work.append((rhs, false))
            work.append((lhs, false))
        default:
            instructions.append(.leaf(negated ? .not(expr) : expr))
        }
    }

    var results: [Expression] = []
    for instruction in instructions.reversed() {
        switch instruction {
        case .leaf(let e):
            results.append(e)
        case .buildAnd:
            let lhs = results.removeLast()
            let rhs = results.removeLast()
            results.append(.and(lhs, rhs))
        case .buildOr:
            let lhs = results.removeLast()
            let rhs = results.removeLast()
            results.append(.or(lhs, rhs))
        }
    }

    return results.last ?? expression
}

private enum Instruction {
    case leaf(Expression)
    case buildAnd
    case buildOr
}
