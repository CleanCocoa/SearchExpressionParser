import XCTest
@testable import SearchExpressionParser

final class KeyValueNodesTests: XCTestCase {

    // MARK: - Task 1.1: Single .keyValue leaf

    func test_singleKeyValueLeaf_returnsOnePair() {
        let result = keyValueNodes(in: .keyValue(key: "tag", value: "bar"))
        XCTAssertEqual(result.map { $0.key }, ["tag"])
        XCTAssertEqual(result.map { $0.value }, ["bar"])
    }

    // MARK: - Task 1.2: Non-key-value expressions return []

    func test_containsNode_returnsEmpty() {
        let result = keyValueNodes(in: .contains("hello"))
        XCTAssertTrue(result.isEmpty)
    }

    func test_anythingNode_returnsEmpty() {
        let result = keyValueNodes(in: .anything)
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Task 1.3: Traversal through .and, .or, .not composites

    func test_keyValueInAnd_returnsKeyValue() {
        let result = keyValueNodes(in: .and(.contains("foo"), .keyValue(key: "tag", value: "bar")))
        XCTAssertEqual(result.map { $0.key }, ["tag"])
        XCTAssertEqual(result.map { $0.value }, ["bar"])
    }

    func test_keyValuesInOr_returnsBoth() {
        let result = keyValueNodes(in: .or(.keyValue(key: "tag", value: "a"), .keyValue(key: "tag", value: "b")))
        XCTAssertEqual(result.map { $0.key }, ["tag", "tag"])
        XCTAssertEqual(result.map { $0.value }, ["a", "b"])
    }

    func test_keyValueInNot_returnsKeyValue() {
        let result = keyValueNodes(in: .not(.keyValue(key: "tag", value: "bar")))
        XCTAssertEqual(result.map { $0.key }, ["tag"])
        XCTAssertEqual(result.map { $0.value }, ["bar"])
    }

    // MARK: - Task 1.4: Preserving duplicates

    func test_duplicateKeyValuePairs_returnsBothEntries() {
        let result = keyValueNodes(in: .and(.keyValue(key: "tag", value: "a"), .keyValue(key: "tag", value: "a")))
        XCTAssertEqual(result.map { $0.key }, ["tag", "tag"])
        XCTAssertEqual(result.map { $0.value }, ["a", "a"])
    }

    // MARK: - Task 1.5: Deeply nested trees

    func test_deeplyNestedTree_returnsAllKeyValues() {
        let expr = Expression.and(
            .or(.keyValue(key: "tag", value: "a"), .contains("x")),
            .not(.keyValue(key: "title", value: "b"))
        )
        let result = keyValueNodes(in: expr)
        XCTAssertEqual(result.map { $0.key }.sorted(), ["tag", "title"])
        XCTAssertEqual(result.map { $0.value }.sorted(), ["a", "b"])
    }
}
