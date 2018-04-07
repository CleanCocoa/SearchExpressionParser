//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import SearchExpressionParser

func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
    case (is AnythingNode, is AnythingNode):
        return true
    case let (lhs as ContainsNode,
              rhs as ContainsNode):
        return lhs.string == rhs.string
    default:
        return false
    }
}

func XCTAssertEqual<E2>(
    _ lhs: Expression,
    _ rhs: E2,
    file: StaticString = #file, line: UInt = #line)
    where E2: Expression
{

    guard let realLHS = lhs as? E2 else {
        XCTFail("Expected \(type(of: rhs)), got \(type(of: lhs))", file: file, line: line)
        return
    }

    XCTAssert(realLHS == rhs, "\(lhs) does not equal \(rhs)", file: file, line: line)
}
