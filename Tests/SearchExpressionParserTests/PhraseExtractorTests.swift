import XCTest
@testable import SearchExpressionParser

class PhraseExtractorTests: XCTestCase {

    // MARK: 1.1 — Leaf methods

    /// @spec phrase-extractor/evaluate-contains/single-phrase
    func testEvaluateContains_returnsSinglePhrase() {
        let extractor = PhraseExtractor()
        let cString = Expression.cStringFactory("hello")
        XCTAssertEqual(extractor.evaluateContains("hello", cString: cString), ["hello"])
    }

    /// @spec phrase-extractor/evaluate-key-value/no-phrases
    func testEvaluateKeyValue_returnsEmpty() {
        let extractor = PhraseExtractor()
        XCTAssertEqual(extractor.evaluateKeyValue(key: "tag", value: "bar"), [])
    }

    /// @spec phrase-extractor/evaluate-anything/no-phrases
    func testEvaluateAnything_returnsEmpty() {
        let extractor = PhraseExtractor()
        XCTAssertEqual(extractor.evaluateAnything(), [])
    }

    // MARK: 1.2 — Combinator methods

    /// @spec phrase-extractor/evaluate-not/drops-inner-phrases
    func testEvaluateNot_returnsEmpty() {
        let extractor = PhraseExtractor()
        XCTAssertEqual(extractor.evaluateNot(["hello"]), [])
    }

    /// @spec phrase-extractor/evaluate-and/combines-phrases
    func testEvaluateAnd_concatenates() {
        let extractor = PhraseExtractor()
        XCTAssertEqual(extractor.evaluateAnd(["hello"], ["world"]), ["hello", "world"])
    }

    /// @spec phrase-extractor/evaluate-or/combines-phrases
    func testEvaluateOr_concatenates() {
        let extractor = PhraseExtractor()
        XCTAssertEqual(extractor.evaluateOr(["hello"], ["world"]), ["hello", "world"])
    }

    // MARK: 1.4 — Integration

    /// @spec phrase-extractor/integration/and-with-negated-term-after-normalization
    func testIntegration_andWithNegatedTermAfterNormalization() {
        let expr = normalize(.and(.contains("foo"), .not(.contains("bar"))))
        let result: [String] = evaluate(expr, with: PhraseExtractor())
        XCTAssertEqual(result, ["foo"])
    }

    /// @spec phrase-extractor/integration/or-collects-all-candidates
    func testIntegration_orCollectsAllCandidates() {
        let result: [String] = evaluate(.or(.contains("foo"), .contains("bar")), with: PhraseExtractor())
        XCTAssertEqual(result, ["foo", "bar"])
    }
}
