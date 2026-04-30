## ADDED Requirements

### Requirement: Rainbow typing editor
The system SHALL provide a project-local pi extension that replaces the default interactive editor with a custom editor that rainbow-colors typed content while preserving normal editor input behavior.

#### Scenario: Interactive session loads the extension
- **WHEN** pi starts in this project with the extension available under `.pi/extensions/`
- **THEN** the session uses the custom rainbow editor instead of the default editor component

#### Scenario: User types text into the editor
- **WHEN** the user enters text in the interactive editor
- **THEN** visible editor content is rendered with rainbow foreground colors as the text is displayed

### Requirement: ANSI-safe recoloring
The extension SHALL preserve ANSI escape sequences emitted by pi’s editor while applying rainbow colors so cursor rendering, borders, and other terminal control sequences continue to function.

#### Scenario: Editor output contains terminal escape sequences
- **WHEN** the rainbow renderer processes a rendered editor line containing ANSI escape sequences
- **THEN** it preserves those escape sequences and only adds rainbow foreground colors around printable content

#### Scenario: Editor border line is rendered
- **WHEN** the rainbow renderer receives a pure border line from the editor
- **THEN** it leaves that border line unchanged
