/**
 * #626 after-reload input probe: does the touch pipeline stay alive after a reload, and does a
 * second reload restore it? The sitting twice hung its first touch dispatch 150 s after the
 * reload leg, while a single-reload probe answered in 341 ms — so the inputs accumulate here.
 *
 *     node scripts/after-reload.mjs <url> <outDir>
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
  url, outDir, label: 'after-reload', callTimeoutMs: 20000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `after-reload-${tag}.png`;
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

    // Cycle 1: a tap, then a reload — the shape the sitting had before it hung.
    await touch('tap-before-reload-1', 178, 155);
    await sleep(3000);
    await send('Page.reload', { ignoreCache: true });
    await sleep(14000);
    await touch('tap-after-reload-1', 178, 155);
    note({ step: 'after-reload-1', shot: await look('02-after-reload-1') });

    // Cycle 2: the same again, on top of cycle 1.
    await send('Page.reload', { ignoreCache: true });
    await sleep(14000);
    await touch('tap-after-reload-2', 178, 203);
    note({ step: 'after-reload-2', shot: await look('03-after-reload-2') });

    // Recovery attempt: a fresh navigation to the same URL.
    await send('Page.navigate', { url });
    await sleep(14000);
    await touch('tap-after-renavigate', 178, 155);
    note({ step: 'after-renavigate', shot: await look('04-after-renavigate') });

    return findings;
  },
}).catch((error) => {
  note({ step: 'fatal', error: String(error.message || error) });
});

fs.writeFileSync(path.join(logs, 'after-reload.json'), `${JSON.stringify(findings, null, 2)}\n`);
