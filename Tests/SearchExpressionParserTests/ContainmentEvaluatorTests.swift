//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class ContainmentEvaluatorTests: XCTestCase {

    // MARK: - Normalization

    func normalForm(_ evaluable: ContainmentEvaluator.Evaluable) throws -> Expression {
        return try ContainmentEvaluator(evaluable: evaluable).normalizedEvaluable()
    }

    func testNormalized_Anything() {
        guard let normalization = XCTAssertNoThrows(try normalForm(AnythingNode())) else { return }
        XCTAssertEqual(
            normalization,
            AnythingNode())
    }

    func testNormalized_Contains() {
        guard let normalization = XCTAssertNoThrows(try normalForm(ContainsNode("something"))) else { return }
        XCTAssertEqual(
            normalization,
            ContainsNode("something"))
    }

    func testNormalized_Not_1LevelDeep_Contains() {
        let expression = NotNode(ContainsNode("x"))
        guard let normalization = XCTAssertNoThrows(try normalForm(expression)) else { return }
        XCTAssertEqual(
            normalization,
            NotNode(ContainsNode("x")))
    }

    func testNormalized_Not_1LevelDeep_And() {
        let expression = NotNode(AndNode(ContainsNode("x"), ContainsNode("y")))
        guard let normalization = XCTAssertNoThrows(try normalForm(expression)) else { return }
        XCTAssertEqual(
            normalization,
            OrNode(NotNode(ContainsNode("x")),
                   NotNode(ContainsNode("y"))))
    }

    func testNormalized_Not_1LevelDeep_Or() {
        let expression = NotNode(OrNode(ContainsNode("x"), ContainsNode("y")))
        guard let normalization = XCTAssertNoThrows(try normalForm(expression)) else { return }
        XCTAssertEqual(
            normalization,
            AndNode(NotNode(ContainsNode("x")),
                    NotNode(ContainsNode("y"))))
    }

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

    func testPhrases_Anything() {
        XCTAssertEqual(phrases(AnythingNode()), [])
    }

    func testPhrases_Contains() {
        XCTAssertEqual(phrases(ContainsNode("foo")), ["foo"])
        XCTAssertEqual(phrases(ContainsNode("bar")), ["bar"])
    }

    func testPhrases_Not() {
        XCTAssertEqual(phrases(NotNode(ContainsNode("foo"))), [])
        XCTAssertEqual(phrases(NotNode(ContainsNode("bar"))), [])
    }

    func testPhrases_And() {
        XCTAssertEqual(phrases(AndNode(ContainsNode("foo"), ContainsNode("bar"))), ["foo", "bar"])
        XCTAssertEqual(phrases(AndNode(NotNode(ContainsNode("foo")), ContainsNode("bar"))), ["bar"])
        XCTAssertEqual(phrases(AndNode(ContainsNode("foo"), NotNode(ContainsNode("bar")))), ["foo"])
    }

    func testPhrases_Or() {
        XCTAssertEqual(phrases(OrNode(ContainsNode("foo"), ContainsNode("bar"))), ["foo", "bar"])
        XCTAssertEqual(phrases(OrNode(NotNode(ContainsNode("foo")), ContainsNode("bar"))), ["bar"])
        XCTAssertEqual(phrases(OrNode(ContainsNode("foo"), NotNode(ContainsNode("bar")))), ["foo"])
    }

}
