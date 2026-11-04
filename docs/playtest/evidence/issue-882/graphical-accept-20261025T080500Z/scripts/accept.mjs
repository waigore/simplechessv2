/**
 * #882 acceptance run on a `Web Release` export whose served `game_assets/`
 * tree is stripped (the issue's reproduction), at phone width 390×844.
 *
 *     node scripts/accept.mjs <url> <outDir>
 *
 * Records the settled cold-open frame, the console window, the gesture log, and
 * the frames after C5 Reload. It judges only what it can see from pixels and the
 * page console; the reading of those pixels lives in `notes.md`.
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [url, out] = process.argv.slice(2);
const shotDir = path.join(out, 'screenshots');
const logDir = path.join(out, 'logs');
fs.mkdirSync(shotDir, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

const sha = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex');
const startedAt = new Date().toISOString();
const record = { url, viewport: { width: 390, height: 844, dpr: 3 }, startedAt, steps: [] };

const page = await connect({
  width: 390, height: 844, dpr: 3, url, outDir: shotDir, logDir, label: 'accept', touch: true,
});

const shot = async (name) => {
  const buffer = await page.shot(name, shotDir);
  return { path: `screenshots/${name}.png`, sha256: sha(buffer) };
};

/** Settled frame: two identical captures 1.5 s apart, after one earlier frame. */
async function settled(name, attempts = 40) {
  let previous = null;
  for (let i = 0; i < attempts; i++) {
    const buffer = await page.shot(`${name}-${i}`, shotDir);
    const digest = sha(buffer);
    if (previous !== null && digest === previous && i > 1) {
      return { path: `screenshots/${name}-${i}.png`, sha256: digest };
    }
    previous = digest;
    await sleep(1500);
  }
  throw new Error(`${name}: no settled frame`);
}

// --- Cold open with the Boot group unresolvable ---------------------------
const cold = await settled('cold-open');
record.steps.push({ step: 'cold-open', frame: cold, storage: await page.storage() });

// --- C5 Reload: the failure surface's one way forward ---------------------
// The panel is centred; the Reload button is its lowest control. The point is
// the one measured from `cold-open` (see `notes.md`): x 195, y 705 in CSS px.
const reloadPoint = { x: 195, y: 705 };
const consoleBefore = page.consoleLogs.length;
const imagesBefore = fs.readdirSync(shotDir).length;
await page.press(reloadPoint.x, reloadPoint.y, 200);
await sleep(3000);
const postPress = await shot('after-reload-press');
record.steps.push({
  step: 'C5-reload', point: reloadPoint, frame: postPress,
  tapLog: await page.tapLog(),
});
await sleep(6000);
const afterReload = await shot('after-reload-settled');
record.steps.push({ step: 'C5-reload-settled', frame: afterReload });
record.consoleTail = page.consoleLogs.slice(consoleBefore);
record.shotsWritten = fs.readdirSync(shotDir).length - imagesBefore;
record.finishedAt = new Date().toISOString();
fs.writeFileSync(path.join(out, 'readings.json'), `${JSON.stringify(record, null, 2)}\n`);
await page.close();
console.log(JSON.stringify({ cold: cold.path, postPress: postPress.path, afterReload: afterReload.path }));
