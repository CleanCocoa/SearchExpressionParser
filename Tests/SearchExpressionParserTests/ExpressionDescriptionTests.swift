import XCTest
@testable import SearchExpressionParser

class ExpressionDescriptionTests: XCTestCase {

    func testDescription_anything() {
        XCTAssertEqual(Expression.anything.description, "anything")
    }

    func testDescription_contains() {
        let expr = Expression.contains(string: "hello", cString: Expression.cStringFactory("hello"))
        XCTAssertEqual(expr.description, "hello")
    }

    func testDescription_not() {
        let expr = Expression.not(.anything)
        XCTAssertEqual(expr.description, "NOT anything")
    }

    func testDescription_and() {
        let expr = Expression.and(.anything, .anything)
        XCTAssertEqual(expr.description, "(anything AND anything)")
    }

    func testDescription_or() {
        let expr = Expression.or(.anything, .anything)
        XCTAssertEqual(expr.description, "(anything OR anything)")
    }

    func testDescription_keyValue() {
        let expr = Expression.keyValue(key: "tag", value: "swift")
        XCTAssertEqual(expr.description, "tag:swift")
    }

    func testDescription_nested() {
        let expr = Expression.and(.not(.contains("hello")), .or(.anything, .contains("world")))
        XCTAssertEqual(expr.description, "(NOT hello AND (anything OR world))")
    }
}
