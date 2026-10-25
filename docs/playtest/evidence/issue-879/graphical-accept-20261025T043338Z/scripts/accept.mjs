/**
 * #879 acceptance run on the published build: cold open, then two presses, each
 * the first press of its own generation of the game page.
 *
 *     node scripts/accept.mjs <url> <outDir> <label>
 *
 * The game page reloads itself, so a session holds several generations of the
 * flat screen. The mode-pick press that acts is always the first press of a
 * generation; later presses in the same generation do not. This run therefore
 * presses Shared game once, waits for the next generation, presses Puzzle stream
 * once, and records the settled mode-pick frame of the generation that follows.
 * `localStorage` stays inside the session so `last_mode` persists.
 *
 * The driver records; it judges only what it can see from pixels, the page gesture
 * log, and `localStorage`.
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [url, out, label] = process.argv.slice(2);
const shotDir = path.join(out, 'screenshots');
const logDir = path.join(out, 'logs');
fs.mkdirSync(shotDir, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

const sha = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex');
const boxes = JSON.parse(fs.readFileSync(path.join(out, 'boxes.json'), 'utf8'));
const record = {
  url, label, viewport: { width: 390, height: 844, dpr: 3 }, boxes,
  startedAt: new Date().toISOString(), generations: [], steps: [],
};

const page = await connect({
  width: 390, height: 844, dpr: 3, url, outDir: shotDir, logDir, label, touch: true,
});

const shot = async (name) => {
  const buffer = await page.shot(name, shotDir);
  return { path: `screenshots/${name}.png`, sha256: sha(buffer) };
};

/** A generation boundary: two identical frames 1.5 s apart after a different one. */
async function nextSettledFrame(name) {
  let previous = null;
  let changed = false;
  for (let i = 0; i < 70; i++) {
    const buffer = await page.shot(`${name}-${i}`, shotDir);
    const digest = sha(buffer);
    if (previous !== null && digest !== previous) changed = true;
    if (changed && previous === digest) {
      return { path: `screenshots/${name}-${i - 1}.png`, sha256: digest };
    }
    previous = digest;
    await sleep(1500);
  }
  throw new Error(`${name}: no settled frame after a change`);
}

async function press(point, control, name) {
  const before = await shot(`${label}-${name}-before`);
  await page.press(point.x, point.y, 200);
  await sleep(4000);
  const after = await shot(`${label}-${name}-after`);
  const storage = await page.storage();
  let lastMode = null;
  try { lastMode = JSON.parse(storage['simplechessv2.persist.v1'] ?? '{}').last_mode ?? null; } catch {}
  return { point, control, advanced: before.sha256 !== after.sha256, before, after, lastMode, storage };
}

// --- S1 / P4: cold open on an empty localStorage (fresh profile) ----------
const cold = await nextSettledFrame(`${label}-cold`);
record.coldOpen = { frame: cold.path, sha256: cold.sha256, storageAtStart: await page.storage() };

// --- S2: first press of the cold generation ------------------------------
record.steps.push({ step: 'S2', ...(await press(boxes.shared, 'shared', 'shared')) });
record.generations.push(await nextSettledFrame(`${label}-gen2`));

// --- S3: first press of the next generation ------------------------------
record.steps.push({ step: 'S3', ...(await press(boxes.puzzle, 'puzzle', 'puzzle')) });
record.generations.push(await nextSettledFrame(`${label}-gen3`));

record.finalStorage = await page.storage();
record.finishedAt = new Date().toISOString();
fs.writeFileSync(path.join(logDir, `${label}-record.json`), `${JSON.stringify(record, null, 2)}\n`);
await page.close();
console.log(JSON.stringify({
  cold: record.coldOpen,
  steps: record.steps.map((s) => ({
    step: s.step, point: s.point, advanced: s.advanced, lastMode: s.lastMode,
    before: s.before.path, after: s.after.path,
  })),
  generations: record.generations.map((g) => g.path),
  finalStorage: record.finalStorage,
}, null, 2));
