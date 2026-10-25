/**
 * #626 sitting: one continuous 15–40 minute run on the published build under test, with the
 * mobile-browser behaviours #558/#557 reach only weakly from a desktop devtools session.
 *
 * One page, one browser, one wall clock — a second browser profile would break the sitting claim.
 *
 *   01  cold open → mode pick
 *   02  Shared game → setup → board
 *   03  Advice-Off leg: toggle advice off on the board, make one move with Advice Off, then stay
 *       still so no advice marks may appear, and read the control back
 *   04  background / foreground: a second tab takes the foreground and the game tab is activated
 *       again — the browser's real tab lifecycle, the phone's app switch. (`Page.setWebLifecycleState`
 *       `frozen → active` does not resume in this headless build: `logs/resume-path.json` records
 *       `document.hidden: true`, no rAF, and every later input dispatch hanging, so it is not used.)
 *   05  quit / reopen in the same profile, so the origin store persists as a phone's does
 *   06  reload — a fresh document from the same origin (a discarded tab's shape)
 *   07  the rest of the window: a move, then stillness, repeated until the window closes
 *
 * Each cycle reads `localStorage` before and after, so a lost or kept commit is a recorded value,
 * and prints a *control read* at the end (`document.hidden`, a frame count, a live tap) so the
 * run can prove the page accepted input again rather than only that it drew a screen.
 *
 * It records; it never judges a row. `manifest.md` does the judging.
 *
 *     node scripts/sit.mjs <url> <outDir> <windowMinutes>
 *
 * Writes `screenshots/sit-*.png`, `logs/sit-console.log`, `logs/sit-network.log`, `sit.json`.
 * It writes as it goes, so an interrupted sitting still has its evidence on disk.
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, tap, sleep } from './cdp.mjs';

const [url, outDir, minutesArg] = process.argv.slice(2);
if (!url || !outDir) {
  console.error('usage: node scripts/sit.mjs <url> <outDir> <windowMinutes>');
  process.exit(2);
}
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
  // The shared board puts its controls in one row at y≈74 CSS px, left of the board's a-file.
  boardAdvice: { x: 46, y: 74 },
};

/**
 * The board's square grid, read from pixels (`screenshots/probe-puzzle-02-...png`): the 8×8
 * grid is 390 CSS px wide with 39 CSS px squares, its top edge at CSS y = 337.5.
 */
const BOARD = { fileA: 19.5, row8: 318, step: 39 };
const squarePoint = (square) => ({
  x: Math.round(BOARD.fileA + (square.charCodeAt(0) - 97) * BOARD.step),
  y: Math.round(BOARD.row8 - (Number(square[1]) - 1) * BOARD.step),
});

const MARKS = [];
const readStoreExpression = `(() => {
  const raw = localStorage.getItem(${JSON.stringify(KEY)});
  let doc = null;
  if (raw !== null) { try { doc = JSON.parse(raw); } catch { doc = raw; } }
  return {
    key_present: raw !== null,
    player_elo: doc?.player_elo ?? null,
    last_mode: doc?.last_mode ?? null,
    document: doc,
  };
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
    const pendingNetwork = new Map();
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
      fs.writeFileSync(
        path.join(logs, 'sit-console.log'),
        `${consoleLines.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.text}`).join('\n')}\n`,
      );
      fs.writeFileSync(
        path.join(logs, 'sit-network.log'),
        `${network.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.status ?? ''} ${line.url ?? ''} ${line.error ?? ''}`).join('\n')}\n`,
      );
    };

    on((data) => {
      if (data.method === 'Runtime.consoleAPICalled') {
        const text = (data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ');
        consoleLines.push({ t: t(), kind: `console.${data.params.type}`, text });
      }
      if (data.method === 'Runtime.exceptionThrown') {
        consoleLines.push({
          t: t(),
          kind: 'exception',
          text: String(data.params.exceptionDetails.exception?.description || data.params.exceptionDetails.text),
        });
      }
      if (data.method === 'Network.requestWillBeSent') {
        pendingNetwork.set(data.params.requestId, data.params.request.url);
        network.push({ t: t(), kind: 'request', method: data.params.request.method, url: data.params.request.url });
      }
      if (data.method === 'Network.responseReceived') {
        network.push({
          t: t(), kind: 'response', status: data.params.response.status,
          mime: data.params.response.mimeType, url: data.params.response.url,
        });
      }
      if (data.method === 'Network.loadingFailed') {
        network.push({
          t: t(), kind: 'failed', error: data.params.errorText,
          url: pendingNetwork.get(data.params.requestId) || null,
        });
      }
    });

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

    const evaluate = async (expression) => {
      const result = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
      return result.result.value;
    };
    const readStore = () => evaluate(readStoreExpression);
    /** The control read: is the page visible, producing frames, and does a tap land? */
    const control = async (tapPoint) => {
      const hidden = await evaluate('document.hidden');
      const frames = await evaluate(`new Promise((resolve) => { let n = 0; const tick = () => { n += 1; if (n < 10) requestAnimationFrame(tick); else resolve(n); }; requestAnimationFrame(tick); setTimeout(() => resolve({ frames: n, timeout: true }), 4000); })`);
      const startedTap = Date.now();
      let tapResult;
      try {
        await tap(send, tapPoint.x, tapPoint.y);
        tapResult = { ms: Date.now() - startedTap, ok: true };
      } catch (error) {
        tapResult = { ms: Date.now() - startedTap, error: String(error.message || error) };
      }
      return { hidden, frames, tap: tapResult };
    };

    const playMove = async (tag, from, to) => {
      const a = squarePoint(from);
      const b = squarePoint(to);
      await tap(send, a.x, a.y);
      await sleep(800);
      await look(`${tag}-selected`, { from, to });
      await tap(send, b.x, b.y);
      await sleep(1400);
      return look(`${tag}-moved`, { from, to });
    };

    // -- 01 cold open -------------------------------------------------------
    await send('Page.navigate', { url });
    await sleep(12000);
    const coldStore = await readStore();
    await look('01-mode-pick-cold', { store: coldStore });

    // -- 02 shared board ----------------------------------------------------
    await tap(send, POINTS.modeShared.x, POINTS.modeShared.y);
    await sleep(3000);
    await look('02-shared-setup');
    await tap(send, POINTS.setupStart.x, POINTS.setupStart.y);
    await sleep(5000);
    await look('03-board-advice-on', { store: await readStore() });

    // -- 03 Advice-Off leg --------------------------------------------------
    await tap(send, POINTS.boardAdvice.x, POINTS.boardAdvice.y);
    await sleep(250);
    await look('04-advice-off-at250ms');
    await sleep(2250);
    await look('05-advice-off-settled');
    await playMove('06-advice-off-move', 'e2', 'e4');
    for (let step = 1; step <= 3; step++) {
      await sleep(5000);
      await look(`07-advice-off-still-${step}`);
    }

    // -- 04 background / foreground (second tab) ----------------------------
    const beforeBackground = await readStore();
    const gameTarget = (await (await fetch(`http://127.0.0.1:${port}/json/list`)).json())
      .find((target) => target.type === 'page' && target.url.startsWith('http'));
    const created = await send('Target.createTarget', { url: 'about:blank', newWindow: false });
    await send('Target.activateTarget', { targetId: created.targetId });
    const backgroundAt = new Date().toISOString();
    const backgroundStart = Date.now();
    await sleep(45000);
    await send('Target.activateTarget', { targetId: gameTarget.id });
    const backgroundMs = Date.now() - backgroundStart;
    await sleep(4000);
    const afterBackground = await readStore();
    const backgroundControl = await control(POINTS.boardAdvice);
    await send('Target.closeTarget', { targetId: created.targetId }).catch(() => {});
    await look('08-foreground-return', {
      cycle: 'background→foreground',
      background_at: backgroundAt,
      background_ms: backgroundMs,
      before: beforeBackground,
      after: afterBackground,
      control: backgroundControl,
    });

    // -- 05 quit / reopen ---------------------------------------------------
    await send('Page.navigate', { url });
    await sleep(12000);
    const afterReopen = await readStore();
    await look('09-mode-pick-after-reopen', { cycle: 'quit→reopen', after: afterReopen });

    // -- 06 reload ----------------------------------------------------------
    await send('Page.reload', { ignoreCache: true });
    await sleep(14000);
    const afterReload = await readStore();
    await look('10-mode-pick-after-reload', { cycle: 'reload', after: afterReload });

    // -- 07 the rest of the window ------------------------------------------
    await tap(send, POINTS.modeShared.x, POINTS.modeShared.y);
    await sleep(3000);
    await tap(send, POINTS.setupStart.x, POINTS.setupStart.y);
    await sleep(5000);
    await look('11-board-resumed', { store: await readStore() });

    const closeAt = started + WINDOW_MINUTES * 60 * 1000;
    const MOVES = [
      ['d2', 'd4'], ['d7', 'd5'], ['b1', 'c3'], ['g8', 'f6'], ['c1', 'f4'], ['c8', 'f5'],
      ['g1', 'f3'], ['e7', 'e6'], ['e2', 'e3'], ['f8', 'd6'],
    ];
    let index = 0;
    while (Date.now() < closeAt - 30000) {
      const [from, to] = MOVES[index % MOVES.length];
      await playMove(`12-move-${String(index + 1).padStart(2, '0')}`, from, to);
      index += 1;
      // One stillness window per move: a crash or a discard during stillness is the record.
      for (let stall = 0; stall < 2 && Date.now() < closeAt - 30000; stall++) {
        await sleep(25000);
        await look(`13-still-${String(index).padStart(2, '0')}-${stall + 1}`);
      }
    }

    const finalStore = await readStore();
    const finalControl = await control(POINTS.boardAdvice);
    await look('14-window-closed', { store: finalStore, control: finalControl });
    return { startedAt, endedAt: new Date().toISOString(), backgroundMs, finalStore, finalControl };
  },
}).catch((error) => {
  const current = fs.existsSync(path.join(outDir, 'sit.json'))
    ? JSON.parse(fs.readFileSync(path.join(outDir, 'sit.json'), 'utf8'))
    : { marks: MARKS };
  fs.writeFileSync(
    path.join(outDir, 'sit.json'),
    `${JSON.stringify({ ...current, error: String(error.message || error), complete: false }, null, 2)}\n`,
  );
  console.error(error);
  process.exit(1);
});

writeSit({ complete: true, ended_at: new Date().toISOString() });
console.log(`sitting complete: ${MARKS.length} marks`);
