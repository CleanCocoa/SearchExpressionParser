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


    // MARK: AND Operator

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


    // MARK: OR Operator

    func testExpression_OR() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [BinaryOperator.or]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("OR"))
    }

    func testExpression_PhraseBeforeOR() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.or]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("OR")))
    }

    func testExpression_ORBeforePhrase() {
        let tokens: [Token] = [BinaryOperator.or, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("OR"),
                ContainsNode("foo")))
    }

    func testExpression_2PhrasesORConnected() {
        let tokens: [Token] = [
            Phrase("foo"), BinaryOperator.or, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            OrNode(
                ContainsNode("foo"),
                ContainsNode("bar")))
    }

    func testExpression_PhrasesANDandORConnected() {
        let tokens: [Token] = [
            Phrase("foo"), BinaryOperator.or,
            Phrase("bar"), BinaryOperator.and,
            Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            OrNode(
                ContainsNode("foo"),
                AndNode(
                    ContainsNode("bar"),
                    ContainsNode("baz"))))
    }

    func testExpression_AdjacentPhrasesAndORConnection() {
        let tokens: [Token] = [
            Phrase("foo"),
            Phrase("bar"), BinaryOperator.or,
            Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                OrNode(
                    ContainsNode("bar"),
                    ContainsNode("baz"))))
    }


    // MARK: Bang operator

    func testExpression_Bang() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [UnaryOperator.bang]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("!"))
    }

    func testExpression_PhraseBeforeBang() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.bang]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("!")))
    }

    func testExpression_BangBeforePhrase() {
        let tokens: [Token] = [UnaryOperator.bang, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            NotNode(ContainsNode("foo")))
    }

    func testExpression_2PhrasesWithBangBeforeFirst() {
        let tokens: [Token] = [
            UnaryOperator.bang, Phrase("foo"),
            Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                NotNode(ContainsNode("foo")),
                ContainsNode("bar")))
    }

    func testExpression_2PhrasesWithBangBeforeLast() {
        let tokens: [Token] = [
            Phrase("foo"),
            UnaryOperator.bang, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                NotNode(ContainsNode("bar"))))
    }

    func testExpression_BangDoesNotAffectUnparenthesizedSequence() {
        let tokens: [Token] = [
            UnaryOperator.bang, Phrase("a"), BinaryOperator.or,
            Phrase("b"),
            Phrase("c")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            OrNode(
                NotNode(ContainsNode("a")),
                AndNode(
                    ContainsNode("b"),
                    ContainsNode("c"))))
    }


    // MARK: NOT operator

    func testExpression_NOT() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [UnaryOperator.not]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("NOT"))
    }

    func testExpression_PhraseBeforeNOT() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.not]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("NOT")))
    }

    func testExpression_NOTBeforePhrase() {
        let tokens: [Token] = [UnaryOperator.not, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            NotNode(ContainsNode("foo")))
    }

    func testExpression_2PhrasesWithNOTBeforeFirst() {
        let tokens: [Token] = [
            UnaryOperator.not, Phrase("foo"),
            Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                NotNode(ContainsNode("foo")),
                ContainsNode("bar")))
    }

    func testExpression_2PhrasesWithNOTBeforeLast() {
        let tokens: [Token] = [
            Phrase("foo"),
            UnaryOperator.not, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                NotNode(ContainsNode("bar"))))
    }

    func testExpression_NOTDoesNotAffectUnparenthesizedSequence() {
        let tokens: [Token] = [
            UnaryOperator.not, Phrase("a"), BinaryOperator.or,
            Phrase("b"),
            Phrase("c")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            OrNode(
                NotNode(ContainsNode("a")),
                AndNode(
                    ContainsNode("b"),
                    ContainsNode("c"))))
    }

    func testExpression_NOTAffectsParenthesizedExpression() {
        let tokens: [Token] = [
            UnaryOperator.not,
            OpeningParens(), Phrase("a"), BinaryOperator.or, Phrase("b"), ClosingParens()]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            NotNode(OrNode(
                ContainsNode("a"),
                ContainsNode("b"))))
    }

    func testExpression_ParensPairsWithImplicitAnd() {
        let tokens: [Token] = [
            OpeningParens(), Phrase("a"), BinaryOperator.or, Phrase("b"), ClosingParens(),
            OpeningParens(), Phrase("c"), BinaryOperator.and, Phrase("d"), ClosingParens()]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                OrNode(
                    ContainsNode("a"),
                    ContainsNode("b")),
                AndNode(
                    ContainsNode("c"),
                    ContainsNode("d"))))
    }

    func testExpression_EmptyParens() {
        let tokens: [Token] = [
            OpeningParens(), ClosingParens(),
            OpeningParens(), OpeningParens(), ClosingParens(), ClosingParens()]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                AndNode(
                    ContainsNode("("),
                    ContainsNode(")")),
                AndNode(
                    ContainsNode("("),
                    ContainsNode(")"))))
    }

}
