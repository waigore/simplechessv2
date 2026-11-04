// Locator helpers for the release build driven over CDP without seams (Linux re-record).
// Every point is derived from the current screenshot, never hard-coded, so a layout
// change fails loudly (element not found) instead of silently tapping the wrong spot.
import { readPng } from './pnglib.mjs';

const INK = ([r, g, b]) => r < 120 && g < 120 && b < 120;          // label text / piece glyphs
const GOLD = ([r, g, b]) => r > 150 && r < 210 && g > 120 && g < 180 && b < 70;
// C1 cream square and C2 brown square as shipped (specs/aesthetics/palette/swatches.md).
const LIGHT = ([r, g, b]) => Math.abs(r - 232) <= 4 && Math.abs(g - 213) <= 4 && Math.abs(b - 181) <= 4;
const DARK = ([r, g, b]) => Math.abs(r - 139) <= 4 && Math.abs(g - 90) <= 4 && Math.abs(b - 60) <= 4;

function bounds(img, pred, region) {
  const { x0 = 0, y0 = 0, x1 = img.w - 1, y1 = img.h - 1 } = region || {};
  let minX = 1e9, minY = 1e9, maxX = -1, maxY = -1;
  for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) {
    if (pred(img.at(x, y))) { if (x < minX) minX = x; if (x > maxX) maxX = x; if (y < minY) minY = y; if (y > maxY) maxY = y; }
  }
  return maxX < 0 ? null : { x: minX, y: minY, x1: maxX, y1: maxY, w: maxX - minX + 1, h: maxY - minY + 1 };
}

// Text-like ink clusters on the chrome, merged per row band. Returns CSS-space boxes.
export function inkBoxes(pngPath, scale = 2, minW = 40, gap = 12) {
  const img = readPng(pngPath);
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

// Selection ring / gold control fill painted around a chosen element.
export function goldRing(pngPath, scale = 2, minH = 20) {
  const img = readPng(pngPath);
  const b = bounds(img, GOLD);
  if (!b || b.h < minH * scale) return null;
  return { css: { left: b.x / scale, top: b.y / scale, right: b.x1 / scale, bottom: b.y1 / scale, centreX: (b.x + b.x1) / 2 / scale, centreY: (b.y + b.y1) / 2 / scale } };
}

// Every distinct gold region (rows of the gold control fill), sorted top-to-bottom.
export function goldRow(pngPath, scale = 2) {
  const img = readPng(pngPath);
  const rows = new Uint8Array(img.h);
  for (let y = 0; y < img.h; y++) for (let x = 0; x < img.w; x++) if (GOLD(img.at(x, y))) { rows[y] = 1; break; }
  const bands = [];
  let y = 0;
  while (y < img.h) {
    if (!rows[y]) { y++; continue; }
    const top = y; let last = y;
    while (y < img.h && (rows[y] || y - last <= 4)) { if (rows[y]) last = y; y++; }
    if (last - top > 8) bands.push({ top: top / scale, bottom: last / scale, centreY: (top + last) / 2 / scale });
  }
  return bands;
}

// Board layout: the 8x8 C1/C2 grid. Returns the grid rect in CSS and a square mapper.
export function boardGrid(pngPath, scale = 2) {
  const img = readPng(pngPath);
  const sq = bounds(img, (c) => LIGHT(c) || DARK(c));
  if (!sq) return null;
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

// Content test: is a board actually drawn at phone width?
export function boardDrawn(pngPath) {
  const g = boardGrid(pngPath);
  return !!g && g.squareCss > 20 && g.squareCss < 80;
}
