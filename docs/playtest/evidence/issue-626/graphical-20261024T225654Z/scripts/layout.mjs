/**
 * #626 board-layout probe: name the board's controls and the board box on this build, from a
 * clean board frame, then exercise the Advice toggle and (if present) the stream entry.
 *
 *     node scripts/layout.mjs <url> <outDir>
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

/** The board box: the light/dark square band, found as the widest run of checker colours. */
function boardBox(file) {
  const image = readPng(file);
  // Scan the row through the middle of the board for the first strong left edge.
  const midY = Math.round(image.height * 0.62);
  let left = null;
  let right = null;
  for (let x = 0; x < image.width; x++) {
    const [r, g, b] = image.rgb(x, midY);
    const light = r > 200 && g > 180 && b < 200;
    const dark = r > 100 && r < 180 && g > 60 && g < 150 && b < 110;
    if (light || dark) { if (left === null) left = x; right = x; }
  }
  // Vertical extent at the board's centre column.
  const cx = Math.round((left + right) / 2);
  let top = null;
  let bottom = null;
  for (let y = 0; y < image.height; y++) {
    const [r, g, b] = image.rgb(cx, y);
    const light = r > 200 && g > 180 && b < 200;
    const dark = r > 100 && r < 180 && g > 60 && g < 150 && b < 110;
    if (light || dark) { if (top === null) top = y; bottom = y; }
  }
  if (left === null || top === null) return null;
  const width = right - left + 1;
  return {
    left, top, width, height: bottom - top + 1,
    css: { left: left / 2, top: top / 2, size: width / 2, square: +(width / 2 / 8).toFixed(2) },
  };
}

function boardInk(file) {
  const image = readPng(file);
  let dark = 0;
  let total = 0;
  for (let y = 600; y < 1400; y += 2) {
    for (let x = 0; x < image.width; x += 2) {
      const [r, g, b] = image.rgb(x, y);
      total += 1;
      if ((r + g + b) / 3 < 120) dark += 1;
    }
  }
  return +(dark / total).toFixed(3);
}

await runCapture({
  url, outDir, label: 'layout', callTimeoutMs: 60000,
  body: async ({ send, on }) => {
    const consoleLines = [];
    on((data) => {
      if (data.method === 'Runtime.consoleAPICalled') {
        consoleLines.push(`[${data.params.type}] ${(data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ')}`);
      }
    });
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `layout-${String(notes.length + 1).padStart(2, '0')}-${tag}.png`;
      const file = path.join(shots, name);
      fs.writeFileSync(file, Buffer.from(result.data, 'base64'));
      return { file, shot: `screenshots/${name}` };
    };

    await send('Page.navigate', { url });
    await sleep(12000);
    await tap(send, 178, 155);
    await sleep(3000);
    await tap(send, 95, 325);
    await sleep(7000);
    const board = await look('board');
    note({ step: 'board', box: boardBox(board.file), ink: boardInk(board.file), shot: board.shot });

    // The board's control row: tap each control and record which dialog it opens.
    for (const [label, point] of [
      ['advice', { x: 46, y: 74 }],
      ['resign', { x: 96, y: 74 }],
      ['draw', { x: 143, y: 74 }],
    ]) {
      await tap(send, point.x, point.y);
      await sleep(2500);
      const shot = await look(`${label}-tapped`);
      note({ step: `control-${label}`, css: point, ink: boardInk(shot.file), shot: shot.shot });
      // Dismiss any dialog with Cancel / Back, then re-enter the board if the tap left it.
      await tap(send, 242, 122); // Cancel in the draw dialog
      await sleep(1500);
      const after = await look(`${label}-cancelled`);
      if (boardInk(after.file) < 0.05) {
        await tap(send, 178, 155);
        await sleep(3000);
        await tap(send, 95, 325);
        await sleep(6000);
        note({ step: `${label}-re-entered-board`, shot: (await look('re-entered-board')).shot });
      }
    }

    fs.writeFileSync(path.join(logs, 'layout-console.log'), `${consoleLines.join('\n')}\n`);
    return notes;
  },
}).catch((error) => note({ step: 'fatal', error: String(error.message || error) }));

fs.writeFileSync(path.join(logs, 'layout.json'), `${JSON.stringify(notes, null, 2)}\n`);
