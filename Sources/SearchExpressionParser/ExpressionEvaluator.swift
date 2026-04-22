public protocol ExpressionEvaluator {
    associatedtype Result
    func evaluateContains(_ string: String, cString: Expression.CString) -> Result
    func evaluateKeyValue(key: String, value: String) -> Result
    func evaluateAnything() -> Result
    func evaluateNot(_ inner: Result) -> Result
    func evaluateAnd(_ lhs: Result, _ rhs: Result) -> Result
    func evaluateOr(_ lhs: Result, _ rhs: Result) -> Result
}

public extension ExpressionEvaluator where Result == Bool {
    func evaluateNot(_ inner: Bool) -> Bool { !inner }
    func evaluateAnd(_ lhs: Bool, _ rhs: Bool) -> Bool { lhs && rhs }
    func evaluateOr(_ lhs: Bool, _ rhs: Bool) -> Bool { lhs || rhs }
    func evaluateAnything() -> Bool { true }
}

public func evaluate<E: ExpressionEvaluator>(_ expression: Expression, with evaluator: E) -> E.Result {
    var stack: [EvalFrame<E.Result>] = [.push(expression)]
    var values: [E.Result] = []

    while let frame = stack.popLast() {
        switch frame {
        case .push(let expr):
            switch expr {
            case .anything:
                values.append(evaluator.evaluateAnything())
            case .contains(let string, let cString):
                values.append(evaluator.evaluateContains(string, cString: cString))
            case .keyValue(let key, let value):
                values.append(evaluator.evaluateKeyValue(key: key, value: value))
            case .not(let inner):
                stack.append(.applyNot)
                stack.append(.push(inner))
            case .and(let lhs, let rhs):
                stack.append(.applyAnd(rhs))
                stack.append(.push(lhs))
            case .or(let lhs, let rhs):
                stack.append(.applyOr(rhs))
                stack.append(.push(lhs))
            }
        case .applyNot:
            let inner = values.removeLast()
            values.append(evaluator.evaluateNot(inner))
        case .applyAnd(let rhs):
            let lhs = values.removeLast()
            stack.append(.applyAnd2(lhs))
            stack.append(.push(rhs))
        case .applyAnd2(let lhs):
            let rhs = values.removeLast()
            values.append(evaluator.evaluateAnd(lhs, rhs))
        case .applyOr(let rhs):
            let lhs = values.removeLast()
            stack.append(.applyOr2(lhs))
            stack.append(.push(rhs))
        case .applyOr2(let lhs):
            let rhs = values.removeLast()
            values.append(evaluator.evaluateOr(lhs, rhs))
        }
    }

    return values.last!
}

public func evaluate<E: ExpressionEvaluator>(_ expression: Expression, with evaluator: E) -> Bool where E.Result == Bool {
    var stack: [BoolEvalFrame] = [.push(expression)]
    var values: [Bool] = []

    while let frame = stack.popLast() {
        switch frame {
        case .push(let expr):
            switch expr {
            case .anything:
                values.append(evaluator.evaluateAnything())
            case .contains(let string, let cString):
                values.append(evaluator.evaluateContains(string, cString: cString))
            case .keyValue(let key, let value):
                values.append(evaluator.evaluateKeyValue(key: key, value: value))
            case .not(let inner):
                stack.append(.applyNot)
                stack.append(.push(inner))
            case .and(let lhs, let rhs):
                stack.append(.applyAnd(rhs))
                stack.append(.push(lhs))
            case .or(let lhs, let rhs):
                stack.append(.applyOr(rhs))
                stack.append(.push(lhs))
            }
        case .applyNot:
            values.append(!values.removeLast())
        case .applyAnd(let rhs):
            if values.last == false {
                // short-circuit: leave false on stack
            } else {
                values.removeLast()
                stack.append(.push(rhs))
            }
        case .applyOr(let rhs):
            if values.last == true {
                // short-circuit: leave true on stack
            } else {
                values.removeLast()
                stack.append(.push(rhs))
            }
        }
    }

    return values.last!
}

private enum EvalFrame<Result> {
    case push(Expression)
    case applyNot
    case applyAnd(Expression)
    case applyAnd2(Result)
    case applyOr(Expression)
    case applyOr2(Result)
}

private enum BoolEvalFrame {
    case push(Expression)
    case applyNot
    case applyAnd(Expression)
    case applyOr(Expression)
}
