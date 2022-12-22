//
//  TestHelpers.swift
//  <https://github.com/davedelong/DDMathParser>
//
//  Copyright (c) 2010-2018 Dave DeLong
//  Licensed under the MIT License.
//

import XCTest

func XCTAssertNoThrows(_ expression: @autoclosure () throws -> Void, _ message: String = "", file: StaticString = #file, line: UInt = #line) -> Bool {
    var ok = false
    do {
        try expression()
        ok = true
    } catch let e {
        let failMessage = "Unexpected exception: \(e). \(message)"
        XCTFail(failMessage, file: file, line: line)
    }
    return ok
}

func XCTAssertNoThrows<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) -> T? {
    var t: T? = nil
    do {
        t = try expression()
    } catch let e {
        let failMessage = "Unexpected exception: \(e). \(message)"
        XCTFail(failMessage, file: file, line: line)
    }
    return t
}

func XCTAssertThrows<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    do {
        let _ = try expression()
        XCTFail("Expected thrown error", file: file, line: line)
    } catch _ {
    }
}
