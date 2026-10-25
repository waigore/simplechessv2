/**
 * Read the painted 8×8 board and the selection ring out of a screenshot.
 *
 * `boardRect` finds the checkerboard's painted frame by counting dark square
 * pixels per row and column, so the grid is measured from the build's own
 * paint rather than taken from the defect's prose. `ringSquare` names the
 * square the gold ring (COLOR_SELECT #B8940C) sits on, using that grid and
 * White-at-the-bottom orientation.
 *
 * Written for #845's capture; reads CSS pixels by dividing device pixels by the
 * frame's device-pixel ratio (2).
 */
import { decodePng } from './png.mjs';

/** Decode a screenshot for `boardRect`/`ringSquare` callers that already hold a path. */
export function decodeBoard(file) {
  return decodePng(file);
}

export const COLOR_LIGHT = [232, 213, 181];
export const COLOR_DARK = [139, 90, 60];
export const COLOR_SELECT = [184, 148, 12];

const FILES = 'abcdefgh';
const TOLERANCE = 10;

function near(color, target, tolerance = TOLERANCE) {
  return Math.abs(color[0] - target[0]) <= tolerance
    && Math.abs(color[1] - target[1]) <= tolerance
    && Math.abs(color[2] - target[2]) <= tolerance;
}

function isDarkSquare(color) {
  return near(color, COLOR_DARK);
}

export function boardRect(image, dpr = 2) {
  // Dark squares are the board's own ink; the beige margin around the
  // checkerboard shares COLOR_LIGHT with the light squares, so only dark
  // pixels can separate the painted board from its backdrop.
  const rows = [];
  const columns = [];
  for (let y = 0; y < image.height; y++) {
    let count = 0;
    for (let x = 0; x < image.width; x++) if (isDarkSquare(image.at(x, y))) count++;
    rows.push(count);
  }
  for (let x = 0; x < image.width; x++) {
    let count = 0;
    for (let y = 0; y < image.height; y++) if (isDarkSquare(image.at(x, y))) count++;
    columns.push(count);
  }
  const span = (counts) => {
    // A dark square is at least a few pixels wide, so any run over the click
    // threshold is board paint (pieces' outlines fall well under it).
    const threshold = Math.max(4, Math.max(...counts) * 0.05);
    let first = -1;
    let last = -1;
    counts.forEach((count, index) => {
      if (count < threshold) return;
      if (first < 0) first = index;
      last = index;
    });
    return { from: first / dpr, to: (last + 1) / dpr };
  };
  const horizontal = span(rows);
  const vertical = span(columns);
  return {
    left: vertical.from,
    right: vertical.to,
    top: horizontal.from,
    bottom: horizontal.to,
    square: (vertical.to - vertical.from) / 8,
  };
}

/** Name of the square at a CSS point inside the painted grid, or '' off it. */
export function squareAt(rect, x, y) {
  const file = Math.floor((x - rect.left) / rect.square);
  const rank = Math.floor((rect.bottom - y) / rect.square);
  if (file < 0 || file > 7 || rank < 0 || rank > 7) return '';
  return `${FILES[file]}${rank + 1}`;
}

/** CSS point at the centre of a named square, from the measured grid. */
export function squareCentre(rect, square) {
  const file = FILES.indexOf(square[0]);
  const rank = Number(square[1]);
  return {
    x: rect.left + (file + 0.5) * rect.square,
    y: rect.bottom - (rank - 0.5) * rect.square,
  };
}

export function ringSquare(file, dpr = 2) {
  const image = decodePng(file);
  const rect = boardRect(image, dpr);
  let minX = Infinity;
  let maxX = -Infinity;
  let minY = Infinity;
  let maxY = -Infinity;
  let count = 0;
  for (let y = 0; y < image.height; y++) {
    for (let x = 0; x < image.width; x++) {
      if (!near(image.at(x, y), COLOR_SELECT, 30)) continue;
      count++;
      minX = Math.min(minX, x);
      maxX = Math.max(maxX, x);
      minY = Math.min(minY, y);
      maxY = Math.max(maxY, y);
    }
  }
  if (count === 0) return { rect, square: '', ring: null };
  const centreX = (minX + maxX) / 2 / dpr;
  const centreY = (minY + maxY) / 2 / dpr;
  return {
    rect,
    square: squareAt(rect, centreX, centreY),
    ring: { left: minX / dpr, right: maxX / dpr, top: minY / dpr, bottom: maxY / dpr },
  };
}
