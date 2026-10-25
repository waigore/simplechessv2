/**
 * #626 responsiveness probe: after a reload, does the page still answer, and does its canvas
 * still paint? This separates "the driver hung on CDP" from "the build stopped responding".
 *
 *     node scripts/responsive.mjs <url> <outDir>
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
  url, outDir, label: 'responsive', callTimeoutMs: 45000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `responsive-${tag}.png`;
      fs.writeFileSync(path.join(shots, name), Buffer.from(result.data, 'base64'));
      return `screenshots/${name}`;
    };
    const evaluate = async (expression) => {
      const started = Date.now();
      try {
        const result = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
        return { ms: Date.now() - started, value: result.result.value };
      } catch (error) {
        return { ms: Date.now() - started, error: String(error.message || error) };
      }
    };
    const touch = async (x, y) => {
      const started = Date.now();
      try {
        await tap(send, x, y);
        return { ms: Date.now() - started, ok: true };
      } catch (error) {
        return { ms: Date.now() - started, error: String(error.message || error) };
      }
    };
    const frames = () => evaluate(`new Promise((resolve) => {
      let n = 0;
      const tick = () => { n += 1; if (n < 30) requestAnimationFrame(tick); else resolve(n); };
      requestAnimationFrame(tick);
      setTimeout(() => resolve({ frames: n, timeout: true }), 5000);
    })`);

    await send('Page.navigate', { url });
    await sleep(14000);
    note({ step: 'cold-open', evaluate: await evaluate('1+1'), frames: await frames(), shot: await look('01-cold') });

    await send('Page.reload', { ignoreCache: true });
    await sleep(14000);
    note({ step: 'after-reload', evaluate: await evaluate('1+1'), frames: await frames(), shot: await look('02-after-reload') });
    note({ step: 'touch-after-reload-mode-shared', touch: await touch(178, 155) });
    await sleep(4000);
    note({ step: 'after-touch', shot: await look('03-after-touch') });
    return findings;
  },
}).catch((error) => {
  note({ step: 'error', error: String(error.message || error) });
});

fs.writeFileSync(path.join(logs, 'responsive.json'), `${JSON.stringify(findings, null, 2)}\n`);
