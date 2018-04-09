//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public extension Parser {
    /// Tokenizes and then parses `searchString`.
    /// - throws: `TokenizerError` or `ParseError` for invalid expressions. Consider these to be framework errors that you don't have to deal with in detail.
    /// - parameter searchString: Search string to be transformed into an expression tree.
    /// - returns: Root expression of the expression tree.
    static func parse(searchString: String) throws -> Expression {
        let tokens = try Tokenizer(searchString: searchString).tokens()
        let expression = try Parser(tokens: tokens).expression()
        return expression
    }
}
