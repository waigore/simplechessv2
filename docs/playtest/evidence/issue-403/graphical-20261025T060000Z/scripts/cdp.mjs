/**
 * The CDP driver the #403 captures share: launch headless Chrome, speak CDP over one
 * WebSocket, keep screenshots, and always shut the browser down.
 *
 * Written for #403 because the capture scripts it grew carried their own copy of this block
 * and each *hung* after writing its output (an open CDP WebSocket keeps Node's event loop
 * alive), and because two CDP behaviours cost a whole afternoon of bad readings:
 *
 *   1. **A screencast is pausable by neglect.** A frame is only followed by another once the
 *      last one is acked; acking from inside the same handler that writes the file left a
 *      stream of empty files, and a stream that never started looks exactly like a stream
 *      that has no frames. So frames are collected here and acked one round-trip behind.
 *   2. **`Runtime.evaluate` does not unwrap a promise unless asked.** An `async` probe came
 *      back as the probe's own source text — a truthy string that reads as success with
 *      every field missing. `evaluate` here always passes `awaitPromise`.
 *
 * It records; it never judges a row.
 */

import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

export const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/** Screencast frames seen by the most recent `runCapture` (timestamp, bytes). */
export const traceLines = [];

async function pageTarget(port) {
  for (let attempt = 0; attempt < 100; attempt++) {
    await sleep(100);
    try {
      const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const page = pages.find((candidate) => candidate.type === 'page');
      if (page) return page.webSocketDebuggerUrl;
    } catch {}
  }
  return null;
}

/** Frame summary over a list of `requestAnimationFrame` timestamps (ms). */
export function frameSummary(frames) {
  const deltas = frames.slice(1).map((ts, index) => +(ts - frames[index]).toFixed(2));
  const sorted = [...deltas].sort((a, b) => a - b);
  const at = (q) => (sorted.length ? sorted[Math.min(sorted.length - 1, Math.floor(q * sorted.length))] : null);
  const span = frames.length ? +(frames[frames.length - 1] - frames[0]).toFixed(1) : 0;
  return {
    frames: frames.length,
    spanMs: span,
    fps: span ? +(((frames.length - 1) / span) * 1000).toFixed(2) : null,
    p50: at(0.5), p95: at(0.95), p99: at(0.99),
    max: sorted.length ? sorted[sorted.length - 1] : null,
    over16_7ms: deltas.filter((delta) => delta > 16.7).length,
    over33_4ms: deltas.filter((delta) => delta > 33.4).length,
    over100ms: deltas.filter((delta) => delta > 100).length,
  };
}

export const SAMPLER = `(() => {
  window.__frames = [];
  const tick = (ts) => { window.__frames.push(ts); if (window.__frames.length < 200000) requestAnimationFrame(tick); };
  requestAnimationFrame(tick);
  return 'sampling';
})()`;

/**
 * Open `url` at 390×844 CSS px / DPR 2 with touch emulation, hand a live driver to `body`,
 * then stop the screencast, kill Chrome and close the socket.
 *
 * `body` receives:
 *   - `send(method, params)` — one CDP call, rejects after `callTimeoutMs`;
 *   - `on(handler)` — every CDP event (returns an unsubscribe);
 *   - `evaluate(expression)` — `Runtime.evaluate` with `returnByValue` + `awaitPromise`;
 *   - `screenshot(name)` — a PNG at `outDir/name`, returns the file name;
 *   - `close()` — stop the screencast so its last frames are on disk;
 *   - `castFrames` — `{ index, tsMs, file }` for every screencast frame received.
 */
export async function runCapture({
  url, outDir, label, body, width = 390, height = 844, callTimeoutMs = 60000, screencast = null,
}) {
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = process.env.PROFILE_DIR || path.join(outDir, `.chrome-${port}`);
  fs.mkdirSync(profile, { recursive: true });
  const chrome = spawn(CHROME, [
    '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
    `--window-size=${width},${height}`, '--force-device-scale-factor=2',
    '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
    '--autoplay-policy=no-user-gesture-required', 'about:blank',
  ], { stdio: ['ignore', 'pipe', 'pipe'] });
  chrome.stderr.resume();

  const wsUrl = await pageTarget(port);
  if (!wsUrl) { chrome.kill('SIGKILL'); throw new Error('no page target'); }
  const ws = new WebSocket(wsUrl);
  await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });

  const traceStart = Date.now();
  let nextId = 1;
  const pending = new Map();
  const handlers = new Set();
  const castFrames = [];
  let unacked = null;

  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    const timer = setTimeout(() => {
      if (pending.delete(id)) reject(new Error(`CDP ${method} exceeded ${callTimeoutMs} ms`));
    }, callTimeoutMs);
    pending.set(id, { resolve, reject, timer });
    ws.send(JSON.stringify({ id, method, params }));
  });

  const ackLatest = async () => {
    if (!unacked) return;
    const sessionId = unacked;
    unacked = null;
    await send('Page.screencastFrameAck', { sessionId }).catch(() => {});
  };

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    if (data.id && pending.has(data.id)) {
      const { resolve, reject, timer } = pending.get(data.id);
      pending.delete(data.id);
      clearTimeout(timer);
      if (data.error) reject(new Error(JSON.stringify(data.error))); else resolve(data.result);
      return;
    }
    if (!data.method) return;
    if (data.method === 'Page.screencastFrame') {
      const index = castFrames.length + 1;
      const file = `${label}-cast-${String(index).padStart(3, '0')}.jpg`;
      fs.writeFileSync(path.join(outDir, file), Buffer.from(data.params.data, 'base64'));
      castFrames.push({ index, tsMs: Math.round(data.params.metadata.timestamp * 1000), file });
      traceLines.push({ t: (Date.now() - traceStart) / 1000, method: data.method, bytes: data.params?.data?.length });
      unacked = data.params.sessionId;
      // Acked from the top of the queue, not from inside this handler: the frame is on disk
      // by the time its ack leaves, which is what keeps the stream from stalling.
      setTimeout(() => { ackLatest(); }, 0);
    }
    for (const handler of handlers) handler(data);
  };

  const on = (handler) => { handlers.add(handler); return () => handlers.delete(handler); };
  const evaluate = async (expression) => {
    const result = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
    if (!result.result) return null;
    if (result.result.subtype === 'error') throw new Error(String(result.result.description || 'evaluate error'));
    return result.result.value;
  };
  const shots = [];
  const screenshot = async (tag) => {
    const result = await send('Page.captureScreenshot', { format: 'png' });
    const name = `${label}-${String(shots.length + 1).padStart(2, '0')}-${tag}.png`;
    fs.writeFileSync(path.join(outDir, name), Buffer.from(result.data, 'base64'));
    shots.push(name);
    return name;
  };

  const close = async () => {
    await ackLatest();
    if (screencast) await send('Page.stopScreencast').catch(() => {});
    await sleep(150);
    await ackLatest();
  };

  await send('Runtime.enable');
  await send('Page.enable');
  await send('Network.enable');
  await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 2, mobile: true });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });

  let outcome = null;
  let failure = null;
  try {
    outcome = await body({
      send, on, evaluate, screenshot, close, shots, castFrames, port, profile, url, width, height,
    });
  } catch (error) {
    failure = error;
  }

  await close().catch(() => {});
  ws.close();
  await new Promise((resolve) => { ws.onclose = resolve; setTimeout(resolve, 2000); });
  chrome.kill('SIGKILL');
  if (process.env.KEEP_PROFILE !== '1') fs.rmSync(profile, { recursive: true, force: true });
  if (failure) throw failure;
  return outcome;
}

/** Install a script in every new document before it loads (CDP `Page.addScriptToEvaluateOnNewDocument`). */
export async function installHook(send, source) {
  await send('Page.addScriptToEvaluateOnNewDocument', { source });
}

/** Touch tap at CSS px (x, y): press, brief hold, release. */
export async function tap(send, x, y, holdMs = 60) {
  await send('Input.dispatchTouchEvent', {
    type: 'touchStart',
    touchPoints: [{ x, y, radiusX: 8, radiusY: 8, force: 1, id: 1 }],
  });
  await sleep(holdMs);
  await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
}
