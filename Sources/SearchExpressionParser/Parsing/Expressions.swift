import Foundation

public enum Expression: Sendable, Equatable {
    case anything
    case contains(string: String, cString: CString)
    indirect case not(Expression)
    indirect case and(Expression, Expression)
    indirect case or(Expression, Expression)
    case keyValue(key: String, value: String)

    public typealias CString = [CChar]

    public nonisolated(unsafe) static var cStringFactory: (String) -> CString = { string in
        string.precomposedStringWithCanonicalMapping
            .lowercased()
            .cString(using: .utf8) ?? []
    }

    public static func contains(_ string: String) -> Expression {
        return .contains(string: string, cString: cStringFactory(string))
    }
}

extension Expression: CustomStringConvertible {
    public var description: String {
        switch self {
        case .anything:
            return "anything"
        case .contains(let string, _):
            return string
        case .not(let expr):
            return "NOT \(expr)"
        case .and(let lhs, let rhs):
            return "(\(lhs) AND \(rhs))"
        case .or(let lhs, let rhs):
            return "(\(lhs) OR \(rhs))"
        case .keyValue(let key, let value):
            return "\(key):\(value)"
        }
    }
}
