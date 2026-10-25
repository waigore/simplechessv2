/**
 * #879 arm grid: press inside the mode-pick buttons on one build and record,
 * per arm, the hit point, the hold duration, and whether the screen advanced.
 *
 *     node scripts/measure.mjs <url> <out-dir> <label> <touch|mouse> <waitMs|settle> <json-arms>
 *
 * <json-arms> is a JSON array of `{"point": "shared", "x": 194, "y": 147, "hold": 300}`.
 * The script records pass/total; it never judges a row.
 *
 * An "advance" is a frame that differs from the frame taken immediately before
 * that arm's press, in the same session: this build carries no playtest seam
 * (ADR-0004), so the painted frame is the only observable the published page
 * offers. Every arm records the page-level gesture log so delivery and
 * activation stay separable.
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [url, out, label, mode, waitArg, armsArg] = process.argv.slice(2);
const arms = JSON.parse(armsArg);
const touch = mode !== 'mouse';
const shotDir = path.join(out, 'screenshots');
const logDir = path.join(out, 'logs');
fs.mkdirSync(shotDir, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

let current = null;
let sessionIndex = 0;
const readings = {
  url,
  label,
  mode,
  viewport: { width: 390, height: 844, dpr: 3 },
  wait: waitArg,
  startedAt: new Date().toISOString(),
  sessions: [],
  arms: [],
};

async function open() {
  sessionIndex += 1;
  current = await connect({
    width: 390, height: 844, dpr: 3, url, outDir: shotDir, logDir,
    label: `${label}-s${sessionIndex}`, touch,
  });
}

const sha = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex');

async function capture(name) {
  return sha(await current.shot(name, shotDir));
}

/** Two identical frames 2 s apart: the cold open and its fades have settled. */
async function settle(maxMs = 90000) {
  await sleep(3000);
  const t0 = Date.now();
  let previous = null;
  while (Date.now() - t0 < maxMs) {
    const frame = await capture(`${label}-s${sessionIndex}-settle`);
    if (previous === frame) return { sha: frame, waitedMs: Date.now() - t0 };
    previous = frame;
    await sleep(2000);
  }
  throw new Error('the frame never settled');
}

async function ready() {
  if (waitArg === 'settle') return settle();
  await sleep(Number(waitArg));
  return { sha: await capture(`${label}-s${sessionIndex}-ready`), waitedMs: Number(waitArg) };
}

await open();
const first = await ready();
readings.sessions.push({ index: sessionIndex, mode: 'fresh', sha: first.sha, waitedMs: first.waitedMs });
readings.storageAtBaseline = await current.storage();
console.log(`baseline ${first.sha.slice(0, 12)} after ${first.waitedMs} ms`);

for (const arm of arms) {
  const index = readings.arms.length;
  const before = await current.tapLog();
  const preSha = await capture(`${label}-arm${String(index).padStart(2, '0')}-${arm.point}-before`);
  if (touch) await current.press(arm.x, arm.y, arm.hold);
  else await current.click(arm.x, arm.y, arm.hold);
  await sleep(1200);
  const after = await current.tapLog();
  const postSha = await capture(`${label}-arm${String(index).padStart(2, '0')}-${arm.point}-after`);
  const advanced = postSha !== preSha;
  readings.arms.push({
    index,
    session: sessionIndex,
    point: arm.point,
    x: arm.x,
    y: arm.y,
    hold_ms: arm.hold,
    preSha,
    postSha,
    advanced,
    pageGestures: after.slice(before.length),
    storage: await current.storage(),
  });
  console.log(`${String(index).padStart(2, '0')} ${arm.point} (${arm.x},${arm.y}) ${arm.hold}ms → ${advanced ? 'ADVANCED' : 'no change'}`);
  if (arm.reloadAfter || advanced) {
    await current.close();
    await open();
    const settled = await ready();
    readings.sessions.push({ index: sessionIndex, mode: 'reopened', sha: settled.sha, waitedMs: settled.waitedMs });
  }
}

readings.finishedAt = new Date().toISOString();
const byPoint = {};
for (const arm of readings.arms) {
  const row = (byPoint[arm.point] ??= { advanced: 0, total: 0 });
  row.total += 1;
  if (arm.advanced) row.advanced += 1;
}
readings.summary = byPoint;
fs.writeFileSync(path.join(out, `${label}-readings.json`), JSON.stringify(readings, null, 2));
console.log(JSON.stringify(byPoint, null, 2));
await current.close();
