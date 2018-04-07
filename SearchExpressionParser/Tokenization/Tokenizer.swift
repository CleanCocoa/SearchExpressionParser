//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public struct Tokenizer {
    internal typealias Result = Either<Token, TokenizerError>

    internal static var defaultExtractors: [TokenExtractor] {
        return [
            EscapingExtractor(),

            OpeningParensExtractor(),
            ClosingParensExtractor(),
            QuotationMarkExtractor(),

            BangExtractor(),
            NotExtractor(),
            AndExtractor(),

            WordExtractor() // Wildcard extractor comes last
        ]
    }

    public let searchString: String

    public init(searchString: String) {
        self.searchString = searchString
    }

    public func tokens() throws -> [Token] {

        let buffer = TokenCharacterBuffer(string: searchString)
        let extractors = Tokenizer.defaultExtractors
        var tokens = [Token]()

        while let next = next(buffer: buffer, extractors: extractors) {
            switch next {
            case .error(let e): throw e
            case .value(let t): tokens.append(t)
            }
        }

        return tokens
    }

    internal func next(buffer: TokenCharacterBuffer, extractors: [TokenExtractor]) -> Result? {

        buffer.skipWhitespace()

        guard buffer.isNotAtEnd else { return nil }

        let start = buffer.currentIndex
        var errors = Array<Result>()

        for extractor in extractors where  extractor.matchesPreconditions(buffer) {

            buffer.resetTo(start)
            let result = extractor.extract(buffer)

            switch result {
            case .value(_): return result
            case .error(_): errors.append(result)
            }
        }

        return errors.first
    }
}

extension TokenCharacterBuffer {
    func skipWhitespace() {
        while self.peekNext()?.isWhitespace == true {
            self.consume()
        }
    }

    var isNotAtEnd: Bool {
        return !isAtEnd
    }
}

internal struct TokenizerError: Error {
    enum Kind {
        case cannotExtractOpeningParens
        case cannotExtractQuotationMark
        case cannotExtractEscapingCharacter
        case cannotExtractOperator(Operator)
    }

    let kind: Kind
    let range: Range<Int>
}

extension TokenizerError {
    init(kind: Kind, index: Int) {
        self.init(
            kind: kind,
            range: index ..< index + 1)
    }
}

extension TokenizerError.Kind: Equatable { }

func ==(lhs: TokenizerError.Kind, rhs: TokenizerError.Kind) -> Bool {

    switch (lhs, rhs) {
    case (.cannotExtractOpeningParens, .cannotExtractOpeningParens):
        return true

    default:
        return false
    }
}
