import XCTest
@testable import SearchExpressionParser

class KeyValueTokenTests: XCTestCase {

    /// @spec keyvalue-tokenization/keyvalue-token-type/keyvalue-token-string-representation
    func testKeyValue_StringProperty_ReturnsKeyColonValue() {
        let token = KeyValueToken(key: "tag", value: "bar")
        XCTAssertEqual(token.string, "tag:bar")
    }

    func testKeyValue_KeyProperty() {
        let token = KeyValueToken(key: "title", value: "hello world")
        XCTAssertEqual(token.key, "title")
    }

    func testKeyValue_ValueProperty() {
        let token = KeyValueToken(key: "title", value: "hello world")
        XCTAssertEqual(token.value, "hello world")
    }
}
