import XCTest
@testable import SearchExpressionParser

class StackOverflowTests: XCTestCase {

    // MARK: - Vector 1: Many implicit-AND words ("a b c d ...")

    func testImplicitAND_100()   { tryParse(implicitANDWords(count: 100)) }
    func testImplicitAND_500()   { tryParse(implicitANDWords(count: 500)) }
    func testImplicitAND_1000()  { tryParse(implicitANDWords(count: 1000)) }
    func testImplicitAND_2000()  { tryParse(implicitANDWords(count: 2000)) }
    func testImplicitAND_5000()  { tryParse(implicitANDWords(count: 5000)) }
    func testImplicitAND_10000() { tryParse(implicitANDWords(count: 10000)) }

    // MARK: - Vector 2: Explicit AND-chained words ("a AND b AND c ...")

    func testExplicitAND_100()   { tryParse(explicitANDWords(count: 100)) }
    func testExplicitAND_500()   { tryParse(explicitANDWords(count: 500)) }
    func testExplicitAND_1000()  { tryParse(explicitANDWords(count: 1000)) }
    func testExplicitAND_2000()  { tryParse(explicitANDWords(count: 2000)) }
    func testExplicitAND_5000()  { tryParse(explicitANDWords(count: 5000)) }
    func testExplicitAND_10000() { tryParse(explicitANDWords(count: 10000)) }

    // MARK: - Vector 3: Deeply nested parentheses "((((a))))"

    func testNestedParens_100()   { tryParse(nestedParens(depth: 100)) }
    func testNestedParens_500()   { tryParse(nestedParens(depth: 500)) }
    func testNestedParens_1000()  { tryParse(nestedParens(depth: 1000)) }
    func testNestedParens_2000()  { tryParse(nestedParens(depth: 2000)) }
    func testNestedParens_5000()  { tryParse(nestedParens(depth: 5000)) }
    func testNestedParens_10000() { tryParse(nestedParens(depth: 10000)) }

    // MARK: - Vector 4: Chained negations "! ! ! ... ! a"

    func testChainedBangs_100()   { tryParse(chainedBangs(count: 100)) }
    func testChainedBangs_500()   { tryParse(chainedBangs(count: 500)) }
    func testChainedBangs_1000()  { tryParse(chainedBangs(count: 1000)) }
    func testChainedBangs_2000()  { tryParse(chainedBangs(count: 2000)) }
    func testChainedBangs_5000()  { tryParse(chainedBangs(count: 5000)) }
    func testChainedBangs_10000() { tryParse(chainedBangs(count: 10000)) }

    // MARK: - Vector 5: Combined nested parens + AND: "(a AND (b AND (c AND ...)))"

    func testNestedParensAND_100()   { tryParse(nestedParensAND(depth: 100)) }
    func testNestedParensAND_500()   { tryParse(nestedParensAND(depth: 500)) }
    func testNestedParensAND_1000()  { tryParse(nestedParensAND(depth: 1000)) }
    func testNestedParensAND_2000()  { tryParse(nestedParensAND(depth: 2000)) }
    func testNestedParensAND_5000()  { tryParse(nestedParensAND(depth: 5000)) }

    // MARK: - Vector 6: OR-chained words ("a OR b OR c ...")

    func testExplicitOR_100()   { tryParse(explicitORWords(count: 100)) }
    func testExplicitOR_500()   { tryParse(explicitORWords(count: 500)) }
    func testExplicitOR_1000()  { tryParse(explicitORWords(count: 1000)) }
    func testExplicitOR_2000()  { tryParse(explicitORWords(count: 2000)) }
    func testExplicitOR_5000()  { tryParse(explicitORWords(count: 5000)) }
    func testExplicitOR_10000() { tryParse(explicitORWords(count: 10000)) }

    // MARK: - Vector 7: Evaluate deep trees with isSatisfied

    func testEvalImplicitAND_100()   { tryParseAndEval(implicitANDWords(count: 100)) }
    func testEvalImplicitAND_500()   { tryParseAndEval(implicitANDWords(count: 500)) }
    func testEvalImplicitAND_1000()  { tryParseAndEval(implicitANDWords(count: 1000)) }
    func testEvalImplicitAND_2000()  { tryParseAndEval(implicitANDWords(count: 2000)) }
    func testEvalImplicitAND_5000()  { tryParseAndEval(implicitANDWords(count: 5000)) }
    func testEvalImplicitAND_10000() { tryParseAndEval(implicitANDWords(count: 10000)) }

    // MARK: - Vector 8: Extract phrases from deep trees

    func testPhrasesImplicitAND_100()   { tryParseAndPhrases(implicitANDWords(count: 100)) }
    func testPhrasesImplicitAND_500()   { tryParseAndPhrases(implicitANDWords(count: 500)) }
    func testPhrasesImplicitAND_1000()  { tryParseAndPhrases(implicitANDWords(count: 1000)) }
    func testPhrasesImplicitAND_2000()  { tryParseAndPhrases(implicitANDWords(count: 2000)) }
    func testPhrasesImplicitAND_5000()  { tryParseAndPhrases(implicitANDWords(count: 5000)) }
    func testPhrasesImplicitAND_10000() { tryParseAndPhrases(implicitANDWords(count: 10000)) }

    // MARK: - Input Generators

    private func implicitANDWords(count: Int) -> String {
        (0..<count).map { String(UnicodeScalar(97 + ($0 % 26))!) }.joined(separator: " ")
    }

    private func explicitANDWords(count: Int) -> String {
        (0..<count).map { String(UnicodeScalar(97 + ($0 % 26))!) }.joined(separator: " AND ")
    }

    private func explicitORWords(count: Int) -> String {
        (0..<count).map { String(UnicodeScalar(97 + ($0 % 26))!) }.joined(separator: " OR ")
    }

    private func nestedParens(depth: Int) -> String {
        String(repeating: "(", count: depth) + "a" + String(repeating: ")", count: depth)
    }

    private func chainedBangs(count: Int) -> String {
        String(repeating: "! ", count: count) + "a"
    }

    private func nestedParensAND(depth: Int) -> String {
        var result = ""
        for i in 0..<depth {
            result += "(\(String(UnicodeScalar(97 + (i % 26))!)) AND "
        }
        result += "z"
        result += String(repeating: ")", count: depth)
        return result
    }

    // MARK: - Test Runners

    private func tryParse(_ input: String, file: StaticString = #file, line: UInt = #line) {
        do {
            let expression = try Parser.parse(searchString: input)
            XCTAssertFalse(expression is AnythingNode, "Unexpected AnythingNode for non-empty input", file: file, line: line)
        } catch {
            XCTFail("Parse threw: \(error)", file: file, line: line)
        }
    }

    private func tryParseAndEval(_ input: String, file: StaticString = #file, line: UInt = #line) {
        do {
            let expression = try Parser.parse(searchString: input)
            _ = expression.isSatisfied(by: "hello world")
        } catch {
            XCTFail("Parse threw: \(error)", file: file, line: line)
        }
    }

    private func tryParseAndPhrases(_ input: String, file: StaticString = #file, line: UInt = #line) {
        do {
            let expression = try Parser.parse(searchString: input)
            if let evaluable = expression as? ContainmentEvaluator.Evaluable {
                _ = ContainmentEvaluator(evaluable: evaluable).phrases()
            }
        } catch {
            XCTFail("Parse threw: \(error)", file: file, line: line)
        }
    }
}
