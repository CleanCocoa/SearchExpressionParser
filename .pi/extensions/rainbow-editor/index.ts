import { CustomEditor, type ExtensionAPI } from "@mariozechner/pi-coding-agent";

import { colorizeAnsiText, isBorderLine } from "./rendering.mjs";

class RainbowTypingEditor extends CustomEditor {
  private colorOffset = 0;

  handleInput(data: string): void {
    const before = this.getText();
    super.handleInput(data);

    if (this.getText() !== before) {
      this.colorOffset = (this.colorOffset + 1) % 7;
    }
  }

  render(width: number): string[] {
    return super
      .render(width)
      .map((line) => (isBorderLine(line) ? line : colorizeAnsiText(line, this.colorOffset)));
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (!ctx.hasUI) return;
    ctx.ui.setEditorComponent((tui, theme, keybindings) => new RainbowTypingEditor(tui, theme, keybindings));
  });
}
