//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct BangExtractor: TokenExtractor {
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext(0) == "!"
            && buffer.peekNext(1)?.isWhitespace == false
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {

        guard buffer.peekNext(0) == "!"
            && buffer.peekNext(1)?.isWhitespace == false
            else {
            return .error(TokenizerError(
                kind: .cannotExtractOperator(.not),
                index: buffer.currentIndex))
        }

        buffer.consume(1)

        return .value(Operator.not)
    }
}
