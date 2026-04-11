//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

/// Literal string matching.
public protocol StringExpressionSatisfiable {
    func contains(phrase: String) -> Bool
}

/// The fastest search on earch is `strstr(haystack, needle)` with lowercased string.
/// This provides the needle as UTF-8, lowercased, precomposed string with canonical mapping.
public protocol CStringExpressionSatisfiable {
    func matches(needle: ContainsNode.CString) -> Bool
}

extension String: StringExpressionSatisfiable {
    public func contains(phrase: String) -> Bool {
        return self.contains(phrase)
    }
}

public protocol Expression {
    func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool
    func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool
}

/// Wildcard that is satisfied by any string.
public struct AnythingNode: Expression {

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return true
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return true
    }
}

public struct ContainsNode: Expression {

    public typealias CString = [CChar]
    public let string: String
    public let cString: CString

    public static var cStringFactory: (String) -> CString = ContainsNode.cString(string:)

    public static func cString(string: String) -> CString {
        return string.precomposedStringWithCanonicalMapping
            .lowercased()
            .cString(using: .utf8) ?? []
    }

    public init(_ string: String) {
        self.string = string
        self.cString = ContainsNode.cStringFactory(string)
    }

    public init(token: Token) {
        self.init(token.string)
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return satisfiable.contains(phrase: string)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return satisfiable.matches(needle: cString)
    }
}

public struct NotNode: Expression {

    public let expression: Expression

    public init(_ expression: Expression) {
        self.expression = expression
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return iterativeIsSatisfied(self, by: satisfiable)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return iterativeIsSatisfied(self, by: satisfiable)
    }
}

public struct AndNode: Expression {
    public let lhs: Expression
    public let rhs: Expression

    public init(_ lhs: Expression, _ rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return iterativeIsSatisfied(self, by: satisfiable)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return iterativeIsSatisfied(self, by: satisfiable)
    }
}

public struct OrNode: Expression {
    public let lhs: Expression
    public let rhs: Expression

    public init(_ lhs: Expression, _ rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return iterativeIsSatisfied(self, by: satisfiable)
    }

    public func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return iterativeIsSatisfied(self, by: satisfiable)
    }
}

private enum EvalFrame {
    case evaluate(Expression)
    case applyAnd(Expression)
    case applyOr(Expression)
    case applyNot
}

private func iterativeIsSatisfied(_ root: Expression, by satisfiable: StringExpressionSatisfiable) -> Bool {
    var stack: [EvalFrame] = [.evaluate(root)]
    var values: [Bool] = []

    while let frame = stack.popLast() {
        switch frame {
        case .evaluate(let expr):
            switch expr {
            case is AnythingNode:
                values.append(true)
            case let c as ContainsNode:
                values.append(satisfiable.contains(phrase: c.string))
            case let n as NotNode:
                stack.append(.applyNot)
                stack.append(.evaluate(n.expression))
            case let a as AndNode:
                stack.append(.applyAnd(a.rhs))
                stack.append(.evaluate(a.lhs))
            case let o as OrNode:
                stack.append(.applyOr(o.rhs))
                stack.append(.evaluate(o.lhs))
            default:
                values.append(expr.isSatisfied(by: satisfiable))
            }
        case .applyNot:
            values.append(!values.removeLast())
        case .applyAnd(let rhs):
            if values.last == false {
                // short-circuit
            } else {
                values.removeLast()
                stack.append(.evaluate(rhs))
            }
        case .applyOr(let rhs):
            if values.last == true {
                // short-circuit
            } else {
                values.removeLast()
                stack.append(.evaluate(rhs))
            }
        }
    }
    return values.last ?? true
}

private func iterativeIsSatisfied(_ root: Expression, by satisfiable: CStringExpressionSatisfiable) -> Bool {
    var stack: [EvalFrame] = [.evaluate(root)]
    var values: [Bool] = []

    while let frame = stack.popLast() {
        switch frame {
        case .evaluate(let expr):
            switch expr {
            case is AnythingNode:
                values.append(true)
            case let c as ContainsNode:
                values.append(satisfiable.matches(needle: c.cString))
            case let n as NotNode:
                stack.append(.applyNot)
                stack.append(.evaluate(n.expression))
            case let a as AndNode:
                stack.append(.applyAnd(a.rhs))
                stack.append(.evaluate(a.lhs))
            case let o as OrNode:
                stack.append(.applyOr(o.rhs))
                stack.append(.evaluate(o.lhs))
            default:
                values.append(expr.isSatisfied(by: satisfiable))
            }
        case .applyNot:
            values.append(!values.removeLast())
        case .applyAnd(let rhs):
            if values.last == false {
                // short-circuit
            } else {
                values.removeLast()
                stack.append(.evaluate(rhs))
            }
        case .applyOr(let rhs):
            if values.last == true {
                // short-circuit
            } else {
                values.removeLast()
                stack.append(.evaluate(rhs))
            }
        }
    }
    return values.last ?? true
}
