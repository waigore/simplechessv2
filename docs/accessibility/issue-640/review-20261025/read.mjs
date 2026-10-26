/**
 * #640 readings: the board canvas, the drawn swatches, and the two K1
 * simulations, measured from the capture `run.mjs` wrote.
 *
 * Usage: node read.mjs <runDir>
 *
 * Writes `screenshots/lightness-<sim>.png` (the board canvas as simulated) and
 * `readings.json`. Nothing here decides a verdict; it records numbers beside
 * the spec constants so `notes.md` can quote them.
 */
import fs from 'node:fs';
import path from 'node:path';
import { decodePng } from './png.mjs';
import {
  SPEC, K1_MIN_DELTA, hexToRgb, rgbToHex, luminance, contrastRatio, simulate, simulateImage,
  writePng, crop, boardRect, patchMedian,
} from './measure.mjs';

const runDir = process.argv[2] || '.';
const shotsDir = path.join(runDir, 'screenshots');
const capture = JSON.parse(fs.readFileSync(path.join(runDir, 'capture.json'), 'utf8'));
const dpr = capture.frame.dpr;

const control = decodePng(path.join(shotsDir, capture.control));
const rect = boardRect(control);
const square = rect.square;

// --- 1. The drawn swatches, sampled on the un-simulated control ------------
// Sample well inside the checkerboard's interior: file 0 / file 1 on rank 3,
// which are the two middle centre squares (no piece stands on them at the
// starting position), so a 9×9 median patch is pure square paint.
const drawn = {};
for (const [name, file, rank] of [['C1-light', 1, 3], ['C2-dark', 0, 3], ['C2-dark-b', 2, 3], ['C1-light-b', 3, 3]]) {
  const cx = Math.round(rect.left + (file + 0.5) * square);
  const cy = Math.round(rect.bottom - (rank - 0.5) * square);
  const rgb = patchMedian(control, cx, cy, 4);
  drawn[name] = { file, rank, x: cx, y: cy, xCss: cx / dpr, yCss: cy / dpr, rgb, hex: rgbToHex(rgb) };
}

const specC1 = hexToRgb(SPEC.C1);
const specC2 = hexToRgb(SPEC.C2);
const drawnC1 = drawn['C1-light'].rgb;
const drawnC2 = drawn['C2-dark'].rgb;

// --- 2. K1 — the board canvas, simulated -----------------------------------
const canvas = crop(control, rect.left, rect.top, square * 8, square * 8);
const sims = ['protanopia', 'deuteranopia'];
const lightness = {};
for (const sim of sims) {
  const image = simulateImage(canvas, sim);
  writePng(path.join(shotsDir, `lightness-${sim}.png`), image);
  // Re-read the same sample points in the simulated canvas.
  const read = {};
  for (const [name, file, rank] of [['C1-light', 1, 3], ['C2-dark', 0, 3], ['C2-dark-b', 2, 3], ['C1-light-b', 3, 3]]) {
    const cx = Math.round((file + 0.5) * square);
    const cy = Math.round((rank - 0.5) * square);
    const rgb = patchMedian(image, cx, cy, 4);
    read[name] = { x: cx, y: cy, rgb, hex: rgbToHex(rgb) };
  }
  const d1 = Math.abs(luminance(read['C1-light'].rgb) - luminance(read['C2-dark'].rgb));
  const d1b = Math.abs(luminance(read['C1-light-b'].rgb) - luminance(read['C2-dark-b'].rgb));
  lightness[sim] = {
    samples: read,
    delta: Math.max(d1, d1b),
    deltaPerPair: [d1, d1b],
    luminances: {
      C1light: luminance(read['C1-light'].rgb),
      C2dark: luminance(read['C2-dark'].rgb),
      C1lightb: luminance(read['C1-light-b'].rgb),
      C2darkb: luminance(read['C2-dark-b'].rgb),
    },
    passes: Math.max(d1, d1b) >= K1_MIN_DELTA,
  };
}

// The un-simulated control delta, quoted alongside.
const controlDelta = Math.abs(luminance(drawnC1) - luminance(drawnC2));

// --- 3. The spec->render comparison ----------------------------------------
const swatchMatch = {
  C1: { spec: SPEC.C1, drawn: drawn['C1-light'].hex, equal: drawn['C1-light'].hex === SPEC.C1 },
  C2: { spec: SPEC.C2, drawn: drawn['C2-dark'].hex, equal: drawn['C2-dark'].hex === SPEC.C2 },
  c1SecondSample: { drawn: drawn['C1-light-b'].hex, equal: drawn['C1-light-b'].hex === SPEC.C1 },
  c2SecondSample: { drawn: drawn['C2-dark-b'].hex, equal: drawn['C2-dark-b'].hex === SPEC.C2 },
};

// --- 4. Square geometry, in capture pixels and CSS pixels ------------------
const geometry = {
  capturePx: { left: rect.left, top: rect.top, side: rect.side, square, bottom: rect.bottom },
  cssPx: { left: rect.left / dpr, top: rect.top / dpr, side: rect.side / dpr, square: square / dpr },
  capture: { width: control.width, height: control.height },
};

const readings = {
  source: capture.url,
  frame: capture.frame,
  capturePng: `screenshots/${capture.control}`,
  geometry,
  spec: { ...SPEC, K1_MIN_DELTA },
  drawn,
  control: { delta: controlDelta, luminance: { C1: luminance(drawnC1), C2: luminance(drawnC2) } },
  swatchMatch,
  lightness,
  simulations: {
    protanopia: 'Viénot, Brettel & Mollon (1999) dichromat LMS-plane reduction, applied in linear RGB',
    deuteranopia: 'Viénot, Brettel & Mollon (1999) dichromat LMS-plane reduction, applied in linear RGB',
  },
};

fs.writeFileSync(path.join(runDir, 'readings.json'), `${JSON.stringify(readings, null, 2)}\n`);
console.log(JSON.stringify({ geometry, drawn, swatchMatch, control: readings.control, lightness }, null, 2));
