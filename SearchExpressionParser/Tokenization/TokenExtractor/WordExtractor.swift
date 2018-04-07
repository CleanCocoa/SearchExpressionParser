//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct WordExtractor: TokenExtractor {
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext()?.isWhitespace == false
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {

        var characters = [Character]()

        while buffer.isNotAtEnd && buffer.peekNext()?.isWordConsumable == true {
            if     buffer.peekNext(0) == "\\"
                && buffer.peekNext(1) != nil {
                buffer.consume(1) // Skip the '\'
            }

            characters.append(buffer[buffer.currentIndex])
            buffer.consume(1)
        }

        return .value(Word(String(characters)))
    }
}

fileprivate extension Character {
    var isWordConsumable: Bool {
        return !isWhitespace
            && !isParens
            && !isQuotationMark
    }

    var isParens: Bool {
        switch self {
        case "(", ")": return true
        default: return false
        }
    }

    var isQuotationMark: Bool {
        return self == "\""
    }
}
