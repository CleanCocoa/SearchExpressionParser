const COLORS = [
  [233, 137, 115],
  [228, 186, 103],
  [141, 192, 122],
  [102, 194, 179],
  [121, 157, 207],
  [157, 134, 195],
  [206, 130, 172],
];

const RESET = "\x1b[0m";

function colorCode(index) {
  const [r, g, b] = COLORS[((index % COLORS.length) + COLORS.length) % COLORS.length];
  return `\x1b[38;2;${r};${g};${b}m`;
}

function extractAnsiCode(str, pos) {
  if (pos >= str.length || str[pos] !== "\x1b") return null;

  const next = str[pos + 1];

  if (next === "[") {
    let end = pos + 2;
    while (end < str.length && !/[A-Za-z]/.test(str[end])) end++;
    return end < str.length ? str.slice(pos, end + 1) : null;
  }

  if (next === "]" || next === "_") {
    let end = pos + 2;
    while (end < str.length) {
      if (str[end] === "\x07") return str.slice(pos, end + 1);
      if (str[end] === "\x1b" && str[end + 1] === "\\") return str.slice(pos, end + 2);
      end++;
    }
    return null;
  }

  return null;
}

function nextSymbol(str, pos) {
  const codePoint = str.codePointAt(pos);
  if (codePoint === undefined) return "";
  return String.fromCodePoint(codePoint);
}

export function stripAnsi(str) {
  let result = "";

  for (let i = 0; i < str.length; ) {
    const ansi = extractAnsiCode(str, i);
    if (ansi) {
      i += ansi.length;
      continue;
    }

    const symbol = nextSymbol(str, i);
    result += symbol;
    i += symbol.length;
  }

  return result;
}

export function isBorderLine(line) {
  const stripped = stripAnsi(line).trim();
  return /^─+$/.test(stripped) || /^─── [↑↓] \d+ more ─*$/.test(stripped);
}

export function colorizeAnsiText(text, offset = 0) {
  let result = "";
  let colorIndex = offset;
  let appliedColor = false;

  for (let i = 0; i < text.length; ) {
    const ansi = extractAnsiCode(text, i);
    if (ansi) {
      result += ansi;
      i += ansi.length;
      continue;
    }

    const symbol = nextSymbol(text, i);
    if (/\s/u.test(symbol)) {
      result += symbol;
    } else {
      result += `${colorCode(colorIndex)}${symbol}`;
      colorIndex += 1;
      appliedColor = true;
    }

    i += symbol.length;
  }

  return appliedColor ? `${result}${RESET}` : result;
}
