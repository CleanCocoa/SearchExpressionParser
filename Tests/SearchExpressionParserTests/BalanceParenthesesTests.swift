//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class BalanceParenthesesTests: XCTestCase {

    /// @spec parentheses-balancing/pre-parse-transformation/empty-input
    func testBalance_Empty() {
        XCTAssertEqual(
            balanceParentheses(tokens: []),
            [])
    }

    /// @spec parentheses-balancing/pre-parse-transformation/non-parenthesis-tokens-pass-through-unchanged
    func testBalance_Phrases() {
        let input = [Phrase("asd"), Phrase("def")]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    /// @spec parentheses-balancing/unmatched-opening-parens-converted-to-phrase/single-unmatched-opening-paren
    /// @spec parsing-grammar/unbalanced-parentheses-are-converted-to-words/unmatched-opening-paren-with-no-closer
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

    /// @spec parentheses-balancing/unmatched-closing-parens-converted-to-phrase/single-unmatched-closing-paren
    /// @spec parsing-grammar/unbalanced-parentheses-are-converted-to-words/unmatched-closing-paren-at-root-level
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

    /// @spec parentheses-balancing/matched-pairs-preserved/empty-balanced-pair
    func testBalance_BalancedEmptyParens() {
        XCTAssertEqual(
            balanceParentheses(tokens: [OpeningParens(), ClosingParens()]),
            [OpeningParens(), ClosingParens()])
    }

    /// @spec parentheses-balancing/nested-balanced-parens/two-levels-of-nesting
    func testBalance_2LevelsOfBalancedNestedEmptyParens() {
        let input: [Token] = [
            OpeningParens(), OpeningParens(),
            ClosingParens(), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    /// @spec parentheses-balancing/matched-pairs-preserved/simple-balanced-pair
    func testBalance_BalancedParensWithStuffInBetween() {
        let input: [Token] = [OpeningParens(), Word("some"), BinaryOperator.or, Word("stuff"), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    /// @spec parentheses-balancing/non-greedy-matching/two-adjacent-balanced-groups
    func testBalance_2AdjacentBalancedEmptyParens() {
        let input: [Token] = [
            OpeningParens(), ClosingParens(),
            OpeningParens(), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    /// @spec parentheses-balancing/unmatched-opening-parens-converted-to-phrase/excess-opening-paren-with-balanced-pair
    func testBalance_2Opening1Closing() {
        XCTAssertEqual(
            balanceParentheses(tokens: [OpeningParens(), Word("some"), OpeningParens(), ClosingParens()]),
            [Phrase("("), Word("some"), OpeningParens(), ClosingParens()])
    }

    /// @spec parentheses-balancing/unmatched-closing-parens-converted-to-phrase/excess-closing-paren-after-balanced-pair
    func testBalance_1Opening2ClosingWithPhrases() {
        XCTAssertEqual(
            balanceParentheses(tokens: [OpeningParens(), Word("some"), ClosingParens(), Word("stuff"), ClosingParens()]),
            [OpeningParens(), Word("some"), ClosingParens(), Word("stuff"), Phrase(")")])
    }

    /// @spec parentheses-balancing/non-greedy-matching/two-adjacent-balanced-groups
    func testBalance_MultipleBalancedSequencesIsNotGreedy() {
        let input: [Token] = [
            OpeningParens(), Word("a"), ClosingParens(),
            OpeningParens(), Word("b"), ClosingParens()]
        XCTAssertEqual(
            balanceParentheses(tokens: input),
            input)
    }

    /// @spec parentheses-balancing/nested-balanced-parens/complex-nested-structure
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
