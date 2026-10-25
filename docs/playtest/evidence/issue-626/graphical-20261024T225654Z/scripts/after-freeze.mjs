/**
 * #626 after-freeze input probe: after `frozen` → `active`, does the page still receive input?
 *
 * `Input.dispatchTouchEvent` stops answering after a freeze, but that is the *driver's* input
 * channel. This asks the page itself: are touch/pointer events still delivered to the canvas,
 * does `dispatchEvent` reach the scene, and does the scene still react to a tap?
 *
 *     node scripts/after-freeze.mjs <url> <outDir>
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
  url, outDir, label: 'after-freeze', callTimeoutMs: 20000,
  body: async ({ send }) => {
    const look = async (tag) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `after-freeze-${tag}.png`;
      fs.writeFileSync(path.join(shots, name), Buffer.from(result.data, 'base64'));
      return `screenshots/${name}`;
    };
    const evaluate = async (expression) => {
      try {
        const result = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
        return result.result.value;
      } catch (error) {
        return { error: String(error.message || error) };
      }
    };
    const tapQuietly = async (label, x, y) => {
      const started = Date.now();
      try {
        await tap(send, x, y);
        return { label, ms: Date.now() - started, ok: true };
      } catch (error) {
        return { label, ms: Date.now() - started, error: String(error.message || error) };
      }
    };

    // Count what the canvas actually receives, whatever the input source.
    const installCounters = `(() => {
      window.__events = { touchstart: 0, pointerdown: 0, mousedown: 0, visibility: [] };
      const canvas = document.querySelector('canvas');
      const bump = (kind) => () => { window.__events[kind] += 1; };
      for (const [kind, type] of [['touchstart', 'touchstart'], ['pointerdown', 'pointerdown'], ['mousedown', 'mousedown']]) {
        const add = kind === 'touchstart' ? 'addEventListener' : 'addEventListener';
        canvas[add](type, bump(kind), true);
      }
      document.addEventListener('visibilitychange', () => window.__events.visibility.push(document.visibilityState));
      return true;
    })()`;

    await send('Page.navigate', { url });
    await sleep(12000);
    await evaluate(installCounters);
    note({ step: 'cold-open', tap: await tapQuietly('cold-tap-shared', 178, 155) });
    await sleep(3000);
    note({ step: 'after-cold-tap', shot: await look('01-after-cold-tap'), events: await evaluate('window.__events') });

    // Freeze / resume.
    await send('Page.setWebLifecycleState', { state: 'frozen' });
    await sleep(20000);
    await send('Page.setWebLifecycleState', { state: 'active' });
    await sleep(4000);
    note({ step: 'after-resume', shot: await look('02-after-resume'), events: await evaluate('window.__events') });

    // (a) CDP touch after the freeze.
    note({ step: 'cdp-touch-after-freeze', tap: await tapQuietly('cdp-touch', 178, 203) });

    // (b) A page-synthesized touch event, bypassing CDP input entirely.
    const synthesized = await evaluate(`(() => {
      const canvas = document.querySelector('canvas');
      const touch = new Touch({ identifier: 1, target: canvas, clientX: 178, clientY: 203 });
      canvas.dispatchEvent(new TouchEvent('touchstart', { touches: [touch], changedTouches: [touch], bubbles: true, cancelable: true }));
      canvas.dispatchEvent(new TouchEvent('touchend', { touches: [], changedTouches: [touch], bubbles: true, cancelable: true }));
      return window.__events;
    })()`);
    await sleep(2000);
    note({ step: 'synthesized-touch-after-freeze', events: synthesized, shot: await look('03-after-synthesized-touch') });

    // (c) Does the page still run, and does CDP screenshot/evaluate still work?
    note({ step: 'still-alive', evaluate: await evaluate('1+1'), hidden: await evaluate('document.hidden') });
    return findings;
  },
}).catch((error) => {
  note({ step: 'fatal', error: String(error.message || error) });
});

fs.writeFileSync(path.join(logs, 'after-freeze.json'), `${JSON.stringify(findings, null, 2)}\n`);
