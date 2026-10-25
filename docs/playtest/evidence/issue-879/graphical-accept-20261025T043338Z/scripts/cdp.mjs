/**
 * Dependency-free Chrome DevTools Protocol driver for the #879 re-measurement.
 *
 * Starts a headless Chrome with a debugging port, attaches over the built-in
 * WebSocket, sets the phone frame the run names, and exposes press/click/
 * screenshot helpers. Node 22+ only, no third-party package. Adapted from the
 * #868 driver; it never picks the URL or the build itself.
 *
 * The driver records; it never judges a row.
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/** Capture-phase listener the run reads to show the gesture reached the page. */
const GESTURE_RECORDER = `(() => {
  window.__tapLog = [];
  const t0 = performance.now();
  for (const name of ['pointerdown', 'pointerup', 'touchstart', 'touchend', 'click']) {
    document.addEventListener(name, (event) => {
      window.__tapLog.push({
        type: name,
        t: Math.round((performance.now() - t0) * 10) / 10,
        x: event.clientX ?? event.changedTouches?.[0]?.clientX ?? null,
        y: event.clientY ?? event.changedTouches?.[0]?.clientY ?? null,
        target: event.target?.tagName ?? null,
      });
    }, true);
  }
})();`;

async function pageTarget(port) {
  for (let attempt = 0; attempt < 150; attempt++) {
    await sleep(100);
    try {
      const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const page = pages.find((candidate) => candidate.type === 'page');
      if (page) return page.webSocketDebuggerUrl;
    } catch {}
  }
  return null;
}

export async function connect({
  width, height, dpr, url, outDir, logDir = outDir, label,
  touch = true, autoplayFlag = false,
}) {
  fs.mkdirSync(outDir, { recursive: true });
  fs.mkdirSync(logDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `a879-chrome-${port}-`));
  const args = [
    '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
    `--window-size=${width},${height}`, `--force-device-scale-factor=${dpr}`,
    '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--no-sandbox',
  ];
  // The published leg runs with the real autoplay gate: no policy flag (issue #879).
  if (autoplayFlag) args.push('--autoplay-policy=no-user-gesture-required');
  args.push('about:blank');
  const chrome = spawn(CHROME, args, { stdio: ['ignore', 'pipe', 'pipe'] });
  chrome.stderr.resume();

  const wsUrl = await pageTarget(port);
  if (!wsUrl) {
    chrome.kill('SIGKILL');
    throw new Error('Chrome exposed no page target');
  }
  const ws = new WebSocket(wsUrl);
  await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });

  let nextId = 1;
  const pending = new Map();
  const logs = [];
  ws.onmessage = (message) => {
    const data = JSON.parse(message.data);
    if (data.id && pending.has(data.id)) {
      const { resolve, reject } = pending.get(data.id);
      pending.delete(data.id);
      if (data.error) reject(new Error(JSON.stringify(data.error)));
      else resolve(data.result);
      return;
    }
    if (data.method === 'Runtime.consoleAPICalled') {
      const text = (data.params.args || [])
        .map((arg) => arg.value ?? arg.description ?? arg.type).join(' ');
      logs.push(`console.${data.params.type} ${text}`);
    }
    if (data.method === 'Log.entryAdded') {
      logs.push(`log.${data.params.entry.level} [${data.params.entry.source}] ${data.params.entry.text}`);
    }
    if (data.method === 'Runtime.exceptionThrown') {
      const details = data.params.exceptionDetails;
      logs.push(`exception ${details.exception?.description || details.text}`);
    }
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });

  await send('Runtime.enable');
  await send('Log.enable');
  await send('Page.enable');
  await send('Network.enable');
  await send('Emulation.setDeviceMetricsOverride', {
    width, height, deviceScaleFactor: dpr, mobile: true,
  });
  if (touch) {
    await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  }
  await send('Page.addScriptToEvaluateOnNewDocument', { source: GESTURE_RECORDER });
  await send('Page.navigate', { url });

  const shot = async (name, dir = outDir) => {
    const captured = await send('Page.captureScreenshot', { format: 'png' });
    const buf = Buffer.from(captured.data, 'base64');
    fs.writeFileSync(path.join(dir, `${name}.png`), buf);
    return buf;
  };
  /** Hold a touch at (x, y) for holdMs, then release. The #879 arm shape. */
  const press = async (x, y, holdMs) => {
    await send('Input.dispatchTouchEvent', {
      type: 'touchStart', touchPoints: [{ x, y, id: 1, radiusX: 3, radiusY: 3 }],
    });
    await sleep(holdMs);
    await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  };
  /** Plain mouse click: no touch emulation, real mousePressed/mouseReleased. */
  const click = async (x, y, holdMs) => {
    await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1 });
    await sleep(holdMs);
    await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
  };
  const evaluate = async (expression) => {
    const out = await send('Runtime.evaluate', { expression, returnByValue: true });
    return out.result?.value;
  };
  const tapLog = async () => JSON.parse(await evaluate('JSON.stringify(window.__tapLog ?? [])'));
  const storage = async () => JSON.parse(await evaluate('JSON.stringify(Object.fromEntries(Object.entries(localStorage)))'));
  const close = async () => {
    fs.writeFileSync(path.join(logDir, `${label}-console.log`), `${logs.join('\n')}\n`);
    ws.close();
    await new Promise((resolve) => {
      if (chrome.exitCode !== null) { resolve(); return; }
      chrome.once('exit', resolve);
      chrome.kill('SIGKILL');
    });
    try {
      fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 });
    } catch {
      // A leftover scratch profile does not change the capture.
    }
  };
  return { send, shot, press, click, evaluate, tapLog, storage, close, logs };
}
