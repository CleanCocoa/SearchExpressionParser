import XCTest
@testable import SearchExpressionParser

class ParserTests: XCTestCase {

    /// @spec parsing/parser-return-type/empty-input-produces-anything
    func testExpression_EmptyTokens() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: []).expression()) else { return }
        XCTAssertEqual(expression, .anything)
    }

    /// @spec parsing/parser-return-type/single-word-produces-contains
    func testExpression_SinglePhrase() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [Phrase("foo bar")]).expression()) else { return }
        XCTAssertEqual(expression, .contains("foo bar"))
    }


    // MARK: AND Operator

    func testExpression_TwoPhrases() {
        let tokens: [Token] = [Phrase("foo"), Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .contains("bar")))
    }

    func testExpression_3Phrases() {
        let tokens: [Token] = [Phrase("foo"), Phrase("bar"), Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .and(
                .contains("foo"),
                .and(
                    .contains("bar"),
                    .contains("baz"))))
    }

    func testExpression_6Phrases() {
        let tokens: [Token] = [Phrase("1"), Phrase("2"), Phrase("3"), Phrase("4"), Phrase("5"), Phrase("6")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .and(
                .contains("1"),
                .and(
                    .contains("2"),
                    .and(
                        .contains("3"),
                        .and(
                            .contains("4"),
                            .and(
                                .contains("5"),
                                .contains("6")))))))
    }

    func testExpression_AND() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [BinaryOperator.and]).expression()) else { return }
        XCTAssertEqual(expression, .contains("AND"))
    }

    func testExpression_PhraseBeforeAND() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.and]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .contains("AND")))
    }

    func testExpression_ANDBeforePhrase() {
        let tokens: [Token] = [BinaryOperator.and, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("AND"), .contains("foo")))
    }

    /// @spec parsing/parser-return-type/and-expression
    func testExpression_2PhrasesANDConnected() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.and, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .contains("bar")))
    }

    func testExpression_3PhrasesANDConnected() {
        let tokens: [Token] = [
            Phrase("foo"), BinaryOperator.and,
            Phrase("bar"), BinaryOperator.and,
            Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .and(
                .contains("foo"),
                .and(
                    .contains("bar"),
                    .contains("baz"))))
    }


    // MARK: OR Operator

    func testExpression_OR() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [BinaryOperator.or]).expression()) else { return }
        XCTAssertEqual(expression, .contains("OR"))
    }

    func testExpression_PhraseBeforeOR() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.or]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .contains("OR")))
    }

    func testExpression_ORBeforePhrase() {
        let tokens: [Token] = [BinaryOperator.or, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("OR"), .contains("foo")))
    }

    /// @spec parsing/parser-return-type/or-expression
    func testExpression_2PhrasesORConnected() {
        let tokens: [Token] = [Phrase("foo"), BinaryOperator.or, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .or(.contains("foo"), .contains("bar")))
    }

    func testExpression_PhrasesANDandORConnected() {
        let tokens: [Token] = [
            Phrase("foo"), BinaryOperator.or,
            Phrase("bar"), BinaryOperator.and,
            Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .or(
                .contains("foo"),
                .and(
                    .contains("bar"),
                    .contains("baz"))))
    }

    func testExpression_AdjacentPhrasesAndORConnection() {
        let tokens: [Token] = [
            Phrase("foo"),
            Phrase("bar"), BinaryOperator.or,
            Phrase("baz")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .and(
                .contains("foo"),
                .or(
                    .contains("bar"),
                    .contains("baz"))))
    }


    // MARK: Bang operator

    func testExpression_Bang() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [UnaryOperator.bang]).expression()) else { return }
        XCTAssertEqual(expression, .contains("!"))
    }

    func testExpression_PhraseBeforeBang() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.bang]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .contains("!")))
    }

    func testExpression_BangBeforePhrase() {
        let tokens: [Token] = [UnaryOperator.bang, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .not(.contains("foo")))
    }

    func testExpression_2PhrasesWithBangBeforeFirst() {
        let tokens: [Token] = [UnaryOperator.bang, Phrase("foo"), Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.not(.contains("foo")), .contains("bar")))
    }

    func testExpression_2PhrasesWithBangBeforeLast() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.bang, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .not(.contains("bar"))))
    }

    func testExpression_BangDoesNotAffectUnparenthesizedSequence() {
        let tokens: [Token] = [
            UnaryOperator.bang, Phrase("a"), BinaryOperator.or,
            Phrase("b"),
            Phrase("c")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .or(
                .not(.contains("a")),
                .and(
                    .contains("b"),
                    .contains("c"))))
    }


    // MARK: NOT operator

    func testExpression_NOT() {
        guard let expression = XCTAssertNoThrows(try Parser(tokens: [UnaryOperator.not]).expression()) else { return }
        XCTAssertEqual(expression, .contains("NOT"))
    }

    func testExpression_PhraseBeforeNOT() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.not]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .contains("NOT")))
    }

    /// @spec parsing/parser-return-type/not-expression
    func testExpression_NOTBeforePhrase() {
        let tokens: [Token] = [UnaryOperator.not, Phrase("foo")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .not(.contains("foo")))
    }

    func testExpression_2PhrasesWithNOTBeforeFirst() {
        let tokens: [Token] = [UnaryOperator.not, Phrase("foo"), Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.not(.contains("foo")), .contains("bar")))
    }

    func testExpression_2PhrasesWithNOTBeforeLast() {
        let tokens: [Token] = [Phrase("foo"), UnaryOperator.not, Phrase("bar")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .and(.contains("foo"), .not(.contains("bar"))))
    }

    func testExpression_NOTDoesNotAffectUnparenthesizedSequence() {
        let tokens: [Token] = [
            UnaryOperator.not, Phrase("a"), BinaryOperator.or,
            Phrase("b"),
            Phrase("c")]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .or(
                .not(.contains("a")),
                .and(
                    .contains("b"),
                    .contains("c"))))
    }

    func testExpression_NOTAffectsParenthesizedExpression() {
        let tokens: [Token] = [
            UnaryOperator.not,
            OpeningParens(), Phrase("a"), BinaryOperator.or, Phrase("b"), ClosingParens()]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(expression, .not(.or(.contains("a"), .contains("b"))))
    }

    func testExpression_ParensPairsWithImplicitAnd() {
        let tokens: [Token] = [
            OpeningParens(), Phrase("a"), BinaryOperator.or, Phrase("b"), ClosingParens(),
            OpeningParens(), Phrase("c"), BinaryOperator.and, Phrase("d"), ClosingParens()]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .and(
                .or(.contains("a"), .contains("b")),
                .and(.contains("c"), .contains("d"))))
    }

    func testExpression_EmptyParens() {
        let tokens: [Token] = [
            OpeningParens(), ClosingParens(),
            OpeningParens(), OpeningParens(), ClosingParens(), ClosingParens()]
        guard let expression = XCTAssertNoThrows(try Parser(tokens: tokens).expression()) else { return }
        XCTAssertEqual(
            expression,
            .and(
                .and(.contains("("), .contains(")")),
                .and(.contains("("), .contains(")"))))
    }

}
