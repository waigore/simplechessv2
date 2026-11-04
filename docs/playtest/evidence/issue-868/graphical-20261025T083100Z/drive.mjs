/**
 * #868 graphical run — the S4 promotion chooser on a real screen, driven through
 * the real pointer path.
 *
 * Build under test: a `Web Playtest` export (ADR-0007, the seam-carrying preset)
 * of `main` at ad9c04d — the commit the `Web playtest` job built green on
 * 2026-10-25T07:53Z. The published page (ADR-0009) serves `69a03d4`, which
 * predates PR #873, so it is not this build; `notes.md` records why the export
 * was used and what it does and does not show.
 *
 * Usage:
 *   node drive.mjs <baseUrl> <runDir>
 *
 * One browser for the whole run (a released headless shell drops its page
 * target), at 390×844 CSS / DPR 2 with CDP touch emulation. `serve.mjs` serves
 * the export and this folder side by side, so PNG readback uses the browser's
 * own decoder.
 *
 * The dealt Shared board has no pawn one square from its last rank, so each
 * fixture builds the S4 position by play with the ordinary tap pair — the same
 * player-facing route every earlier run used. `sequences.json` is unchanged from
 * the previous run: every tap is legal and neither king is ever in check.
 *
 *   White: tap d5, tap c6 → S4 at c6; read the chooser (Queen, rook, bishop,
 *   knight at ±0.28 square, S4); tap the Queen sprite → C6 must commit a White
 *   queen. Deselect leg: repeat the place, then tap c6's centre between the
 *   sprites → IN.deselect must drop the choice and leave the pawn selected.
 *   Black: the same with a Black c-pawn on c1, committed with the knight.
 *   No promotion: select e2, tap c6 (empty, nothing pending) → nothing commits.
 *
 * Writes into <runDir>: screenshots/*.png, readings.json, logs/drive-console.log.
 * Readings only; the judgement is notes.md.
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [baseUrl, runArg] = process.argv.slice(2);
if (!baseUrl || !runArg) {
  console.error('usage: node drive.mjs <baseUrl> <runDir>');
  process.exit(2);
}
const runDir = path.resolve(runArg);
const shotsDir = path.join(runDir, 'screenshots');
const logDir = path.join(runDir, 'logs');
fs.mkdirSync(shotsDir, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

const PAGE = `${baseUrl.replace(/\/$/, '')}/build/web/index.html`;
const FRAME = { width: 390, height: 844, dpr: 2 };
const MODE_PICK_SHARED = { x: 195, y: 164 };
const SETUP_START = { x: 120, y: 323 };
const here = path.dirname(new URL(import.meta.url).pathname);
const SEQUENCES = JSON.parse(fs.readFileSync(path.join(here, 'sequences.json'), 'utf8'));

const driver = await connect({ ...FRAME, url: PAGE, outDir: shotsDir, logDir, label: 'drive' });

/** Read boxes out of a captured frame with the browser's PNG decoder. */
async function readOnce(pngName, jobs) {
  const source = fs.readFileSync(path.join(shotsDir, pngName)).toString('base64');
  const expression = `(async () => {
    const mod = await import('${baseUrl.replace(/\/$/, '')}/evidence/issue-868/browser-read.js');
    const bin = Uint8Array.from(atob(${JSON.stringify(source)}), (c) => c.charCodeAt(0));
    const bitmap = await createImageBitmap(new Blob([bin], { type: 'image/png' }));
    const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(bitmap, 0, 0);
    const img = { width: bitmap.width, height: bitmap.height, rgba: ctx.getImageData(0, 0, bitmap.width, bitmap.height).data };
    const jobs = ${JSON.stringify(jobs)};
    return jobs.map((job) => {
      if (job.op === 'boardRect') return mod.boardRect(img, ${FRAME.dpr});
      if (job.op === 'ink') return mod.inkInBox(img, ${FRAME.dpr}, job.x, job.y, job.r);
      if (job.op === 'mean') return mod.meanColour(img, ${FRAME.dpr}, job.x, job.y, job.r);
      throw new Error('unknown op ' + job.op);
    });
  })()`;
  const out = await driver.send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true });
  if (out.exceptionDetails) throw new Error(JSON.stringify(out.exceptionDetails));
  return out.result.value;
}

const FILES = 'abcdefgh';
const centre = (grid, name) => ({
  x: grid.left + (FILES.indexOf(name[0]) + 0.5) * grid.square,
  y: grid.top + (8 - Number(name[1]) + 0.5) * grid.square,
});

const slot = (c, square, kind) => {
  const d = 0.28 * square;
  return {
    queen: { x: c.x - d, y: c.y - d },
    rook: { x: c.x + d, y: c.y - d },
    bishop: { x: c.x - d, y: c.y + d },
    knight: { x: c.x + d, y: c.y + d },
  }[kind];
};

/** One frame: the four chooser slots at `dest`, the centre, origin, destination. */
async function readState(pngName, grid, origin, dest) {
  const c = centre(grid, dest);
  const r = grid.square * 0.14;
  const jobs = [
    { op: 'ink', x: centre(grid, origin).x, y: centre(grid, origin).y, r: grid.square * 0.2 },
    { op: 'ink', x: c.x, y: c.y, r: grid.square * 0.2 },
    { op: 'mean', x: c.x, y: c.y, r },
  ];
  for (const kind of ['queen', 'rook', 'bishop', 'knight']) {
    const at = slot(c, grid.square, kind);
    jobs.push({ op: 'ink', x: at.x, y: at.y, r });
    jobs.push({ op: 'mean', x: at.x, y: at.y, r });
  }
  const out = await readOnce(pngName, jobs);
  return {
    originInk: out[0],
    centreInk: out[1],
    centreMean: out[2],
    slots: ['queen', 'rook', 'bishop', 'knight'].map((kind, i) => ({
      kind, ...slot(c, grid.square, kind), ink: out[3 + i * 2], mean: out[4 + i * 2],
    })),
  };
}

/** Reload, then tap mode pick → Shared game → Start. Returns the painted grid. */
async function openBoard(tag) {
  await driver.reload().catch(() => {});
  await sleep(15000);
  await driver.tap(MODE_PICK_SHARED.x, MODE_PICK_SHARED.y);
  await sleep(1800);
  await driver.tap(SETUP_START.x, SETUP_START.y);
  await sleep(3200);
  const shot = await driver.shot(`${tag}-board`);
  const [grid] = await readOnce(shot, [{ op: 'boardRect' }]);
  if (!grid) throw new Error(`${tag}: no painted board in ${shot} — the page did not start; run again`);
  return { shot, grid };
}

async function play(grid, from, to) {
  const f = centre(grid, from);
  await driver.tap(f.x, f.y);
  await sleep(220);
  const t = centre(grid, to);
  await driver.tap(t.x, t.y);
  await sleep(380);
}

await sleep(15000);
const startShot = await driver.shot('step-mode-pick');
const [startGrid] = await readOnce(startShot, [{ op: 'boardRect' }]);
if (startGrid) throw new Error('mode-pick should paint no board');

const CASES = [
  { tag: 'white', sequence: 'white', origin: 'd5', dest: 'c6', kind: 'queen', opponent: 'e7' },
  { tag: 'white-deselect', sequence: 'white', origin: 'd5', dest: 'c6', kind: '', opponent: 'e7' },
  { tag: 'black', sequence: 'black', origin: 'c2', dest: 'c1', kind: 'knight', opponent: 'd2' },
];

const readings = { frame: FRAME, page: PAGE, build: 'ad9c04d', preset: 'Web Playtest', fixtures: [] };

for (const item of CASES) {
  const read = { tag: item.tag, origin: item.origin, dest: item.dest, tapKind: item.kind };
  const { grid, shot } = await openBoard(item.tag);
  read.grid = grid;
  read.shots = { board: `screenshots/${shot}` };
  let i = 0;
  for (const [from, to] of SEQUENCES[item.sequence]) {
    await play(grid, from, to);
    i += 1;
    if (i % 12 === 0) await driver.shot(`${item.tag}-stage-${String(i).padStart(2, '0')}`);
  }
  read.shots.ready = `screenshots/${await driver.shot(`${item.tag}-ready`)}`;
  const origin = centre(grid, item.origin);
  const dest = centre(grid, item.dest);
  read.points = { origin, dest };

  await driver.tap(origin.x, origin.y);
  await sleep(500);
  read.shots.armed = `screenshots/${await driver.shot(`${item.tag}-armed`)}`;
  await driver.tap(dest.x, dest.y);
  await sleep(1100);
  const s4 = await driver.shot(`${item.tag}-s4`);
  read.shots.s4 = `screenshots/${s4}`;
  read.s4 = await readState(s4, grid, item.origin, item.dest);

  if (item.deselect) {
    // IN.deselect: the destination centre sits between the four sprites.
    await driver.tap(dest.x, dest.y);
    await sleep(1100);
    const after = await driver.shot(`${item.tag}-after`);
    read.shots.after = `screenshots/${after}`;
    read.afterDeselect = await readState(after, grid, item.origin, item.dest);
  } else {
    const at = slot(dest, grid.square, item.kind);
    await driver.tap(at.x, at.y);
    await sleep(1400);
    const after = await driver.shot(`${item.tag}-committed`);
    read.shots.committed = `screenshots/${after}`;
    read.afterCommit = await readState(after, grid, item.origin, item.dest);
    // S4 closed and S1 is live: the opponent may select a piece of their own.
    const opponent = centre(grid, item.opponent);
    await driver.tap(opponent.x, opponent.y);
    await sleep(700);
    const live = await driver.shot(`${item.tag}-after-commit-tap`);
    read.shots.afterCommitTap = `screenshots/${live}`;
    read.afterCommitTap = await readState(live, grid, item.opponent, item.dest);
  }
  readings.fixtures.push(read);
}

// C6 where no promotion is open: select e2, tap c6 (empty, nothing pending).
{
  const read = { tag: 'no-promotion', origin: 'e2', dest: 'c6' };
  const { grid, shot } = await openBoard('no-promotion');
  read.grid = grid;
  read.shots = { board: `screenshots/${shot}` };
  const e2 = centre(grid, 'e2');
  const c6 = centre(grid, 'c6');
  await driver.tap(e2.x, e2.y);
  await sleep(600);
  read.shots.armed = `screenshots/${await driver.shot('no-promotion-armed')}`;
  await driver.tap(c6.x, c6.y);
  await sleep(1100);
  const after = await driver.shot('no-promotion-after-c6');
  read.shots.after = `screenshots/${after}`;
  read.after = await readState(after, grid, 'e2', 'c6');
  read.shots.recovered = `screenshots/${await driver.shot('no-promotion-recovered')}`;
  readings.fixtures.push(read);
}

fs.writeFileSync(path.join(runDir, 'readings.json'), `${JSON.stringify(readings, null, 2)}\n`);
await driver.close();
console.log(`wrote ${path.join(runDir, 'readings.json')}`);
