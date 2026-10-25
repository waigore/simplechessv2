/**
 * Capture driver for the #641 colour-blind review run.
 *
 * Walks the published release at a 390×844 CSS px phone frame with touch
 * emulation and saves one un-simulated PNG per surface × signal. The
 * protanopia / deuteranopia copies are derived from these exact files by
 * simulate.py, so every pair shares one frame.
 *
 * Usage: node capture.mjs <url> <runDir>
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const url = process.argv[2] || 'https://waigore.github.io/simplechessv2/';
const runDir = process.argv[3] || '.';
const shotDir = path.join(runDir, 'screenshots');
fs.rmSync(shotDir, { recursive: true, force: true });
fs.mkdirSync(shotDir, { recursive: true });
const burstLog = [];
const page = await connect({ outDir: runDir, logDir: path.join(runDir, 'logs') });

// Board as painted on this build at 390×844: x 39–351, y 376–688 CSS px, one
// square 39 CSS px, White at the bottom (read off mode-pick and shared-turn-a).
const BOARD_X = 39;
const BOARD_Y = 376;
const SQUARE = 39;
const centre = (square) => [
  BOARD_X + SQUARE * 'abcdefgh'.indexOf(square[0]) + SQUARE / 2,
  BOARD_Y + SQUARE * (8 - Number(square[1])) + SQUARE / 2,
];
const tapSquare = (square) => page.tap(...centre(square));

const frames = [];
const shot = async (name) => {
  await page.shot(`${name}.png`);
  frames.push(name);
};

try {
  await page.goto(url);
  await sleep(4500);
  await shot('mode-pick');

  // mode-pick C1 → shared-setup; Clock C2 → Blitz; Start C5. Advice stays On.
  await page.tap(195, 163);
  await sleep(900);
  await shot('shared-setup-default');
  await page.tap(195, 199);
  await sleep(600);
  await shot('shared-setup-blitz');
  await page.tap(148, 227);
  await sleep(1500);

  // Row 1 — whose turn is active; which clock is running. Two frames 4 s apart.
  await shot('shared-turn-a');
  await sleep(4000);
  await shot('shared-turn-b');

  // Row 6 — advice best-move mark and eval, Advice On (no backend shipped).
  await shot('shared-advice');

  // Row 2 — selection: the ring, and the piece it holds.
  await tapSquare('e2');
  await sleep(400);
  await shot('shared-selection');

  // Row 2 — refused place (S5 / PER.R8): the e2 pawn is selected and d7 is an
  // enemy pawn it cannot take, so this is EX.rejected, not IN.deselect. The
  // burst spans the flash from the pointer-up onward.
  await page.tap(...centre('d7'));
  const burstStart = Date.now();
  for (let i = 0; i < 8; i++) {
    burstLog.push(`shared-refused-${String(i).padStart(2, '0')}: +${Date.now() - burstStart} ms after pointer-up`);
    await page.shot(`shared-refused-${String(i).padStart(2, '0')}.png`);
  }
  await sleep(700);
  await shot('shared-refused-settled');

  // Row 3 — legal destinations, empty (diamonds) and capture (rings).
  await tapSquare('g1');
  await sleep(400);
  await shot('shared-destinations-empty');
  await tapSquare('e2');
  await sleep(200);
  await tapSquare('e4');
  await sleep(1200);

  // Row 5 — last move: the board 1.e4 leaves behind, sampled from the moment
  // the move lands so no transient mark is missed.
  const lastMoveStart = Date.now();
  for (let i = 0; i < 8; i++) {
    burstLog.push(`shared-last-move-${String(i).padStart(2, '0')}: +${Date.now() - lastMoveStart} ms after the move tap`);
    await page.shot(`shared-last-move-${String(i).padStart(2, '0')}.png`);
  }
  await sleep(600);
  await shot('shared-last-move');
  await tapSquare('f7');
  await sleep(250);
  await tapSquare('f5');
  await sleep(1200);
  await tapSquare('e4');
  await sleep(400);
  await shot('shared-destinations-capture');

  // Row 4 — check: 2.Qh5+ leaves Black to move in check.
  await tapSquare('d1');
  await sleep(250);
  await tapSquare('h5');
  await sleep(1200);
  await shot('shared-check');

  // Row 7 — puzzle play: the player's side with both colours on the board.
  await page.goto(url);
  await sleep(4500);
  await page.tap(195, 202);
  await sleep(8000);
  await shot('puzzle-side');
  await sleep(4000);
  await shot('puzzle-side-steady');
} finally {
  fs.writeFileSync(path.join(runDir, 'frames.json'), `${JSON.stringify(frames, null, 2)}\n`);
  fs.writeFileSync(
    path.join(runDir, 'logs', 'capture-timings.txt'),
    `${burstLog.join('\n')}\n`,
  );
  await page.close();
}
