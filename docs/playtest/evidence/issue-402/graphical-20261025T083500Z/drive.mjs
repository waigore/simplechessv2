// Small Node client for the Chrome DevTools Protocol over a manually spawned Chrome.
// The evidence driver (drive.mjs) speaks raw CDP with no npm dependencies; this same
// client carries the browser probe, because CDP is the only interface either needs.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Puppeteer's own Chrome for Testing, newest linux build under ~/.cache/puppeteer.
// Override with CHROME=<path> when the cache lives elsewhere.
const HOME = process.env.HOME || '/root';
const CHROME_DIR = path.join(HOME, '.cache/puppeteer/chrome');
export const CHROME = process.env.CHROME || (() => {
  const dirs = fs.existsSync(CHROME_DIR) ? fs.readdirSync(CHROME_DIR).sort() : [];
  for (const d of dirs.slice().reverse()) {
    const p = path.join(CHROME_DIR, d, 'chrome-linux64', 'chrome');
    if (fs.existsSync(p)) return p;
  }
  return '/usr/bin/google-chrome';
})();

export async function openBrowser({ url, outDir, label, width = 390, height = 844, swiftshader = true, profile: reuseProfile = null }) {
  fs.mkdirSync(path.join(outDir, 'screenshots'), { recursive: true });
  fs.mkdirSync(path.join(outDir, 'logs'), { recursive: true });
  const port = 9000 + Math.floor(Math.random() * 900);
  const profile = reuseProfile || path.join(outDir, `.chrome-${port}`);
  const args = ['--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars', `--window-size=${width},${height}`,
    '--force-device-scale-factor=2', '--autoplay-policy=no-user-gesture-required',
    '--no-sandbox', '--disable-dev-shm-usage'];
  if (swiftshader) args.push('--use-angle=swiftshader', '--enable-unsafe-swiftshader');
  args.push('about:blank');
  const chrome = spawn(CHROME, args, { stdio: ['ignore', 'pipe', 'pipe'] });
  chrome.stderr.resume();
  let wsUrl = null;
  for (let i = 0; i < 150 && !wsUrl; i++) {
    await sleep(100);
    try {
      const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const p = pages.find((x) => x.type === 'page');
      if (p) wsUrl = p.webSocketDebuggerUrl;
    } catch {}
  }
  if (!wsUrl) throw new Error(`Chrome exposed no page on ${port}`);
  const ws = new WebSocket(wsUrl);
  await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
  let id = 1;
  const pending = new Map();
  const events = [];
  const t0 = Date.now();
  ws.onmessage = (m) => {
    const d = JSON.parse(m.data);
    if (d.id && pending.has(d.id)) {
      const { res, rej } = pending.get(d.id);
      pending.delete(d.id);
      d.error ? rej(new Error(JSON.stringify(d.error))) : res(d.result);
      return;
    }
    if (d.method) events.push({ t: (Date.now() - t0) / 1000, method: d.method, params: d.params });
  };
  const send = (method, params = {}) => new Promise((res, rej) => { const i = id++; pending.set(i, { res, rej }); ws.send(JSON.stringify({ id: i, method, params })); });

  const logLines = (name) => events.map(({ t, method, params }) => {
    if (method === 'Runtime.consoleAPICalled') return `${t.toFixed(3)}s console.${params.type} ${(params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ')}`;
    if (method === 'Log.entryAdded') return `${t.toFixed(3)}s log.${params.entry.entry?.level ?? params.entry.level} ${params.entry.entry?.text ?? params.entry.text}`;
    if (method === 'Runtime.exceptionThrown') return `${t.toFixed(3)}s exception ${params.exceptionDetails.text}`;
    if (method === 'Page.javascriptDialogOpening') return `${t.toFixed(3)}s dialog ${params.message}`;
    return null;
  }).filter(Boolean);

  return {
    send,
    events,
    async init() {
      await send('Runtime.enable');
      await send('Log.enable');
      await send('Page.enable');
      await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 2, mobile: true });
      await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
    },
    async goto(u = url, settle = 2600) { await send('Page.navigate', { url: u }); await sleep(settle); },
    async shot(name) {
      const s = await send('Page.captureScreenshot', { format: 'png' });
      const file = path.join(outDir, 'screenshots', `${label}-${name}.png`);
      fs.writeFileSync(file, Buffer.from(s.data, 'base64'));
      return file;
    },
    async shotB64() { const s = await send('Page.captureScreenshot', { format: 'png' }); return s.data; },
    async mv(x, y) { await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y, button: 'none', buttons: 0 }); },
    async down(x, y) {
      await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y, button: 'none', buttons: 0 });
      await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', buttons: 1, clickCount: 1 });
    },
    async up(x, y) {
      await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', buttons: 0, clickCount: 1 });
    },
    async click(x, y, settle = 500) { await this.down(x, y); await sleep(60); await this.up(x, y); await sleep(settle); },
    async key(k, code, settle = 300) {
      await send('Input.dispatchKeyEvent', { type: 'rawKeyDown', key: k, code: k, windowsVirtualKeyCode: code || (k === 'Enter' ? 13 : 9) });
      await send('Input.dispatchKeyEvent', { type: 'keyUp', key: k, code: k, windowsVirtualKeyCode: code || (k === 'Enter' ? 13 : 9) });
      await sleep(settle);
    },
    async tap(x, y, settle = 500) {
      await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
      await sleep(80);
      await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      await sleep(settle);
    },
    async evaluate(expr) {
      const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true });
      return r.result?.value;
    },
    async storage() { return JSON.parse(await this.evaluate(`JSON.stringify(Object.fromEntries(Object.entries(localStorage)))`)); },
    writeLogs(name) {
      const lines = logLines(name);
      fs.writeFileSync(path.join(outDir, 'logs', `${label}-${name}-events.log`), `${lines.join('\n')}\n`);
      return lines;
    },
    async close(opts = {}) { try { ws.close(); } catch {} chrome.kill('SIGKILL'); if (!opts.keepProfile) fs.rmSync(profile, { recursive: true, force: true }); },
    chromePid: () => chrome.pid,
    profile,
    chrome,
  };
}
