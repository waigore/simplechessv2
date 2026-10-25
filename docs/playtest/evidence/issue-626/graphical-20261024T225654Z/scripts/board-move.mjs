/**
 * #626 board-move probe: does a tap pair actually move a piece on this build, and which CSS
 * pixel maps to which square?
 *
 * The sitting's `e2 → e4` did not move the pawn. #403's `touch-mapping.md` records that the same
 * tap "landed". One of the two maps is wrong, so this probe selects a piece and reads the square
 * overlays back from pixels instead of trusting either map.
 *
 *     node scripts/board-move.mjs <url> <outDir>
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, tap, sleep } from './cdp.mjs';
import { readPng } from './pixels.mjs';

const [url, outDir] = process.argv.slice(2);
const shots = path.join(outDir, 'screenshots');
const logs = path.join(outDir, 'logs');
fs.mkdirSync(shots, { recursive: true });
fs.mkdirSync(logs, { recursive: true });

const findings = [];
const note = (entry) => { findings.push(entry); console.log(JSON.stringify(entry)); };

/** Ink and overlay share per square, from the 390 CSS px board at DPR 2 (top at CSS 337.5). */
const GRID = { left: 0, top: 337.5, step: 39 };
const squareOf = (file, rank) => ({
  x: Math.round((GRID.left + file * GRID.step + GRID.step / 2) * 2),
  y: Math.round((GRID.top + (8 - rank) * GRID.step + GRID.step / 2) * 2),
});

function squareRead(image, file, rank) {
  const centre = squareOf(file, rank);
  const half = 30;
  let dark = 0;
  let total = 0;
  for (let y = centre.y - half; y < centre.y + half; y++) {
    for (let x = centre.x - half; x < centre.x + half; x++) {
      const [r, g, b] = image.rgb(x, y);
      total += 1;
      if ((r + g + b) / 3 < 90) dark += 1;
    }
  }
  return +(100 * dark / total).toFixed(1);
}

const boardRead = (image) => {
  const out = {};
  for (const [name, file, rank] of [['e2', 4, 2], ['e3', 4, 3], ['e4', 4, 4], ['e1', 4, 1], ['d2', 3, 2], ['d4', 3, 4]]) {
    out[name] = squareRead(image, file, rank);
  }
  return out;
};

await runCapture({
  url, outDir, label: 'board-move', callTimeoutMs: 45000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `board-${tag}.png`;
      const file = path.join(shots, name);
      fs.writeFileSync(file, Buffer.from(result.data, 'base64'));
      return { file, shot: `screenshots/${name}` };
    };
    const css = (file, rank) => ({
      x: Math.round(GRID.left + file * GRID.step + GRID.step / 2),
      y: Math.round(GRID.top + (8 - rank) * GRID.step + GRID.step / 2),
    });

    await send('Page.navigate', { url });
    await sleep(12000);
    await tap(send, 178, 155);
    await sleep(3000);
    await tap(send, 95, 325);
    await sleep(6000);

    const before = await look('01-before');
    note({ step: 'before', board: boardRead(readPng(before.file)), shot: before.shot });

    const e2 = css(4, 2);
    await tap(send, e2.x, e2.y);
    await sleep(2500);
    const selected = await look('02-e2-selected');
    note({ step: 'tap-e2', css: e2, board: boardRead(readPng(selected.file)), shot: selected.shot });

    const e4 = css(4, 4);
    await tap(send, e4.x, e4.y);
    await sleep(3000);
    const moved = await look('03-e4-placed');
    note({ step: 'tap-e4', css: e4, board: boardRead(readPng(moved.file)), shot: moved.shot });

    // If that refused, try the same pair one rank lower (the #845 hypothesis) to see which lands.
    const e2b = css(4, 1);
    await tap(send, e2b.x, e2b.y);
    await sleep(2000);
    const e2bShot = await look('04-e1-tapped');
    note({ step: 'tap-e1', css: e2b, board: boardRead(readPng(e2bShot.file)), shot: e2bShot.shot });
    return findings;
  },
}).catch((error) => note({ step: 'fatal', error: String(error.message || error) }));

fs.writeFileSync(path.join(logs, 'board-move.json'), `${JSON.stringify(findings, null, 2)}\n`);
