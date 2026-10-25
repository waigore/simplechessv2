/**
 * Per-target CDP session for the #879 acceptance run.
 *
 * One attach to the page target per browser session, rebuilt only when Chrome
 * reports the target gone; the touch state of `Input.dispatchTouchEvent` lives
 * on the attach, so a press keeps its own.
 *
 * Node 22+, no third-party package.
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

/** Attach to the current page target; returns `{ call, targetId }`. */
async function attach(port, consoleLogs) {
  let page = null;
  for (let attempt = 0; attempt < 200 && !page; attempt++) {
    await sleep(100);
    try {
      const list = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      page = list.find((candidate) => candidate.type === 'page') ?? null;
    } catch {}
  }
  if (!page) throw new Error('Chrome exposed no page target');
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });
  let nextId = 1;
  const pending = new Map();
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
      consoleLogs.push(`console.${data.params.type} ${(data.params.args || [])
        .map((arg) => arg.value ?? arg.description ?? arg.type).join(' ')}`);
    }
    if (data.method === 'Log.entryAdded') {
      consoleLogs.push(`log.${data.params.entry.level} ${data.params.entry.text}`);
    }
  };
  const call = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });
  return { call, targetId: page.id, ws };
}

export async function connect({ width, height, dpr, url, outDir, logDir = outDir, label, touch = true }) {
  fs.mkdirSync(outDir, { recursive: true });
  fs.mkdirSync(logDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `a879-accept-${port}-`));
  const args = [
    '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--hide-scrollbars', '--window-size=' + `${width},${height}`,
    `--force-device-scale-factor=${dpr}`, '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
    '--no-sandbox',
  ];
  // No autoplay-policy flag: the published leg keeps the real autoplay gate (#879).
  args.push(url);
  const chrome = spawn(CHROME, args, { stdio: ['ignore', 'pipe', 'pipe'] });
  const chromeLog = [];
  chrome.stderr.on('data', (chunk) => chromeLog.push(chunk.toString()));

  const consoleLogs = [];
  let session = await attach(port, consoleLogs);
  const emulation = async (call) => {
    await call('Page.enable');
    await call('Runtime.enable');
    await call('Log.enable');
    await call('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: dpr, mobile: true });
    if (touch) await call('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
    await call('Page.addScriptToEvaluateOnNewDocument', { source: GESTURE_RECORDER });
  };
  await emulation(session.call);

  /** Run a command, reattaching once if Chrome reports the target gone. */
  const send = async (method, params = {}) => {
    try {
      return await session.call(method, params);
    } catch (error) {
      if (!String(error.message).includes('Not attached to an active page')) throw error;
      session = await attach(port, consoleLogs);
      await emulation(session.call);
      return session.call(method, params);
    }
  };

  const shot = async (name, dir = outDir) => {
    const buffer = Buffer.from((await send('Page.captureScreenshot', { format: 'png' })).data, 'base64');
    fs.writeFileSync(path.join(dir, `${name}.png`), buffer);
    return buffer;
  };
  const press = async (x, y, holdMs) => {
    await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y, id: 1, radiusX: 3, radiusY: 3 }] });
    await sleep(holdMs);
    await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  };
  const click = async (x, y, holdMs) => {
    await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1 });
    await sleep(holdMs);
    await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
  };
  const evaluate = async (expression) => {
    const out = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
    return out.result?.value;
  };
  const tapLog = async () => JSON.parse((await evaluate('JSON.stringify(window.__tapLog ?? [])')) ?? '[]');
  const storage = async () => JSON.parse((await evaluate('JSON.stringify(Object.fromEntries(Object.entries(localStorage)))')) ?? '{}');
  const reload = async () => send('Page.reload', { ignoreCache: false });
  const close = async () => {
    fs.writeFileSync(path.join(logDir, `${label}-console.log`), `${consoleLogs.join('\n')}\n`);
    if (chrome.exitCode === null) chrome.kill('SIGKILL');
    await new Promise((resolve) => {
      if (chrome.exitCode !== null) resolve();
      else chrome.once('exit', resolve);
    });
    try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 }); } catch {}
  };
  return { send, shot, press, click, evaluate, tapLog, storage, reload, close, consoleLogs, chromeLog };
}
