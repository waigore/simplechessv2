// Screenshot-derived UI helpers for the #558 sitting. No hard-coded button rows:
// bands and boxes are read from the current capture, so a layout change fails loudly.
import { readPng } from './pnglib.mjs';

const INK = ([r, g, b]) => r < 150 && g < 150 && b < 150;

export function textBands(pngPath, scale = 2) {
  const img = readPng(pngPath);
  const rowHasInk = new Uint8Array(img.h);
  for (let y = 0; y < img.h; y++) {
    for (let x = 0; x < img.w; x++) {
      if (INK(img.at(x, y))) { rowHasInk[y] = 1; break; }
    }
  }
  const bands = [];
  let y = 0;
  while (y < img.h) {
    if (!rowHasInk[y]) { y++; continue; }
    const top = y;
    let last = y;
    while (y < img.h && (rowHasInk[y] || y - last <= 10)) {
      if (rowHasInk[y]) last = y;
      y++;
    }
    bands.push({ top, bottom: last });
  }
  return bands.map(({ top, bottom }) => {
    const cols = new Uint8Array(img.w);
    for (let x = 0; x < img.w; x++) {
      for (let yy = top; yy <= bottom; yy++) {
        if (INK(img.at(x, yy))) { cols[x] = 1; break; }
      }
    }
    // Split into boxes on wide ink gaps (button labels are separate boxes).
    const boxes = [];
    let x = 0;
    while (x < img.w) {
      if (!cols[x]) { x++; continue; }
      const left = x;
      let lastX = x;
      while (x < img.w && (cols[x] || x - lastX <= 24)) {
        if (cols[x]) lastX = x;
        x++;
      }
      boxes.push({ left, right: lastX, cx: (left + lastX) / 2 / scale, cy: (top + bottom) / 2 / scale });
    }
    return { top: top / scale, bottom: bottom / scale, cy: (top + bottom) / 2 / scale, boxes };
  });
}

// Mode pick: two title bands, then Shared game, Puzzle stream, Quit | locale.
export function modePickRows(pngPath) {
  const bands = textBands(pngPath);
  if (bands.length < 5) throw new Error(`mode pick: expected >=5 bands, got ${bands.length}`);
  const shared = bands[2];
  const puzzle = bands[3];
  const tail = bands[4].boxes;
  return {
    shared: { x: shared.boxes[shared.boxes.length - 1].cx, y: shared.cy },
    puzzle: { x: puzzle.boxes[puzzle.boxes.length - 1].cx, y: puzzle.cy },
    quit: { x: tail[0].cx, y: bands[4].cy },
    locale: { x: tail[tail.length - 1].cx, y: bands[4].cy },
    bands,
  };
}

// Shared setup: title (one band) then Seat, Clock, Increment, Advice, Start | Back.
export function setupRows(pngPath) {
  const bands = textBands(pngPath);
  const rowBands = bands.slice(-5);
  if (rowBands.length < 5) throw new Error(`setup: expected >=5 row bands, got ${bands.length}`);
  const [seat, clock, increment, advice, actions] = rowBands;
  const start = actions.boxes[0];
  const back = actions.boxes[actions.boxes.length - 1];
  return {
    seat: { x: seat.boxes[0].cx, y: seat.cy },
    clock: { x: clock.boxes[0].cx, y: clock.cy },
    increment: { x: increment.boxes[0].cx, y: increment.cy },
    advice: { x: advice.boxes[0].cx, y: advice.cy },
    start: { x: start.cx, y: actions.cy },
    back: { x: back.cx, y: actions.cy },
    bands,
  };
}

export function boardRect(pngPath, scale = 2) {
  const img = readPng(pngPath);
  // Dark squares only: the light square colour also paints the band beside the
  // board, so a light-or-dark union reports the full phone width (the #845 trap).
  const dark = ([r, g, b]) => Math.abs(r - 139) <= 3 && Math.abs(g - 90) <= 3 && Math.abs(b - 60) <= 3;
  let x0 = img.w, x1 = -1, y0 = img.h, y1 = -1;
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) {
    if (dark(img.at(x, y))) {
      if (x < x0) x0 = x; if (x > x1) x1 = x;
      if (y < y0) y0 = y; if (y > y1) y1 = y;
    }
  }
  if (x1 < 0) return null;
  const s = (x1 - x0 + 1) / 8;
  return {
    css: { left: x0 / scale, top: y0 / scale, right: x1 / scale, bottom: y1 / scale, square: s / scale },
    at(name) {
      const file = name.charCodeAt(0) - 97;
      const rank = Number(name[1]);
      return { x: (x0 + s * (file + 0.5)) / scale, y: (y0 + s * (8 - rank + 0.5)) / scale };
    },
  };
}

export function hasBoard(pngPath) {
  try { return boardRect(pngPath) != null; } catch { return false; }
}
