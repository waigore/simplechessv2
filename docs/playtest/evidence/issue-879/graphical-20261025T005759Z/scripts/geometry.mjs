/**
 * #879 geometry probe: does the mode-pick frame's painted layout move after it
 * is first drawn? Samples the frame every <stepMs> for <count> samples after the
 * cold open, and writes the PNGs plus their sha256. `boxes.py` reads the button
 * borders off each frame.
 *
 *     node scripts/geometry.mjs <url> <out-dir> <label> <samples> <stepMs>
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [url, out, label, countArg, stepArg] = process.argv.slice(2);
const count = Number(countArg || 12);
const step = Number(stepArg || 2000);
const shotDir = path.join(out, 'screenshots');
fs.mkdirSync(shotDir, { recursive: true });

const page = await connect({
  width: 390, height: 844, dpr: 3, url, outDir: shotDir, logDir: path.join(out, 'logs'),
  label, touch: true,
});
const frames = [];
const t0 = Date.now();
for (let i = 0; i < count; i++) {
  await sleep(i === 0 ? 3000 : step);
  const buffer = await page.shot(`${label}-${String(i).padStart(2, '0')}`, shotDir);
  frames.push({
    sample: i,
    tMs: Date.now() - t0,
    sha: crypto.createHash('sha256').update(buffer).digest('hex'),
  });
  console.log(`${i} t=${frames[i].tMs}ms ${frames[i].sha.slice(0, 12)}`);
}
fs.writeFileSync(path.join(out, `${label}-frames.json`), JSON.stringify({ url, label, count, step, frames }, null, 2));
await page.close();
