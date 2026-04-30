# SearchExpressionParser

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-blue.svg?style=flat)
![Version](https://img.shields.io/github/tag/CleanCocoa/SearchExpressionParser.svg?style=flat)
![License](https://img.shields.io/github/license/CleanCocoa/SearchExpressionParser.svg?style=flat)
![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-lightgrey.svg?style=flat)

Parses search strings (as in: what you put into a search engine) into evaluable expression trees.

## Parsing

Call `Parser.parse(searchString:)` to get an `Expression` tree, then evaluate it with an `ExpressionEvaluator`:

```swift
import SearchExpressionParser

let expr = try Parser.parse(searchString: "Hello")
let result = evaluate(expr, with: StringContainmentEvaluator("Hello World!"))
// result == true
```

Empty search strings parse to `.anything` and match everything.

### Built-in full-text matching

`StringContainmentEvaluator` is the default full-text backend. It lowercases and canonicalizes the haystack and uses C's `strstr` for substring checks — much faster than `String.contains`, and handles emoji correctly:

```swift
let evaluator = StringContainmentEvaluator(warAndPeace.text)
let protagonist = try Parser.parse(searchString: "\"Pierre Bezukhov\" OR \"Pyotr Kirillovich\"")
evaluate(protagonist, with: evaluator) // true
```

For custom matching (e.g. searching multiple fields, hitting an external index), conform to `ExpressionEvaluator`:

```swift
struct MyEvaluator: ExpressionEvaluator {
    typealias Result = Bool
    let note: Note

    func evaluateContains(_ string: String, cString: Expression.CString) -> Bool {
        note.text.localizedCaseInsensitiveContains(string)
    }
    func evaluateKeyValue(key: String, value: String) -> Bool {
        // Dispatch to your tag/title/link index here.
        false
    }
    // evaluateAnything / evaluateAnd / evaluateOr / evaluateNot
    // come from the protocol's default Bool implementation.
}
```

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

There is no operator precedence beyond grouping with parentheses; the full-text search context this was built for didn't need it.

The parsed tree for `!(foo OR (baz AND !bar))`:

```swift
.not(.or(.contains("foo"),
         .and(.contains("baz"),
              .not(.contains("bar")))))
```

### Key-value tokens

Tokens of the form `key:value` parse into `.keyValue(key:value:)` nodes. The library recognizes the syntax but does not evaluate it — the consuming app dispatches each key to the right index (tags, titles, links, citations, ...).

- `tag:bar` → `.keyValue(key: "tag", value: "bar")`
- `title:"hello world"` → `.keyValue(key: "title", value: "hello world")` (quoted values use the same escape rules as phrase search)
- `\tag:bar` → `.contains("tag:bar")` (escape suppresses key-value recognition)
- `key :value` (space before colon) is two separate tokens

`StringContainmentEvaluator.evaluateKeyValue` returns `false`, since key-value predicates can't be answered by string containment. Plug in your own evaluator to dispatch.

For pre-flight inspection (deciding which indices to query, contextual autocomplete, etc.), use `keyValueNodes(in:)`:

```swift
let expr = try Parser.parse(searchString: "foo tag:swift title:\"hello world\"")
keyValueNodes(in: expr)
// [(key: "tag", value: "swift"), (key: "title", value: "hello world")]
```

### Expressions

`Expression` is a `Sendable` enum:

```swift
public enum Expression: Sendable, Equatable {
    case anything
    case contains(string: String, cString: CString)
    indirect case not(Expression)
    indirect case and(Expression, Expression)
    indirect case or(Expression, Expression)
    case keyValue(key: String, value: String)
}
```

You walk the tree with `evaluate(_:with:)` and an `ExpressionEvaluator`. The protocol defines one method per case; default implementations exist for `Result == Bool` so most callers only implement `evaluateContains` and (optionally) `evaluateKeyValue`.

Cases:

- `.anything` — wildcard, the empty search.
- `.contains` — substring check; carries both the original string and a precomputed lowercased C-string.
- `.not` — negates the wrapped expression.
- `.and` / `.or` — boolean combinators.
- `.keyValue` — opaque `key:value` pair for the consuming app to interpret.

## Apps that use this

- [The Archive](https://zettelkasten.de/the-archive/), a fast plain-text note-taking app for macOS.

Use this in your app? Open a PR and tell the world about it!

## License

Copyright (c) 2018-2026 Christian Tietze. Distributed under the MIT License.
