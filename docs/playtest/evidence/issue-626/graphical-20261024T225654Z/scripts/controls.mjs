/**
 * #626 control probe: what do the board's controls do on the published build?
 *
 * Reads each board control's effect from pixels so the sitting can name the points it taps and
 * the copy it expects. Board controls sit in one row at CSS y≈74: `Advice On` (x≈46),
 * `Resign` (x≈96), `Offer draw` (x≈143), and a menu control at the right (x≈285).
 *
 *     node scripts/controls.mjs <url> <outDir>
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

/** Board ink and "is a board drawn" from the 390×844 frame at DPR 2. */
function shape(file) {
  const image = readPng(file);
  const band = (y0, y1) => {
    let dark = 0;
    let total = 0;
    for (let y = y0; y < y1; y += 2) {
      for (let x = 0; x < image.width; x += 2) {
        const [r, g, b] = image.rgb(x, y);
        total += 1;
        if ((r + g + b) / 3 < 120) dark += 1;
      }
    }
    return +(dark / total).toFixed(3);
  };
  return { board_ink: band(600, 1400), body_ink: band(140, 600) };
}

await runCapture({
  url, outDir, label: 'controls', callTimeoutMs: 60000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `control-${String(notes.length + 1).padStart(2, '0')}-${tag}.png`;
      const file = path.join(shots, name);
      fs.writeFileSync(file, Buffer.from(result.data, 'base64'));
      return { file, shot: `screenshots/${name}` };
    };
    const step = async (label, point) => {
      if (point) await tap(send, point.x, point.y);
      await sleep(2500);
      const shot = await look(label);
      note({ step: label, css: point ?? null, ...shape(shot.file), shot: shot.shot });
    };

    await send('Page.navigate', { url });
    await sleep(12000);
    await step('mode-pick');
    await step('shared-setup', { x: 178, y: 155 });
    await step('board', { x: 95, y: 325 });

    await step('tap-board-menu', { x: 285, y: 74 });
    await step('tap-advice-toggle', { x: 46, y: 74 });
    await step('tap-advice-toggle-back', { x: 46, y: 74 });
    await step('tap-board-square-f1', { x: 215, y: 632 });
    await step('tap-board-menu-again', { x: 285, y: 74 });
    return notes;
  },
}).catch((error) => note({ step: 'fatal', error: String(error.message || error) }));

fs.writeFileSync(path.join(logs, 'controls.json'), `${JSON.stringify(notes, null, 2)}\n`);
