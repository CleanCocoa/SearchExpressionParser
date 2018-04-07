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

    func testExpression_3Phrases() {
        let tokens: [Token] = [Phrase("foo"), Phrase("bar"), Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                AndNode(
                    ContainsNode("bar"),
                    ContainsNode("baz"))))
    }

    func testExpression_6Phrases() {
        let tokens: [Token] = [Phrase("1"), Phrase("2"), Phrase("3"), Phrase("4"), Phrase("5"), Phrase("6")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("1"),
                AndNode(
                    ContainsNode("2"),
                    AndNode(
                        ContainsNode("3"),
                        AndNode(
                            ContainsNode("4"),
                            AndNode(
                                ContainsNode("5"),
                                ContainsNode("6")))))))

    }

    func testExpression_AND() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [BinaryOperator.and]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("AND"))
    }

    func testExpression_PhraseBeforeAND() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.and]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("AND")))
    }

    func testExpression_ANDBeforePhrase() {
        let tokens: [Token] = [BinaryOperator.and, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("AND"),
                ContainsNode("foo")))
    }

    func testExpression_2PhrasesANDConnected() {
        let tokens: [Token] = [
            Phrase("foo"), BinaryOperator.and, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("bar")))
    }


    func testExpression_3PhrasesANDConnected() {
        let tokens: [Token] = [
            Phrase("foo"), BinaryOperator.and,
            Phrase("bar"), BinaryOperator.and,
            Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                AndNode(
                    ContainsNode("bar"),
                    ContainsNode("baz"))))
    }
}
