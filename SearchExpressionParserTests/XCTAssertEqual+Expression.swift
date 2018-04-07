//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import SearchExpressionParser

func ==(lhs: Expression, rhs: Expression) -> Bool {

    switch (lhs, rhs) {
    case (is AnythingNode,
          is AnythingNode):
        return true

    case let (lContains as ContainsNode,
              rContains as ContainsNode):
        return lContains.string == rContains.string

    case let (lAnd as AndNode,
              rAnd as AndNode):
        return lAnd.lhs == rAnd.lhs
            && lAnd.rhs == rAnd.rhs

    case let (lOr as OrNode,
              rOr as OrNode):
        return lOr.lhs == rOr.lhs
            && lOr.rhs == rOr.rhs

    case let (lNot as NotNode,
              rNot as NotNode):
        return lNot.expression == rNot.expression

    default:
        return false
    }
}

func XCTAssertEqual(
    _ lhs: Expression,
    _ rhs: Expression,
    file: StaticString = #file, line: UInt = #line) {

    XCTAssert(lhs == rhs, "\(lhs) does not equal \(rhs)", file: file, line: line)
}
