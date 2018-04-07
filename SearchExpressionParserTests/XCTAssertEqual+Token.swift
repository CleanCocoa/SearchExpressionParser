//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import SearchExpressionParser

func ==(lhs: Token, rhs: Token) -> Bool {

    return lhs.string == rhs.string
}

func XCTAssertEqual(
    _ lhs: [Token],
    _ rhs: [Token],
    file: StaticString = #file, line: UInt = #line) {

    let leftEquatable  = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }

    XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
}

struct AnyEquatable<Target>: Equatable {
    typealias Comparer = (Target, Target) -> Bool

    let _target: Target
    let _comparer: Comparer

    init(target: Target, comparer: @escaping Comparer) {
        _target = target
        _comparer = comparer
    }
}

func ==<T>(lhs: AnyEquatable<T>, rhs: AnyEquatable<T>) -> Bool {
    return lhs._comparer(lhs._target, rhs._target)
}

// Hide the `AnyEquatable<...>(...)` portion from assertion failures
extension AnyEquatable: CustomDebugStringConvertible, CustomStringConvertible  {
    var description: String {
        return "\(_target)"
    }

    var debugDescription: String {
        return "\(_target)"
    }
}
