/**
 * #626 touch-mapping probe: does the published build accept a board tap through the CDP pointer
 * path at all, and if not, what does it accept?
 *
 * Every board tap in this session's drivers — this run's, and #403's own map and points — either
 * does nothing or *dismisses the panel back to mode pick*. The page panel is interactive (mode
 * rows, Start, the setup toggle all react), so the panel is a Godot-drawn surface with hit areas.
 * This probe sweeps the input routes and reports which one a board tap reaches through.
 *
 *     node scripts/touch-map.mjs <url> <outDir>
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

/** #403's map (the one its `touch-mapping.md` says accepts taps). */
const P403 = { fileA: 59.5, row8: 399.5, step: 38.75 };
const p403 = (square) => ({
  x: Math.round(P403.fileA + (square.charCodeAt(0) - 97) * P403.step),
  y: Math.round(P403.row8 + (8 - Number(square[1])) * P403.step),
});

const BOARD_PX = { left: 0, top: 675, step: 78 };

function ringedSquare(file) {
  const image = readPng(file);
  let count = 0;
  let sumX = 0;
  let sumY = 0;
  for (let y = BOARD_PX.top; y < BOARD_PX.top + 780; y++) {
    for (let x = 0; x < 780; x++) {
      const [r, g, b] = image.rgb(x, y);
      if (r > 140 && r < 200 && g > 110 && g < 165 && b < 80) { count += 1; sumX += x; sumY += y; }
    }
  }
  if (count < 50) return { ringed: false };
  const cx = sumX / count;
  const cy = sumY / count;
  return {
    ringed: true,
    square: `${'abcdefgh'[Math.floor(cx / BOARD_PX.step)]}${8 - Math.floor((cy - BOARD_PX.top) / BOARD_PX.step)}`,
  };
}

/** A coarse screen classifier: which panel is drawn, from the ink pattern of the frame. */
function screenShape(file) {
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
  const board = band(600, 1400);
  return { board_ink: board, top_ink: band(20, 600) };
}

await runCapture({
  url, outDir, label: 'touch', callTimeoutMs: 60000,
  body: async ({ send, on }) => {
    const consoleLines = [];
    on((data) => {
      if (data.method === 'Runtime.consoleAPICalled') {
        consoleLines.push(`[${data.params.type}] ${(data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ')}`);
      }
    });
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `touch-${String(notes.length + 1).padStart(2, '0')}-${tag}.png`;
      const file = path.join(shots, name);
      fs.writeFileSync(file, Buffer.from(result.data, 'base64'));
      return { file, shot: `screenshots/${name}` };
    };

    const mouseTap = async (x, y) => {
      await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1 });
      await sleep(60);
      await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
    };

    // Reach the board with this build's own points.
    await send('Page.navigate', { url });
    await sleep(12000);
    const modePick = await look('mode-pick');
    note({ step: 'mode-pick', ...screenShape(modePick.file), shot: modePick.shot });

    await tap(send, 178, 155);
    await sleep(3000);
    const setup = await look('setup');
    note({ step: 'setup', ...screenShape(setup.file), shot: setup.shot });

    await tap(send, 95, 325);
    await sleep(6000);
    const board = await look('board');
    note({ step: 'board', ...screenShape(board.file), shot: board.shot });

    // Route 1: CDP touch at #403's e2 point.
    const e2 = p403('e2');
    await tap(send, e2.x, e2.y);
    await sleep(2000);
    const touchShot = await look('after-touch-e2');
    note({ step: 'touch-e2-403-point', css: e2, ...screenShape(touchShot.file), ...ringedSquare(touchShot.file), shot: touchShot.shot });

    // If that left the board, re-enter before the next route.
    let current = screenShape(touchShot.file).board_ink;
    if (current < 0.05) {
      await tap(send, 178, 155);
      await sleep(3000);
      await tap(send, 95, 325);
      await sleep(6000);
    }

    // Route 2: a mouse press/release at the same point.
    await mouseTap(e2.x, e2.y);
    await sleep(2000);
    const mouseShot = await look('after-mouse-e2');
    note({ step: 'mouse-e2-403-point', css: e2, ...screenShape(mouseShot.file), ...ringedSquare(mouseShot.file), shot: mouseShot.shot });

    // Route 3: a page-synthesized touch at the canvas, bypassing CDP input.
    const synthesized = await send('Runtime.evaluate', {
      expression: `(() => {
        const canvas = document.querySelector('canvas');
        if (!canvas) return { error: 'no canvas' };
        const rect = canvas.getBoundingClientRect();
        const clientX = ${e2.x};
        const clientY = ${e2.y};
        const touch = new Touch({ identifier: 1, target: canvas, clientX, clientY, screenX: clientX, screenY: clientY });
        const options = { touches: [touch], targetTouches: [touch], changedTouches: [touch], bubbles: true, cancelable: true };
        canvas.dispatchEvent(new TouchEvent('touchstart', options));
        canvas.dispatchEvent(new TouchEvent('touchend', { ...options, touches: [], targetTouches: [] }));
        return { canvas: [rect.width, rect.height, rect.left, rect.top] };
      })()`,
      returnByValue: true,
    });
    await sleep(2000);
    const synthShot = await look('after-synth-e2');
    note({
      step: 'synthesized-touch-e2-403-point', css: e2, canvas: synthesized.result.value,
      ...screenShape(synthShot.file), ...ringedSquare(synthShot.file), shot: synthShot.shot,
    });

    fs.writeFileSync(path.join(logs, 'touch-map-console.log'), `${consoleLines.join('\n')}\n`);
    return notes;
  },
}).catch((error) => note({ step: 'fatal', error: String(error.message || error) }));

fs.writeFileSync(path.join(logs, 'touch-map.json'), `${JSON.stringify(notes, null, 2)}\n`);
