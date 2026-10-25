/**
 * #626 resume path: which lifecycle resume actually brings the page back?
 *
 * After `frozen → active` the page reports `document.hidden: true` and accepts no gesture, so
 * the sitting can never play again. This tries the resume routes a browser offers and reads
 * `document.hidden` plus gesture acceptance after each, so the sitting can use a path that
 * models a real foreground return.
 *
 *     node scripts/resume-path.mjs <url> <outDir>
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
  url, outDir, label: 'resume-path', callTimeoutMs: 25000,
  body: async ({ send }) => {
    const evaluate = async (expression) => {
      try {
        const result = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
        return result.result.value;
      } catch (error) {
        return { error: String(error.message || error) };
      }
    };
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `resume-${tag}.png`;
      fs.writeFileSync(path.join(shots, name), Buffer.from(result.data, 'base64'));
      return `screenshots/${name}`;
    };
    const tapQuietly = async (x, y) => {
      const started = Date.now();
      try {
        await tap(send, x, y);
        return { ms: Date.now() - started, ok: true };
      } catch (error) {
        return { ms: Date.now() - started, error: String(error.message || error) };
      }
    };

    await send('Page.navigate', { url });
    await sleep(12000);
    note({ step: 'cold-open', hidden: await evaluate('document.hidden') });

    for (const [label, resume] of [
      ['active', async () => send('Page.setWebLifecycleState', { state: 'active' })],
      ['Emulation visibility-change', async () => send('Emulation.setPageVisibilityState', { visibility: 'visible' })],
    ]) {
      await send('Page.navigate', { url });
      await sleep(12000);
      await send('Page.setWebLifecycleState', { state: 'frozen' });
      await sleep(20000);
      let resumeError = null;
      try { await resume(); } catch (error) { resumeError = String(error.message || error); }
      await sleep(4000);
      note({
        step: `freeze → ${label}`,
        resume_error: resumeError,
        hidden: await evaluate('document.hidden'),
        visibility: await evaluate('document.visibilityState'),
        frames: await evaluate(`new Promise((resolve) => { let n = 0; const tick = () => { n += 1; if (n < 10) requestAnimationFrame(tick); else resolve(n); }; requestAnimationFrame(tick); setTimeout(() => resolve(n), 3000); })`),
        tap: await tapQuietly(178, 155),
        shot: await look(label.replace(/\W+/g, '-')),
      });
    }
    return findings;
  },
}).catch((error) => {
  note({ step: 'fatal', error: String(error.message || error) });
});

fs.writeFileSync(path.join(logs, 'resume-path.json'), `${JSON.stringify(findings, null, 2)}\n`);
