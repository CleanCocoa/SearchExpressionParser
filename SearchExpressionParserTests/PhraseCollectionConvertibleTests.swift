//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class PhraseCollectionConvertibleTests: XCTestCase {

    func testPhrases() {
        XCTAssertEqual(AnythingNode().phrases, [])
        XCTAssertEqual(ContainsNode("foo").phrases, ["foo"])
        XCTAssertEqual(NotNode(ContainsNode("foo")).phrases, [])
        XCTAssertEqual(AndNode(ContainsNode("foo"), ContainsNode("bar")).phrases, ["foo", "bar"])
        XCTAssertEqual(OrNode(ContainsNode("foo"), ContainsNode("bar")).phrases, ["foo", "bar"])
    }
}
