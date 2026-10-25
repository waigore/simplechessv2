/** PNG decode + board/readback helpers for the #868 run. Node 22+, no packages. */
import fs from 'node:fs';
import zlib from 'node:zlib';

/** Decode a non-interlaced 8-bit RGB/RGBA PNG into { width, height, rgba }. */
export function decodePng(file) {
  const buf = fs.readFileSync(file);
  let offset = 8;
  let width = 0;
  let height = 0;
  let colorType = 6;
  const idat = [];
  while (offset < buf.length) {
    const length = buf.readUInt32BE(offset);
    const type = buf.toString('ascii', offset + 4, offset + 8);
    const data = buf.subarray(offset + 8, offset + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      colorType = data[9];
    } else if (type === 'IDAT') {
      idat.push(data);
    } else if (type === 'IEND') {
      break;
    }
    offset += 12 + length;
  }
  const channels = colorType === 6 ? 4 : 3;
  const raw = zlib.inflateSync(Buffer.concat(idat));
  const stride = width * channels;
  const out = Buffer.alloc(width * height * 4);
  let prev = Buffer.alloc(stride);
  let pos = 0;
  for (let y = 0; y < height; y++) {
    const filter = raw[pos];
    pos += 1;
    const line = Buffer.from(raw.subarray(pos, pos + stride));
    pos += stride;
    for (let i = 0; i < stride; i++) {
      const a = i >= channels ? line[i - channels] : 0;
      const b = prev[i];
      const c = i >= channels ? prev[i - channels] : 0;
      let value = line[i];
      if (filter === 1) value = (value + a) & 0xff;
      else if (filter === 2) value = (value + b) & 0xff;
      else if (filter === 3) value = (value + ((a + b) >> 1)) & 0xff;
      else if (filter === 4) {
        const p = a + b - c;
        const pa = Math.abs(p - a);
        const pb = Math.abs(p - b);
        const pc = Math.abs(p - c);
        const pred = pa <= pb && pa <= pc ? a : (pb <= pc ? b : c);
        value = (value + pred) & 0xff;
      }
      line[i] = value;
    }
    for (let x = 0; x < width; x++) {
      const s = x * channels;
      const d = (y * width + x) * 4;
      out[d] = line[s];
      out[d + 1] = line[s + 1];
      out[d + 2] = line[s + 2];
      out[d + 3] = channels === 4 ? line[s + 3] : 255;
    }
    prev = line;
  }
  return { width, height, rgba: out };
}

const px = (img, x, y) => {
  const d = (y * img.width + x) * 4;
  return [img.rgba[d], img.rgba[d + 1], img.rgba[d + 2]];
};

// The painted checkerboard's two tile colours on this build: a warm light tile
// (beige) and a warm dark tile (brown). Both are matched by hue, not luminance,
// so the page's dark banner above and below the board is not counted.
export const isLightTile = (r, g, b) => r > 225 && g > 200 && g < 235 && b > 160 && b < 205;
export const isDarkTile = (r, g, b) => r > 75 && r < 130 && g > 45 && g < 95 && b > 30 && b < 80;

/** Tile-coloured bounds of the painted board, in CSS px. */
export function boardRect(img, dpr = 1) {
  let minX = Infinity; let maxX = -1; let minY = Infinity; let maxY = -1;
  for (let y = 0; y < img.height; y++) {
    for (let x = 0; x < img.width; x++) {
      const [r, g, b] = px(img, x, y);
      if (isLightTile(r, g, b) || isDarkTile(r, g, b)) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) return null;
  const left = (minX + 0.5) / dpr;
  const right = (maxX + 0.5) / dpr;
  const top = (minY + 0.5) / dpr;
  const bottom = (maxY + 0.5) / dpr;
  return { left, right, top, bottom, square: (right - left) / 8, lightFirst: true, dpr };
}

const FILES = 'abcdefgh';

/** CSS centre of algebra square `name`, White at the bottom. */
export function squareCentre(grid, name) {
  const file = FILES.indexOf(name[0]);
  const rank = Number(name[1]);
  return {
    x: grid.left + (file + 0.5) * grid.square,
    y: grid.top + (8 - rank + 0.5) * grid.square,
  };
}

/**
 * The four chooser sprite centres around a square's centre, in S4's order:
 * Queen, rook, bishop, knight at ±0.28 square (shared-play-states.md S4).
 */
export function chooserSlots(centre, square) {
  return [
    { kind: 'queen', x: centre.x - 0.28 * square, y: centre.y - 0.28 * square },
    { kind: 'rook', x: centre.x + 0.28 * square, y: centre.y - 0.28 * square },
    { kind: 'bishop', x: centre.x - 0.28 * square, y: centre.y + 0.28 * square },
    { kind: 'knight', x: centre.x + 0.28 * square, y: centre.y + 0.28 * square },
  ];
}

/** Mean colour of a small box, in CSS px. */
export function meanColour(img, dpr, cx, cy, cssRadius) {
  const r = Math.round(cssRadius * dpr);
  const sx = Math.round(cx * dpr);
  const sy = Math.round(cy * dpr);
  let acc = [0, 0, 0];
  let n = 0;
  for (let y = sy - r; y <= sy + r; y++) {
    for (let x = sx - r; x <= sx + r; x++) {
      if (x < 0 || y < 0 || x >= img.width || y >= img.height) continue;
      const [rr, gg, bb] = px(img, x, y);
      acc[0] += rr; acc[1] += gg; acc[2] += bb;
      n += 1;
    }
  }
  return n ? acc.map((v) => Math.round(v / n)) : null;
}

/** Whether a mean colour is an empty-tile colour (no ink or sprite at that point). */
export function isTileLike(mean) {
  return mean != null && (isLightTile(mean[0], mean[1], mean[2]) || isDarkTile(mean[0], mean[1], mean[2]));
}

/**
 * Ink profile of a box: the share of pixels that are neither tile colour, the
 * mean brightness of that ink (white roles are bright, black roles are near
 * black), and whether any ink is present. A square with a piece has ink; an
 * empty square of the right colour has none.
 */
export function inkInBox(img, dpr, cx, cy, cssRadius) {
  const r = Math.round(cssRadius * dpr);
  const sx = Math.round(cx * dpr);
  const sy = Math.round(cy * dpr);
  let ink = 0;
  let n = 0;
  let sum = 0;
  for (let y = sy - r; y <= sy + r; y++) {
    for (let x = sx - r; x <= sx + r; x++) {
      if (x < 0 || y < 0 || x >= img.width || y >= img.height) continue;
      n += 1;
      const [rr, gg, bb] = px(img, x, y);
      if (isLightTile(rr, gg, bb) || isDarkTile(rr, gg, bb)) continue;
      ink += 1;
      sum += 0.299 * rr + 0.587 * gg + 0.114 * bb;
    }
  }
  return {
    inkShare: n ? Number((ink / n).toFixed(3)) : 0,
    inkBrightness: ink ? Math.round(sum / ink) : 0,
    inked: ink / Math.max(n, 1) > 0.12,
  };
}
