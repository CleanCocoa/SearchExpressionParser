import XCTest
@testable import SearchExpressionParser

// MARK: - Task 2.1: A String-result evaluator must implement all six methods

private struct StringEvaluator: ExpressionEvaluator {
    typealias Result = String
    func evaluateContains(_ string: String, cString: [CChar]) -> String { "contains:\(string)" }
    func evaluateKeyValue(key: String, value: String) -> String { "kv:\(key)=\(value)" }
    func evaluateAnything() -> String { "anything" }
    func evaluateNot(_ inner: String) -> String { "not(\(inner))" }
    func evaluateAnd(_ lhs: String, _ rhs: String) -> String { "and(\(lhs),\(rhs))" }
    func evaluateOr(_ lhs: String, _ rhs: String) -> String { "or(\(lhs),\(rhs))" }
}

// MARK: - Task 3.3: A Bool evaluator only needs evaluateContains + evaluateKeyValue

private struct MinimalBoolEvaluator: ExpressionEvaluator {
    typealias Result = Bool
    func evaluateContains(_ string: String, cString: [CChar]) -> Bool { string == "yes" }
    func evaluateKeyValue(key: String, value: String) -> Bool { false }
}

// MARK: - Short-circuit spy

private final class CountingEvaluator: ExpressionEvaluator {
    typealias Result = Bool
    var callLog: [String] = []
    func evaluateContains(_ string: String, cString: [CChar]) -> Bool {
        callLog.append(string)
        return string == "hit"
    }
    func evaluateKeyValue(key: String, value: String) -> Bool { false }
}

// MARK: -

class ExpressionEvaluatorTests: XCTestCase {

    // MARK: 2.1 — String-result evaluator covers all six protocol methods

    /// @spec expression-evaluator/protocol-conformance/string-result-evaluator-implements-all-methods
    func testStringEvaluator_evaluateContains() {
        let e = StringEvaluator()
        XCTAssertEqual(e.evaluateContains("hello", cString: []), "contains:hello")
    }

    /// @spec expression-evaluator/protocol-conformance/string-result-evaluator-implements-all-methods
    func testStringEvaluator_evaluateKeyValue() {
        let e = StringEvaluator()
        XCTAssertEqual(e.evaluateKeyValue(key: "k", value: "v"), "kv:k=v")
    }

    /// @spec expression-evaluator/protocol-conformance/string-result-evaluator-implements-all-methods
    func testStringEvaluator_evaluateAnything() {
        let e = StringEvaluator()
        XCTAssertEqual(e.evaluateAnything(), "anything")
    }

    /// @spec expression-evaluator/protocol-conformance/string-result-evaluator-implements-all-methods
    func testStringEvaluator_evaluateNot() {
        let e = StringEvaluator()
        XCTAssertEqual(e.evaluateNot("x"), "not(x)")
    }

    /// @spec expression-evaluator/protocol-conformance/string-result-evaluator-implements-all-methods
    func testStringEvaluator_evaluateAnd() {
        let e = StringEvaluator()
        XCTAssertEqual(e.evaluateAnd("a", "b"), "and(a,b)")
    }

    /// @spec expression-evaluator/protocol-conformance/string-result-evaluator-implements-all-methods
    func testStringEvaluator_evaluateOr() {
        let e = StringEvaluator()
        XCTAssertEqual(e.evaluateOr("a", "b"), "or(a,b)")
    }

    // MARK: 3.1 — Bool extension defaults

    /// @spec expression-evaluator/bool-defaults/evaluateNot-default
    func testBoolDefault_evaluateNot() {
        let e = MinimalBoolEvaluator()
        XCTAssertEqual(e.evaluateNot(true), false)
        XCTAssertEqual(e.evaluateNot(false), true)
    }

    /// @spec expression-evaluator/bool-defaults/evaluateAnd-default
    func testBoolDefault_evaluateAnd() {
        let e = MinimalBoolEvaluator()
        XCTAssertEqual(e.evaluateAnd(true, true), true)
        XCTAssertEqual(e.evaluateAnd(true, false), false)
        XCTAssertEqual(e.evaluateAnd(false, true), false)
        XCTAssertEqual(e.evaluateAnd(false, false), false)
    }

    /// @spec expression-evaluator/bool-defaults/evaluateOr-default
    func testBoolDefault_evaluateOr() {
        let e = MinimalBoolEvaluator()
        XCTAssertEqual(e.evaluateOr(true, true), true)
        XCTAssertEqual(e.evaluateOr(true, false), true)
        XCTAssertEqual(e.evaluateOr(false, true), true)
        XCTAssertEqual(e.evaluateOr(false, false), false)
    }

    /// @spec expression-evaluator/bool-defaults/evaluateAnything-default
    func testBoolDefault_evaluateAnything() {
        let e = MinimalBoolEvaluator()
        XCTAssertEqual(e.evaluateAnything(), true)
    }

    // MARK: 3.3 — MinimalBoolEvaluator compiles and works with only two methods implemented

    /// @spec expression-evaluator/bool-defaults/minimal-bool-evaluator-compiles
    func testMinimalBoolEvaluator_compiles() {
        let e = MinimalBoolEvaluator()
        XCTAssertTrue(e.evaluateContains("yes", cString: []))
        XCTAssertFalse(e.evaluateContains("no", cString: []))
    }

    // MARK: 4.1 — evaluate(_:with:) dispatches leaf nodes

    /// @spec expression-evaluator/evaluate-function/dispatches-anything
    func testEvaluate_anything() {
        let e = StringEvaluator()
        XCTAssertEqual(evaluate(.anything, with: e), "anything")
    }

    /// @spec expression-evaluator/evaluate-function/dispatches-contains
    func testEvaluate_contains() {
        let e = StringEvaluator()
        XCTAssertEqual(evaluate(.contains("hello"), with: e), "contains:hello")
    }

    /// @spec expression-evaluator/evaluate-function/dispatches-keyValue
    func testEvaluate_keyValue() {
        let e = StringEvaluator()
        XCTAssertEqual(evaluate(.keyValue(key: "k", value: "v"), with: e), "kv:k=v")
    }

    // MARK: 4.2 — evaluate(_:with:) dispatches composite nodes

    /// @spec expression-evaluator/evaluate-function/dispatches-not
    func testEvaluate_not() {
        let e = StringEvaluator()
        XCTAssertEqual(evaluate(.not(.anything), with: e), "not(anything)")
    }

    /// @spec expression-evaluator/evaluate-function/dispatches-and
    func testEvaluate_and() {
        let e = StringEvaluator()
        XCTAssertEqual(evaluate(.and(.anything, .contains("x")), with: e), "and(anything,contains:x)")
    }

    /// @spec expression-evaluator/evaluate-function/dispatches-or
    func testEvaluate_or() {
        let e = StringEvaluator()
        XCTAssertEqual(evaluate(.or(.anything, .contains("x")), with: e), "or(anything,contains:x)")
    }

    // MARK: 4.4 — AND short-circuit: false left skips right

    /// @spec expression-evaluator/short-circuit/and-false-left-skips-right
    func testShortCircuit_and_falseLeft_skipsRight() {
        let e = CountingEvaluator()
        let expr = Expression.and(.contains("miss"), .contains("hit"))
        let result: Bool = evaluate(expr, with: e)
        XCTAssertFalse(result)
        XCTAssertEqual(e.callLog, ["miss"])
    }

    /// @spec expression-evaluator/short-circuit/and-true-left-evaluates-right
    func testShortCircuit_and_trueLeft_evaluatesRight() {
        let e = CountingEvaluator()
        let expr = Expression.and(.contains("hit"), .contains("miss"))
        let result: Bool = evaluate(expr, with: e)
        XCTAssertFalse(result)
        XCTAssertEqual(e.callLog, ["hit", "miss"])
    }

    // MARK: 4.5 — OR short-circuit: true left skips right

    /// @spec expression-evaluator/short-circuit/or-true-left-skips-right
    func testShortCircuit_or_trueLeft_skipsRight() {
        let e = CountingEvaluator()
        let expr = Expression.or(.contains("hit"), .contains("miss"))
        let result: Bool = evaluate(expr, with: e)
        XCTAssertTrue(result)
        XCTAssertEqual(e.callLog, ["hit"])
    }

    /// @spec expression-evaluator/short-circuit/or-false-left-evaluates-right
    func testShortCircuit_or_falseLeft_evaluatesRight() {
        let e = CountingEvaluator()
        let expr = Expression.or(.contains("miss"), .contains("hit"))
        let result: Bool = evaluate(expr, with: e)
        XCTAssertTrue(result)
        XCTAssertEqual(e.callLog, ["miss", "hit"])
    }
}
