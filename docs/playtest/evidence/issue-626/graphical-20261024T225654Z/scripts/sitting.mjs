/**
 * #626 #558 legs — the sitting soak and the Advice-Off observation on the published build in a
 * phone-class viewport, with the two cycles a phone browser adds (background/foreground and
 * quit/reopen) inside one continuous run.
 *
 * Read off this build (`screenshots/layout-*.png`, `control-*.png`): mode pick's rows sit at
 * x=178 / y=155 and 203; setup's `Start` at (95, 325); the board's `Advice On` control at (46, 74);
 * `Offer draw` at (143, 74) opens a Cancel/Confirm dialog whose Cancel is (242, 122). The board
 * holds no `Leave`/'stream' control, so this build exposes no route into the puzzle stream from the
 * board — the sitting records that rather than assuming one.
 *
 *   01  cold open → mode pick                                (save read 0)
 *   02  Shared game → setup → board                          (Advice On)
 *   03  Advice-Off observation: toggle off, settle, a move, stillness
 *   04  background/foreground (second tab), store read       (save read 1)
 *   05  quit/reopen in the same profile, store read          (save read 2)
 *   06  reload, store read                                   (save read 3)
 *   07  board again: liveness taps and stillness to the window's end
 *
 *     node scripts/sitting.mjs <url> <outDir> <windowMinutes>
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, tap, sleep } from './cdp.mjs';

const [url, outDir, minutesArg] = process.argv.slice(2);
const WINDOW_MINUTES = Number(minutesArg || 16);
const shots = path.join(outDir, 'screenshots');
const logs = path.join(outDir, 'logs');
fs.mkdirSync(shots, { recursive: true });
fs.mkdirSync(logs, { recursive: true });

const KEY = 'simplechessv2.persist.v1';
const POINTS = {
  modeShared: { x: 178, y: 155 },
  modePuzzle: { x: 178, y: 203 },
  setupStart: { x: 95, y: 325 },
  boardAdvice: { x: 46, y: 74 },
  boardSquare: { x: 215, y: 632 },
};

const MARKS = [];
const storeExpression = `(() => {
  const raw = localStorage.getItem(${JSON.stringify(KEY)});
  let doc = null;
  if (raw !== null) { try { doc = JSON.parse(raw); } catch { doc = raw; } }
  return { key_present: raw !== null, player_elo: doc?.player_elo ?? null, last_mode: doc?.last_mode ?? null, document: doc };
})()`;

const writeSit = (extra = {}) => fs.writeFileSync(
  path.join(outDir, 'sit.json'),
  `${JSON.stringify({ url, window_minutes_requested: WINDOW_MINUTES, marks: MARKS, ...extra }, null, 2)}\n`,
);

await runCapture({
  url, outDir, label: 'sit', callTimeoutMs: 150000,
  body: async ({ send, on, port }) => {
    const started = Date.now();
    const startedAt = new Date(started).toISOString();
    const consoleLines = [];
    const network = [];
    const t = () => +((Date.now() - started) / 1000).toFixed(3);
    const flush = (extra = {}) => writeSit({
      started_at: startedAt,
      flushed_at: new Date().toISOString(),
      wall_clock_minutes: +((Date.now() - started) / 60000).toFixed(2),
      console_lines: consoleLines.length,
      network_lines: network.length,
      complete: false,
      ...extra,
    });
    const flushLogs = () => {
      fs.writeFileSync(path.join(logs, 'sit-console.log'), `${consoleLines.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.text}`).join('\n')}\n`);
      fs.writeFileSync(path.join(logs, 'sit-network.log'), `${network.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.status ?? ''} ${line.url ?? ''} ${line.error ?? ''}`).join('\n')}\n`);
    };

    on((data) => {
      if (data.method === 'Runtime.consoleAPICalled') {
        consoleLines.push({ t: t(), kind: `console.${data.params.type}`, text: (data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ') });
      }
      if (data.method === 'Runtime.exceptionThrown') {
        consoleLines.push({ t: t(), kind: 'exception', text: String(data.params.exceptionDetails.exception?.description || data.params.exceptionDetails.text) });
      }
      if (data.method === 'Network.requestWillBeSent') {
        network.push({ t: t(), kind: 'request', url: data.params.request.url });
      }
      if (data.method === 'Network.responseReceived') {
        network.push({ t: t(), kind: 'response', status: data.params.response.status, url: data.params.response.url });
      }
      if (data.method === 'Network.loadingFailed') {
        network.push({ t: t(), kind: 'failed', error: data.params.errorText });
      }
    });

    const evaluate = async (expression) => {
      const result = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
      return result.result.value;
    };
    const readStore = () => evaluate(storeExpression);
    const look = async (tag, extra = {}) => {
      const result = await send('Page.captureScreenshot', { format: 'png' });
      const name = `sit-${String(MARKS.length + 1).padStart(2, '0')}-${tag}.png`;
      fs.writeFileSync(path.join(shots, name), Buffer.from(result.data, 'base64'));
      const entry = { tag, at: new Date().toISOString(), t_s: t(), shot: `screenshots/${name}`, ...extra };
      MARKS.push(entry);
      flush();
      flushLogs();
      return entry;
    };
    const control = async (point) => {
      const hidden = await evaluate('document.hidden');
      const frames = await evaluate(`new Promise((resolve) => { let n = 0; const tick = () => { n += 1; if (n < 10) requestAnimationFrame(tick); else resolve(n); }; requestAnimationFrame(tick); setTimeout(() => resolve({ frames: n, timeout: true }), 4000); })`);
      const tapStart = Date.now();
      try {
        await tap(send, point.x, point.y);
        return { hidden, frames, tap: { ms: Date.now() - tapStart, ok: true } };
      } catch (error) {
        return { hidden, frames, tap: { ms: Date.now() - tapStart, error: String(error.message || error) } };
      }
    };

    // -- 01 cold open -------------------------------------------------------
    await send('Page.navigate', { url });
    await sleep(12000);
    await look('01-mode-pick-cold', { store: await readStore() });

    // -- 02 board -----------------------------------------------------------
    await tap(send, POINTS.modeShared.x, POINTS.modeShared.y);
    await sleep(3000);
    await look('02-shared-setup');
    await tap(send, POINTS.setupStart.x, POINTS.setupStart.y);
    await sleep(7000);
    await look('03-board-advice-on', { store: await readStore() });

    // -- 03 Advice-Off observation -----------------------------------------
    await tap(send, POINTS.boardAdvice.x, POINTS.boardAdvice.y);
    await sleep(250);
    await look('04-advice-off-at250ms');
    await sleep(2250);
    await look('05-advice-off-settled');
    // A tile tap with Advice Off must not be marked up; the stillness is the read.
    await tap(send, POINTS.boardSquare.x, POINTS.boardSquare.y);
    await sleep(2500);
    await look('06-advice-off-after-tap');
    for (let step = 1; step <= 3; step++) {
      await sleep(5000);
      await look(`07-advice-off-still-${step}`);
    }

    // -- 04 background / foreground ----------------------------------------
    const beforeBackground = await readStore();
    const gameTarget = (await (await fetch(`http://127.0.0.1:${port}/json/list`)).json()).find((target) => target.type === 'page' && target.url.startsWith('http'));
    const second = await send('Target.createTarget', { url: 'about:blank', newWindow: false });
    await send('Target.activateTarget', { targetId: second.targetId });
    const backgroundAt = new Date().toISOString();
    const backgroundStart = Date.now();
    await sleep(45000);
    await send('Target.activateTarget', { targetId: gameTarget.id });
    const backgroundMs = Date.now() - backgroundStart;
    await sleep(4000);
    const afterBackground = await readStore();
    const backgroundControl = await control(POINTS.boardAdvice);
    await send('Target.closeTarget', { targetId: second.targetId }).catch(() => {});
    await look('08-foreground-return', {
      cycle: 'background→foreground', background_at: backgroundAt, background_ms: backgroundMs,
      before: beforeBackground, after: afterBackground, control: backgroundControl,
    });

    // -- 05 quit / reopen ---------------------------------------------------
    await send('Page.navigate', { url });
    await sleep(12000);
    await look('09-mode-pick-after-reopen', { cycle: 'quit→reopen', after: await readStore() });

    // -- 06 reload ----------------------------------------------------------
    await send('Page.reload', { ignoreCache: true });
    await sleep(14000);
    await look('10-mode-pick-after-reload', { cycle: 'reload', after: await readStore() });

    // -- 07 the rest of the window -----------------------------------------
    await tap(send, POINTS.modeShared.x, POINTS.modeShared.y);
    await sleep(3000);
    await tap(send, POINTS.setupStart.x, POINTS.setupStart.y);
    await sleep(6000);
    await look('11-board-resumed', { store: await readStore() });

    const closeAt = started + WINDOW_MINUTES * 60 * 1000;
    let cycle = 0;
    while (Date.now() < closeAt - 30000) {
      cycle += 1;
      // A live session answers a tile tap with a selection; the frame after it is the read.
      await tap(send, POINTS.boardSquare.x, POINTS.boardSquare.y);
      await sleep(2500);
      await look(`12-liveness-${String(cycle).padStart(2, '0')}`);
      await tap(send, POINTS.boardSquare.x, POINTS.boardSquare.y);
      await sleep(1200);
      for (let stall = 0; stall < 2 && Date.now() < closeAt - 30000; stall++) {
        await sleep(25000);
        await look(`13-still-${String(cycle).padStart(2, '0')}-${stall + 1}`);
      }
    }

    const finalStore = await readStore();
    const finalControl = await control(POINTS.boardAdvice);
    await look('14-window-closed', { store: finalStore, control: finalControl });
    return { startedAt, endedAt: new Date().toISOString(), backgroundMs, finalStore, finalControl };
  },
}).catch((error) => {
  const current = fs.existsSync(path.join(outDir, 'sit.json')) ? JSON.parse(fs.readFileSync(path.join(outDir, 'sit.json'), 'utf8')) : { marks: MARKS };
  fs.writeFileSync(path.join(outDir, 'sit.json'), `${JSON.stringify({ ...current, error: String(error.message || error), complete: false }, null, 2)}\n`);
  console.error(error);
  process.exit(1);
});

writeSit({ complete: true, ended_at: new Date().toISOString() });
console.log(`sitting complete: ${MARKS.length} marks`);
