/**
 * Continue the #879 acceptance run on an existing session after the two mode
 * presses: the outside-control positive control and the Last mode frame.
 *
 *     node scripts/finish.mjs <url> <outDir> <label> <prefix> [touch|mouse]
 *
 * A fresh profile is used, so `localStorage` starts empty like a returning player's
 * first visit; the state the run needs (`last_mode`) is set here by one Shared game
 * press and one Puzzle stream press, then the outside press and the Last mode frame
 * are recorded. The driver records; it does not judge.
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [url, out, label, prefix, modeArg = 'touch'] = process.argv.slice(2);
const touch = modeArg !== 'mouse';
const shotDir = path.join(out, 'screenshots');
const logDir = path.join(out, 'logs');
const sha = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex');
const boxes = JSON.parse(fs.readFileSync(path.join(out, 'boxes.json'), 'utf8'));
const record = { url, label, mode: modeArg, boxes, startedAt: new Date().toISOString(), steps: [] };

const page = await connect({
  width: 390, height: 844, dpr: 3, url, outDir: shotDir, logDir, label, touch,
});

const shot = async (name) => {
  const buffer = await page.shot(name, shotDir);
  return { path: `screenshots/${name}.png`, sha256: sha(buffer) };
};

async function settledFrame(name, maxSamples = 40) {
  let previous = null;
  const samples = [];
  for (let i = 0; i < maxSamples; i++) {
    const buffer = await page.shot(`${name}-${i}`, shotDir);
    const digest = sha(buffer);
    samples.push(digest);
    if (previous === digest) return { path: `screenshots/${name}-${i - 1}.png`, sha256: digest };
    previous = digest;
    await sleep(1500);
  }
  throw new Error(`${name} did not settle`);
}

async function press(point, control) {
  const before = await shot(`${prefix}-${control}-before`);
  if (touch) await page.press(point.x, point.y, 200);
  else await page.click(point.x, point.y, 200);
  await sleep(3000);
  const after = await shot(`${prefix}-${control}-after`);
  const gestures = await page.tapLog();
  const storage = await page.storage();
  let lastMode = null;
  try {
    lastMode = JSON.parse(storage['simplechessv2.persist.v1'] ?? '{}').last_mode ?? null;
  } catch {}
  return { point, control, advanced: before.sha256 !== after.sha256, before, after, gestures, lastMode };
}

const reload = async (name) => { await page.reload(); return settledFrame(name); };

record.coldFrame = await settledFrame(`${prefix}-cold`);
record.storageAtStart = await page.storage();

// Set `last_mode` with the two mode presses, then return to a clean mode pick.
record.steps.push({ step: 'seed-shared', ...(await press(boxes.shared, 'shared')) });
await reload(`${prefix}-seed-return-1`);
record.steps.push({ step: 'seed-puzzle', ...(await press(boxes.puzzle, 'puzzle')) });
await reload(`${prefix}-seed-return-2`);
record.storageAfterSeeding = await page.storage();

// Positive control: a press outside every control must change nothing.
record.steps.push({ step: 'control-outside', ...(await press(boxes.outside, 'outside')) });

record.lastModeScreen = await reload(`${prefix}-last-mode`);
record.finalStorage = await page.storage();
record.finishedAt = new Date().toISOString();
fs.writeFileSync(path.join(logDir, `${label}-record.json`), `${JSON.stringify(record, null, 2)}\n`);
await page.close();
console.log(JSON.stringify({
  storageAtStart: record.storageAtStart,
  steps: record.steps.map((s) => ({
    step: s.step, point: s.point, advanced: s.advanced, lastMode: s.lastMode,
    gestures: s.gestures.map((g) => g.type).join('/'), before: s.before.path, after: s.after.path,
  })),
  storageAfterSeeding: record.storageAfterSeeding,
  lastModeScreen: record.lastModeScreen.path,
  finalStorage: record.finalStorage,
}, null, 2));
