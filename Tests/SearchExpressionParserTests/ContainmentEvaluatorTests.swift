//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class ContainmentEvaluatorTests: XCTestCase {

    // MARK: - Normalization

    func normalForm(_ evaluable: ContainmentEvaluator.Evaluable) throws -> SearchExpressionParser.Expression {
        return try ContainmentEvaluator(evaluable: evaluable).normalizedEvaluable()
    }

    /// @spec negation-normal-form/non-not-nodes-returned-unchanged/leaf-nodes-pass-through
    func testNormalized_Anything() {
        guard let normalization = XCTAssertNoThrows(try normalForm(AnythingNode())) else { return }
        XCTAssertEqual(
            normalization,
            AnythingNode())
    }

    /// @spec negation-normal-form/non-not-nodes-returned-unchanged/leaf-nodes-pass-through
    func testNormalized_Contains() {
        guard let normalization = XCTAssertNoThrows(try normalForm(ContainsNode("something"))) else { return }
        XCTAssertEqual(
            normalization,
            ContainsNode("something"))
    }

    /// @spec negation-normal-form/not-over-leaf-nodes-preserved/not-wrapping-a-containsnode
    func testNormalized_Not_1LevelDeep_Contains() {
        let expression = NotNode(ContainsNode("x"))
        guard let normalization = XCTAssertNoThrows(try normalForm(expression)) else { return }
        XCTAssertEqual(
            normalization,
            NotNode(ContainsNode("x")))
    }

    /// @spec negation-normal-form/not-over-and-applies-de-morgans-law/not-wrapping-an-and-of-two-leaf-nodes
    func testNormalized_Not_1LevelDeep_And() {
        let expression = NotNode(AndNode(ContainsNode("x"), ContainsNode("y")))
        guard let normalization = XCTAssertNoThrows(try normalForm(expression)) else { return }
        XCTAssertEqual(
            normalization,
            OrNode(NotNode(ContainsNode("x")),
                   NotNode(ContainsNode("y"))))
    }

    /// @spec negation-normal-form/not-over-or-applies-de-morgans-law/not-wrapping-an-or-of-two-leaf-nodes
    func testNormalized_Not_1LevelDeep_Or() {
        let expression = NotNode(OrNode(ContainsNode("x"), ContainsNode("y")))
        guard let normalization = XCTAssertNoThrows(try normalForm(expression)) else { return }
        XCTAssertEqual(
            normalization,
            AndNode(NotNode(ContainsNode("x")),
                    NotNode(ContainsNode("y"))))
    }

    /// @spec negation-normal-form/multi-level-normalization-through-arbitrary-nesting/two-levels-of-nesting
    func testNormalized_Not_2LevelsDeep() {
        let expression = NotNode(AndNode(
            OrNode(ContainsNode("a"),
                   ContainsNode("b")),
            AndNode(ContainsNode("c"),
                    ContainsNode("d"))))
        guard let normalization = XCTAssertNoThrows(try normalForm(expression)) else { return }
        XCTAssertEqual(
            normalization,
            OrNode(AndNode(NotNode(ContainsNode("a")),
                           NotNode(ContainsNode("b"))),
                   OrNode(NotNode(ContainsNode("c")),
                          NotNode(ContainsNode("d")))))
    }

    // MARK: - Phrases

    func phrases(_ evaluable: ContainmentEvaluator.Evaluable) -> [String] {
        return ContainmentEvaluator(evaluable: evaluable).phrases()
    }

    /// @spec phrase-extraction/anythingnode-contributes-no-phrases/wildcard-match
    func testPhrases_Anything() {
        XCTAssertEqual(phrases(AnythingNode()), [])
    }

    /// @spec phrase-extraction/containsnode-contributes-its-string-as-a-phrase/single-contains-term
    func testPhrases_Contains() {
        XCTAssertEqual(phrases(ContainsNode("foo")), ["foo"])
        XCTAssertEqual(phrases(ContainsNode("bar")), ["bar"])
    }

    /// @spec phrase-extraction/notnode-contributes-no-phrases/negated-term
    func testPhrases_Not() {
        XCTAssertEqual(phrases(NotNode(ContainsNode("foo"))), [])
        XCTAssertEqual(phrases(NotNode(ContainsNode("bar"))), [])
    }

    /// @spec negation-normal-form/phrases-extraction-excludes-negated-terms/and-with-one-negated-operand
    /// @spec phrase-extraction/andnode-concatenates-phrases-from-both-children/two-positive-terms
    /// @spec phrase-extraction/andnode-concatenates-phrases-from-both-children/one-negated-child
    func testPhrases_And() {
        XCTAssertEqual(phrases(AndNode(ContainsNode("foo"), ContainsNode("bar"))), ["foo", "bar"])
        XCTAssertEqual(phrases(AndNode(NotNode(ContainsNode("foo")), ContainsNode("bar"))), ["bar"])
        XCTAssertEqual(phrases(AndNode(ContainsNode("foo"), NotNode(ContainsNode("bar")))), ["foo"])
    }

    /// @spec phrase-extraction/ornode-concatenates-phrases-from-both-children/two-alternative-terms
    /// @spec phrase-extraction/ornode-concatenates-phrases-from-both-children/one-negated-alternative
    func testPhrases_Or() {
        XCTAssertEqual(phrases(OrNode(ContainsNode("foo"), ContainsNode("bar"))), ["foo", "bar"])
        XCTAssertEqual(phrases(OrNode(NotNode(ContainsNode("foo")), ContainsNode("bar"))), ["bar"])
        XCTAssertEqual(phrases(OrNode(ContainsNode("foo"), NotNode(ContainsNode("bar")))), ["foo"])
    }

    /// @spec negation-normal-form/recursion-depth-guard/default-recursion-limit
    func testNormalized_DefaultRecursionLimit() {
        let evaluator = ContainmentEvaluator(evaluable: ContainsNode("x"))
        XCTAssertEqual(evaluator.maxRecursion, 50)
    }

    /// @spec negation-normal-form/recursion-depth-guard/custom-recursion-limit
    func testNormalized_CustomRecursionLimit() {
        let expression = NotNode(AndNode(
            NotNode(AndNode(ContainsNode("a"), ContainsNode("b"))),
            ContainsNode("c")))
        let evaluator = ContainmentEvaluator(evaluable: expression, maxRecursion: 1)
        XCTAssertThrowsError(try evaluator.normalizedEvaluable()) { error in
            XCTAssert(error is ContainmentEvaluator.RecursionTooDeepError)
        }
    }

    /// @spec negation-normal-form/phrases-extraction-excludes-negated-terms/recursion-too-deep-returns-empty-phrases
    /// @spec phrase-extraction/containmentevaluator-returns-empty-array-on-recursion-overflow/deeply-nested-expression
    func testPhrases_RecursionTooDeep_ReturnsEmpty() {
        var deep: ContainmentEvaluator.Evaluable = ContainsNode("x")
        for _ in 0..<60 {
            deep = NotNode(NotNode(deep))
        }
        let evaluator = ContainmentEvaluator(evaluable: deep)
        XCTAssertEqual(evaluator.phrases(), [])
    }

    /// @spec phrase-extraction/containmentevaluator-normalizes-before-collecting-phrases/negated-and-expression
    func testPhrases_NormalizedBeforeCollecting() {
        let expr = NotNode(AndNode(ContainsNode("a"), ContainsNode("b")))
        let evaluator = ContainmentEvaluator(evaluable: expr)
        XCTAssertEqual(evaluator.phrases(), [])
    }

}
