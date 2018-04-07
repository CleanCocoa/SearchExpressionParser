//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import SearchExpressionParser

func ==(lhs: Token, rhs: Token) -> Bool {

    return type(of: lhs) == type(of: rhs)
        && lhs.string == rhs.string
}

func XCTAssertEqual(
    _ lhs: [Token]?,
    _ rhs: [Token],
    file: StaticString = #file, line: UInt = #line) {

    guard let lhs = lhs else {
        XCTFail("nil is not equal to \(rhs.debugDescription)", file: file, line: line)
        return
    }
    
    XCTAssertEqual(lhs, rhs, file: file, line: line)
}

func XCTAssertEqual(
    _ lhs: [Token],
    _ rhs: [Token],
    file: StaticString = #file, line: UInt = #line) {

    let leftEquatable  = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }

    XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
}
