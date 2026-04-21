import Foundation

public struct StringContainmentEvaluator: ExpressionEvaluator {
    public typealias Result = Bool

    public let haystack: String
    public let haystackCString: Expression.CString

    public init(_ haystack: String) {
        self.haystack = haystack
        self.haystackCString = haystack
            .precomposedStringWithCanonicalMapping
            .lowercased()
            .cString(using: .utf8) ?? []
    }

    public func evaluateContains(_ string: String, cString needle: Expression.CString) -> Bool {
        guard !needle.isEmpty || needle.count == 1 else { return false }
        if needle.isEmpty { return false }
        let needleIsEmpty = needle.count == 1 && needle[0] == 0
        if needleIsEmpty { return false }
        return haystackCString.withUnsafeBufferPointer { haystackBuf in
            needle.withUnsafeBufferPointer { needleBuf in
                guard let h = haystackBuf.baseAddress, let n = needleBuf.baseAddress else { return false }
                return strstr(h, n) != nil
            }
        }
    }

    public func evaluateKeyValue(key: String, value: String) -> Bool {
        return false
    }
}
