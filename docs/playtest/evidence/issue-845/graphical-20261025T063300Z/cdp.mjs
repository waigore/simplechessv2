/**
 * Dependency-free Chrome DevTools Protocol driver for the #845 board-tap run.
 *
 * Starts a headless Chrome with a debugging port, attaches over the built-in
 * WebSocket, sets the phone frame the defect names, and exposes tap/screenshot
 * helpers. No third-party package: Node 22+ only.
 *
 * Usage: imported by drive.mjs; never picks the URL or the build itself.
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

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

export async function connect({ width, height, dpr, url, outDir, logDir = outDir, label }) {
  fs.mkdirSync(outDir, { recursive: true });
  fs.mkdirSync(logDir, { recursive: true });
  // The profile is scratch: keep it out of the run folder, and never inside a
  // directory that holds committed screenshots.
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `od845-chrome-${port}-`));
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
  await send('Emulation.setDeviceMetricsOverride', {
    width, height, deviceScaleFactor: dpr, mobile: true,
  });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  await send('Page.navigate', { url });

  const shot = async (name) => {
    const captured = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(path.join(outDir, `${name}.png`), Buffer.from(captured.data, 'base64'));
    return `${name}.png`;
  };
  const tap = async (x, y) => {
    await send('Input.dispatchTouchEvent', {
      type: 'touchStart', touchPoints: [{ x, y, id: 1 }],
    });
    await sleep(40);
    await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await sleep(250);
  };
  const close = async () => {
    fs.writeFileSync(path.join(logDir, `${label}-console.log`), `${logs.join('\n')}\n`);
    ws.close();
    // Chrome keeps writing its profile after the kill signal lands, so the
    // removal can race it; the profile is scratch and never part of the run.
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
  return { send, shot, tap, close };
}
