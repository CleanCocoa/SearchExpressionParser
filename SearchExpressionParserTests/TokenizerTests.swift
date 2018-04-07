//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class TokenizerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTokens_EmptyString_ReturnsEmptyTokenList() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "").tokens()) else { return }

        XCTAssert(tokens.isEmpty)
    }

    func testTokens_SingleWhitespace_ReturnsEmptyTokenList() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: " ").tokens()) else { return }

        XCTAssert(tokens.isEmpty)
    }

    func testTokens_LotsaWhitespace_ReturnsEmptyTokenList() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "          ").tokens()) else { return }

        XCTAssert(tokens.isEmpty)
    }

    func testTokens_1Character_ReturnsWord() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "x").tokens()) else { return }

        XCTAssertEqual(tokens, [Word(string: "x")])
    }

    func testTokens_1CharacterWithWhitespace_ReturnsWordWithCharacter() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "     x    ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word(string: "x")])
    }

    func testTokens_3Characters_ReturnsWord() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "foo").tokens()) else { return }

        XCTAssertEqual(tokens, [Word(string: "foo")])
    }

    func testTokens_2Words_ReturnsWords() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   foo   bar   ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word(string: "foo"), Word(string: "bar")])
    }

    func testTokens_Sentence_ReturnsWords() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "Lorem ipsum dolor sit amet! Consectetur?").tokens()) else { return }

        let expectedWords = ["Lorem", "ipsum", "dolor", "sit", "amet!", "Consectetur?"].map(Word.init(string:))
        XCTAssertEqual(tokens, expectedWords)
    }
    
}
