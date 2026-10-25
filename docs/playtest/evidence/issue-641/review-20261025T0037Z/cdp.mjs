/**
 * Dependency-free Chrome DevTools Protocol driver for the #641 colour-blind run.
 *
 * Starts headless Chrome with a debugging port, attaches over the built-in
 * WebSocket, fixes the phone frame, and exposes tap and screenshot helpers.
 * Node 22+ only, no third-party package.
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function pageTarget(port) {
  for (let attempt = 0; attempt < 200; attempt++) {
    await sleep(100);
    try {
      const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const page = pages.find((candidate) => candidate.type === 'page');
      if (page) return page.webSocketDebuggerUrl;
    } catch {}
  }
  return null;
}

export async function connect({ width = 390, height = 844, dpr = 2, outDir, logDir = outDir }) {
  fs.mkdirSync(path.join(outDir, 'screenshots'), { recursive: true });
  fs.mkdirSync(logDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `od641-chrome-${port}-`));
  const chrome = spawn(CHROME, [
    '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
    `--window-size=${width},${height}`, `--force-device-scale-factor=${dpr}`,
    '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
    '--autoplay-policy=no-user-gesture-required', 'about:blank',
  ], { stdio: ['ignore', 'pipe', 'pipe'] });
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
      if (data.error) reject(new Error(`${data.error.message} (${JSON.stringify(data.error.data ?? null)})`));
      else resolve(data.result);
      return;
    }
    if (data.method === 'Runtime.consoleAPICalled') {
      logs.push(`${data.params.type}: ${(data.params.args || []).map((a) => a.value ?? a.description ?? '').join(' ')}`);
    }
    if (data.method === 'Log.entryAdded') {
      logs.push(`${data.params.entry.level}: ${data.params.entry.text}`);
    }
  };

  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });

  await send('Page.enable');
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Emulation.setDeviceMetricsOverride', {
    width, height, deviceScaleFactor: dpr, mobile: true,
  });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });

  const touch = (type, x, y) => send('Input.dispatchTouchEvent', {
    type,
    touchPoints: type === 'touchEnd' ? [] : [{ x, y, radiusX: 6, radiusY: 6, force: 1, id: 1 }],
  });

  return {
    send,
    logs,
    async goto(url) {
      await send('Page.navigate', { url });
      await sleep(500);
    },
    async tap(x, y, holdMs = 60) {
      await touch('touchStart', x, y);
      await sleep(holdMs);
      await touch('touchEnd', x, y);
    },
    async shot(file) {
      const { data } = await send('Page.captureScreenshot', { format: 'png', fromSurface: true });
      const target = path.join(outDir, 'screenshots', file);
      fs.writeFileSync(target, Buffer.from(data, 'base64'));
      return target;
    },
    async close() {
      fs.writeFileSync(path.join(logDir, 'console.log'), `${logs.join('\n')}\n`);
      try { ws.close(); } catch {}
      chrome.kill('SIGKILL');
    },
  };
}
