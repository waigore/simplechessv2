/**
 * #626 real backgrounding: put the game in a background tab and bring it back, the way a phone
 * browser does when the person switches apps.
 *
 * `Page.setWebLifecycleState: frozen → active` does not resume in this headless build
 * (see `logs/resume-path.json`): the page keeps `document.hidden: true`, `requestAnimationFrame`
 * never fires again, and every later input dispatch hangs. This driver uses the browser's real
 * tab lifecycle instead — a second tab takes the foreground, then the game tab is activated
 * again — and reads `document.hidden`, frame production, the store, and whether a tap lands.
 *
 *     node scripts/background-tab.mjs <url> <outDir> [backgroundSeconds]
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, tap, sleep } from './cdp.mjs';

const [url, outDir, secondsArg] = process.argv.slice(2);
const BACKGROUND_SECONDS = Number(secondsArg || 45);
const shots = path.join(outDir, 'screenshots');
const logs = path.join(outDir, 'logs');
fs.mkdirSync(shots, { recursive: true });
fs.mkdirSync(logs, { recursive: true });

const findings = [];
const note = (entry) => { findings.push(entry); console.log(JSON.stringify(entry)); };

const KEY = 'simplechessv2.persist.v1';

await runCapture({
  url, outDir, label: 'background-tab', callTimeoutMs: 25000,
  body: async ({ send, port }) => {
    const targets = async () => (await (await fetch(`http://127.0.0.1:${port}/json/list`)).json());
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
      const name = `background-${tag}.png`;
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
    const frames = () => evaluate(`new Promise((resolve) => { let n = 0; const tick = () => { n += 1; if (n < 10) requestAnimationFrame(tick); else resolve(n); }; requestAnimationFrame(tick); setTimeout(() => resolve({ frames: n, timeout: true }), 4000); })`);
    const store = () => evaluate(`(() => {
      const raw = localStorage.getItem(${JSON.stringify(KEY)});
      let doc = null;
      if (raw !== null) { try { doc = JSON.parse(raw); } catch { doc = raw; } }
      return { key_present: raw !== null, player_elo: doc?.player_elo ?? null, last_mode: doc?.last_mode ?? null };
    })()`);

    await send('Page.navigate', { url });
    await sleep(12000);
    note({ step: 'cold-open', hidden: await evaluate('document.hidden'), store: await store(), shot: await look('01-cold') });

    // Into the board, so the sitting happens on a live session.
    await tapQuietly(178, 155);
    await sleep(3000);
    await tapQuietly(95, 325);
    await sleep(5000);
    note({ step: 'on-board', store: await store(), shot: await look('02-board') });

    // -- background: open a second tab and bring it forward ----------------
    const before = await targets();
    const gameTarget = before.find((target) => target.type === 'page' && target.url.includes('waigore.github.io'));
    const created = await send('Target.createTarget', { url: 'about:blank', newWindow: false });
    note({ step: 'backgrounding', game_target: gameTarget?.id, second_tab: created.targetId });

    // Bringing a new tab to the front: `Target.activateTarget` on it.
    await send('Target.activateTarget', { targetId: created.targetId }).catch((error) => note({ step: 'activate-target-error', error: String(error.message || error) }));
    const backgroundAt = new Date().toISOString();
    const backgroundStart = Date.now();
    await sleep(BACKGROUND_SECONDS * 1000);

    // -- foreground: activate the game tab again ---------------------------
    await send('Target.activateTarget', { targetId: gameTarget.id }).catch((error) => note({ step: 'reactivate-error', error: String(error.message || error) }));
    const backgroundMs = Date.now() - backgroundStart;
    await sleep(4000);
    const hidden = await evaluate('document.hidden');
    const after = await store();
    const afterFrames = await frames();
    await look('03-foreground-return', {});
    note({
      step: 'foreground',
      background_at: backgroundAt,
      background_ms: backgroundMs,
      hidden,
      store: after,
      frames: afterFrames,
      shot: (await targets()).length && 'screenshots/background-03-foreground-return.png',
    });

    // Does a tap still land on the board's advice toggle after the return?
    const tapResult = await tapQuietly(46, 74);
    await sleep(2500);
    note({ step: 'tap-after-foreground', tap: tapResult, shot: await look('04-after-tap') });

    await send('Target.closeTarget', { targetId: created.targetId }).catch(() => {});
    return findings;
  },
}).catch((error) => {
  note({ step: 'fatal', error: String(error.message || error) });
});

fs.writeFileSync(path.join(logs, 'background-tab.json'), `${JSON.stringify(findings, null, 2)}\n`);
