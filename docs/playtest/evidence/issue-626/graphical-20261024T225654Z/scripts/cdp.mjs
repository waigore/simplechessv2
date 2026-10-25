/**
 * Shared CDP driver for the #626 sitting: launch headless Chrome at a phone-class viewport, speak
 * CDP over one WebSocket, take screenshots, and always shut the browser down.
 *
 * Copied from `docs/playtest/evidence/issue-558/sitting-20261024T221400Z/scripts/cdp.mjs`, which
 * already solved the two CDP traps that cost that run time (a screencast that pauses when not
 * acked; `Runtime.evaluate` not unwrapping a promise unless asked).
 *
 * This run writes screenshots into `<outDir>/screenshots/` itself, so the helpers here expose
 * the raw protocol `send` and leave capture to the caller.
 */

import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

export const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

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

/**
 * Open `url` at 390×844 CSS px / DPR 2 with touch emulation, hand a live driver to `body`,
 * then kill Chrome and close the socket.
 */
export async function runCapture({
  url, outDir, label, body, width = 390, height = 844, callTimeoutMs = 60000,
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

  let nextId = 1;
  const pending = new Map();
  const handlers = new Set();

  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    const timer = setTimeout(() => {
      if (pending.delete(id)) reject(new Error(`CDP ${method} exceeded ${callTimeoutMs} ms`));
    }, callTimeoutMs);
    pending.set(id, { resolve, reject, timer });
    ws.send(JSON.stringify({ id, method, params }));
  });

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
    for (const handler of handlers) handler(data);
  };

  const on = (handler) => { handlers.add(handler); return () => handlers.delete(handler); };

  await send('Runtime.enable');
  await send('Page.enable');
  await send('Network.enable');
  await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 2, mobile: true });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });

  let outcome = null;
  let failure = null;
  try {
    outcome = await body({ send, on, port, profile, url, width, height });
  } catch (error) {
    failure = error;
  }

  ws.close();
  await new Promise((resolve) => { ws.onclose = resolve; setTimeout(resolve, 2000); });
  chrome.kill('SIGKILL');
  if (process.env.KEEP_PROFILE !== '1') fs.rmSync(profile, { recursive: true, force: true });
  if (failure) throw failure;
  return outcome;
}

/** Touch tap at CSS px (x, y): press, brief hold, release — the shipped build's own path. */
export async function tap(send, x, y, holdMs = 60) {
  await send('Input.dispatchTouchEvent', {
    type: 'touchStart',
    touchPoints: [{ x, y, radiusX: 8, radiusY: 8, force: 1, id: 1 }],
  });
  await sleep(holdMs);
  await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
}
