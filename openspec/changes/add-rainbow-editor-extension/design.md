## Context

The user wants a pi extension, not a change to the SearchExpressionParser Swift library. pi already supports replacing the main editor via `ctx.ui.setEditorComponent()` and provides `CustomEditor` to preserve app-level keybindings. The main technical risk is styling typed content without corrupting ANSI escape sequences used by the editor for borders, cursor rendering, and IME cursor markers.

## Goals / Non-Goals

**Goals:**
- Add a project-local extension that auto-loads from `.pi/extensions/`.
- Rainbow-color typed editor content in interactive sessions.
- Preserve default editor behavior such as submission, cursor movement, and app shortcuts.
- Cover the text-coloring helper with focused tests before wiring the extension.

**Non-Goals:**
- Modifying the Swift package or its runtime behavior.
- Creating a configurable theme system or global pi installer.
- Reworking autocomplete or other editor UI beyond the rainbow effect.

## Decisions

- Use `CustomEditor` and `ctx.ui.setEditorComponent()` so the extension inherits pi’s built-in keybindings and editor behavior instead of reimplementing input handling.
- Post-process rendered editor lines instead of rebuilding the editor layout. This keeps wrapping, cursor placement, and scrolling delegated to pi.
- Isolate ANSI-aware rainbow rendering in a small helper module and test it with Node’s built-in test runner. This provides red/green coverage for the risky text transformation logic.
- Skip pure border lines during recoloring so the rainbow effect targets typed/editor content instead of the editor chrome.

## Risks / Trade-offs

- [ANSI parsing misses an escape sequence] → Support the escape sequence families pi’s editor emits (CSI, OSC, APC) and test preservation behavior.
- [Rainbow styling affects highlighted cursor characters] → Preserve existing escape sequences and only inject foreground colors around printable content.
- [Autocomplete lines also receive rainbow styling] → Acceptable for this first pass because the user requested a typing effect, and the implementation remains small and robust.
