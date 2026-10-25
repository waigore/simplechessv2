/**
 * #868 graphical run — S4 promotion chooser through the real screen pointer path.
 *
 * Usage:
 *   node drive.mjs <url> <runDir>
 *
 * One browser at 390×844 CSS / DPR 2 with CDP touch emulation. The dealt Shared
 * board has no pawn one square from its last rank, so the run *builds* the S4
 * position by play: it taps a legal sequence on the standard opening (dx) that
 * reaches a last-rank place with no kind chosen, then reads the screen.
 *
 * The sequence is a repetition trap rather than a single push, so every tap is
 * legal and neither king is ever left in check:
 *
 *   White: Ng1–f3–g1 first (so the rook still covers f1), then Rh1–g1–h1 and
 *   Nf3–g1–f3 threefold-repetition retired … details in notes.md.
 *
 * For each fixture, on a fresh session, the whole sequence is played by tapped
 * controls, then:
 *
 *   White: tap d5, tap c6 → S4 at c6; read the four sprite slots from pixels
 *   (±0.28 square: Queen, rook, bishop, knight per S4), tap the Queen sprite →
 *   C6 must commit a White queen. Deselect leg: repeat the place, then tap c6's
 *   centre between the sprites → IN.deselect must drop the choice.
 *   Black: the same with a Black c-pawn taking c1.
 *
 * Writes into <runDir>: screenshots/*.png, readings.json, logs/drive-console.log.
 * Readings only; the judgement is notes.md.
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';
import {
  boardRect, chooserSlots, decodePng, inkInBox, meanColour, squareCentre,
} from './png.mjs';

const [url, runDir] = process.argv.slice(2);
if (!url || !runDir) {
  console.error('usage: node drive.mjs <url> <runDir>');
  process.exit(2);
}
const shotsDir = path.join(runDir, 'screenshots');
const logDir = path.join(runDir, 'logs');
fs.mkdirSync(shotsDir, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

const FRAME = { width: 390, height: 844, dpr: 2 };
const MODE_PICK_SHARED = { x: 195, y: 164 };
const SETUP_START = { x: 120, y: 323 };

// The sequences are exported from this file so they can be replayed outside a
// browser; see SEQUENCES at the bottom of the file.
const SEQUENCES = JSON.parse(fs.readFileSync(path.join(path.dirname(new URL(import.meta.url).pathname), 'sequences.json'), 'utf8'));

const driver = await connect({ ...FRAME, url, outDir: shotsDir, logDir, label: 'drive' });
const readings = { frame: FRAME, url, fixtures: [] };

/** Reload and tap mode pick → Shared game → Start. Returns the painted grid. */
async function openBoard(tag) {
  await driver.reload();
  await sleep(12000);
  await driver.tap(MODE_PICK_SHARED.x, MODE_PICK_SHARED.y);
  await sleep(1500);
  await driver.tap(SETUP_START.x, SETUP_START.y);
  await sleep(2200);
  const shot = await driver.shot(`${tag}-board`);
  const grid = boardRect(decodePng(path.join(shotsDir, shot)), FRAME.dpr);
  if (!grid) throw new Error(`${tag}: no painted board found`);
  return { shot, grid };
}

/** Select `from`, then place on `to`, on the grid already painted. */
async function play(grid, from, to) {
  const f = squareCentre(grid, from);
  await driver.tap(f.x, f.y);
  await sleep(180);
  const t = squareCentre(grid, to);
  await driver.tap(t.x, t.y);
  await sleep(320);
}

/** Play a sequence from a fresh session; returns the grid it landed on. */
async function playSequence(tag, sequence) {
  const { shot, grid } = await openBoard(tag);
  let i = 0;
  for (const [from, to] of sequence) {
    await play(grid, from, to);
    i += 1;
    if (i % 12 === 0) await driver.shot(`${tag}-stage-${String(i).padStart(2, '0')}`);
  }
  const landed = await driver.shot(`${tag}-ready`);
  return { grid, shots: { board: `screenshots/${shot}`, ready: `screenshots/${landed}` } };
}

/** Chooser slot colours around `centre`, and the centre between them. */
function readChooser(img, grid, centre) {
  return {
    slots: chooserSlots(centre, grid.square).map((slot) => ({
      ...slot,
      mean: meanColour(img, FRAME.dpr, slot.x, slot.y, grid.square * 0.14),
      ink: inkInBox(img, FRAME.dpr, slot.x, slot.y, grid.square * 0.14),
    })),
    centre: meanColour(img, FRAME.dpr, centre.x, centre.y, grid.square * 0.14),
    centreInk: inkInBox(img, FRAME.dpr, centre.x, centre.y, grid.square * 0.14),
  };
}

await sleep(12000);
await driver.shot('step-mode-pick');

const CASES = [
  {
    tag: 'white',
    sequence: SEQUENCES.white,
    origin: 'd5',
    dest: 'c6',
    deselect: false,
  },
  {
    tag: 'white-deselect',
    sequence: SEQUENCES.white,
    origin: 'd5',
    dest: 'c6',
    deselect: true,
  },
  {
    tag: 'black',
    sequence: SEQUENCES.black,
    origin: 'c2',
    dest: 'c1',
    deselect: false,
  },
];

for (const item of CASES) {
  const read = { tag: item.tag, sequence: item.sequence, origin: item.origin, dest: item.dest };
  const { grid, shots } = await playSequence(item.tag, item.sequence);
  read.grid = grid;
  read.shots = shots;
  const origin = squareCentre(grid, item.origin);
  const dest = squareCentre(grid, item.dest);
  read.points = { origin, dest };

  await driver.tap(origin.x, origin.y);
  await sleep(400);
  read.shots.armed = `screenshots/${await driver.shot(`${item.tag}-armed`)}`;
  await driver.tap(dest.x, dest.y);
  await sleep(900);
  read.shots.s4 = `screenshots/${await driver.shot(`${item.tag}-s4`)}`;
  const s4Img = decodePng(path.join(shotsDir, `${item.tag}-s4.png`));
  read.s4 = readChooser(s4Img, grid, dest);
  read.originBefore = inkInBox(s4Img, FRAME.dpr, origin.x, origin.y, grid.square * 0.2);
  read.destBefore = inkInBox(s4Img, FRAME.dpr, dest.x, dest.y, grid.square * 0.2);

  if (item.deselect) {
    await driver.tap(dest.x, dest.y);
    await sleep(900);
    read.shots.after = `screenshots/${await driver.shot(`${item.tag}-after`)}`;
    const img = decodePng(path.join(shotsDir, `${item.tag}-after.png`));
    read.afterDeselect = {
      chooser: readChooser(img, grid, dest),
      origin: inkInBox(img, FRAME.dpr, origin.x, origin.y, grid.square * 0.2),
      dest: inkInBox(img, FRAME.dpr, dest.x, dest.y, grid.square * 0.2),
    };
  } else {
    const queen = read.s4.slots[0];
    await driver.tap(queen.x, queen.y);
    await sleep(900);
    read.shots.committed = `screenshots/${await driver.shot(`${item.tag}-committed`)}`;
    const img = decodePng(path.join(shotsDir, `${item.tag}-committed.png`));
    read.afterCommit = {
      chooser: readChooser(img, grid, dest),
      origin: inkInBox(img, FRAME.dpr, origin.x, origin.y, grid.square * 0.2),
      dest: inkInBox(img, FRAME.dpr, dest.x, dest.y, grid.square * 0.2),
    };
  }
  readings.fixtures.push(read);
}

fs.writeFileSync(path.join(runDir, 'readings.json'), `${JSON.stringify(readings, null, 2)}\n`);
await driver.close();
console.log(`wrote ${path.join(runDir, 'readings.json')}`);
