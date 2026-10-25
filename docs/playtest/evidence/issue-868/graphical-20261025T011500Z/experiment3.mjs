/**
 * Experiment 3 — how the published build behaves under CDP-driven touch input.
 *
 * Usage: node experiment3.mjs <url> <outDir>
 *
 * Runs three known-legal places three ways and screenshots each, so notes.md can
 * state exactly which pointer route this run's harness reaches:
 *
 *   A  tap pair (tap e2, tap e4)
 *   B  drag (press e2, move, release on e4)
 *   C  tap pair on the a-file only (a2, a3) — bandwidth sanity, near the edge
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';
import { boardRect, decodePng, inkInBox, squareCentre } from './png.mjs';

const [url, out] = process.argv.slice(2);
fs.mkdirSync(out, { recursive: true });
const driver = await connect({ width: 390, height: 844, dpr: 2, url, outDir: out, logDir: out, label: 'exp3' });
await sleep(12000);
await driver.tap(195, 164);
await sleep(1500);
await driver.tap(120, 323);
await sleep(2200);
const shot = await driver.shot('board');
const grid = boardRect(decodePng(path.join(out, shot)), 2);
console.log('grid', JSON.stringify(grid));

const read = async (name, squares) => {
  const file = await driver.shot(name);
  const img = decodePng(path.join(out, file));
  const rows = {};
  for (const s of squares) {
    const c = squareCentre(grid, s);
    rows[s] = inkInBox(img, 2, c.x, c.y, grid.square * 0.2);
  }
  console.log(name, JSON.stringify(rows));
  return rows;
};

// A — tap pair e2→e4.
const e2 = squareCentre(grid, 'e2');
await driver.tap(e2.x, e2.y);
await sleep(400);
await read('A-selected-e2', ['e2']);
const e4 = squareCentre(grid, 'e4');
await driver.tap(e4.x, e4.y);
await sleep(900);
await read('A-after-e2e4', ['e2', 'e4']);

// B — drag e7→e5 on the same board (Black's reply), press-hold, move, release.
const drag = async (from, to) => {
  const f = squareCentre(grid, from);
  const t = squareCentre(grid, to);
  await driver.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: f.x, y: f.y, id: 1 }] });
  await sleep(150);
  for (let i = 1; i <= 8; i++) {
    const x = f.x + ((t.x - f.x) * i) / 8;
    const y = f.y + ((t.y - f.y) * i) / 8;
    await driver.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x, y, id: 1 }] });
    await sleep(60);
  }
  await sleep(150);
  await driver.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await sleep(900);
};
await drag('e7', 'e5');
await read('B-after-drag-e7e5', ['e7', 'e5']);

// C — tap pair on the a-file.
await driver.tap(squareCentre(grid, 'a2').x, squareCentre(grid, 'a2').y);
await sleep(400);
await driver.tap(squareCentre(grid, 'a3').x, squareCentre(grid, 'a3').y);
await sleep(900);
await read('C-after-a2a3', ['a2', 'a3']);

await driver.close();
