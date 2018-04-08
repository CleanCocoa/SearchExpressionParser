//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class BalanceParenthesesTests: XCTestCase {

    func testBalance_Empty() {
        XCTAssertEqual(
            balanceParentheses(tokens: []),
            [])
    }

    func testBalance_Phrases() {
        let input = [Phrase("asd"), Phrase("def")]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    func testBalance_SingleOpeningParens() {
        XCTAssertEqual(
            balanceParentheses(tokens: [OpeningParens()]),
            [Phrase("(")])
    }

//    func testBalance_10OpeningParens() {
//        XCTAssertEqual(
//            balanceParentheses(tokens: [OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens()]),
//            [Phrase("((((((((((")])
//    }

    func testBalance_SingleClosingParens() {
        XCTAssertEqual(
            balanceParentheses(tokens: [ClosingParens()]),
            [Phrase(")")])
    }

//    func testBalance_10ClosingParens() {
//        XCTAssertEqual(
//            balanceParentheses(tokens: [ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens()]),
//            [Phrase("))))))))))")])
//    }

    func testBalance_BalancedEmptyParens() {
        XCTAssertEqual(
            balanceParentheses(tokens: [OpeningParens(), ClosingParens()]),
            [OpeningParens(), ClosingParens()])
    }

    func testBalance_2LevelsOfBalancedNestedEmptyParens() {
        let input: [Token] = [
            OpeningParens(), OpeningParens(),
            ClosingParens(), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    func testBalance_BalancedParensWithStuffInBetween() {
        let input: [Token] = [OpeningParens(), Word("some"), BinaryOperator.or, Word("stuff"), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    func testBalance_2AdjacentBalancedEmptyParens() {
        let input: [Token] = [
            OpeningParens(), ClosingParens(),
            OpeningParens(), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    func testBalance_2Opening1Closing() {
        XCTAssertEqual(
            balanceParentheses(tokens: [OpeningParens(), Word("some"), OpeningParens(), ClosingParens()]),
            [Phrase("("), Word("some"), OpeningParens(), ClosingParens()])
    }

    func testBalance_1Opening2ClosingWithPhrases() {
        XCTAssertEqual(
            balanceParentheses(tokens: [OpeningParens(), Word("some"), ClosingParens(), Word("stuff"), ClosingParens()]),
            [OpeningParens(), Word("some"), ClosingParens(), Word("stuff"), Phrase(")")])
    }

    func testBalance_MultipleBalancedSequencesIsNotGreedy() {
        let input: [Token] = [
            OpeningParens(), Word("a"), ClosingParens(),
            OpeningParens(), Word("b"), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    func testBalance_NestedBalancedParens() {
        let input: [Token] = [
            OpeningParens(),
                OpeningParens(), Word("a"), ClosingParens(),
                Word("b"),
                OpeningParens(), Word("c"), ClosingParens(),
            ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }
}
