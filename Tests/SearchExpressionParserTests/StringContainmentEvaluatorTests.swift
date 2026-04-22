import XCTest
@testable import SearchExpressionParser

class StringContainmentEvaluatorTests: XCTestCase {

    // MARK: 5.1 — init stores haystack and haystackCString

    /// @spec string-containment-evaluator/initialization/stores-haystack
    func testInit_storesHaystack() {
        let e = StringContainmentEvaluator("Hello World")
        XCTAssertEqual(e.haystack, "Hello World")
    }

    /// @spec string-containment-evaluator/initialization/stores-haystackCString
    func testInit_storesHaystackCString() {
        let e = StringContainmentEvaluator("Hello")
        let expected = Expression.cStringFactory("Hello")
        XCTAssertEqual(e.haystackCString, expected)
    }

    // MARK: 5.2 — evaluateContains: found, not found, empty needle, NUL-only needle

    /// @spec string-containment-evaluator/evaluate-contains/found
    func testEvaluateContains_found() {
        let e = StringContainmentEvaluator("hello world")
        let needle = Expression.cStringFactory("world")
        XCTAssertTrue(e.evaluateContains("world", cString: needle))
    }

    /// @spec string-containment-evaluator/evaluate-contains/not-found
    func testEvaluateContains_notFound() {
        let e = StringContainmentEvaluator("hello world")
        let needle = Expression.cStringFactory("xyz")
        XCTAssertFalse(e.evaluateContains("xyz", cString: needle))
    }

    /// @spec string-containment-evaluator/evaluate-contains/empty-needle
    func testEvaluateContains_emptyNeedle() {
        let e = StringContainmentEvaluator("hello world")
        XCTAssertFalse(e.evaluateContains("", cString: []))
    }

    /// @spec string-containment-evaluator/evaluate-contains/nul-only-needle
    func testEvaluateContains_nulOnlyNeedle() {
        let e = StringContainmentEvaluator("hello world")
        XCTAssertFalse(e.evaluateContains("", cString: [0]))
    }

    // MARK: 5.3 — evaluateKeyValue returns false

    /// @spec string-containment-evaluator/evaluate-key-value/always-false
    func testEvaluateKeyValue_returnsFalse() {
        let e = StringContainmentEvaluator("tag:value")
        XCTAssertFalse(e.evaluateKeyValue(key: "tag", value: "value"))
    }

    // MARK: 5.5 — full tree integration via evaluate(_:with:) with AND, OR, NOT

    /// @spec string-containment-evaluator/integration/and-both-match
    func testIntegration_and_bothMatch() {
        let e = StringContainmentEvaluator("hello world")
        let expr = Expression.and(.contains("hello"), .contains("world"))
        XCTAssertTrue(evaluate(expr, with: e))
    }

    /// @spec string-containment-evaluator/integration/and-one-missing
    func testIntegration_and_oneMissing() {
        let e = StringContainmentEvaluator("hello world")
        let expr = Expression.and(.contains("hello"), .contains("xyz"))
        XCTAssertFalse(evaluate(expr, with: e))
    }

    /// @spec string-containment-evaluator/integration/or-one-match
    func testIntegration_or_oneMatch() {
        let e = StringContainmentEvaluator("hello world")
        let expr = Expression.or(.contains("hello"), .contains("xyz"))
        XCTAssertTrue(evaluate(expr, with: e))
    }

    /// @spec string-containment-evaluator/integration/or-neither-match
    func testIntegration_or_neitherMatch() {
        let e = StringContainmentEvaluator("hello world")
        let expr = Expression.or(.contains("abc"), .contains("xyz"))
        XCTAssertFalse(evaluate(expr, with: e))
    }

    /// @spec string-containment-evaluator/integration/not-negates
    func testIntegration_not_negates() {
        let e = StringContainmentEvaluator("hello world")
        XCTAssertFalse(evaluate(Expression.not(.contains("hello")), with: e))
        XCTAssertTrue(evaluate(Expression.not(.contains("xyz")), with: e))
    }

    /// @spec string-containment-evaluator/integration/nested-tree
    func testIntegration_nestedTree() {
        let e = StringContainmentEvaluator("swift programming language")
        let expr = Expression.and(
            .contains("swift"),
            .or(.contains("programming"), .contains("xyz"))
        )
        XCTAssertTrue(evaluate(expr, with: e))
    }
}
