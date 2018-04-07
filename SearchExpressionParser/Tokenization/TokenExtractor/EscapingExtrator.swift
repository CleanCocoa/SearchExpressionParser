//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct EscapingExtractor: TokenExtractor {
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() == "\\"
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {

        guard buffer.peekNext() == "\\" else {
            return .error(TokenizerError(
                kind: .cannotExtractEscapingCharacter,
                index: buffer.currentIndex))
        }

        buffer.consume(1)

        return .value(Escaping())
    }
}
