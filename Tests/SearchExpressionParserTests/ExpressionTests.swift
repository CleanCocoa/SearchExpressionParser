//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class ExpressionTests: XCTestCase {

    var irrelevant: StringExpressionSatisfiable {
        return "irrelevant"
    }

    /// @spec expression-evaluation/anythingnode-always-matches/anythingnode-with-empty-string
    /// @spec expression-evaluation/anythingnode-always-matches/anythingnode-with-arbitrary-content
    func testSatisfy_Anything() {
        XCTAssert(AnythingNode().isSatisfied(by: ""))
        XCTAssert(AnythingNode().isSatisfied(by: " "))
        XCTAssert(AnythingNode().isSatisfied(by: "\n"))
        XCTAssert(AnythingNode().isSatisfied(by: "something"))
    }

    /// @spec expression-evaluation/containsnode-substring-match/substring-found
    /// @spec expression-evaluation/containsnode-substring-match/multi-character-substring-found
    /// @spec expression-evaluation/containsnode-substring-match/substring-not-found
    /// @spec expression-evaluation/containsnode-substring-match/substring-with-space-not-found
    /// @spec expression-evaluation/containsnode-empty-string-behavior/empty-search-term-against-empty-input
    /// @spec expression-evaluation/containsnode-empty-string-behavior/empty-search-term-against-non-empty-input
    func testSatisfy_Contains() {
        XCTAssertFalse(ContainsNode("").isSatisfied(by: ""))
        XCTAssertFalse(ContainsNode("").isSatisfied(by: " "))
        XCTAssertFalse(ContainsNode("").isSatisfied(by: "\n"))
        XCTAssertFalse(ContainsNode("").isSatisfied(by: "something"))

        XCTAssertFalse(ContainsNode("a").isSatisfied(by: ""))
        XCTAssertFalse(ContainsNode("a").isSatisfied(by: " "))
        XCTAssertFalse(ContainsNode("a").isSatisfied(by: "something"))
        XCTAssert(ContainsNode("e").isSatisfied(by: "something"))
        XCTAssert(ContainsNode("et").isSatisfied(by: "something"))
        XCTAssertFalse(ContainsNode("m t").isSatisfied(by: "something"))
    }

    /// @spec expression-evaluation/andnode-short-circuit-evaluation/both-true
    /// @spec expression-evaluation/andnode-short-circuit-evaluation/left-false-right-true
    /// @spec expression-evaluation/andnode-short-circuit-evaluation/left-true-right-false
    /// @spec expression-evaluation/andnode-short-circuit-evaluation/both-false
    func testSatisfy_And() {
        XCTAssert(     AndNode(TruthyNode(), TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssertFalse(AndNode(FalsyNode(),  TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssertFalse(AndNode(TruthyNode(), FalsyNode() ).isSatisfied(by: irrelevant))
        XCTAssertFalse(AndNode(FalsyNode(),  FalsyNode() ).isSatisfied(by: irrelevant))
    }

    /// @spec expression-evaluation/ornode-short-circuit-evaluation/both-true
    /// @spec expression-evaluation/ornode-short-circuit-evaluation/left-false-right-true
    /// @spec expression-evaluation/ornode-short-circuit-evaluation/left-true-right-false
    /// @spec expression-evaluation/ornode-short-circuit-evaluation/both-false
    func testSatisfy_Or() {
        XCTAssert(     OrNode(TruthyNode(), TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssert(     OrNode(FalsyNode(),  TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssert(     OrNode(TruthyNode(), FalsyNode() ).isSatisfied(by: irrelevant))
        XCTAssertFalse(OrNode(FalsyNode(),  FalsyNode() ).isSatisfied(by: irrelevant))
    }

    /// @spec expression-evaluation/notnode-boolean-negation/negate-true
    /// @spec expression-evaluation/notnode-boolean-negation/negate-false
    func testSatisfy_Not() {
        XCTAssertFalse(NotNode(TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssert(     NotNode(FalsyNode() ).isSatisfied(by: irrelevant))
    }

    /// @spec expression-evaluation/dual-evaluation-paths/string-conformance-on-swift-string
    func testSatisfy_StringConformance() {
        XCTAssert("hello world".contains(phrase: "world"))
        XCTAssertFalse("hello world".contains(phrase: "xyz"))
    }

    /// @spec expression-evaluation/containsnode-cstring-factory/default-cstring-creation
    func testContainsNode_CStringFactory() {
        let cString = ContainsNode.cString(string: "Hello")
        let expected = "hello".precomposedStringWithCanonicalMapping.cString(using: .utf8)!
        XCTAssertEqual(cString, expected)
    }

}

struct FalsyNode: SearchExpressionParser.Expression {
    func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return false
    }

    func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return false
    }
}

struct TruthyNode: SearchExpressionParser.Expression {
    func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool {
        return true
    }

    func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool {
        return true
    }
}
