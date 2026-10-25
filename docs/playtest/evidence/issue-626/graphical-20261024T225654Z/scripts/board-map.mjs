/**
 * #626 board-move map probe: which CSS pixel is which board square on the published build?
 *
 * The sitting's moves did not move pieces, and the headless frames show a reachable shared board
 * but no selection ring. #403's `squarePoint` (fileA 59.5 / row8 399.5 / step 38.75) is the map a
 * desktop run used; this sweeps candidate pixels and reads the header and square ink back from
 * pixels, so the run uses a map it has proven instead of one it assumed.
 *
 *     node scripts/board-map.mjs <url> <outDir>
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

await runCapture({
  url, outDir, label: 'board-map', callTimeoutMs: 45000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `map-${String(findings.length + 1).padStart(2, '0')}-${tag}.png`;
      const file = path.join(shots, name);
      fs.writeFileSync(file, Buffer.from(result.data, 'base64'));
      return { file, shot: `screenshots/${name}` };
    };
    /**
     * A cheap "did anything change" read: the mean colour of the board band and of the whole
     * frame, plus the header band's darkness (a ring or a moved piece changes at least one).
     */
    const frameStats = (file) => {
      const image = readPng(file);
      const band = (y0, y1) => {
        let sum = 0;
        let count = 0;
        for (let y = y0; y < y1; y += 4) {
          for (let x = 0; x < image.width; x += 4) {
            const [r, g, b] = image.rgb(x, y);
            sum += (r + g + b) / 3;
            count += 1;
          }
        }
        return +(sum / count).toFixed(2);
      };
      return { full: band(0, image.height), board: band(600, 1380), header: band(20, 140) };
    };

    await send('Page.navigate', { url });
    await sleep(12000);
    await tap(send, 178, 155);
    await sleep(3000);
    await tap(send, 95, 325);
    await sleep(6000);

    const base = await look('board');
    const baseStats = frameStats(base.file);
    note({ step: 'board', shot: base.shot, stats: baseStats });

    // Sweep candidate points for the e2 pawn: the #403 map, the 403 map at 390 width, and a
    // ladder down the e-file so the rank mapping is read rather than assumed.
    const candidates = [
      ['p403-e2', { x: 188, y: 631 }],
      ['p403-scaled-e2', { x: 176, y: 592 }],
      ['e-file-541', { x: 176, y: 541 }],
      ['e-file-566', { x: 176, y: 566 }],
      ['e-file-592', { x: 176, y: 592 }],
      ['e-file-617', { x: 176, y: 617 }],
    ];
    for (const [name, point] of candidates) {
      await tap(send, point.x, point.y);
      await sleep(1800);
      const shot = await look(`${name}-selected`);
      const stats = frameStats(shot.file);
      note({
        step: name,
        css: point,
        stats,
        board_delta: +(stats.board - baseStats.board).toFixed(2),
        full_delta: +(stats.full - baseStats.full).toFixed(2),
        shot: shot.shot,
      });
      // Clear any selection before the next probe, so a ring from one probe is not read as
      // another's: tap the same point again.
      await tap(send, point.x, point.y);
      await sleep(800);
    }
    return findings;
  },
}).catch((error) => note({ step: 'fatal', error: String(error.message || error) }));

fs.writeFileSync(path.join(logs, 'board-map.json'), `${JSON.stringify(findings, null, 2)}\n`);
