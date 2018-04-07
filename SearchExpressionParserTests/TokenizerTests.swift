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

    func testTokens_EscapeCharacter() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\").tokens()) else { return }

        XCTAssertEqual(tokens, [Escaping()])
    }

    func testTokens_EscapedEscapeCharacter() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\\\").tokens()) else { return }

        XCTAssertEqual(tokens, [Escaping(), Escaping()])
    }

    // MARK: Simple words

    func testTokens_1Character() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "x").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("x")])
    }

    func testTokens_1CharacterWithWhitespace() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "     x    ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("x")])
    }

    func testTokens_3Characters() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "foo").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("foo")])
    }

    func testTokens_2Words() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   foo   bar   ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("foo"), Word("bar")])
    }

    func testTokens_Sentence() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "Lorem ipsum dolor sit amet! Consectetur?").tokens()) else { return }

        let expectedWords = ["Lorem", "ipsum", "dolor", "sit", "amet!", "Consectetur?"].map(Word.init)
        XCTAssertEqual(tokens, expectedWords)
    }


    // MARK: Parens

    func testTokens_OpeningParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "(").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens()])
    }

    func testTokens_OpeningParensWithWhitespace() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   (     ").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens()])
    }

    func testTokens_EscapedOpeningParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\(").tokens()) else { return }

        XCTAssertEqual(tokens, [Escaping(), OpeningParens()])
    }

    func testTokens_5OpeningParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "(((((").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens()])
    }

    func testTokens_ClosingParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: ")").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens()])
    }

    func testTokens_ClosingParensWithWhitespace() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: " \t  )   ").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens()])
    }

    func testTokens_EscapedClosingParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\)").tokens()) else { return }

        XCTAssertEqual(tokens, [Escaping(), ClosingParens()])
    }

    func testTokens_4ClosingParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "))))").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens()])
    }

    func testTokens_ParenthesizedWord() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "(red)").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens(), Word("red"), ClosingParens()])
    }

    func testTokens_ParenthesizedWordWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "    ( red) ").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens(), Word("red"), ClosingParens()])
    }

    func testTokens_MixedWordsAndParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "))Yes, mighty warrior) what (you) hear now").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens(), ClosingParens(), Word("Yes,"), Word("mighty"), Word("warrior"), ClosingParens(), Word("what"), OpeningParens(), Word("you"), ClosingParens(), Word("hear"), Word("now")])
    }


    // MARK: Quotation marks

    func testTokens_Quotation() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"").tokens()) else { return }

        XCTAssertEqual(tokens, [QuotationMark()])
    }

    func testTokens_EscapedQuotation() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\\"").tokens()) else { return }

        XCTAssertEqual(tokens, [Escaping(), QuotationMark()])
    }

    func testTokens_QuotationWithWhitespae() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   \"   ").tokens()) else { return }

        XCTAssertEqual(tokens, [QuotationMark()])
    }

    func testTokens_QuotedWord() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"justice\"").tokens()) else { return }

        XCTAssertEqual(tokens, [QuotationMark(), Word("justice"), QuotationMark()])
    }

    func testTokens_QuotedPhrase() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"fair play\"").tokens()) else { return }

        XCTAssertEqual(tokens, [QuotationMark(), Word("fair"), Word("play"), QuotationMark()])
    }

    // MARK: Bang/NOT operator

    func testTokens_BangOnly() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("!")])
    }

    func testTokens_BangWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "    !  ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("!")])
    }

    func testTokens_WordWithExclamationMark() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "this!").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("this!")])
    }

    func testTokens_BangedWord_OMGIsThisWhatNativeSpeakersWouldSay() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!word").tokens()) else { return }

        XCTAssertEqual(tokens, [Operator.not, Word("word")])
    }

    func testTokens_BangedWordWithWhitespace_ThisDoesntFeelRight() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "! word").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("!"), Word("word")])
    }

    func testTokens_BangedBang_HopefullySomeoneWillCreateAPullRequestToCorrectMe() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!!").tokens()) else { return }

        XCTAssertEqual(tokens, [Operator.not, Word("!")])
    }

    func testTokens_5BangsBeforeWord_ThisKindaLookedBetterBeforeIAddedTheOthers() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!!!!!foo").tokens()) else { return }

        XCTAssertEqual(tokens, [Operator.not, Operator.not, Operator.not, Operator.not, Operator.not, Word("foo")])
    }

    func testTokens_NOTOnly() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "NOT").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("NOT")])
    }

    func testTokens_NOTWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   \t NOT  ").tokens()) else { return }

        XCTAssertEqual(tokens, [Operator.not])
    }

    func testTokens_NOTBeforeWord() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "NOT me").tokens()) else { return }

        XCTAssertEqual(tokens, [Operator.not, Word("me")])
    }

    func testTokens_WordStartingWithNOT() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "NOTest").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("NOTest")])
    }

    func testTokens_NOTBetweenWords() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "this is NOT me").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("this"), Word("is"), Operator.not, Word("me")])
    }

    func testTokens_MixedCaseNotBeforeWord() {

        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "not me").tokens()),
            [Word("not"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "Not me").tokens()),
            [Word("Not"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "nOt me").tokens()),
            [Word("nOt"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "noT me").tokens()),
            [Word("noT"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "NOt me").tokens()),
            [Word("NOt"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "NoT me").tokens()),
            [Word("NoT"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "nOT me").tokens()),
            [Word("nOT"), Word("me")])
    }
}
