// Locator helpers for the release build driven over CDP without seams.
// Every point is derived from the current screenshot, never hard-coded, so a layout
// change fails loudly (element not found) instead of silently tapping the wrong spot.
import { readPng } from './pnglib.mjs';

const INK = ([r, g, b]) => r < 120 && g < 120 && b < 120;          // label text / piece glyphs
const GOLD = ([r, g, b]) => r > 150 && r < 210 && g > 120 && g < 180 && b < 70;

function bounds(img, pred, region) {
  const { x0 = 0, y0 = 0, x1 = img.w - 1, y1 = img.h - 1 } = region || {};
  let minX = 1e9, minY = 1e9, maxX = -1, maxY = -1;
  for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) {
    if (pred(img.at(x, y))) { if (x < minX) minX = x; if (x > maxX) maxX = x; if (y < minY) minY = y; if (y > maxY) maxY = y; }
  }
  return maxX < 0 ? null : { x: minX, y: minY, x1: maxX, y1: maxY, w: maxX - minX + 1, h: maxY - minY + 1 };
}

// Buttons on the shared-setup / shared-play / mode-pick chrome are bordered boxes with
// dark label ink. Returns CSS-space boxes of every ink cluster merged per row band.
export function inkBoxes(pngPath, scale = 2, minW = 40, gap = 12) {
  const img = readPng(pngPath);
  // Row projection: mark rows that contain ink, then split into text bands.
  const inkRow = new Uint8Array(img.h);
  for (let y = 0; y < img.h; y++) { for (let x = 0; x < img.w; x++) { if (INK(img.at(x, y))) { inkRow[y] = 1; break; } } }
  const bands = [];
  let y = 0;
  while (y < img.h) {
    if (!inkRow[y]) { y++; continue; }
    const top = y;
    let last = y;
    while (y < img.h && (inkRow[y] || y - last <= gap)) { if (inkRow[y]) last = y; y++; }
    bands.push([top, last]);
  }
  // Column projection within each band: split into words/phrases by wide gaps.
  const boxes = [];
  for (const [top, bot] of bands) {
    const inkCol = new Uint8Array(img.w);
    for (let x = 0; x < img.w; x++) { for (let yy = top; yy <= bot; yy++) { if (INK(img.at(x, yy))) { inkCol[x] = 1; break; } } }
    let x = 0;
    while (x < img.w) {
      if (!inkCol[x]) { x++; continue; }
      const left = x; let last = x;
      while (x < img.w && (inkCol[x] || x - last <= 24)) { if (inkCol[x]) last = x; x++; }
      if (last - left + 1 >= minW) boxes.push({ x: left, y: top, x1: last, y1: bot, w: last - left + 1, h: bot - top + 1 });
    }
  }
  return boxes.map((b) => ({ ...b, css: { x: (b.x + b.x1) / 2 / scale, y: (b.y + b.y1) / 2 / scale, left: b.x / scale, top: b.y / scale, right: b.x1 / scale, bottom: b.y1 / scale } }));
}

// Selection ring painted around a chosen square.
export function goldRing(pngPath, scale = 2) {
  const img = readPng(pngPath);
  const b = bounds(img, GOLD, { y0: Math.round(300 * scale) });
  if (!b || b.h < 20 * scale) return null;
  return { css: { left: b.x / scale, top: b.y / scale, right: b.x1 / scale, bottom: b.y1 / scale, centreX: (b.x + b.x1) / 2 / scale, centreY: (b.y + b.y1) / 2 / scale } };
}

// Board square layout: the 8x8 grid is drawn between the cafe bands. Returns the grid
// rect in CSS and a square-name -> point mapper.
export function boardGrid(pngPath, scale = 2) {
  const img = readPng(pngPath);
  const light = ([r, g, b]) => Math.abs(r - 232) <= 3 && Math.abs(g - 213) <= 3 && Math.abs(b - 181) <= 3;
  const dark = ([r, g, b]) => Math.abs(r - 139) <= 3 && Math.abs(g - 90) <= 3 && Math.abs(b - 60) <= 3;
  const sq = bounds(img, (c) => light(c) || dark(c));
  return {
    css: { left: sq.x / scale, top: sq.y / scale, right: sq.x1 / scale, bottom: sq.y1 / scale },
    squareCss: (sq.x1 - sq.x + 1) / 8 / scale,
    at: (name) => {
      const file = name.charCodeAt(0) - 97, rank = Number(name[1]);
      const s = (sq.x1 - sq.x + 1) / 8;
      return { x: (sq.x + s * (file + 0.5)) / scale, y: (sq.y + s * (8 - rank + 0.5)) / scale };
    },
  };
}
