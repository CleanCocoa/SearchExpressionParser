internal struct KeyValueExtractor: TokenExtractor {
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext()?.isLetter == true
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {
        let start = buffer.currentIndex

        var keyChars = [Character]()

        while buffer.isNotAtEnd {
            guard let ch = buffer.peekNext() else { break }
            if ch == ":" { break }
            if ch.isWhitespace || ch.isParens || ch.isQuotationMark { break }
            keyChars.append(ch)
            buffer.consume(1)
        }

        guard !keyChars.isEmpty,
              buffer.peekNext() == ":" else {
            buffer.resetTo(start)
            return .error(TokenizerError(kind: .cannotExtractKeyValue, index: start))
        }

        buffer.consume(1)

        if buffer.peekNext() == "\"" {
            buffer.consume(1)

            if buffer.isAtEnd {
                buffer.resetTo(start)
                return .error(TokenizerError(kind: .cannotExtractKeyValue, index: start))
            }

            var valueChars = [Character]()
            while buffer.isNotAtEnd {
                if buffer.peekNext() == "\"" {
                    buffer.consume(1)
                    break
                }
                if buffer.peekNext(0) == "\\" && buffer.peekNext(1) == "\"" {
                    valueChars.append("\"")
                    buffer.consume(2)
                    continue
                }
                valueChars.append(buffer[buffer.currentIndex])
                buffer.consume(1)
            }

            let key = String(keyChars)
            let value = String(valueChars)
            return .value(KeyValueToken(key: key, value: value))
        }

        var valueChars = [Character]()
        while buffer.isNotAtEnd {
            guard let ch = buffer.peekNext() else { break }
            if ch.isWhitespace || ch.isParens || ch.isQuotationMark { break }
            valueChars.append(ch)
            buffer.consume(1)
        }

        guard !valueChars.isEmpty else {
            buffer.resetTo(start)
            return .error(TokenizerError(kind: .cannotExtractKeyValue, index: start))
        }

        let key = String(keyChars)
        let value = String(valueChars)
        return .value(KeyValueToken(key: key, value: value))
    }
}

fileprivate extension Character {
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
