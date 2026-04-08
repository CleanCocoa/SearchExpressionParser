//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import SearchExpressionParser

class PhraseCollectionConvertibleTests: XCTestCase {

    /// @spec phrase-extraction/containsnode-contributes-its-string-as-a-phrase/single-contains-term
    /// @spec phrase-extraction/anythingnode-contributes-no-phrases/wildcard-match
    /// @spec phrase-extraction/notnode-contributes-no-phrases/negated-term
    /// @spec phrase-extraction/andnode-concatenates-phrases-from-both-children/two-positive-terms
    /// @spec phrase-extraction/ornode-concatenates-phrases-from-both-children/two-alternative-terms
    func testPhrases() {
        XCTAssertEqual(AnythingNode().phrases, [])
        XCTAssertEqual(ContainsNode("foo").phrases, ["foo"])
        XCTAssertEqual(NotNode(ContainsNode("foo")).phrases, [])
        XCTAssertEqual(AndNode(ContainsNode("foo"), ContainsNode("bar")).phrases, ["foo", "bar"])
        XCTAssertEqual(OrNode(ContainsNode("foo"), ContainsNode("bar")).phrases, ["foo", "bar"])
    }
}
