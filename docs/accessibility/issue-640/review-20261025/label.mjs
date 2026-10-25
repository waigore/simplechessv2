/**
 * Label the FRM.L1 silhouette sheet with the six anonymous labels, A–F, in
 * sheet order (left to right, tallest to shortest of the lineup).
 *
 * The label pass runs before the blind read, and it records nothing but the
 * labels: the key (label → type) is withheld in `logs/key.md` until the naming
 * record carries its six verdicts.
 *
 * Usage: node label.mjs <runDir>
 */
import fs from 'node:fs';
import path from 'node:path';
import { decodePng } from './png.mjs';
import { writePng } from './measure.mjs';

const runDir = process.argv[2] || '.';
const shotsDir = path.join(runDir, 'screenshots');
const sheet = decodePng(path.join(shotsDir, 'silhouette-sheet-body.png'));
const meta = JSON.parse(fs.readFileSync(path.join(shotsDir, 'sheet.json'), 'utf8'));

// 5×8 bitmap glyphs, so the sheet needs no font file and the labels are the
// only text on it.
const GLYPHS = {
  A: ['01110', '10001', '10001', '11111', '10001', '10001', '10001'],
  B: ['11110', '10001', '10001', '11110', '10001', '10001', '11110'],
  C: ['01111', '10000', '10000', '10000', '10000', '10000', '01111'],
  D: ['11110', '10001', '10001', '10001', '10001', '10001', '11110'],
  E: ['11111', '10000', '10000', '11110', '10000', '10000', '11111'],
  F: ['11111', '10000', '10000', '11110', '10000', '10000', '11111'],
};
const SCALE = 5;

const palette = Array.from({ length: sheet.width * sheet.height }, (_, i) => sheet.at(i % sheet.width, Math.floor(i / sheet.width)));
const labels = meta.boxes.map((_, index) => String.fromCharCode(65 + index));
const placements = [];
for (const [index, box] of meta.boxes.entries()) {
  const label = labels[index];
  const glyph = GLYPHS[label];
  const width = glyph[0].length * SCALE;
  const height = glyph.length * SCALE;
  const left = box.left + Math.round(box.width / 2 - width / 2);
  const top = meta.height - Math.round((meta.height - meta.groundY) * 0.55);
  for (const [gy, row] of glyph.entries()) {
    for (const [gx, bit] of [...row].entries()) {
      if (bit !== '1') continue;
      for (let sy = 0; sy < SCALE; sy++) {
        for (let sx = 0; sx < SCALE; sx++) {
          const px = left + gx * SCALE + sx;
          const py = top + gy * SCALE + sy;
          if (px < 0 || py < 0 || px >= sheet.width || py >= sheet.height) continue;
          palette[py * sheet.width + px] = [0, 0, 0];
        }
      }
    }
  }
  placements.push({ label, x: left, y: top, width, height, box });
}

writePng(path.join(shotsDir, 'silhouette-sheet.png'), {
  width: sheet.width,
  height: sheet.height,
  at: (x, y) => palette[y * sheet.width + x],
});
fs.writeFileSync(path.join(shotsDir, 'silhouette-sheet-labels.json'), `${JSON.stringify({ labels, placements }, null, 2)}\n`);
console.log(JSON.stringify(placements.map((p) => ({ label: p.label, x: p.x, y: p.y, key: p.box.key })), null, 2));
