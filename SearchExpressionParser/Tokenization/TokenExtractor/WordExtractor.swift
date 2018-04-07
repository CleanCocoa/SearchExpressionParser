//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

internal struct WordExtractor: TokenExtractor {
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext()?.isWhitespace == false
    }

    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {

        let start = buffer.currentIndex

        while buffer.peekNext()?.isWhitespace == false {
            buffer.consume()
        }

        let end = buffer.currentIndex
        let range: Range<Int> = start ..< end
        let string = buffer[range]

        return .value(Word(string: string))
    }
}
