//
//  Character+isWhitespace.swift
//
//  Adapted from Character.swift
//  <https://github.com/davedelong/DDMathParser>
//
//  Copyright (c) 2010-2018 Dave DeLong
//  Licensed under the MIT License.
//

extension Character {
    var isWhitespace: Bool {
        switch self {
            // From CoreFoundation/CFUniChar.c:297
        // http://www.opensource.apple.com/source/CF/CF-1151.16/CFUniChar.c
        case "\u{0020}": return true
        case "\u{0009}": return true
        case "\u{00a0}": return true
        case "\u{1680}": return true
        case "\u{2000}"..."\u{200b}": return true
        case "\u{202f}": return true
        case "\u{205f}": return true
        case "\u{3000}": return true
        default: return false
        }
    }
}
