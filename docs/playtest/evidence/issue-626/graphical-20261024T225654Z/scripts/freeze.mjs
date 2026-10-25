/**
 * #626 freeze probe: does `Page.setWebLifecycleState` / `frozen` → `active` leave the touch
 * pipeline able to receive input, and if not, what restores it?
 *
 * The sitting hung its first touch dispatch 150 s after a reload that followed a freeze; a
 * reload-only probe answered in 243–379 ms. This isolates the freeze.
 *
 *     node scripts/freeze.mjs <url> <outDir>
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, tap, sleep } from './cdp.mjs';

const [url, outDir] = process.argv.slice(2);
const shots = path.join(outDir, 'screenshots');
const logs = path.join(outDir, 'logs');
fs.mkdirSync(shots, { recursive: true });
fs.mkdirSync(logs, { recursive: true });

const findings = [];
const note = (entry) => { findings.push(entry); console.log(JSON.stringify(entry)); };

await runCapture({
  url, outDir, label: 'freeze', callTimeoutMs: 20000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `freeze-${tag}.png`;
      fs.writeFileSync(path.join(shots, name), Buffer.from(result.data, 'base64'));
      return `screenshots/${name}`;
    };
    const touch = async (label, x, y) => {
      const started = Date.now();
      try {
        await tap(send, x, y);
        return note({ step: label, touch: { ms: Date.now() - started, ok: true } });
      } catch (error) {
        return note({ step: label, touch: { ms: Date.now() - started, error: String(error.message || error) } });
      }
    };

    await send('Page.navigate', { url });
    await sleep(12000);
    note({ step: 'cold-open', shot: await look('01-cold') });

    // Into the board first, so the freeze happens on a live session as in the sitting.
    await touch('tap-shared', 178, 155);
    await sleep(3000);
    await touch('tap-start', 95, 325);
    await sleep(5000);
    note({ step: 'on-board', shot: await look('02-board') });

    // Freeze / resume, the sitting's shape.
    await send('Page.setWebLifecycleState', { state: 'frozen' });
    await sleep(45000);
    await send('Page.setWebLifecycleState', { state: 'active' });
    await sleep(4000);
    note({ step: 'after-resume', shot: await look('03-after-resume') });
    await touch('tap-after-resume', 46, 74);

    // Then the reopen + reload the sitting did, then a touch.
    await send('Page.navigate', { url });
    await sleep(12000);
    await touch('tap-after-reopen', 178, 155);
    await send('Page.reload', { ignoreCache: true });
    await sleep(14000);
    await touch('tap-after-reload', 178, 155);
    note({ step: 'after-reload', shot: await look('04-after-reload') });
    return findings;
  },
}).catch((error) => {
  note({ step: 'fatal', error: String(error.message || error) });
});

fs.writeFileSync(path.join(logs, 'freeze.json'), `${JSON.stringify(findings, null, 2)}\n`);
