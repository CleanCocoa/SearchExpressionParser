import test from "node:test";
import assert from "node:assert/strict";

import { colorizeAnsiText, isBorderLine, stripAnsi } from "./rendering.mjs";

const RESET = "\x1b[0m";
const CURSOR_MARKER = "\x1b_pi:c\x07";

test("colorizeAnsiText preserves ANSI escape sequences while coloring printable text", () => {
  const input = `A\x1b[7mB\x1b[0m${CURSOR_MARKER}C\x1b]8;;https://example.com\x07D\x1b]8;;\x07`;
  const output = colorizeAnsiText(input, 2);

  assert.match(output, /\x1b\[38;2;\d+;\d+;\d+mA/);
  assert.match(output, /\x1b\[7m\x1b\[38;2;\d+;\d+;\d+mB\x1b\[0m/);
  assert.ok(output.includes(CURSOR_MARKER));
  assert.ok(output.includes("\x1b]8;;https://example.com\x07"));
  assert.ok(output.endsWith(RESET));
  assert.equal(stripAnsi(output), "ABCD");
});

test("isBorderLine recognizes editor border lines and scroll indicators", () => {
  assert.equal(isBorderLine("──────────"), true);
  assert.equal(isBorderLine("─── ↑ 3 more ─────"), true);
  assert.equal(isBorderLine("─── ↓ 2 more ─────"), true);
  assert.equal(isBorderLine(" rainbow text "), false);
});

test("colorizeAnsiText leaves whitespace-only lines visually unchanged", () => {
  const output = colorizeAnsiText("   ");
  assert.equal(output, "   ");
});
