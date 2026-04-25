private struct KeyValueCollector: ExpressionEvaluator {
    typealias Result = [(key: String, value: String)]

    func evaluateKeyValue(key: String, value: String) -> Result {
        [(key: key, value: value)]
    }

    func evaluateContains(_ string: String, cString: Expression.CString) -> Result { [] }
    func evaluateAnything() -> Result { [] }
    func evaluateNot(_ inner: Result) -> Result { inner }
    func evaluateAnd(_ lhs: Result, _ rhs: Result) -> Result { lhs + rhs }
    func evaluateOr(_ lhs: Result, _ rhs: Result) -> Result { lhs + rhs }
}

public func keyValueNodes(in expression: Expression) -> [(key: String, value: String)] {
    evaluate(expression, with: KeyValueCollector())
}
