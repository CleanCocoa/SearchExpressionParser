//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class ExpressionTests: XCTestCase {

    var irrelevant: ExpressionSatisfiable {
        return "irrelevant"
    }

    func testSatisfy_Anything() {
        XCTAssert(AnythingNode().isSatisfied(by: ""))
        XCTAssert(AnythingNode().isSatisfied(by: " "))
        XCTAssert(AnythingNode().isSatisfied(by: "\n"))
        XCTAssert(AnythingNode().isSatisfied(by: "something"))
    }

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

    func testSatisfy_And() {
        XCTAssert(     AndNode(TruthyNode(), TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssertFalse(AndNode(FalsyNode(),  TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssertFalse(AndNode(TruthyNode(), FalsyNode() ).isSatisfied(by: irrelevant))
        XCTAssertFalse(AndNode(FalsyNode(),  FalsyNode() ).isSatisfied(by: irrelevant))
    }

    func testSatisfy_Or() {
        XCTAssert(     OrNode(TruthyNode(), TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssert(     OrNode(FalsyNode(),  TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssert(     OrNode(TruthyNode(), FalsyNode() ).isSatisfied(by: irrelevant))
        XCTAssertFalse(OrNode(FalsyNode(),  FalsyNode() ).isSatisfied(by: irrelevant))
    }

    func testSatisfy_Not() {
        XCTAssertFalse(NotNode(TruthyNode()).isSatisfied(by: irrelevant))
        XCTAssert(     NotNode(FalsyNode() ).isSatisfied(by: irrelevant))
    }

}

struct FalsyNode: Expression {
    func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool {
        return false
    }
}

struct TruthyNode: Expression {
    func isSatisfied(by satisfiable: ExpressionSatisfiable) -> Bool {
        return true
    }
}
