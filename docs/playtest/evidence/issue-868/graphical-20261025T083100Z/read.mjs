/**
 * Read the run's captured screenshots into a comparison table.
 *
 *   node read.mjs <runDir>
 *
 * One block per fixture: a line per shot with the destination's four chooser
 * slots and the centre between them, then the origin and destination squares.
 * A slot/section with ink (`ink:1/240`) is painted; `---` is plain tile. The
 * judgement is the before/after comparison of those numbers, recorded in
 * `notes.md`.
 *
 * Node decodes the PNG with its own inflate; the tile rules and box readers are
 * `../browser-read.js`, shared with the browser run.
 */
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { boardRect, inkInBox, meanColour } from '../browser-read.js';

/** Decode a non-interlaced 8-bit RGB/RGBA PNG into { width, height, rgba }. */
function decodePng(file) {
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

const [runArg] = process.argv.slice(2);
const runDir = path.resolve(runArg);
const shots = path.join(runDir, 'screenshots');
const FILES = 'abcdefgh';

const at = (grid, square) => ({
  x: grid.left + (FILES.indexOf(square[0]) + 0.5) * grid.square,
  y: grid.top + (8 - Number(square[1]) + 0.5) * grid.square,
});

const box = (img, grid, point, factor = 0.2) => {
  const ink = inkInBox(img, 2, point.x, point.y, grid.square * factor);
  return `${ink.inked ? 'ink' : '---'}:${ink.inkShare}/${ink.inkBrightness}`;
};

const chooser = (img, grid, dest) => {
  const c = at(grid, dest);
  const d = 0.28 * grid.square;
  const r = grid.square * 0.14;
  const slots = [['Q', -d, -d], ['R', d, -d], ['B', -d, d], ['N', d, d]]
    .map(([name, dx, dy]) => {
      const ink = inkInBox(img, 2, c.x + dx, c.y + dy, r);
      return `${name} ${ink.inked ? 'ink' : '---'}:${ink.inkShare}/${ink.inkBrightness}`;
    });
  const mean = meanColour(img, 2, c.x, c.y, r);
  return { slots, centre: `${box(img, grid, c)}/${mean.join(',')}` };
};

const FIXTURES = [
  ['white', 'd5', 'c6', 'e7'],
  ['white-deselect', 'd5', 'c6', 'e7'],
  ['black', 'c2', 'c1', 'd2'],
  ['no-promotion', 'e2', 'c6', ''],
];

for (const [tag, origin, dest, opponent] of FIXTURES) {
  const boardFile = path.join(shots, `${tag}-board.png`);
  if (!fs.existsSync(boardFile)) continue;
  const grid = boardRect(decodePng(boardFile), 2);
  console.log(`\n## ${tag}  origin ${origin}  dest ${dest}`);
  const names = fs
    .readdirSync(shots)
    .filter((name) => name.startsWith(`${tag}-`) && name.endsWith('.png') && !name.endsWith('-board.png'))
    .sort();
  for (const file of names) {
    const img = decodePng(path.join(shots, file));
    const read = chooser(img, grid, dest);
    const extra = opponent ? `  ${opponent} ${box(img, grid, at(grid, opponent))}` : '';
    console.log(`${file.padEnd(34)} origin ${box(img, grid, at(grid, origin))}  dest ${box(img, grid, at(grid, dest))}  centre ${read.centre}${extra}`);
    console.log(`${''.padEnd(34)} ${read.slots.join('  ')}`);
  }
}
