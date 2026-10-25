/**
 * Board/silhouette measurement for the #640 accessibility review.
 *
 * Dependency-free: decodes the PNGs the capture wrote (`png.mjs`), finds the
 * painted checkerboard, samples square colours, applies documented colour-blind
 * simulation matrices, and measures square/piece contrast.
 *
 * Every constant that comes from a spec is labelled with its element ID so a
 * reader can check the number against the rule rather than against this file.
 */
import fs from 'node:fs';
import zlib from 'node:zlib';
import { decodePng } from './png.mjs';

// --- spec constants (palette/swatches.md, palette.md) ------------------------
export const SPEC = {
  C1: '#E8D5B5', // light square
  C2: '#8B5A3C', // dark square
  C3: '#F5F0E6', // white piece fill / black piece contour (SRF.O1)
  C4: '#2C2A28', // black piece fill / white piece contour (SRF.O1)
};
export const K1_MIN_DELTA = 0.25; // PAL.K1
export const K2_MIN_RATIO = 3.0; // PAL.K2

// --- colour maths ------------------------------------------------------------
export function hexToRgb(hex) {
  const h = hex.replace('#', '');
  return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
}
export function rgbToHex([r, g, b]) {
  return `#${[r, g, b].map((v) => Math.round(Math.max(0, Math.min(255, v))).toString(16).padStart(2, '0').toUpperCase()).join('')}`;
}
function channelLuminance(value) {
  const c = value / 255;
  return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
}
/** WCAG 2.x relative luminance — the measure PAL.K1 and PAL.K2 quote. */
export function luminance([r, g, b]) {
  return 0.2126 * channelLuminance(r) + 0.7152 * channelLuminance(g) + 0.0722 * channelLuminance(b);
}
export function contrastRatio(a, b) {
  const la = luminance(a);
  const lb = luminance(b);
  const [hi, lo] = la >= lb ? [la, lb] : [lb, la];
  return (hi + 0.05) / (lo + 0.05);
}

// --- colour-blind simulation -------------------------------------------------
// Viénot, Brettel & Mollon (1999) LMS-plane reduction for *dichromacy*
// (protanopia / deuteranopia), applied in linear RGB. Documented in logs/.
const RGB_TO_LMS = [
  [0.31399022, 0.63951294, 0.04649755],
  [0.15537241, 0.75789446, 0.08670142],
  [0.01775239, 0.10944209, 0.87256922],
];
const LMS_TO_RGB = [
  [5.47221206, -4.6419601, 0.16963708],
  [-1.1252419, 2.29317094, -0.1678952],
  [0.02980165, -0.19318073, 1.16364789],
];
const SIMULATIONS = {
  protanopia: [
    [0, 1.05118294, -0.05116099],
    [0, 1, 0],
    [0, 0, 1],
  ],
  deuteranopia: [
    [1, 0, 0],
    [0.9513092, 0, 0.04866992],
    [0, 0, 1],
  ],
};
const toLinear = (v) => (v / 255 <= 0.04045 ? v / 255 / 12.92 : ((v / 255 + 0.055) / 1.055) ** 2.4);
const fromLinear = (v) => {
  const c = Math.max(0, Math.min(1, v));
  return 255 * (c <= 0.0031308 ? c * 12.92 : 1.055 * c ** (1 / 2.4) - 0.055);
};
function multiply(m, v) {
  return [
    m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2],
    m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2],
    m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2],
  ];
}
/** Simulate one of the dichromacies on an sRGB triple. */
export function simulate(rgb, kind) {
  const linear = rgb.map(toLinear);
  const lms = multiply(RGB_TO_LMS, linear);
  return multiply(LMS_TO_RGB, multiply(SIMULATIONS[kind], lms)).map(fromLinear);
}

// --- PNG writing (for the simulated artefacts) -------------------------------
function crc32(buffer) {
  let crc = 0xffffffff;
  for (let i = 0; i < buffer.length; i++) {
    crc ^= buffer[i];
    for (let k = 0; k < 8; k++) crc = crc & 1 ? (crc >>> 1) ^ 0xedb88320 : crc >>> 1;
  }
  return (crc ^ 0xffffffff) >>> 0;
}
function chunk(type, data) {
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body));
  return Buffer.concat([length, body, crc]);
}
/** Write an RGB image ({width, height, at(x,y)}) as a PNG. */
export function writePng(file, image) {
  const raw = Buffer.alloc(image.height * (image.width * 3 + 1));
  for (let y = 0; y < image.height; y++) {
    raw[y * (image.width * 3 + 1)] = 0;
    for (let x = 0; x < image.width; x++) {
      const [r, g, b] = image.at(x, y);
      const offset = y * (image.width * 3 + 1) + 1 + x * 3;
      raw[offset] = r;
      raw[offset + 1] = g;
      raw[offset + 2] = b;
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(image.width, 0);
  ihdr.writeUInt32BE(image.height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  fs.writeFileSync(file, Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]));
}
/** Apply a simulation to every pixel of a decoded image. */
export function simulateImage(image, kind) {
  const cache = new Map();
  const at = (x, y) => {
    const rgb = image.at(x, y);
    const key = (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
    let out = cache.get(key);
    if (!out) {
      out = simulate(rgb, kind).map((v) => Math.round(v));
      cache.set(key, out);
    }
    return out;
  };
  return { width: image.width, height: image.height, at };
}

/** Decode a PNG to RGBA, including an alpha channel when the encoder wrote one. */
export function decodeRgba(file) {
  const buffer = fs.readFileSync(file);
  let position = 8;
  let width = 0;
  let height = 0;
  let colorType = 0;
  const chunks = [];
  while (position < buffer.length) {
    const length = buffer.readUInt32BE(position);
    const type = buffer.toString('ascii', position + 4, position + 8);
    const data = buffer.subarray(position + 8, position + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      colorType = data[9];
    } else if (type === 'IDAT') {
      chunks.push(data);
    }
    position += 12 + length;
  }
  const bpp = colorType === 6 ? 4 : 3;
  const raw = zlib.inflateSync(Buffer.concat(chunks));
  const stride = width * bpp;
  const out = Buffer.alloc(height * stride);
  let previous = Buffer.alloc(stride);
  for (let y = 0; y < height; y++) {
    const filter = raw[y * (stride + 1)];
    const line = raw.subarray(y * (stride + 1) + 1, (y + 1) * (stride + 1));
    const current = Buffer.from(line);
    for (let i = 0; i < stride; i++) {
      const a = i >= bpp ? current[i - bpp] : 0;
      const b = previous[i];
      const c = i >= bpp ? previous[i - bpp] : 0;
      if (filter === 1) current[i] = (current[i] + a) & 255;
      else if (filter === 2) current[i] = (current[i] + b) & 255;
      else if (filter === 3) current[i] = (current[i] + ((a + b) >> 1)) & 255;
      else if (filter === 4) {
        const p = a + b - c;
        const pa = Math.abs(p - a);
        const pb = Math.abs(p - b);
        const pc = Math.abs(p - c);
        current[i] = (current[i] + (pa <= pb && pa <= pc ? a : pb <= pc ? b : c)) & 255;
      }
    }
    current.copy(out, y * stride);
    previous = current;
  }
  const at = (x, y) => {
    const offset = (y * width + x) * bpp;
    return bpp === 4
      ? [out[offset], out[offset + 1], out[offset + 2], out[offset + 3]]
      : [out[offset], out[offset + 1], out[offset + 2], 255];
  };
  return { width, height, at };
}

/** The opaque bounding box of an RGBA image and its opaque pixel count. */
export function opaqueBounds(image, alphaThreshold = 24) {
  let left = image.width; let top = image.height; let right = -1; let bottom = -1; let count = 0;
  for (let y = 0; y < image.height; y++) {
    for (let x = 0; x < image.width; x++) {
      if (image.at(x, y)[3] < alphaThreshold) continue;
      count++;
      if (x < left) left = x;
      if (x > right) right = x;
      if (y < top) top = y;
      if (y > bottom) bottom = y;
    }
  }
  return { left, top, width: right - left + 1, height: bottom - top + 1, count };
}

/**
 * Build the six types in solid black at their FRM.P2 heights, in the FRM.L1
 * lineup, standing on one ground line at a PRJ.V1 9:16-scale frame.
 *
 * FRM.P1: one uniform scale for every type, set so the King's opaque height is
 * 0.85 of the square. Every opaque pixel of the shipped sprite — including the
 * area SRF.O1:O1 would outline — is written solid black, so no fill/outline
 * composition survives to leak side or type.
 */
export function silhouetteSheet(sprites, { squarePx = 120, labelRow = 64 }) {
  const tallest = Math.max(...sprites.map((s) => s.opaque.height));
  const unitToPx = squarePx; // one FRM.P2 unit of body height == one square
  const scale = (0.85 * unitToPx) / tallest;
  const placed = sprites.map((s) => ({
    key: s.key,
    width: Math.max(1, Math.round(s.opaque.width * scale)),
    height: Math.max(1, Math.round(s.opaque.height * scale)),
  }));
  const gap = Math.round(squarePx * 0.42);
  const pad = Math.round(squarePx * 0.25);
  const width = placed.reduce((sum, p) => sum + p.width, 0) + gap * (placed.length - 1) + pad * 2;
  const height = Math.round(squarePx * 2.2) + labelRow;
  const baseline = height - labelRow;
  const data = new Uint8ClampedArray(width * height * 3).fill(255);
  const set = (x, y) => {
    const offset = (y * width + x) * 3;
    data[offset] = 0; data[offset + 1] = 0; data[offset + 2] = 0;
  };
  let x = pad;
  const boxes = [];
  for (const [index, sprite] of sprites.entries()) {
    const box = placed[index];
    const top = baseline - box.height;
    let opaque = 0;
    for (let dy = 0; dy < box.height; dy++) {
      for (let dx = 0; dx < box.width; dx++) {
        const sx = sprite.opaque.left + Math.min(sprite.opaque.width - 1,
          Math.floor((dx / box.width) * sprite.opaque.width));
        const sy = sprite.opaque.top + Math.min(sprite.opaque.height - 1,
          Math.floor((dy / box.height) * sprite.opaque.height));
        if (sprite.image.at(sx, sy)[3] < 128) continue;
        set(x + dx, top + dy);
        opaque++;
      }
    }
    boxes.push({ key: box.key, left: x, top, width: box.width, height: box.height, opaque });
    x += box.width + gap;
  }
  const image = {
    width,
    height,
    at: (px, py) => {
      const offset = (py * width + px) * 3;
      return [data[offset], data[offset + 1], data[offset + 2]];
    },
  };
  return { image, scale, unitToPx, width, height, groundY: baseline, placed: boxes, tallest };
}
/** Copy a rectangular crop out of a decoded or simulated image. */
export function crop(image, left, top, width, height) {
  return {
    width,
    height,
    at: (x, y) => image.at(left + x, top + y),
  };
}

// --- painted board geometry --------------------------------------------------
const near = (color, target, tolerance) => Math.abs(color[0] - target[0]) <= tolerance
  && Math.abs(color[1] - target[1]) <= tolerance
  && Math.abs(color[2] - target[2]) <= tolerance;

/**
 * Find the painted 8×8 grid by counting pixels near each square colour per row
 * and column. Dark squares are the board's own ink; the beige margin shares
 * ~C1 with the light squares, so both colours are counted and the grid is the
 * span where the checkerboard pattern makes one of them dense.
 */
export function boardRect(image, specC1 = hexToRgb(SPEC.C1), specC2 = hexToRgb(SPEC.C2), tolerance = 12) {
  const isDark = (color) => near(color, specC2, tolerance);
  const rows = new Array(image.height).fill(0);
  const cols = new Array(image.width).fill(0);
  for (let y = 0; y < image.height; y++) {
    for (let x = 0; x < image.width; x++) {
      if (!isDark(image.at(x, y))) continue;
      rows[y]++;
      cols[x]++;
    }
  }
  const span = (list) => {
    // Inside the board a full row of dark squares is about half the side; the
    // dark backdrop band above the board is ~90% of the width, so the band is
    // removed first and the remaining runs are the checkerboard's.
    const max = Math.max(...list);
    const threshold = Math.max(8, max * 0.55);
    let first = -1;
    let last = -1;
    list.forEach((count, index) => {
      if (count < threshold) return;
      if (first < 0) first = index;
      last = index;
    });
    return { from: first, to: last + 1 };
  };
  // Drop runs longer than 60% of the opposite axis: that is the full-bleed band.
  const pruneBand = (list, limit) => list.map((count) => (count > limit ? 0 : count));
  const horizontal = span(pruneBand(rows, image.width * 0.7));
  const vertical = span(pruneBand(cols, image.height * 0.7));
  const side = horizontal.to - horizontal.from;
  return {
    left: vertical.from,
    top: horizontal.from,
    side,
    square: side / 8,
    bottom: horizontal.to,
    right: vertical.from + side,
  };
}

/** Sample a small patch's median colour — robust against anti-aliased text/pieces. */
export function patchMedian(image, cx, cy, half) {
  const chans = [[], [], []];
  for (let y = cy - half; y <= cy + half; y++) {
    for (let x = cx - half; x <= cx + half; x++) {
      const [r, g, b] = image.at(x, y);
      chans[0].push(r); chans[1].push(g); chans[2].push(b);
    }
  }
  const median = (values) => {
    const sorted = [...values].sort((a, b) => a - b);
    return sorted[Math.floor(sorted.length / 2)];
  };
  return chans.map(median);
}

/** The square colour that occupies a square's centre patch. */
export function squareColour(image, rect, file, rank, half = 3) {
  const cx = Math.round(rect.left + (file + 0.5) * rect.square);
  const cy = Math.round(rect.bottom - (rank - 0.5) * rect.square);
  return { x: cx, y: cy, rgb: patchMedian(image, cx, cy, half) };
}
