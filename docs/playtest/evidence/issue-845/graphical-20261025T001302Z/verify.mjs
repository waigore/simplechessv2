/**
 * #845 capture + mapping check on the release Web build, phone frame.
 *
 * Usage:
 *   node verify.mjs <url> <runDir>
 *
 * Three parts, all in one browser at 390×844 CSS / DPR 2 with touch emulation:
 *
 *   1. The filing's coordinate (219, 654): the ring must name the square whose
 *      painted box contains that point (e1), not e2.
 *   2. Select-then-move pairs, each on a *fresh* session: tap the painted centre
 *      of `from`, then of `to`; the pawn/knight must be painted on `to` and the
 *      header must flip to Black. A release→release tap on the already selected
 *      piece deselects it (B8), so each pair reloads rather than toggling.
 *   3. A painted-grid measurement (board.mjs) so every coordinate in this file
 *      is derived from the build's own paint, never from prose.
 *
 * Writes into <runDir>: screenshots/*.png, readings.json, logs/verify-console.log
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect } from './cdp.mjs';
import { boardRect, decodeBoard, ringSquare, squareCentre } from './board.mjs';
import { headerSide, pieceSquares } from './readback.mjs';

const [url, runDir] = process.argv.slice(2);
if (!url || !runDir) {
  console.error('usage: node verify.mjs <url> <runDir>');
  process.exit(2);
}
const shotsDir = path.join(runDir, 'screenshots');
const logDir = path.join(runDir, 'logs');
fs.mkdirSync(shotsDir, { recursive: true });

const FRAME = { width: 390, height: 844, dpr: 2 };
const FILE_TAP = { x: 219, y: 654 };
const PAIRS = [
  { from: 'e2', to: 'e4', piece: 'pawn' },
  { from: 'd2', to: 'd4', piece: 'pawn' },
  { from: 'b1', to: 'c3', piece: 'knight' },
  { from: 'g1', to: 'f3', piece: 'knight' },
];
// Where this build paints its mode-pick and setup controls (#546's phone-width
// layout moved them). Kept as screenshots so a reader can check them.
const MODE_PICK_SHARED = { x: 195, y: 164 };
const SETUP_START = { x: 120, y: 323 };

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const driver = await connect({ ...FRAME, url, outDir: shotsDir, logDir, label: 'verify' });

/** Mode pick → Shared game → Start; returns the painted board grid. */
async function openBoard(tag) {
  await driver.tap(MODE_PICK_SHARED.x, MODE_PICK_SHARED.y);
  await sleep(1500);
  await driver.tap(SETUP_START.x, SETUP_START.y);
  await sleep(2200);
  const shot = await driver.shot(`${tag}-board`);
  return { shot, grid: boardRect(decodeBoard(path.join(shotsDir, shot)), FRAME.dpr) };
}

const readings = { frame: FRAME, filingTap: null, pairs: [] };

// 1. The filing's coordinate.
await sleep(12000);
await driver.shot('step-mode-pick');
const first = await openBoard('filing');
await driver.tap(FILE_TAP.x, FILE_TAP.y);
await sleep(600);
const afterFile = await driver.shot('filing-after-219-654');
const fileRead = ringSquare(path.join(shotsDir, afterFile), FRAME.dpr);
readings.grid = first.grid;
readings.filingTap = {
  tap: FILE_TAP,
  ringSquare: fileRead.square,
  ringBox: fileRead.ring,
  e1Box: { top: first.grid.bottom - first.grid.square, bottom: first.grid.bottom },
  e2Centre: squareCentre(first.grid, 'e2'),
  e4Centre: squareCentre(first.grid, 'e4'),
  side: headerSide(path.join(shotsDir, afterFile), FRAME.dpr),
  shot: `screenshots/${afterFile}`,
};

// 2. Select-then-move pairs, one fresh session each.
for (const pair of PAIRS) {
  await driver.reload();
  await sleep(12000);
  const name = `${pair.from}-${pair.to}`;
  const { grid } = await openBoard(name);
  const fromTap = squareCentre(grid, pair.from);
  await driver.tap(fromTap.x, fromTap.y);
  await sleep(500);
  const a = await driver.shot(`${name}-a`);
  const selected = ringSquare(path.join(shotsDir, a), FRAME.dpr).square;
  const toTap = squareCentre(grid, pair.to);
  await driver.tap(toTap.x, toTap.y);
  await sleep(900);
  const b = await driver.shot(`${name}-b`);
  readings.pairs.push({
    pair: name,
    fromTap,
    toTap,
    selectedRing: selected,
    afterSide: headerSide(path.join(shotsDir, b), FRAME.dpr),
    afterInk: pieceSquares(path.join(shotsDir, b), FRAME.dpr),
    shots: { select: `screenshots/${a}`, after: `screenshots/${b}` },
  });
}

fs.writeFileSync(path.join(runDir, 'readings.json'), `${JSON.stringify(readings, null, 2)}\n`);
await driver.close();

// 3. Verdict, from the readings above.
const problems = [];
if (readings.filingTap.ringSquare !== 'e1') {
  problems.push(`filing tap ${JSON.stringify(FILE_TAP)} rang ${readings.filingTap.ringSquare || 'nothing'}, not e1`);
}
for (const r of readings.pairs) {
  if (r.selectedRing !== r.pair.split('-')[0]) {
    problems.push(`${r.pair}: painted selection rang ${r.selectedRing || 'nothing'}`);
  }
  if (r.afterSide !== 'black') {
    problems.push(`${r.pair}: header still ${r.afterSide || 'unread'}, not black`);
  }
  const target = r.pair.split('-')[1];
  if (!r.afterInk.includes(target)) {
    problems.push(`${r.pair}: nothing painted on ${target} (ink: ${r.afterInk.join(',') || 'none'})`);
  }
}
if (problems.length) {
  console.error(`FAIL\n- ${problems.join('\n- ')}`);
  process.exit(1);
}
console.log('ok: filing coordinate rings e1; all four moves commit on the tapped square');
