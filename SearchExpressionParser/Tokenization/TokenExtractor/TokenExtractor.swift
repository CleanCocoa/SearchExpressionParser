//
//  TokenExtractor.swift
//  <https://github.com/davedelong/DDMathParser>
//
//  Copyright (c) 2010-2018 Dave DeLong
//  Licensed under the MIT License.
//

internal protocol TokenExtractor {
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool
    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result
    
}
