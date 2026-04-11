## Context

The iterative refactoring replaced recursive tree walking with explicit-stack loops. Three `default` branches silently fall back to recursive dispatch, and one while loop assumes `parsePrimary` always consumes tokens. These are correct today but fragile under future changes.

## Goals / Non-Goals

**Goals:**
- Add `assertionFailure` calls that fire in debug builds when an unhandled Expression type or non-progressing parse loop is detected
- Keep the existing fallback behavior in release builds (graceful degradation)

**Non-Goals:**
- Removing the fallback behavior entirely (release builds should still work)
- Adding assertions elsewhere in the codebase

## Decisions

- Use `assertionFailure(_:)` (not `fatalError`) so release builds degrade gracefully
- Pattern: `default: assertionFailure("Unhandled Expression type: \(type(of: expr))"); <existing fallback>`
- For the parser loop: capture token buffer position before `parsePrimary`, assert it advanced after
- No new tests needed — these are development-time guards, not behavioral changes

## Risks / Trade-offs

- `assertionFailure` is invisible in release builds. This is intentional — a user hitting an unknown Expression type gets the recursive fallback rather than a crash.
