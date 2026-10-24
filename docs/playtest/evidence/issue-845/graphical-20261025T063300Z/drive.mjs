/**
 * #845 capture: tap the painted board on the release Web build and read back the
 * square the build selected.
 *
 * Usage:
 *   node drive.mjs <url> <runDir>
 *
 * Writes, into <runDir>:
 *   screenshots/board-00-before.png   the painted board after Shared game → Start
 *   screenshots/board-01..03-*.png    one screenshot per tap
 *   screenshots/board-04-after.png    the board after the destination tap
 *   readings.json                     each tap's coordinate, the measured grid,
 *                                     and the square its selection ring named
 *   logs/run-console.log              the page's console for the run
 *
 * The board grid is measured from `board-00-before.png`, so taps are placed on
 * the build's own paint and each ring's square is read back from pixels.
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';
import { boardRect, decodeBoard, ringSquare, squareCentre } from './board.mjs';

const [url, runDir] = process.argv.slice(2);
if (!url || !runDir) {
  console.error('usage: node drive.mjs <url> <runDir>');
  process.exit(2);
}

const shotsDir = path.join(runDir, 'screenshots');
const logsDir = path.join(runDir, 'logs');

const FRAME = { width: 390, height: 844, dpr: 2 };
const MODE_PICK_SHARED = { x: 180, y: 168 };
const SETUP_START = { x: 120, y: 323 };

const driver = await connect({
  ...FRAME, url, outDir: shotsDir, logDir: logsDir, label: 'run',
});
const readings = [];

const record = async (name, at, note) => {
  await driver.tap(at.x, at.y);
  const shot = await driver.shot(name);
  const read = ringSquare(path.join(shotsDir, shot), FRAME.dpr);
  readings.push({
    tap: { x: at.x, y: at.y }, shot: `screenshots/${shot}`, ring: read.square, note,
  });
};

await sleep(12000);
await driver.tap(MODE_PICK_SHARED.x, MODE_PICK_SHARED.y);
await sleep(1500);
await driver.tap(SETUP_START.x, SETUP_START.y);
await sleep(2000);
await driver.shot('board-00-before');

const grid = boardRect(decodeBoard(path.join(shotsDir, 'board-00-before.png')), FRAME.dpr);
const at = (square) => squareCentre(grid, square);

// 1. The defect's own coordinate for the painted e2 pawn (CSS 219, 654).
await record('board-01-tap-219-654', { x: 219, y: 654 }, 'report coordinate');
// 2. The painted centre this run measured for e2, then e4: select, then move.
await record('board-02-tap-painted-e2', at('e2'), 'painted e2 centre');
await record('board-03-tap-painted-e4', at('e4'), 'painted e4 centre');
await driver.shot('board-04-after');

fs.writeFileSync(
  path.join(runDir, 'readings.json'),
  `${JSON.stringify({ frame: FRAME, grid, readings }, null, 2)}\n`,
);
await driver.close();
console.log(JSON.stringify({ grid, readings }, null, 2));
