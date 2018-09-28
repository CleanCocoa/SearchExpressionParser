# SearchExpressionParser

![Swift 4.2](https://img.shields.io/badge/Swift-4.2-blue.svg?style=flat)
![Version](https://img.shields.io/github/tag/CleanCocoa/SearchExpressionParser.svg?style=flat)
![License](https://img.shields.io/github/license/CleanCocoa/SearchExpressionParser.svg?style=flat)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Parses search strings (as in: what you put into a search engine) into evaluable expressions.

## Parsing

You call the `Parser.parse(searchString:)`. This returns a tree of the parsed expression combinations. You can ask the `Expression` object if it is matches a given haystack, for example:

```swift
import SearchExpressionParser
guard let expr = try? Parser.parse(searchString: "Hello") else { fatalError() }
expr.isSatisfied(by: "Hello World!") // true
```

Empty search strings evaluate to a wildcard matching anything.

### Efficient full-text search

To use search expressions effectively in an app, I found it beneficial to operate on an all-lowercase representation of the text and use C's `strstr`.

So in a note-taking app, for example, you should consider lowercasing your notes in-memory and then use C-String comparison for the expressions.

First, make your text implement the `CStringExpressionSatisfiable` protocol:

```swift
struct Note {
    let text: String
    private let cString: [CChar]

    init(text: String) {
        self.text = text
        self.cString = text
            // Favor simple over grapheme cluster characters
            .precomposedStringWithCanonicalMapping
            .cString(using: .utf8)!
    }
}

import SearchExpressionParser

extension Note: CStringExpressionSatisfiable {
    func matches(needle: [CChar]) -> Bool {
        return strstr(self.cString, needle) != nil
    }
}
```

Then pass this object to the expression.

```swift
let warAndPeace = Note(String(contentsOf: "books/Tolstoy/War-and-Peace.txt"))
let protagonist = try! Parser.parse(searchString: "\"Pierre Bezukhov\" OR \"Pyotr Kirillovich\"")
protagonist.isSatisfied(by: warAndPeace) // true
```

This sadly puts the burden of implementing the matching algorithm on your side, but this is by design so you keep a C-String around instead of relying on the framework to convert the text for you on the fly -- because that's be useless. The speed gain is well worth the couple lines of code compared to regular `String.contains` matching, which even gets slower when Emoji are involved.

### Operators

Operators are all caps: `AND`, `OR`, `NOT`/`!`. 

- `foo bar baz` is equivalent to `foo AND bar AND baz`
- `NOT b` equals `!b`
- `! b` (note the space) is `! AND b`
- `"!b"` is a phrase search for "!b", matching the literal exclamation mark
- Escaping works in addition to phrase search, too: `\!b`
- Escaping in phrase searches also works: `hello "you \"lovely\" specimen"`
- Escaping operator keywords treats them literal: `\AND`. Note that a lowercase "and" will not be treated as an operator, only all-caps will.

You can parenthesize expressions:

    !(foo OR (baz AND !bar))

... is, of course, equivalent to:

    !foo OR !baz AND !foo OR !bar

As of yet, there is no real operator precedence implementation because the full-text search context I was using this in didn't need that.

The `Expression` object of this nested term looks like this:

    // !(foo OR (baz AND !bar))
    NotNode(
        OrNode(lhs: ContainsNode("foo"), 
               rhs: AndNode(lhs: ContainsNode("baz"), 
                            rhs: NotNode(ContainsNode("bar")))))


### Expressions

When you call the high-level `Parser.parse(searchString:)` entry point, you get an object in return that conforms to `Expression`. 

The `Expression` protocol is:

    public protocol Expression {
        func isSatisfied(by satisfiable: StringExpressionSatisfiable) -> Bool
        func isSatisfied(by satisfiable: CStringExpressionSatisfiable) -> Bool
    }

You can pass the haystack to `isStatisfied`, e.g. the text you want to search.

When the case of words doesn't matter, remember it's much faster if you make the text you want to search conform to `CStringExpressionSatisfiable` and pass _that_ in, instead. See above for details.

The expressions provided are:

- `AnythingNode` will match anything you put it; it's the wildcard or empty search.
- `ContainsNode` represents check similar to `String.contains`.
- `NotNode` wraps 1 other node and reverses the result of its outcome.
- `AndNode` and `OrNode` both take 2 other notes and combine their results with the boolean operator equivalents.

## License

Copyright (c) 2018 Christian Tietze. Distributed under the MIT License.

## Apps that use this

- [The Archive](https://zettelkasten.de/the-archive/), a fast plain-text note-taking app for macOS.
