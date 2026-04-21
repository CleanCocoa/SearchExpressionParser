import XCTest
@testable import SearchExpressionParser

class ExpressionEnumTests: XCTestCase {

    // MARK: - 1.1 Cases, Equatable, Sendable, CString typealias

    /// @spec expression-data-type/expression-enum-type/equatable-comparison-of-identical-trees
    func testEquatable_Anything() {
        XCTAssertEqual(Expression.anything, Expression.anything)
    }

    /// @spec expression-data-type/expression-enum-type/equatable-comparison-of-identical-trees
    func testEquatable_Contains_identical() {
        let cStr = Expression.cStringFactory("hello")
        let a = Expression.contains(string: "hello", cString: cStr)
        let b = Expression.contains(string: "hello", cString: cStr)
        XCTAssertEqual(a, b)
    }

    /// @spec expression-data-type/expression-enum-type/equatable-comparison-of-different-trees
    func testEquatable_Contains_different() {
        let a = Expression.contains(string: "hello", cString: Expression.cStringFactory("hello"))
        let b = Expression.contains(string: "world", cString: Expression.cStringFactory("world"))
        XCTAssertNotEqual(a, b)
    }

    /// @spec expression-data-type/expression-enum-type/equatable-comparison-of-identical-trees
    func testEquatable_Not_identical() {
        let a = Expression.not(.anything)
        let b = Expression.not(.anything)
        XCTAssertEqual(a, b)
    }

    /// @spec expression-data-type/expression-enum-type/equatable-comparison-of-identical-trees
    func testEquatable_And_identical() {
        let a = Expression.and(.anything, .anything)
        let b = Expression.and(.anything, .anything)
        XCTAssertEqual(a, b)
    }

    /// @spec expression-data-type/expression-enum-type/equatable-comparison-of-identical-trees
    func testEquatable_Or_identical() {
        let a = Expression.or(.anything, .anything)
        let b = Expression.or(.anything, .anything)
        XCTAssertEqual(a, b)
    }

    /// @spec expression-data-type/expression-enum-type/equatable-comparison-of-different-trees
    func testEquatable_DifferentCases() {
        XCTAssertNotEqual(Expression.anything, Expression.not(.anything))
    }

    /// @spec expression-data-type/expression-enum-type/sendable-conformance
    func testSendable() async {
        let expr = Expression.anything
        let result = await Task.detached { expr }.value
        XCTAssertEqual(result, Expression.anything)
    }

    /// @spec expression-data-type/cstring-typealias/cstring-type-alias-resolves
    func testCStringTypealias() {
        let _: SearchExpressionParser.Expression.CString = []
        let _: [CChar] = [] as SearchExpressionParser.Expression.CString
    }

    // MARK: - 1.3 cStringFactory default behavior

    /// @spec expression-data-type/cstring-factory/default-cstring-creation
    func testCStringFactory_default() {
        let result = Expression.cStringFactory("Hello")
        let expected = "hello".precomposedStringWithCanonicalMapping.cString(using: .utf8)!
        XCTAssertEqual(result, expected)
    }

    /// @spec expression-data-type/cstring-factory/custom-cstring-factory
    func testCStringFactory_custom() {
        let saved = Expression.cStringFactory
        defer { Expression.cStringFactory = saved }
        Expression.cStringFactory = { _ in [42, 0] }
        let result = Expression.cStringFactory("anything")
        XCTAssertEqual(result, [42, 0])
    }

    // MARK: - 1.5 contains convenience factory

    /// @spec expression-data-type/contains-convenience-initializer/factory-creates-contains-with-computed-cstring
    func testContainsFactory() {
        let result = Expression.contains("hello")
        let expected = Expression.contains(string: "hello", cString: Expression.cStringFactory("hello"))
        XCTAssertEqual(result, expected)
    }
}
