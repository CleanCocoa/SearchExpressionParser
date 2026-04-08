//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class ParserTests: XCTestCase {

    /// @spec parsing-grammar/empty-input-produces-anythingnode/no-tokens-provided
    func testExpression_EmptyTokens() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: []).expression()) else { return }

        XCTAssertEqual(expression, AnythingNode())
    }

    /// @spec parsing-grammar/single-token-produces-containsnode/single-phrase-token
    func testExpression_SinglePhrase() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [Phrase("foo bar")]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("foo bar"))
    }


    // MARK: AND Operator

    /// @spec parsing-grammar/implicit-and-for-adjacent-terms/two-adjacent-phrases
    func testExpression_TwoPhrases() {
        let tokens: [Token] = [Phrase("foo"), Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(expression, AndNode(ContainsNode("foo"), ContainsNode("bar")))
    }

    /// @spec parsing-grammar/implicit-and-for-adjacent-terms/three-adjacent-phrases-are-right-associative
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

    /// @spec parsing-grammar/lone-binary-operator-becomes-literal-text/lone-and
    func testExpression_AND() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [BinaryOperator.and]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("AND"))
    }

    /// @spec parsing-grammar/trailing-binary-operator-becomes-literal-text/trailing-and
    func testExpression_PhraseBeforeAND() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.and]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("AND")))
    }

    /// @spec parsing-grammar/leading-binary-operator-becomes-implicit-and/leading-and-before-phrase
    func testExpression_ANDBeforePhrase() {
        let tokens: [Token] = [BinaryOperator.and, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("AND"),
                ContainsNode("foo")))
    }

    /// @spec parsing-grammar/explicit-and-operator/two-phrases-with-explicit-and
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


    /// @spec parsing-grammar/explicit-and-operator/three-phrases-with-explicit-and-are-right-associative
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

    /// @spec parsing-grammar/lone-binary-operator-becomes-literal-text/lone-or
    func testExpression_OR() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [BinaryOperator.or]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("OR"))
    }

    /// @spec parsing-grammar/trailing-binary-operator-becomes-literal-text/trailing-or
    func testExpression_PhraseBeforeOR() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.or]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("OR")))
    }

    /// @spec parsing-grammar/leading-binary-operator-becomes-implicit-and/leading-or-before-phrase
    func testExpression_ORBeforePhrase() {
        let tokens: [Token] = [BinaryOperator.or, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("OR"),
                ContainsNode("foo")))
    }

    /// @spec parsing-grammar/or-operator/two-phrases-with-or
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

    /// @spec parsing-grammar/and-and-or-have-no-precedence-difference/or-followed-by-and
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

    /// @spec parsing-grammar/and-and-or-have-no-precedence-difference/implicit-and-followed-by-or
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

    /// @spec parsing-grammar/lone-unary-operator-becomes-literal-text/lone-bang
    func testExpression_Bang() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [UnaryOperator.bang]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("!"))
    }

    /// @spec parsing-grammar/trailing-unary-operator-becomes-literal-text/trailing-bang
    func testExpression_PhraseBeforeBang() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.bang]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("!")))
    }

    /// @spec parsing-grammar/unary-notbang-binds-to-immediately-following-primary/bang-before-single-phrase
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

    /// @spec parsing-grammar/unary-notbang-binds-to-immediately-following-primary/not-does-not-extend-past-immediate-primary
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

    /// @spec parsing-grammar/lone-unary-operator-becomes-literal-text/lone-not
    func testExpression_NOT() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [UnaryOperator.not]).expression()) else { return }

        XCTAssertEqual(expression, ContainsNode("NOT"))
    }

    /// @spec parsing-grammar/trailing-unary-operator-becomes-literal-text/trailing-not
    func testExpression_PhraseBeforeNOT() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.not]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }

        XCTAssertEqual(
            expression,
            AndNode(
                ContainsNode("foo"),
                ContainsNode("NOT")))
    }

    /// @spec parsing-grammar/unary-notbang-binds-to-immediately-following-primary/not-before-single-phrase
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

    /// @spec parsing-grammar/unary-notbang-binds-to-immediately-following-primary/not-does-not-extend-past-immediate-primary
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

    /// @spec parsing-grammar/not-applies-to-parenthesized-group/not-before-parenthesized-or
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

    /// @spec parsing-grammar/parenthesized-grouping/two-parenthesized-groups-with-implicit-and
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

    /// @spec parsing-grammar/empty-parentheses-become-literal-text/empty-parens
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
