// Shared CDP driver for #402 release evidence: no seams, mouse input, and every step
// verified from a screenshot so a missed click fails loudly instead of silently.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

export const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export async function openBrowser({ url, outDir, label, width = 390, height = 844, swiftshader = true, profile: reuseProfile = null }) {
  fs.mkdirSync(path.join(outDir, 'screenshots'), { recursive: true });
  fs.mkdirSync(path.join(outDir, 'logs'), { recursive: true });
  const port = 9000 + Math.floor(Math.random() * 900);
  const profile = reuseProfile || path.join(outDir, `.chrome-${port}`);
  const args = ['--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars', `--window-size=${width},${height}`,
    '--force-device-scale-factor=2', '--autoplay-policy=no-user-gesture-required'];
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
  const b = {
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
    async key(k, code) {
      await send('Input.dispatchKeyEvent', { type: 'rawKeyDown', key: k, code: k, windowsVirtualKeyCode: code || (k === 'Enter' ? 13 : 9) });
      await send('Input.dispatchKeyEvent', { type: 'keyUp', key: k, code: k, windowsVirtualKeyCode: code || (k === 'Enter' ? 13 : 9) });
      await sleep(300);
    },
    async click(x, y) {
      await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y, button: 'none', buttons: 0 });
      await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', buttons: 1, clickCount: 1 });
      await sleep(60);
      await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', buttons: 0, clickCount: 1 });
      await sleep(500);
    },
    async tap(x, y) {
      await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
      await sleep(80);
      await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      await sleep(500);
    },
    async drag(from, to, steps = 12) {
      await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: from.x, y: from.y }] });
      for (let i = 1; i <= steps; i++) {
        await send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: from.x + ((to.x - from.x) * i) / steps, y: from.y + ((to.y - from.y) * i) / steps }] });
        await sleep(16);
      }
      await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      await sleep(500);
    },
    async evaluate(expr) {
      const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true });
      return r.result?.value;
    },
    async storage() { return b.evaluate(`JSON.stringify(Object.fromEntries(Object.entries(localStorage)))`); },
    writeLogs(name) {
      const lines = events.map(({ t, method, params }) => {
        if (method === 'Runtime.consoleAPICalled') return `${t.toFixed(3)}s console.${params.type} ${(params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ')}`;
        if (method === 'Log.entryAdded') return `${t.toFixed(3)}s log.${params.entry.entry?.level ?? params.entry.level} ${params.entry.entry?.text ?? params.entry.text}`;
        if (method === 'Runtime.exceptionThrown') return `${t.toFixed(3)}s exception ${params.exceptionDetails.text}`;
        if (method === 'Page.javascriptDialogOpening') return `${t.toFixed(3)}s dialog ${params.message}`;
        return null;
      }).filter(Boolean);
      fs.writeFileSync(path.join(outDir, 'logs', `${label}-${name}-events.log`), `${lines.join('\n')}\n`);
      return lines;
    },
    async close(opts = {}) { try { ws.close(); } catch {} chrome.kill('SIGKILL'); if (!opts.keepProfile) fs.rmSync(profile, { recursive: true, force: true }); },
    chromePid: () => chrome.pid,
    profile,
  };
  await b.init();
  return b;
}
