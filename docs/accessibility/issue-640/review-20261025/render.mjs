/**
 * Render the two #640 artefacts that are drawn rather than captured:
 *
 *   - `screenshots/silhouette-sheet.png` — the six types, solid black, at their
 *     FRM.P2 heights in the FRM.L1 lineup (see `silhouetteSheet` in measure.mjs).
 *   - `screenshots/piece-contrast-<sim>.png` — the K2 unit: white and black
 *     pieces composed with their SRF.O1:O1 contour, drawn on C1 and C2 at the
 *     judged pixel size, each on its own tile.
 *
 * The contour is the SRF.O1 tone for the piece's side, drawn as a band of
 * `O1`'s width (2% of the subject height) around the shipped sprite's opaque
 * body. The piece is drawn from its opaque bounding box at the judged size, so
 * the rendered pixel height is the frame height the sheet records.
 *
 * Usage: node render.mjs <gameAssetsDir> <outDir>
 */
import fs from 'node:fs';
import path from 'node:path';
import {
  SPEC, hexToRgb, decodeRgba, opaqueBounds, silhouetteSheet, writePng, simulateImage, crop,
} from './measure.mjs';

const TYPES = ['k', 'q', 'b', 'n', 'r', 'p'];
const SIDES = ['white', 'black'];
// FRM.P2 opaque heights, tallest to shortest; the King is the FRM.P1 0.85 unit.
const FRM_P2 = { k: 0.85, q: 0.79, b: 0.76, n: 0.75, r: 0.68, p: 0.62 };
// SRF.O1:O1 contour tone per side (surface.md line 30).
const CONTOUR = { white: SPEC.C4, black: SPEC.C3 };
// SRF.O1:O1 width: 2% of the King's 0.85 body height, on every type.
const O1_WIDTH_OF_HEIGHT = 0.017 / 0.85;

const [assetsDir, outDir] = process.argv.slice(2);
if (!assetsDir || !outDir) {
  console.error('usage: node render.mjs <gameAssetsDir> <outDir>');
  process.exit(2);
}
fs.mkdirSync(outDir, { recursive: true });

const sprite = (kind, side) => {
  const file = path.join(assetsDir, 'piece-sprites', `${kind}-${side}.png`);
  const image = decodeRgba(file);
  return { file: `game_assets/piece-sprites/${kind}-${side}.png`, image, opaque: opaqueBounds(image) };
};

// --- 1. FRM.L1 silhouette sheet ---------------------------------------------
// Both sides are identical in solid black, so the sheet carries one sprite per
// type and says nothing about side (the twelve IDs are traced in the record).
const sheetSources = TYPES.map((kind) => ({ key: kind, ...sprite(kind, 'white') }));
const sheet = silhouetteSheet(sheetSources, { squarePx: 120, labelRow: 64 });

// Anonymous labels are written by label.mjs after the blind read, so the sheet
// PNG itself never carries a label: it is drawn here with a blank label row.
writePng(path.join(outDir, 'silhouette-sheet-body.png'), sheet.image);

// --- 2. K2 piece-contrast tiles ---------------------------------------------
// The judged pixel size: the King's 0.85 unit at the shipped phone board's
// square edge, measured from the capture (see run.mjs). Passed in as argv[3].
const judgedSquarePx = Number(process.argv[4] || 68);
const kingPx = Math.round(FRM_P2.k * judgedSquarePx);

/** One piece composed with its O1 contour at `heightPx` opaque body height. */
function composedPiece(source, heightPx) {
  const widthPx = Math.max(1, Math.round(source.opaque.width * (heightPx / source.opaque.height)));
  const band = Math.max(1, Math.round(heightPx * O1_WIDTH_OF_HEIGHT));
  const width = widthPx + band * 2;
  const height = heightPx + band * 2;
  const fill = hexToRgb(source.fillTone);
  const contour = hexToRgb(CONTOUR[source.side]);
  const data = new Uint8ClampedArray(width * height * 3);
  const set = (x, y, rgb) => {
    const offset = (y * width + x) * 3;
    data[offset] = rgb[0]; data[offset + 1] = rgb[1]; data[offset + 2] = rgb[2];
  };
  const sample = (dx, dy) => {
    const sx = source.opaque.left + Math.min(source.opaque.width - 1,
      Math.floor((dx / widthPx) * source.opaque.width));
    const sy = source.opaque.top + Math.min(source.opaque.height - 1,
      Math.floor((dy / heightPx) * source.opaque.height));
    return source.image.at(sx, sy)[3] >= 128;
  };
  // O1 first: any pixel within `band` of the body is the contour tone, so the
  // contour hugs the silhouette exactly as surface.md composes it.
  const body = [];
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      let inside = false;
      for (let oy = -band; oy <= band && !inside; oy++) {
        for (let ox = -band; ox <= band && !inside; ox++) {
          const dx = x - band + ox;
          const dy = y - band + oy;
          if (dx < 0 || dy < 0 || dx >= widthPx || dy >= heightPx) continue;
          if (sample(dx, dy)) inside = true;
        }
      }
      if (inside) set(x, y, contour);
    }
  }
  // Fill over the contour band's interior.
  for (let dy = 0; dy < heightPx; dy++) {
    for (let dx = 0; dx < widthPx; dx++) {
      if (!sample(dx, dy)) continue;
      set(band + dx, band + dy, fill);
      body.push([band + dx, band + dy]);
    }
  }
  return {
    image: { width, height, at: (x, y) => { const o = (y * width + x) * 3; return [data[o], data[o + 1], data[o + 2]]; } },
    band,
    body,
    fillTone: source.fillTone,
    contourTone: CONTOUR[source.side],
    url: source.file,
  };
}

/** One tile: a square of C1 or C2 with the composed piece centred on it. */
function pieceTile(source, side, squareColour, squarePx) {
  const piece = composedPiece({ ...source, side, fillTone: side === 'white' ? SPEC.C3 : SPEC.C4 }, Math.round(0.85 * squarePx * 0.9));
  const width = squarePx;
  const height = squarePx;
  const background = hexToRgb(squareColour);
  const data = new Uint8ClampedArray(width * height * 3);
  for (let i = 0; i < width * height; i++) {
    const o = i * 3;
    data[o] = background[0]; data[o + 1] = background[1]; data[o + 2] = background[2];
  }
  const left = Math.round((width - piece.image.width) / 2);
  const top = Math.round((height - piece.image.height) / 2);
  for (let y = 0; y < piece.image.height; y++) {
    for (let x = 0; x < piece.image.width; x++) {
      const px = left + x;
      const py = top + y;
      if (px < 0 || py < 0 || px >= width || py >= height) continue;
      const [r, g, b] = piece.image.at(x, y);
      const o = (py * width + px) * 3;
      data[o] = r; data[o + 1] = g; data[o + 2] = b;
    }
  }
  return {
    image: { width, height, at: (x, y) => { const o = (y * width + x) * 3; return [data[o], data[o + 1], data[o + 2]]; } },
    piece,
    left,
    top,
  };
}

// The K2 tested unit: a Pawn of each side on each square colour. The Pawn is
// the smallest body (FRM.P2 0.62), so its 2.3 px contour is the tightest case.
const TILES = [
  { side: 'white', square: SPEC.C1, label: 'white-on-C1' },
  { side: 'white', square: SPEC.C2, label: 'white-on-C2' },
  { side: 'black', square: SPEC.C1, label: 'black-on-C1' },
  { side: 'black', square: SPEC.C2, label: 'black-on-C2' },
];
const pawn = { white: sprite('p', 'white'), black: sprite('p', 'black') };

for (const sim of ['none', 'protanopia', 'deuteranopia']) {
  const tileW = kingPx + 60;
  const gap = 24;
  const width = gap + TILES.length * (tileW + gap);
  const height = tileW + gap * 2;
  const data = new Uint8ClampedArray(width * height * 3).fill(255);
  const meta = [];
  for (const [index, tileSpec] of TILES.entries()) {
    const tile = pieceTile(pawn[tileSpec.side], tileSpec.side, tileSpec.square, tileW);
    const image = sim === 'none' ? tile.image : simulateImage(tile.image, sim);
    const left = gap + index * (tileW + gap);
    const top = gap;
    for (let y = 0; y < tileW; y++) {
      for (let x = 0; x < tileW; x++) {
        const [r, g, b] = image.at(x, y);
        const o = (((top + y) * width) + left + x) * 3;
        data[o] = r; data[o + 1] = g; data[o + 2] = b;
      }
    }
    meta.push({ ...tileSpec, left, top, size: tileW, pieceLeft: left + tile.left, pieceTop: top + tile.top, piece: {
      width: tile.piece.image.width, height: tile.piece.image.height, band: tile.piece.band,
      fillTone: tile.piece.fillTone, contourTone: tile.piece.contourTone,
    } });
  }
  const name = sim === 'none' ? 'piece-contrast-control' : `piece-contrast-${sim}`;
  writePng(path.join(outDir, `${name}.png`), {
    width, height, at: (x, y) => { const o = (y * width + x) * 3; return [data[o], data[o + 1], data[o + 2]]; },
  });
  fs.writeFileSync(path.join(outDir, `${name}.json`), `${JSON.stringify({ sim, judgedSquarePx, kingPx, tiles: meta }, null, 2)}\n`);
}

fs.writeFileSync(path.join(outDir, 'sheet.json'), `${JSON.stringify({
  squarePx: 120,
  width: sheet.width,
  height: sheet.height,
  groundY: sheet.groundY,
  scale: sheet.scale,
  boxes: sheet.placed,
}, null, 2)}\n`);

console.log(JSON.stringify({
  sheet: { width: sheet.width, height: sheet.height, groundY: sheet.groundY, boxes: sheet.placed },
  kingPx,
}, null, 2));
