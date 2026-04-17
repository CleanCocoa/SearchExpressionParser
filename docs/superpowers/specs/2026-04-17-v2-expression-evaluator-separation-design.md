# v2 Design: Expression/Evaluator Separation

## Motivation

v1 fuses data and evaluation: the `Expression` protocol requires every node to implement `isSatisfied(by:)`. This works when every leaf is a `ContainsNode` and the only evaluation strategy is string containment. v2 introduces `KeyValueNode` for queries like `tag:bar`, which cannot be evaluated by string containment -- they require dispatch to external indices (tag index, title index, etc.).

The v1 approach forces `KeyValueNode.isSatisfied` to return `false` -- a lie meaning "unanswerable by this evaluator", not "unsatisfied". Callers who use key-value nodes (like The Archive v2's SearchService) must reimplement the entire AND/OR/NOT tree walk to dispatch leaf nodes to the right index.

Applying SICP's parser/evaluator separation: the expression tree becomes pure data, and evaluation becomes an external operation parameterized by how leaf nodes are handled. The library owns the tree-walking machinery; callers supply the leaf semantics.

## Expression as Pure Data

Replace the `Expression` protocol and node structs with a single enum:

```swift
public enum Expression: Sendable, Equatable {
    case anything
    case contains(string: String, cString: [CChar])
    case keyValue(key: String, value: String)
    case not(Expression)
    indirect case and(Expression, Expression)
    indirect case or(Expression, Expression)
}
```

No evaluation methods on the type. The tree is inert, exhaustive, compiler-checked. `Sendable` and `Equatable` conformance are derived automatically.

The `contains` case carries both the original `string` and the precomputed `cString` (lowercased, precomposed UTF-8) for fast `strstr`-based matching. The `cStringFactory` customization point is retained, moved to the parser or a static function on `Expression`.

### Removed Types

- `Expression` protocol
- `AnythingNode`, `ContainsNode`, `NotNode`, `AndNode`, `OrNode` structs
- `StringExpressionSatisfiable`, `CStringExpressionSatisfiable` protocols
- `PhraseCollectionConvertible` protocol
- `ContainmentEvaluator` struct

## ExpressionEvaluator Protocol

A fold (catamorphism) over the expression tree. The library walks the tree structure; the caller defines what happens at each node.

```swift
public protocol ExpressionEvaluator {
    associatedtype Result
    func evaluateContains(_ string: String, cString: [CChar]) -> Result
    func evaluateKeyValue(key: String, value: String) -> Result
    func evaluateAnything() -> Result
    func evaluateNot(_ inner: Result) -> Result
    func evaluateAnd(_ lhs: Result, _ rhs: Result) -> Result
    func evaluateOr(_ lhs: Result, _ rhs: Result) -> Result
}
```

Every method is required. No `default` cases, no silent swallowing of unknown node types. When a new leaf type is added in a future major version, every evaluator is forced to handle it.

### Boolean Defaults

For the common case of `Result == Bool`, protocol extensions provide the structural combinators:

```swift
extension ExpressionEvaluator where Result == Bool {
    public func evaluateNot(_ inner: Bool) -> Bool { !inner }
    public func evaluateAnd(_ lhs: Bool, _ rhs: Bool) -> Bool { lhs && rhs }
    public func evaluateOr(_ lhs: Bool, _ rhs: Bool) -> Bool { lhs || rhs }
    public func evaluateAnything() -> Bool { true }
}
```

A boolean evaluator only needs to implement `evaluateContains` and `evaluateKeyValue`. No default is provided for `evaluateKeyValue` -- callers must explicitly decide what key-value nodes mean in their context.

### Evaluate Function

The library provides a single entry point that owns the tree walk:

```swift
public func evaluate<E: ExpressionEvaluator>(
    _ expression: Expression,
    with evaluator: E
) -> E.Result
```

Implemented iteratively with a stack (like today's `iterativeIsSatisfied`), preserving short-circuit behavior for AND/OR.

## Built-in Evaluators

### StringContainmentEvaluator

Replaces the v1 `isSatisfied(by:)` for simple full-text containment:

```swift
public struct StringContainmentEvaluator: ExpressionEvaluator {
    public let haystack: String
    public let haystackCString: [CChar]

    public init(_ haystack: String) {
        self.haystack = haystack
        self.haystackCString = // precomposed, lowercased UTF-8
    }

    public func evaluateContains(_ string: String, cString: [CChar]) -> Bool {
        // strstr(haystackCString, cString) for fast path
    }

    public func evaluateKeyValue(key: String, value: String) -> Bool {
        false
    }
}
```

Carries both `String` and `[CChar]` representations of the haystack. The `cString` fast path uses `strstr`; the `String` is available if callers subclass or wrap for locale-aware matching.

Serves as both a convenience for simple callers and a demonstration of the evaluator pattern.

### PhraseExtractor

Replaces `ContainmentEvaluator.phrases()`. A fold that collects positive containment strings for highlighting:

```swift
public struct PhraseExtractor: ExpressionEvaluator {
    // Result == [String]
    // contains: [string]
    // keyValue: []
    // anything: []
    // not: []
    // and: lhs + rhs
    // or: lhs + rhs
}
```

Intended to be used after normalization: `normalize` then `PhraseExtractor`.

## Tree Transform: Normalization

Negation normal form (De Morgan's laws) cannot be expressed as a fold, because `evaluateNot` receives the already-folded inner result, not the original expression. Pushing NOT through AND/OR requires seeing the structure inside the NOT before folding.

Normalization is a dedicated tree-to-tree rewrite:

```swift
public func normalize(_ expression: Expression) -> Expression
```

Rewrite rules:
- `not(and(a, b))` -> `or(not(a), not(b))`
- `not(or(a, b))` -> `and(not(a), not(b))`
- `not(not(a))` -> `a`
- All other nodes pass through unchanged.

Implemented iteratively (like today's `pushNegationIteratively`).

## Inspection: Key-Value Extraction

For pre-flight inspection of parsed trees (e.g. determining which indices are needed):

```swift
public func keyValueNodes(in expression: Expression) -> [(key: String, value: String)]
```

Collects all `.keyValue` leaves from the tree. Could be implemented as a fold internally.

## Parser

`Parser.parse(searchString:)` entry point is unchanged. Return type changes from the `Expression` protocol to the `Expression` enum.

The tokenizer gains key-value token recognition per FR-001 from v2.md:
- `key:value` -> recognized as a key-value token
- `key:"multi word"` -> key-value token with quoted value
- `\key:value` -> escaped, produces `.contains("key:value")`
- `key :value` (space before colon) -> two separate tokens

The parser produces `.keyValue(key:value:)` for key-value tokens and `.contains(string:cString:)` for plain words/phrases, as today.

## CString Factory

The `cStringFactory` customization point is retained for callers who need custom string normalization. Exact placement TBD -- options include a static property on `Expression`, a parameter on the parser, or a configuration struct. The default implementation applies `precomposedStringWithCanonicalMapping.lowercased().cString(using: .utf8)`.

## Public API Surface

```
// Parsing
Parser.parse(searchString:) -> Expression

// Data
enum Expression: Sendable, Equatable

// Evaluation
protocol ExpressionEvaluator
func evaluate(_:with:) -> E.Result

// Built-in evaluators
struct StringContainmentEvaluator: ExpressionEvaluator  // Result == Bool
struct PhraseExtractor: ExpressionEvaluator             // Result == [String]

// Tree transform
func normalize(_:) -> Expression

// Inspection
func keyValueNodes(in:) -> [(key: String, value: String)]
```

## Caller Migration: SearchService

Before (v1 + custom tree walk):

```swift
private func evaluate(_ expr: Expression, noteRef: NoteRef) -> Bool {
    switch expr {
    case let node as ContainsNode:
        return searchableContent[noteRef]?.matches(needle: node.cString) ?? false
    case let node as KeyValueNode where node.key == "tag":
        return tagIndex.noteHasTag(noteRef, tag: node.value)
    case let node as KeyValueNode where node.key == "title":
        return titles[noteRef]?.localizedCaseInsensitiveContains(node.value) ?? false
    case let node as AndNode:
        return evaluate(node.lhs, noteRef: noteRef)
            && evaluate(node.rhs, noteRef: noteRef)
    case let node as OrNode:
        return evaluate(node.lhs, noteRef: noteRef)
            || evaluate(node.rhs, noteRef: noteRef)
    case let node as NotNode:
        return !evaluate(node.expression, noteRef: noteRef)
    case is AnythingNode:
        return true
    default:
        return false
    }
}
```

After (v2 evaluator):

```swift
struct NoteSearchEvaluator: ExpressionEvaluator {
    let noteRef: NoteRef
    let searchableContent: [NoteRef: SearchableContent]
    let tagIndex: TagIndex
    let titles: [NoteRef: String]

    func evaluateContains(_ string: String, cString: [CChar]) -> Bool {
        searchableContent[noteRef]?.matches(needle: cString) ?? false
    }

    func evaluateKeyValue(key: String, value: String) -> Bool {
        switch key {
        case "tag": tagIndex.noteHasTag(noteRef, tag: value)
        case "title": titles[noteRef]?.localizedCaseInsensitiveContains(value) ?? false
        default: false
        }
    }
}

// Usage:
let evaluator = NoteSearchEvaluator(noteRef: noteRef, ...)
let matches = evaluate(expression, with: evaluator)
```

Three leaf methods instead of a full tree walk. AND/OR/NOT handled by the boolean protocol extension.

## Versioning

Release as 2.0.0. This is a source-breaking change:
- `Expression` changes from protocol to enum
- All node structs removed
- `isSatisfied(by:)` removed
- `ContainmentEvaluator`, `PhraseCollectionConvertible` removed
- New evaluator protocol and fold function
