public struct PhraseExtractor: ExpressionEvaluator {
    public typealias Result = [String]

    public init() {}

    public func evaluateContains(_ string: String, cString: Expression.CString) -> [String] {
        return [string]
    }

    public func evaluateKeyValue(key: String, value: String) -> [String] {
        return []
    }

    public func evaluateAnything() -> [String] {
        return []
    }

    public func evaluateNot(_ inner: [String]) -> [String] {
        return []
    }

    public func evaluateAnd(_ lhs: [String], _ rhs: [String]) -> [String] {
        return lhs + rhs
    }

    public func evaluateOr(_ lhs: [String], _ rhs: [String]) -> [String] {
        return lhs + rhs
    }
}
