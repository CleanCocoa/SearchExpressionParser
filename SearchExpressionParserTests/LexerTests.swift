//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class SearchExpressionParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLexer_EmptyString_ReturnsEmptyTokenList() {

        XCTAssert(Lexer(searchString: "").tokens().isEmpty)
    }

    func testLexer_SingleString_ReturnsContains() {

        XCTAssertEqual(Lexer(searchString: "").tokens(), [Contains])
    }
    
}
