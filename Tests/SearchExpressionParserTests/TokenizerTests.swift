//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class TokenizerTests: XCTestCase {

    /// @spec whitespace-handling/empty-and-whitespace-only-input/empty-string
    func testTokens_EmptyString_ReturnsEmptyTokenList() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "").tokens()) else { return }

        XCTAssert(tokens.isEmpty)
    }

    /// @spec whitespace-handling/empty-and-whitespace-only-input/single-space
    func testTokens_SingleWhitespace_ReturnsEmptyTokenList() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: " ").tokens()) else { return }

        XCTAssert(tokens.isEmpty)
    }

    /// @spec whitespace-handling/empty-and-whitespace-only-input/many-spaces
    func testTokens_LotsaWhitespace_ReturnsEmptyTokenList() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "          ").tokens()) else { return }

        XCTAssert(tokens.isEmpty)
    }


    // MARK: Escape Character

    /// @spec word-tokenization/escape-sequences/trailing-backslash-at-end-of-input
    func testTokens_EscapeCharacter() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("\\")])
    }

    /// @spec word-tokenization/escape-sequences/escaped-backslash
    /// @spec operator-recognition/escaping-operators-with-backslash/escaped-backslash
    func testTokens_EscapedEscapeCharacter() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\\\").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("\\")])
    }

    func testTokens_EscapedLetter() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\a").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("a")])
    }

    /// @spec word-tokenization/escape-sequences/escaped-backslash-followed-by-letter
    func testTokens_EscapedEscapeAndLetter() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\\\a").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("\\a")])
    }

    /// @spec word-tokenization/escape-sequences/escaped-letter-within-a-word
    func testTokens_EscapedLetterInWord() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "you\\know").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("youknow")])
    }

    /// @spec word-tokenization/escape-sequences/escaped-backslash-within-a-word
    func testTokens_EscapedEscapeInWord() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "a\\\\b").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("a\\b")])
    }


    // MARK: Simple words

    /// @spec word-tokenization/word-character-set/simple-word
    func testTokens_1Character() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "x").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("x")])
    }

    /// @spec whitespace-handling/leading-and-trailing-whitespace-stripping/single-character-with-surrounding-whitespace
    /// @spec word-tokenization/whitespace-splits-words/single-character-with-surrounding-whitespace
    func testTokens_1CharacterWithWhitespace() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "     x    ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("x")])
    }

    /// @spec word-tokenization/word-character-set/simple-word
    func testTokens_3Characters() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "foo").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("foo")])
    }

    /// @spec whitespace-handling/leading-and-trailing-whitespace-stripping/two-words-with-surrounding-whitespace
    /// @spec whitespace-handling/whitespace-collapsing-between-tokens/multiple-spaces-between-words
    /// @spec whitespace-handling/whitespace-character-set/standard-space-acts-as-whitespace
    /// @spec word-tokenization/whitespace-splits-words/two-words-separated-by-whitespace
    func testTokens_2Words() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   foo   bar   ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("foo"), Word("bar")])
    }

    /// @spec word-tokenization/word-character-set/punctuation-preserved-within-words
    /// @spec word-tokenization/word-character-set/question-mark-preserved-within-words
    /// @spec whitespace-handling/word-termination-by-whitespace/sentence-tokenization
    func testTokens_Sentence() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "Lorem ipsum dolor sit amet! Consectetur?").tokens()) else { return }

        let expectedWords = ["Lorem", "ipsum", "dolor", "sit", "amet!", "Consectetur?"].map(Word.init)
        XCTAssertEqual(tokens, expectedWords)
    }


    // MARK: Parens

    func testTokens_OpeningParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "(").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens()])
    }

    func testTokens_OpeningParensWithWhitespace() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   (     ").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens()])
    }

    /// @spec word-tokenization/escape-sequences/escaped-parenthesis
    func testTokens_EscapedOpeningParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\(").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("(")])
    }

    func testTokens_5OpeningParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "(((((").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens(), OpeningParens()])
    }

    func testTokens_ClosingParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: ")").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens()])
    }

    func testTokens_ClosingParensWithWhitespace() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: " \t  )   ").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens()])
    }

    /// @spec word-tokenization/escape-sequences/escaped-parenthesis
    func testTokens_EscapedClosingParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\)").tokens()) else { return }

        XCTAssertEqual(tokens, [Word(")")])
    }

    func testTokens_4ClosingParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "))))").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens(), ClosingParens(), ClosingParens(), ClosingParens()])
    }

    /// @spec word-tokenization/parentheses-break-word-boundaries/word-inside-parentheses
    func testTokens_ParenthesizedWord() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "(red)").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens(), Word("red"), ClosingParens()])
    }

    func testTokens_ParenthesizedWordWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "    ( red) ").tokens()) else { return }

        XCTAssertEqual(tokens, [OpeningParens(), Word("red"), ClosingParens()])
    }

    /// @spec word-tokenization/parentheses-break-word-boundaries/words-adjacent-to-closing-parentheses
    func testTokens_MixedWordsAndParens() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "))Yes, mighty warrior) what (you) hear now").tokens()) else { return }

        XCTAssertEqual(tokens, [ClosingParens(), ClosingParens(), Word("Yes,"), Word("mighty"), Word("warrior"), ClosingParens(), Word("what"), OpeningParens(), Word("you"), ClosingParens(), Word("hear"), Word("now")])
    }


    // MARK: Quotation marks

    /// @spec quoted-phrases/lone-quotation-mark/single-quotation-mark-at-end-of-input
    func testTokens_Quotation() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("\"")])
    }

    /// @spec word-tokenization/escape-sequences/escaped-quotation-mark
    func testTokens_EscapedQuotation() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\\"").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("\"")])
    }

    /// @spec quoted-phrases/unclosed-quoted-phrase/quote-followed-by-spaces-with-no-closing-quote
    func testTokens_QuotationWithWhitespae() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   \"   ").tokens()) else { return }

        XCTAssertEqual(tokens, [Phrase("   ")])
    }

    /// @spec quoted-phrases/opening-and-closing-delimiters/single-quoted-word
    func testTokens_QuotedWord() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"justice\"").tokens()) else { return }

        XCTAssertEqual(tokens, [Phrase("justice")])
    }

    /// @spec quoted-phrases/opening-and-closing-delimiters/quoted-phrase-with-multiple-words
    /// @spec quoted-phrases/whitespace-preservation/leading-trailing-and-multiple-internal-spaces
    /// @spec whitespace-handling/whitespace-inside-quoted-phrases-is-preserved/quoted-phrase-with-internal-whitespace
    func testTokens_QuotedPhrase() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"  fair   play \"").tokens()) else { return }

        XCTAssertEqual(tokens, [Phrase("  fair   play ")])
    }

    /// @spec quoted-phrases/escaped-quotation-marks/escaped-quote-within-phrase
    func testTokens_QuotedPhraseWithEscapedQuotationMarks() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"foo   \\\"  bar\"").tokens()) else { return }

        XCTAssertEqual(tokens, [Phrase("foo   \"  bar")])
    }


    // MARK: - Bang/NOT operator

    /// @spec operator-recognition/bang-unary-operator/lone-bang-is-a-plain-word
    func testTokens_BangOnly() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("!")])
    }

    /// @spec operator-recognition/bang-unary-operator/lone-bang-is-a-plain-word
    func testTokens_BangWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "    !  ").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("!")])
    }

    /// @spec operator-recognition/bang-unary-operator/trailing-bang-in-a-word
    func testTokens_WordWithExclamationMark() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "this!").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("this!")])
    }

    /// @spec operator-recognition/extractor-priority-order/ambiguous-input-resolved-by-priority
    /// @spec operator-recognition/bang-unary-operator/bang-before-a-word
    func testTokens_BangedWord_OMGIsThisWhatNativeSpeakersWouldSay() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!word").tokens()) else { return }

        XCTAssertEqual(tokens, [UnaryOperator.bang, Word("word")])
    }

    /// @spec operator-recognition/bang-unary-operator/bang-followed-by-whitespace-is-a-plain-word
    func testTokens_BangedWordWithWhitespace_ThisDoesntFeelRight() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "! word").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("!"), Word("word")])
    }

    /// @spec operator-recognition/bang-unary-operator/chained-bangs
    func testTokens_BangedBang_HopefullySomeoneWillCreateAPullRequestToCorrectMe() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!!").tokens()) else { return }

        XCTAssertEqual(tokens, [UnaryOperator.bang, Word("!")])
    }

    /// @spec operator-recognition/bang-unary-operator/chained-bangs
    func testTokens_5BangsBeforeWord_ThisKindaLookedBetterBeforeIAddedTheOthers() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "!!!!!foo").tokens()) else { return }

        XCTAssertEqual(tokens, [UnaryOperator.bang, UnaryOperator.bang, UnaryOperator.bang, UnaryOperator.bang, UnaryOperator.bang, Word("foo")])
    }

    /// @spec operator-recognition/not-unary-operator/not-at-end-of-input-without-trailing-whitespace
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/not-at-end-of-input-no-trailing-whitespace
    func testTokens_NOTOnly() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "NOT").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("NOT")])
    }

    /// @spec operator-recognition/not-unary-operator/not-at-end-of-input-with-leading-whitespace
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/not-with-only-trailing-whitespace
    func testTokens_NOTWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   \t NOT  ").tokens()) else { return }

        XCTAssertEqual(tokens, [UnaryOperator.not])
    }

    /// @spec operator-recognition/not-unary-operator/not-before-a-word
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/not-followed-by-whitespace
    func testTokens_NOTBeforeWord() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "NOT me").tokens()) else { return }

        XCTAssertEqual(tokens, [UnaryOperator.not, Word("me")])
    }

    /// @spec operator-recognition/not-unary-operator/not-as-word-prefix
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/not-as-prefix-of-a-longer-word
    func testTokens_WordStartingWithNOT() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "NOTest").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("NOTest")])
    }

    func testTokens_NOTBetweenWords() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "this is NOT me").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("this"), Word("is"), UnaryOperator.not, Word("me")])
    }

    /// @spec operator-recognition/not-unary-operator/mixed-case-not-is-a-plain-word
    func testTokens_MixedCaseNotBeforeWord() {

        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "not me").tokens()),
            [Word("not"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "Not me").tokens()),
            [Word("Not"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "nOt me").tokens()),
            [Word("nOt"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "noT me").tokens()),
            [Word("noT"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "NOt me").tokens()),
            [Word("NOt"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "NoT me").tokens()),
            [Word("NoT"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "nOT me").tokens()),
            [Word("nOT"), Word("me")])
    }


    // MARK: AND Operator

    /// @spec operator-recognition/and-binary-operator/and-at-end-of-input-no-trailing-whitespace
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/and-at-end-of-input
    func testTokens_ANDOnly() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "AND").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("AND")])
    }

    func testTokens_ANDWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   \t AND  ").tokens()) else { return }

        XCTAssertEqual(tokens, [BinaryOperator.and])
    }

    func testTokens_ANDBeforeWord() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "AND you").tokens()) else { return }

        XCTAssertEqual(tokens, [BinaryOperator.and, Word("you")])
    }

    /// @spec operator-recognition/and-binary-operator/and-as-word-prefix
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/and-as-prefix-of-a-longer-word
    func testTokens_WordStartingWithAND() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "ANDromeda").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("ANDromeda")])
    }

    /// @spec operator-recognition/and-binary-operator/and-between-words
    func testTokens_ANDBetweenWords() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "you AND me").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("you"), BinaryOperator.and, Word("me")])
    }

    /// @spec operator-recognition/and-binary-operator/mixed-case-and-is-a-plain-word
    func testTokens_MixedCaseAndBeforeWord() {

        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "and me").tokens()),
            [Word("and"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "And me").tokens()),
            [Word("And"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "aNd me").tokens()),
            [Word("aNd"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "anD me").tokens()),
            [Word("anD"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "ANd me").tokens()),
            [Word("ANd"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "AnD me").tokens()),
            [Word("AnD"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "aND me").tokens()),
            [Word("aND"), Word("me")])
    }


    // MARK: OR Operator

    /// @spec operator-recognition/or-binary-operator/or-at-end-of-input
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/or-at-end-of-input
    func testTokens_OROnly() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "OR").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("OR")])
    }

    func testTokens_ORWithWhitespace() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "   \t OR  ").tokens()) else { return }

        XCTAssertEqual(tokens, [BinaryOperator.or])
    }

    func testTokens_ORBeforeWord() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "OR you").tokens()) else { return }

        XCTAssertEqual(tokens, [BinaryOperator.or, Word("you")])
    }

    /// @spec operator-recognition/or-binary-operator/or-as-word-prefix
    /// @spec whitespace-handling/operator-keyword-termination-by-whitespace/or-as-prefix-of-a-longer-word
    func testTokens_WordStartingWithOR() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "ORwell").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("ORwell")])
    }

    /// @spec operator-recognition/or-binary-operator/or-between-words
    func testTokens_ORBetweenWords() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "you OR me").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("you"), BinaryOperator.or, Word("me")])
    }

    /// @spec operator-recognition/or-binary-operator/mixed-case-or-is-a-plain-word
    func testTokens_MixedCaseOrBeforeWord() {

        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "or me").tokens()),
            [Word("or"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "Or me").tokens()),
            [Word("Or"), Word("me")])
        XCTAssertEqual(
            XCTAssertNoThrows(try Tokenizer(searchString: "oR me").tokens()),
            [Word("oR"), Word("me")])
    }


    // MARK: - Complex terms

    /// @spec operator-recognition/escaping-operators-with-backslash/escaped-and
    func testTokens_EscapedAND() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\\AND foo").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("AND"), Word("foo")])
    }

    /// @spec quoted-phrases/empty-quoted-phrase/empty-double-quotes
    func testTokens_EmptyQuotedPhrase() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "\"\"").tokens()) else { return }

        XCTAssertEqual(tokens, [Phrase("")])
    }

    /// @spec whitespace-handling/whitespace-character-set/non-breaking-space-acts-as-whitespace
    func testTokens_NonBreakingSpace() {

        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "foo\u{00a0}bar").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("foo"), Word("bar")])
    }

    /// @spec word-tokenization/quotation-marks-break-word-boundaries/quoted-phrase-after-words
    func testTokens_TermWithEverythingInIt() {
        guard let tokens = XCTAssertNoThrows(try Tokenizer(searchString: "so this AND !that (or OR NOT so) is called \"  another \\\" hope\\\"   \" where you come from!").tokens()) else { return }

        XCTAssertEqual(tokens, [Word("so"), Word("this"), BinaryOperator.and, UnaryOperator.bang, Word("that"), OpeningParens(), Word("or"), BinaryOperator.or, UnaryOperator.not, Word("so"), ClosingParens(), Word("is"), Word("called"), Phrase("  another \" hope\"   "), Word("where"), Word("you"), Word("come"), Word("from!")])

    }
}
