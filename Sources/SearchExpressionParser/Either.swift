//
//  Either.swift
//  <https://github.com/davedelong/DDMathParser>
//
//  Copyright (c) 2010-2018 Dave DeLong
//  Licensed under the MIT License.
//

internal enum Either<T, E: Error> {
    case value(T)
    case error(E)
}
