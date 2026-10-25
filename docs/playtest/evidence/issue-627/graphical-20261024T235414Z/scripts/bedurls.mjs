/**
 * #627 bed-URL probe — which `res://…` route does each shipped bed resolve to
 * on the **published** build, and does that route open?
 *
 * `asset_resolver.gd` reads Opus catalog files through the loose Vorbis copy
 * `res://audio_runtime/<id>.ogg`. The published pack has no such entry (see
 * `logs/published-pck-routes.txt`), so the question is whether the published
 * tree serves it beside `index.html` and whether the engine reports success.
 *
 * Usage: node bedurls.mjs <url> <outDir> <label>
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function target(port) {
  for (let i = 0; i < 150; i++) {
    await sleep(100);
    try {
      const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const p = pages.find((c) => c.type === 'page');
      if (p) return p.webSocketDebuggerUrl;
    } catch {}
  }
  return null;
}

async function main() {
  const [url, outDir, label] = process.argv.slice(2);
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `od627b-${port}-`));
  const chrome = spawn(CHROME, [
    '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
    '--window-size=390,844', '--force-device-scale-factor=3',
    '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
    '--autoplay-policy=no-user-gesture-required', 'about:blank',
  ], { stdio: ['ignore', 'pipe', 'pipe'] });
  chrome.stderr.resume();
  const ws = new WebSocket(await target(port));
  await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
  let id = 1; const pend = new Map(); const logs = []; const fetches = [];
  ws.onmessage = (m) => {
    const d = JSON.parse(m.data);
    if (d.id && pend.has(d.id)) {
      const { resolve, reject } = pend.get(d.id); pend.delete(d.id);
      if (d.error) reject(new Error(JSON.stringify(d.error))); else resolve(d.result);
    }
    if (d.method === 'Runtime.consoleAPICalled') {
      logs.push({ kind: d.params.type, text: (d.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ') });
    }
    if (d.method === 'Network.responseReceived') {
      const r = d.params.response;
      if (/audio|game_assets|\.ogg/.test(r.url)) fetches.push({ url: r.url, status: r.status, mime: r.mimeType, fromDisk: r.fromDiskCache });
    }
    if (d.method === 'Network.loadingFailed') {
      const r = d.params;
      fetches.push({ failed: true, error: r.errorText, requestId: r.requestId });
    }
  };
  const send = (method, params = {}) => new Promise((res, rej) => {
    const n = id++; pend.set(n, { resolve: res, reject: rej });
    ws.send(JSON.stringify({ id: n, method, params }));
  });
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Network.enable');
  await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 3, mobile: true });
  await send('Page.navigate', { url });
  await sleep(26000);
  fs.writeFileSync(path.join(outDir, `${label}-bedurls.json`), JSON.stringify({ url, fetches, logs }, null, 1));
  ws.close();
  await new Promise((resolve) => {
    if (chrome.exitCode !== null) { resolve(); return; }
    chrome.once('exit', resolve); chrome.kill('SIGKILL');
  });
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 }); } catch {}
}
main().catch((e) => { console.error(e); process.exit(1); });
