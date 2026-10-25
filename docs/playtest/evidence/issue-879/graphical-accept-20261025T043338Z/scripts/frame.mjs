/**
 * Fresh-session probe for the mode-pick boxes: opens the published build in its
 * own browser session, captures the mode-pick frame, and writes its digest.
 *
 *     node scripts/frame.mjs <url> <outDir> <label>
 */
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [url, out, label] = process.argv.slice(2);
const shotDir = path.join(out, 'screenshots');
const logDir = path.join(out, 'logs');
const sha = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex');

const page = await connect({
  width: 390, height: 844, dpr: 3, url, outDir: shotDir, logDir, label, touch: true,
});

await sleep(3000);
let previous = null;
let settled = null;
for (let i = 0; i < 80; i++) {
  const buffer = await page.shot(`${label}-${i}`, shotDir);
  const digest = sha(buffer);
  if (previous === digest) {
    settled = { frame: `screenshots/${label}-${i - 1}.png`, sha256: digest, waitedMs: (i + 1) * 1500 };
    break;
  }
  previous = digest;
  await sleep(1500);
}
if (!settled) throw new Error('the frame never settled');
fs.writeFileSync(path.join(logDir, `${label}-frame.json`), `${JSON.stringify(settled, null, 2)}\n`);
await page.close();
console.log(JSON.stringify(settled));
