## Why

This repository already carries pi project resources, and the requested workflow customization belongs alongside them rather than in the Swift library itself. A project-local extension lets the editor UI turn typed input into rainbow-colored text with `/reload`, without changing the user’s global pi install.

## What Changes

- Add a project-local pi extension that replaces the default editor with a custom editor component.
- Render typed editor content in rainbow colors as the user types while preserving normal editing behavior.
- Keep the implementation self-contained so it can be reloaded or removed without affecting the Swift package.

## Capabilities

### New Capabilities
- `rainbow-editor-extension`: Provide a project-local pi editor extension that rainbow-colors interactive editor text while preserving normal input handling.

### Modified Capabilities
- None.

## Impact

- New files under `.pi/extensions/` for the extension implementation.
- Small supporting test coverage for ANSI-safe rainbow rendering logic.
- No changes to the Swift package API, runtime library behavior, or published package surface.
