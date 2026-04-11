//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class ContainmentEvaluatorTests: XCTestCase {

    // MARK: - Normalization

    func normalForm(_ evaluable: ContainmentEvaluator.Evaluable) -> SearchExpressionParser.Expression {
        return ContainmentEvaluator(evaluable: evaluable).normalizedEvaluable()
    }

    /// @spec negation-normal-form/non-not-nodes-returned-unchanged/leaf-nodes-pass-through
    func testNormalized_Anything() {
        XCTAssertEqual(
            normalForm(AnythingNode()),
            AnythingNode())
    }

    /// @spec negation-normal-form/non-not-nodes-returned-unchanged/leaf-nodes-pass-through
    func testNormalized_Contains() {
        XCTAssertEqual(
            normalForm(ContainsNode("something")),
            ContainsNode("something"))
    }

    /// @spec negation-normal-form/not-over-leaf-nodes-preserved/not-wrapping-a-containsnode
    func testNormalized_Not_1LevelDeep_Contains() {
        let expression = NotNode(ContainsNode("x"))
        XCTAssertEqual(
            normalForm(expression),
            NotNode(ContainsNode("x")))
    }

    /// @spec negation-normal-form/not-over-and-applies-de-morgans-law/not-wrapping-an-and-of-two-leaf-nodes
    func testNormalized_Not_1LevelDeep_And() {
        let expression = NotNode(AndNode(ContainsNode("x"), ContainsNode("y")))
        XCTAssertEqual(
            normalForm(expression),
            OrNode(NotNode(ContainsNode("x")),
                   NotNode(ContainsNode("y"))))
    }

    /// @spec negation-normal-form/not-over-or-applies-de-morgans-law/not-wrapping-an-or-of-two-leaf-nodes
    func testNormalized_Not_1LevelDeep_Or() {
        let expression = NotNode(OrNode(ContainsNode("x"), ContainsNode("y")))
        XCTAssertEqual(
            normalForm(expression),
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
        XCTAssertEqual(
            normalForm(expression),
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

    /// @spec negation-normal-form/recursion-depth-guard/default-initialization-no-longer-enforces-limit
    func testPhrases_DeepNesting_Succeeds() {
        var deep: ContainmentEvaluator.Evaluable = ContainsNode("x")
        for _ in 0..<60 {
            deep = NotNode(NotNode(deep))
        }
        let evaluator = ContainmentEvaluator(evaluable: deep)
        XCTAssertEqual(evaluator.phrases(), ["x"])
    }

    /// @spec phrase-extraction/containmentevaluator-normalizes-before-collecting-phrases/negated-and-expression
    func testPhrases_NormalizedBeforeCollecting() {
        let expr = NotNode(AndNode(ContainsNode("a"), ContainsNode("b")))
        let evaluator = ContainmentEvaluator(evaluable: expr)
        XCTAssertEqual(evaluator.phrases(), [])
    }

}
