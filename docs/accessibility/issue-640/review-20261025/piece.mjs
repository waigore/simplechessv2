/**
 * K2: the piece-contrast unit as the shipped build draws it, cropped at the
 * judged pixel size, then measured on the square paint and in both simulations.
 *
 * The K2 unit is SRF.O1's composition of a piece's fill and its contour against
 * the square it stands on. The shipped build draws that composition from the
 * shipped sprites, so the tested unit here is a crop of the rendered board —
 * one tile per side per square colour — not a re-render from the source PNGs.
 *
 * Usage: node piece.mjs <gameAssetsDir> <runDir>
 *
 * Writes `screenshots/piece-contrast-<sim>.png` and merges `k2` into readings.json.
 */
import fs from 'node:fs';
import path from 'node:path';
import { decodePng } from './png.mjs';
import {
  SPEC, K2_MIN_RATIO, hexToRgb, rgbToHex, luminance, contrastRatio, simulate, simulateImage,
  writePng, boardRect,
} from './measure.mjs';

const [assetsDir, runDir] = process.argv.slice(2);
if (!assetsDir || !runDir) {
  console.error('usage: node piece.mjs <gameAssetsDir> <runDir>');
  process.exit(2);
}
const shotsDir = path.join(runDir, 'screenshots');
const readings = JSON.parse(fs.readFileSync(path.join(runDir, 'readings.json'), 'utf8'));
const control = decodePng(path.join(shotsDir, `board-control.png`));
const rect = boardRect(control);
const square = rect.square;

// The four worked pairs PAL.K2 names. Only the carriers in `carrier` must clear
// 3:1; the other tone is the pair's weak tone, recorded and never scored.
const PAIRS = [
  {
    label: 'white piece on C2',
    piece: 'b2 pawn',
    side: 'white',
    squareName: 'C2',
    // White piece, rank 2 pawn standing on the dark square: rank-2 pawns sit on
    // file b/d/f/h — b2 is (file 1, rank 2). The capture's own paint confirms
    // b2 is dark: every rank-8 file-a..h sweep reads D/L/D/L/D/L/D/L and every
    // rank-7 sweep reads L/D/L/D/L/D/L/D (readings.json `parity`).
    file: 1,
    rank: 2,
    carrier: { tone: 'fill', spec: SPEC.C3, against: SPEC.C2 },
    weak: { tone: 'contour', spec: SPEC.C4, against: SPEC.C2 },
  },
  {
    label: 'white piece on C1',
    piece: 'f1 bishop',
    side: 'white',
    squareName: 'C1',
    // White piece on a light square: f1 bishop (file 5, rank 1) — light in the
    // same sweep (rank 1 reads D/L/D/L/D/L/D/L).
    file: 5,
    rank: 1,
    carrier: { tone: 'contour', spec: SPEC.C4, against: SPEC.C1 },
    weak: { tone: 'fill', spec: SPEC.C3, against: SPEC.C1 },
  },
  {
    label: 'black piece on C1',
    piece: 'a8 rook',
    side: 'black',
    squareName: 'C1',
    // Black piece on a light square: a8 black rook (file 0, rank 8 — light).
    file: 0,
    rank: 8,
    carrier: { tone: 'fill', spec: SPEC.C4, against: SPEC.C1 },
    weak: { tone: 'contour', spec: SPEC.C3, against: SPEC.C1 },
  },
  {
    label: 'black piece on C2',
    piece: 'b8 knight',
    side: 'black',
    squareName: 'C2',
    // Black piece on a dark square: b8 black knight (file 1, rank 8 — dark).
    file: 1,
    rank: 8,
    carrier: { tone: 'contour', spec: SPEC.C3, against: SPEC.C2 },
    weak: { tone: 'fill', spec: SPEC.C4, against: SPEC.C2 },
  },
];

// The square paint each pair stands on, sampled from the same capture.
const squarePaint = {
  C1: hexToRgb(SPEC.C1),
  C2: hexToRgb(SPEC.C2),
};
const drawnSquare = {
  C1: hexToRgb(readings.drawn['C1-light'].hex),
  C2: hexToRgb(readings.drawn['C2-dark'].hex),
};

/** The crop of one square, at its rendered pixel size. */
function squareCrop(image, file, rank) {
  const left = Math.round(rect.left + file * square);
  const top = Math.round(rect.bottom - (rank) * square);
  const width = Math.round(square);
  const height = Math.round(square);
  return {
    left,
    top,
    width,
    height,
    image: {
      width,
      height,
      at: (x, y) => image.at(left + x, top + y),
    },
  };
}

/** The nearest pixel in `image` to a spec tone — the piece's drawn tone. */
function nearestTone(image, spec, background) {
  const target = hexToRgb(spec);
  const bg = hexToRgb(background);
  let best = null;
  for (let y = 0; y < image.height; y++) {
    for (let x = 0; x < image.width; x++) {
      const rgb = image.at(x, y);
      // Skip the square's own paint (and its anti-aliased halo).
      const distanceToBg = Math.hypot(rgb[0] - bg[0], rgb[1] - bg[1], rgb[2] - bg[2]);
      if (distanceToBg < 24) continue;
      const distance = Math.hypot(rgb[0] - target[0], rgb[1] - target[1], rgb[2] - target[2]);
      if (!best || distance < best.distance) best = { x, y, rgb, distance };
    }
  }
  return best;
}

/**
 * The piece's drawn tones, read from the square crop at the judged pixel size.
 *
 * The piece occupies the middle of its square (SPC.E1: a 0.85 × 0.85 body on a
 * 1-unit square), so only the central footprint is read; that keeps the
 * neighbouring squares out of the histogram. The fill is the most common tone
 * that is neither the square paint nor its anti-aliased halo, and the contour is
 * the next most common: O1 draws the contour as a band hugging the silhouette,
 * so it is the second-largest body of ink after the fill — never the square.
 */
function drawnTones(image, squareHex) {
  const bg = hexToRgb(squareHex);
  const histogram = new Map();
  const halfX = Math.round(image.width * 0.30);
  const halfY = Math.round(image.height * 0.42);
  const cx = Math.round(image.width / 2);
  const cy = Math.round(image.height / 2);
  for (let y = cy - halfY; y < cy + halfY; y++) {
    for (let x = cx - halfX; x < cx + halfX; x++) {
      const rgb = image.at(x, y);
      if (Math.hypot(rgb[0] - bg[0], rgb[1] - bg[1], rgb[2] - bg[2]) < 24) continue;
      const key = rgb.join(',');
      histogram.set(key, (histogram.get(key) || 0) + 1);
    }
  }
  const colours = [...histogram.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([key, count]) => ({ rgb: key.split(',').map(Number), count }));
  const fill = colours[0];
  const contour = colours.slice(1).find((c) => c.count >= 3);
  return { fill, contour, colours };
}

// Crop every pair at the judged pixel size and store its tile geometry.
const tiles = PAIRS.map((pair, index) => {
  const crop = squareCrop(control, pair.file, pair.rank);
  return { ...pair, index, crop };
});

// One strip per simulation: the four crops side by side, each at the judged
// pixel size, so the artefact is the K2 unit as rendered.
const gap = 12;
const stripWidth = tiles.length * square + (tiles.length - 1) * gap;
const stripHeight = square;
for (const sim of ['protanopia', 'deuteranopia']) {
  const data = new Uint8ClampedArray(stripWidth * stripHeight * 3).fill(255);
  const image = {
    width: stripWidth,
    height: stripHeight,
    at: (x, y) => {
      const o = (y * stripWidth + x) * 3;
      return [data[o], data[o + 1], data[o + 2]];
    },
  };
  for (const tile of tiles) {
    const simulated = simulateImage(tile.crop.image, sim);
    const left = tile.index * (square + gap);
    for (let y = 0; y < square; y++) {
      for (let x = 0; x < square; x++) {
        const [r, g, b] = simulated.at(x, y);
        const o = (y * stripWidth + left + x) * 3;
        data[o] = r; data[o + 1] = g; data[o + 2] = b;
      }
    }
  }
  writePng(path.join(shotsDir, `piece-contrast-${sim}.png`), image);
}

// Measure the K2 tested unit in each simulation.
const k2 = { judgedSquarePx: square, minRatio: K2_MIN_RATIO, pairs: [], simulations: {} };
for (const tile of tiles) {
  const simulated = tile.crop.image;
  const squareHex = tile.squareName === 'C1' ? readings.swatchMatch.C1.drawn : readings.swatchMatch.C2.drawn;
  const tones = drawnTones(simulated, squareHex);
  k2.pairs.push({
    label: tile.label,
    side: tile.side,
    square: tile.squareName,
    squareSpec: tile.squareName === 'C1' ? SPEC.C1 : SPEC.C2,
    squareDrawn: squareHex,
    squareAt: { file: tile.file, rank: tile.rank },
    crop: { left: tile.crop.left, top: tile.crop.top, width: tile.crop.width, height: tile.crop.height },
    tones: tones.colours.slice(0, 6).map((c) => ({ hex: rgbToHex(c.rgb), count: c.count })),
    drawnFill: rgbToHex(tones.fill.rgb),
    drawnContour: rgbToHex(tones.contour.rgb),
    carrier: tile.carrier,
    weak: tile.weak,
  });
}

for (const sim of ['protanopia', 'deuteranopia']) {
  k2.simulations[sim] = [];
  for (const [index, tile] of tiles.entries()) {
    // The tones are the *drawn* ones the pieces show in the un-simulated
    // capture (row `index` of k2.pairs); the simulation moves each tone and the
    // square paint through the same matrix, so both sides of every ratio are
    // simulated together.
    const measured = k2.pairs[index];
    const fill = hexToRgb(measured.drawnFill);
    const contour = hexToRgb(measured.drawnContour);
    const squareRgb = simulate(hexToRgb(measured.squareDrawn), sim);
    const fillRatio = contrastRatio(simulate(fill, sim), squareRgb);
    const contourRatio = contrastRatio(simulate(contour, sim), squareRgb);
    const isCarrierFill = tile.carrier.tone === 'fill';
    const carrierRatio = isCarrierFill ? fillRatio : contourRatio;
    const weakRatio = isCarrierFill ? contourRatio : fillRatio;
    k2.simulations[sim].push({
      label: tile.label,
      piece: tile.piece,
      squareHex: rgbToHex(squareRgb),
      fillHex: rgbToHex(simulate(fill, sim)),
      contourHex: rgbToHex(simulate(contour, sim)),
      fillRatio,
      contourRatio,
      carrierTone: tile.carrier.tone,
      carrierRatio,
      weakTone: tile.weak.tone,
      weakRatio,
      carrierPasses: carrierRatio >= K2_MIN_RATIO,
    });
  }
}
k2.carrierPasses = Object.fromEntries(Object.entries(k2.simulations).map(([sim, rows]) => [
  sim,
  rows.every((row) => row.carrierPasses),
]));
readings.k2 = k2;
fs.writeFileSync(path.join(runDir, 'readings.json'), `${JSON.stringify(readings, null, 2)}\n`);
console.log(JSON.stringify(k2, null, 2));
