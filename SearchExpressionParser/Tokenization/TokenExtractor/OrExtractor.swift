//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct OrExtractor: TokenExtractor {
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext(0) == "O"
            && buffer.peekNext(1) == "R"
            && buffer.peekNext(2)?.isWhitespace == true
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {

        guard  buffer.peekNext(0) == "O"
            && buffer.peekNext(1) == "R"
            && buffer.peekNext(2)?.isWhitespace == true
            else {
                return .error(TokenizerError(
                    kind: .cannotExtractOperator(.not),
                    range: buffer.currentIndex ..< buffer.currentIndex + 2))
        }

        buffer.consume(2)

        return .value(Operator.or)
    }
}

