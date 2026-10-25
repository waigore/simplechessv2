/**
 * #640 capture: the rendered board on the published release build.
 *
 * One session at the shipped phone frame (390×844 CSS, DPR 2). It opens the
 * board, captures the un-simulated control, and records the console so the
 * board-rendered validation can quote it. Pixel work happens in `read.mjs`;
 * this file only drives the browser.
 *
 * Usage: node run.mjs <url> <runDir>
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect } from './cdp.mjs';

const [url, runDir] = process.argv.slice(2);
if (!url || !runDir) {
  console.error('usage: node run.mjs <url> <runDir>');
  process.exit(2);
}
const shotsDir = path.join(runDir, 'screenshots');
const logDir = path.join(runDir, 'logs');
fs.mkdirSync(shotsDir, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

const FRAME = { width: 390, height: 844, dpr: 2 };
// Where this build paints its mode-pick and setup controls at 390×844
// (same layout the #845 capture read).
const MODE_PICK_SHARED = { x: 195, y: 164 };
const SETUP_START = { x: 120, y: 323 };
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const driver = await connect({ ...FRAME, url, outDir: shotsDir, logDir, label: 'capture' });
const record = { url, frame: FRAME, steps: [], shots: [] };

const step = (name, shot) => {
  record.steps.push({ name, shot: `screenshots/${shot}` });
  record.shots.push(`screenshots/${shot}`);
  return shot;
};

// Cold open → mode pick.
await sleep(14000);
step('mode pick', await driver.shot('board-01-mode-pick'));

// Mode pick → Shared game → Start.
await driver.tap(MODE_PICK_SHARED.x, MODE_PICK_SHARED.y);
await sleep(1800);
step('after Shared game', await driver.shot('board-02-after-shared'));

await driver.tap(SETUP_START.x, SETUP_START.y);
await sleep(2200);
step('setup-screen after Start', await driver.shot('board-03-after-start'));

// Let the board settle, then take the stable control capture.
await sleep(3000);
const control = step('board canvas (un-simulated control)', await driver.shot('board-control'));

// A second capture a beat later: a board that repainted between frames would
// change pixels; an idle board does not.
await sleep(1200);
const control2 = await driver.shot('board-control-b');
record.shots.push(`screenshots/${control2}`);

await driver.close();

record.control = control;
record.controlRepeat = control2;
record.console = `logs/capture-console.log`;
fs.writeFileSync(path.join(runDir, 'capture.json'), `${JSON.stringify(record, null, 2)}\n`);
console.log(JSON.stringify({ control, shots: record.shots.length }, null, 2));
