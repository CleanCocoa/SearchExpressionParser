//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class ParserTests: XCTestCase {

    func testExpression_EmptyTokens() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: []).expression()) else { return }

        XCTAssertEqual(expression, AnythingNode())
    }

    func testExpression_SinglePhrase() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [Phrase("foo bar")]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("foo bar"))
    }

    func testExpression_TwoPhrases() {
        let tokens: [Token] = [Phrase("foo"), Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(expression, AndNode(ContainsNode("foo"), ContainsNode("bar")))
    }
}
