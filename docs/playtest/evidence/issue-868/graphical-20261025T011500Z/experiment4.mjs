/**
 * Experiment 4 — is a tap pair reaching the build at all on this harness?
 *
 * Usage: node experiment4.mjs <url> <outDir>
 *
 * 1. Tap Shared game / Start through the driver's `tap` (the path every run in
 *    this repo has used).
 * 2. Tap e2; screenshot immediately and again after 2 s.
 * 3. Read `document.activeElement` / canvas focus over CDP; focus, then tap e2.
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';
import { boardRect, decodePng, inkInBox, squareCentre } from './png.mjs';

const [url, out] = process.argv.slice(2);
fs.mkdirSync(out, { recursive: true });
const driver = await connect({ width: 390, height: 844, dpr: 2, url, outDir: out, logDir: out, label: 'exp4' });
await sleep(12000);
// Literal presses: CDP mouse events for the two controls, as a real click.
const click = async (x, y) => {
  await driver.send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1 });
  await sleep(60);
  await driver.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
  await sleep(400);
};
await click(195, 164);
await sleep(1500);
await click(120, 323);
await sleep(2500);
const shot = await driver.shot('board');
const grid = boardRect(decodePng(path.join(out, shot)), 2);
console.log('grid', JSON.stringify(grid));
const e2 = squareCentre(grid, 'e2');
const read = async (name) => {
  const file = await driver.shot(name);
  const img = decodePng(path.join(out, file));
  const ink = inkInBox(img, 2, e2.x, e2.y, grid.square * 0.2);
  console.log(name, JSON.stringify(ink));
  return ink;
};
await read('before');
await driver.tap(e2.x, e2.y);
await read('tap-immediate');
await sleep(2000);
await read('tap-after-2s');

const active = await driver.send('Runtime.evaluate', {
  expression: 'JSON.stringify({active: document.activeElement && document.activeElement.tagName, canvas: !!document.getElementById("canvas")})',
  returnByValue: true,
});
console.log('dom', active.result.value);

// Click the canvas to focus it, then tap again.
await driver.send('Runtime.evaluate', { expression: 'document.getElementById("canvas").focus()', returnByValue: true });
await driver.tap(e2.x, e2.y);
await read('tap-after-focus');

// A long press (300 ms) instead of the driver's 40 ms.
await driver.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: e2.x, y: e2.y, id: 1 }] });
await sleep(300);
await driver.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
await sleep(600);
await read('long-press');

// Drag e7 -> e5 with literal touch points (no id key, as CDP expects).
const dragRaw = async (from, to) => {
  const f = squareCentre(grid, from);
  const t = squareCentre(grid, to);
  await driver.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: f.x, y: f.y }] });
  await sleep(120);
  for (let i = 1; i <= 8; i++) {
    const x = f.x + ((t.x - f.x) * i) / 8;
    const y = f.y + ((t.y - f.y) * i) / 8;
    await driver.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x, y }] });
    await sleep(50);
  }
  await sleep(120);
  await driver.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await sleep(900);
  const file = await driver.shot('after-drag-e7e5');
  const img = decodePng(path.join(out, file));
  for (const s of ['e7', 'e5']) {
    const c = squareCentre(grid, s);
    console.log(`drag ${s}`, JSON.stringify(inkInBox(img, 2, c.x, c.y, grid.square * 0.2)));
  }
};
await dragRaw('e7', 'e5');

// Now a plain touch tap on d2 with literal points.
const d2 = squareCentre(grid, 'd2');
await driver.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: d2.x, y: d2.y }] });
await sleep(60);
await driver.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
await sleep(600);
{
  const file = await driver.shot('after-d2-raw-tap');
  const img = decodePng(path.join(out, file));
  console.log('d2 raw tap', JSON.stringify(inkInBox(img, 2, d2.x, d2.y, grid.square * 0.2)));
}
await driver.close();
