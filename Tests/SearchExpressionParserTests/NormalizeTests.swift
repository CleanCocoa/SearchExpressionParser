import XCTest
@testable import SearchExpressionParser

class NormalizeTests: XCTestCase {

    func testNormalize_KeyValue_PassesThrough() {
        let expr = Expression.keyValue(key: "tag", value: "value")
        XCTAssertEqual(normalize(expr), expr)
    }
}
