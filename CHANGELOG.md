# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-04-30

Major redesign around an `Expression` enum and an evaluator protocol, plus key-value token support driven by The Archive v2 search architecture.

### Added

- `Expression.keyValue(key:value:)` case for `key:value` tokens (`tag:bar`, `title:"hello world"`).
- `KeyValueExtractor` in the tokenizer; escaping with `\tag:bar` produces a plain `.contains` node.
- `ExpressionEvaluator` protocol and iterative `evaluate(_:with:)` driver. Default `Bool` implementations cover `evaluateAnything` / `evaluateNot` / `evaluateAnd` / `evaluateOr`.
- `StringContainmentEvaluator` — built-in full-text evaluator using lowercased C-strings + `strstr`.
- `keyValueNodes(in:) -> [(key: String, value: String)]` for pre-flight tree inspection.
- `Sendable` conformance on `Expression`.
- `Expression` conforms to `CustomStringConvertible` and `Equatable`.

### Changed

- `Expression` is now an enum (`.anything`, `.contains`, `.not`, `.and`, `.or`, `.keyValue`) instead of a protocol with `AnythingNode` / `ContainsNode` / `NotNode` / `AndNode` / `OrNode` structs.
- Parser and evaluator are now iterative; recursion-limit configuration is gone.
- Swift tools version bumped to 6.2; minimum platform raised to macOS 13.

### Removed

- `Expression.isSatisfied(by:)` — call `evaluate(_:with: StringContainmentEvaluator(...))` instead.
- `StringExpressionSatisfiable` / `CStringExpressionSatisfiable` protocols — implement `ExpressionEvaluator` for custom matching backends.
- Per-node node types (`AnythingNode`, `ContainsNode`, `NotNode`, `AndNode`, `OrNode`) — use the enum cases.
- macOS 10.13 support.

## [1.2.0] and earlier

See git history.
