## ADDED Requirements

### Requirement: Assertion on unhandled Expression type in iterativeIsSatisfied
The `iterativeIsSatisfied` function SHALL call `assertionFailure` in its `default` branch before falling back to recursive `isSatisfied(by:)` dispatch.

#### Scenario: Unknown Expression type in debug build
- **WHEN** an Expression type not handled by the explicit cases is encountered during iterative evaluation
- **THEN** `assertionFailure` fires with a message identifying the unhandled type

### Requirement: Assertion on unhandled Expression type in iterativePhrases
The `iterativePhrases` function SHALL call `assertionFailure` in its `default` branch before falling back to recursive `phrases` access.

#### Scenario: Unknown Expression type in debug build
- **WHEN** an Expression type not handled by the explicit cases is encountered during iterative phrase collection
- **THEN** `assertionFailure` fires with a message identifying the unhandled type

### Requirement: Assertion on non-progressing parse loop
The `parseExpression` while loop SHALL assert that the token buffer position advances after each call to `parsePrimary`.

#### Scenario: parsePrimary fails to consume tokens
- **WHEN** `parsePrimary` returns without advancing the token buffer position
- **THEN** `assertionFailure` fires with a message about non-progress to prevent an infinite loop
