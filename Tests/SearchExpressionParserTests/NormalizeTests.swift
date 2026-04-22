import XCTest
@testable import SearchExpressionParser

class NormalizeTests: XCTestCase {

    // MARK: 8.1 — Leaf passthrough

    /// @spec normalize/leaf-passthrough/keyValue
    func testNormalize_KeyValue_PassesThrough() {
        let expr = Expression.keyValue(key: "tag", value: "value")
        XCTAssertEqual(normalize(expr), expr)
    }

    /// @spec normalize/leaf-passthrough/anything
    func testNormalize_Anything_PassesThrough() {
        XCTAssertEqual(normalize(.anything), .anything)
    }

    /// @spec normalize/leaf-passthrough/contains
    func testNormalize_Contains_PassesThrough() {
        let expr = Expression.contains("hello")
        XCTAssertEqual(normalize(expr), expr)
    }

    // MARK: 8.1 — Double negation elimination

    /// @spec normalize/double-negation/not-not-x-becomes-x
    func testNormalize_NotNot_Eliminates() {
        let expr = Expression.not(.not(.contains("hello")))
        XCTAssertEqual(normalize(expr), .contains("hello"))
    }

    /// @spec normalize/double-negation/not-not-not-x-becomes-not-x
    func testNormalize_TripleNot_ReducesToNot() {
        let expr = Expression.not(.not(.not(.contains("hello"))))
        XCTAssertEqual(normalize(expr), .not(.contains("hello")))
    }

    // MARK: 8.1 — De Morgan: NOT (A AND B) → NOT A OR NOT B

    /// @spec normalize/de-morgan/not-and-becomes-or-of-nots
    func testNormalize_NotAnd_DeMorgan() {
        let expr = Expression.not(.and(.contains("a"), .contains("b")))
        let expected = Expression.or(.not(.contains("a")), .not(.contains("b")))
        XCTAssertEqual(normalize(expr), expected)
    }

    // MARK: 8.1 — De Morgan: NOT (A OR B) → NOT A AND NOT B

    /// @spec normalize/de-morgan/not-or-becomes-and-of-nots
    func testNormalize_NotOr_DeMorgan() {
        let expr = Expression.not(.or(.contains("a"), .contains("b")))
        let expected = Expression.and(.not(.contains("a")), .not(.contains("b")))
        XCTAssertEqual(normalize(expr), expected)
    }

    // MARK: 8.1 — Nested cases

    /// @spec normalize/nested/not-not-and-becomes-and
    func testNormalize_NotNot_And_Passthrough() {
        let expr = Expression.not(.not(.and(.contains("a"), .contains("b"))))
        let expected = Expression.and(.contains("a"), .contains("b"))
        XCTAssertEqual(normalize(expr), expected)
    }

    /// @spec normalize/nested/deep-de-morgan
    func testNormalize_Nested_DeMorgan() {
        let inner = Expression.and(.contains("a"), .or(.contains("b"), .contains("c")))
        let expr = Expression.not(inner)
        let expected = Expression.or(
            .not(.contains("a")),
            .and(.not(.contains("b")), .not(.contains("c")))
        )
        XCTAssertEqual(normalize(expr), expected)
    }
}
