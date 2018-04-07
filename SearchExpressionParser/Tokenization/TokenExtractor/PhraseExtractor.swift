//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct PhraseExtractor: TokenExtractor {

    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() == "\""
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {

        guard buffer.peekNext() == "\"" else {
            return .error(TokenizerError(
                kind: .cannotExtractQuotationMark,
                index: buffer.currentIndex))
        }

        buffer.consume(1)

        // Single quotation mark only
        guard buffer.isNotAtEnd else { return .value(Word("\"")) }

        var characters = [Character]()

        while buffer.isNotAtEnd {
            // Phrase end
            if buffer.peekNext() == "\"" {
                buffer.consume(1)
                break
            }

            // Escaped quotation mark
            if     buffer.peekNext(0) == "\\"
                && buffer.peekNext(1) == "\"" {
                characters.append("\"")
                buffer.consume(2)
                continue
            }

            characters.append(buffer[buffer.currentIndex])
            buffer.consume(1)
        }

        return .value(Phrase(String(characters)))
    }
}
