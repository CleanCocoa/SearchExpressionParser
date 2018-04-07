//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct AndExtractor: TokenExtractor {
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext(0) == "A"
            && buffer.peekNext(1) == "N"
            && buffer.peekNext(2) == "D"
            && buffer.peekNext(3)?.isWhitespace == true
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {

        guard  buffer.peekNext(0) == "A"
            && buffer.peekNext(1) == "N"
            && buffer.peekNext(2) == "D"
            && buffer.peekNext(3)?.isWhitespace == true
            else {
                return .error(TokenizerError(
                    kind: .cannotExtractOperator(.not),
                    range: buffer.currentIndex ..< buffer.currentIndex + 3))
        }

        buffer.consume(3)

        return .value(Operator.and)
    }
}
