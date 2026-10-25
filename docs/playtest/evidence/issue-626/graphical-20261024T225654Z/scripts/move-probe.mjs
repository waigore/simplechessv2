/**
 * #626 move probe: the tapped piece, not an assumed square. Tap the selected pawn again to
 * deselect and re-select it, then tap a legal destination, and read the result from pixels.
 *
 *     node scripts/move-probe.mjs <url> <outDir>
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

const notes = [];
const note = (entry) => { notes.push(entry); console.log(JSON.stringify(entry)); };

const BOARD_PX = { top: 675, step: 78 };
const squareCentreCss = (fileIndex, rank) => ({
  x: Math.round(fileIndex * 39 + 19.5),
  y: Math.round(337.5 + (8 - rank) * 39 + 19.5),
});

/** The file/rank of the ringed square, and of the green destination dots. */
function readBoard(file) {
  const image = readPng(file);
  let ring = null;
  let ringCount = 0;
  let ringX = 0;
  let ringY = 0;
  let dots = [];
  for (let y = BOARD_PX.top; y < BOARD_PX.top + 780; y++) {
    for (let x = 0; x < 780; x++) {
      const [r, g, b] = image.rgb(x, y);
      if (r > 140 && r < 200 && g > 110 && g < 165 && b < 80) { ringCount++; ringX += x; ringY += y; }
    }
  }
  // The destination dots are the green PAL.C7 teal/green diamonds: green well above red/blue.
  const seen = new Set();
  for (let y = BOARD_PX.top; y < BOARD_PX.top + 780; y += 2) {
    for (let x = 0; x < 780; x += 2) {
      const [r, g, b] = image.rgb(x, y);
      if (g > 120 && g - r > 40 && g - b > 40) {
        const cell = `${Math.floor(x / 78)},${Math.floor((y - BOARD_PX.top) / 78)}`;
        if (!seen.has(cell)) { seen.add(cell); dots.push(cell); }
      }
    }
  }
  if (ringCount >= 50) {
    const cx = ringX / ringCount;
    const cy = ringY / ringCount;
    ring = `${'abcdefgh'[Math.floor(cx / 78)]}${8 - Math.floor((cy - BOARD_PX.top) / 78)}`;
  }
  const dotsSquares = dots.map((cell) => {
    const [f, r] = cell.split(',').map(Number);
    return `${'abcdefgh'[f]}${8 - r}`;
  });
  return { ring, destination_dots: dotsSquares };
}

await runCapture({
  url, outDir, label: 'move', callTimeoutMs: 60000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `move-${String(notes.length + 1).padStart(2, '0')}-${tag}.png`;
      const file = path.join(shots, name);
      fs.writeFileSync(file, Buffer.from(result.data, 'base64'));
      return { file, shot: `screenshots/${name}` };
    };

    await send('Page.navigate', { url });
    await sleep(12000);
    await tap(send, 178, 155);
    await sleep(3000);
    await tap(send, 95, 325);
    await sleep(6000);

    // Select the pawn that #403's point lands on (f1 per the map probe).
    const from = { x: 215, y: 632 };
    await tap(send, from.x, from.y);
    await sleep(2000);
    const selected = await look('selected');
    note({ step: 'select', css: from, ...readBoard(selected.file), shot: selected.shot });

    // Tap it again to deselect, then again to select, proving the selection can be re-made.
    await tap(send, from.x, from.y);
    await sleep(1200);
    const deselected = await look('deselected');
    note({ step: 'deselect', ...readBoard(deselected.file), shot: deselected.shot });
    await tap(send, from.x, from.y);
    await sleep(1500);
    const reselected = await look('reselected');
    note({ step: 'reselect', ...readBoard(reselected.file), shot: reselected.shot });

    // A legal destination for a rank-2 pawn: one rank up (rank 3), read at the same file.
    const to = squareCentreCss(5, 3);
    await tap(send, to.x, to.y);
    await sleep(3000);
    const placed = await look('placed');
    note({ step: 'place-rank3', css: to, ...readBoard(placed.file), shot: placed.shot });
    return notes;
  },
}).catch((error) => note({ step: 'fatal', error: String(error.message || error) }));

fs.writeFileSync(path.join(logs, 'move-probe.json'), `${JSON.stringify(notes, null, 2)}\n`);
