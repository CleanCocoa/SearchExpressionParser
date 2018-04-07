//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct QuotationMarkExtractor: TokenExtractor {

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

        return .value(QuotationMark())
    }
}
