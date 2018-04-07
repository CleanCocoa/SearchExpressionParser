//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal final class TokenBuffer {
    let tokens: [Token]
    private(set) internal var currentIndex: Int = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    var isAtEnd: Bool {
        return currentIndex >= tokens.count
    }

    var isNotAtEnd: Bool {
        return !isAtEnd
    }

    func peekToken() -> Token? {
        return tokens[safe: currentIndex]
    }

    func popToken() -> Token? {
        guard let token = peekToken() else { return nil }
        currentIndex += 1
        return token
    }
}

internal extension Collection {
    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
