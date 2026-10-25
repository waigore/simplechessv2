/**
 * #879 acceptance run: drive the published build from a fresh profile with
 * player-facing presses and judge the PTU-mode-pick rows (P1, P2, P4) and the
 * PTU-controls P3 pointer rule on `mode-pick`.
 *
 *     node scripts/capture.mjs <url> <outDir> <label>
 *
 * One browser session throughout. Every recorded frame is settled (two identical
 * frames 1.5 s apart), so a reload's blank canvas is never read as an advance, and
 * every press is the first press of its generation of the game page — the shape
 * the issue records. `localStorage` stays in the session, so `last_mode` persists
 * and the Last mode frame is taken from the generation it affects.
 *
 * The driver records; it judges only what it sees in pixels, the page gesture log,
 * and `localStorage`.
 *
 * Host note: on the Linux acceptance host, Chrome 156 sometimes detaches the CDP
 * session while the Godot page reloads itself (an `Input.dispatchTouchEvent` or a
 * `Runtime.evaluate` then fails with `Not attached to an active page`). When that
 * happens the run aborts and the partial screenshots are the record — the run is
 * not retried into a passing shape.
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
  url, label,
  viewport: { width: 390, height: 844, dpr: 3 },
  boxes,
  startedAt: new Date().toISOString(),
  presses: [],
};

const page = await connect({
  width: 390, height: 844, dpr: 3, url, outDir: shotDir, logDir, label, touch: true,
});

/** Keep the frame that settled (two identical shots 1.5 s apart). */
async function settled(name) {
  let previous = null;
  for (let i = 0; i < 90; i++) {
    const buffer = await page.shot(`${name}-${i}`, shotDir);
    const digest = sha(buffer);
    if (previous === digest) {
      fs.writeFileSync(path.join(shotDir, `${name}.png`), buffer);
      fs.rmSync(path.join(shotDir, `${name}-${i}.png`));
      return { frame: `screenshots/${name}.png`, sha256: digest };
    }
    fs.rmSync(path.join(shotDir, `${name}-${i}.png`));
    previous = digest;
    await sleep(1500);
  }
  throw new Error(`${name}: the frame never settled`);
}

async function pressControl(point, control, name) {
  const before = await settled(`${label}-${name}-before`);
  await page.press(point.x, point.y, 200);
  await sleep(15000); // long settle: the game page reloads itself after a press
  const frame = await settled(`${label}-${name}-after`);
  const gestures = await page.tapLog();
  const storage = await page.storage();
  let lastMode = null;
  try { lastMode = JSON.parse(storage['simplechessv2.persist.v1'] ?? '{}').last_mode ?? null; } catch {}
  return {
    control, point, before, after: frame,
    changed: frame.sha256 !== before.sha256, lastMode, storage,
    gestures: gestures.map((g) => g.type),
  };
}

// --- S1 / P4: cold open on an empty localStorage ---------------------------
record.coldOpen = { ...(await settled(`${label}-cold`)), storageAtStart: await page.storage() };

// --- S2: activate Shared game (first press of this generation) ------------
record.presses.push({ step: 'S2', ...(await pressControl(boxes.shared, 'shared', 'shared')) });

// --- S3: activate Puzzle stream on the next generation --------------------
record.presses.push({ step: 'S3', ...(await pressControl(boxes.puzzle, 'puzzle', 'puzzle')) });

// --- Last mode frame, with `last_mode` persisted by S2/S3 -----------------
record.lastModeFrame = await settled(`${label}-last-mode`);
record.finalStorage = await page.storage();
record.finishedAt = new Date().toISOString();
fs.writeFileSync(path.join(logDir, `${label}-record.json`), `${JSON.stringify(record, null, 2)}\n`);
await page.close();
console.log(JSON.stringify({
  coldOpen: record.coldOpen,
  presses: record.presses.map((p) => ({
    step: p.step, control: p.control, point: p.point, changed: p.changed,
    lastMode: p.lastMode, gestures: p.gestures.join('/'),
    before: p.before.frame, beforeSha: p.before.sha256.slice(0, 16),
    after: p.after.frame, afterSha: p.after.sha256.slice(0, 16),
  })),
  lastModeFrame: record.lastModeFrame,
  finalStorage: record.finalStorage,
}, null, 2));
