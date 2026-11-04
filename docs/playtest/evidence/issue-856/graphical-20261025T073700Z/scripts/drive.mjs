/**
 * Drive `PTU-mode-pick` S1 on the #856 acceptance build (page-clock timings +
 * the screenshots the protocol asks for).
 *
 * Steps, one fresh profile, HTTP cache disabled:
 *   1. navigate, stamp `performance.now()` navigation start;
 *   2. 300 ms — screenshot of the loading state, then a tap on the mode-pick
 *      band and a second tap at 600 ms, to show the mode controls are not
 *      reachable while `EX.loading` is up;
 *   3. poll the injected band probe for the first frame that holds the panel;
 *      screenshot at that frame plus ~120 ms (the painted mode pick);
 *   4. tap the Shared game control and screenshot the routed screen, which
 *      proves the mode pick is interactive at the stamped time;
 *   5. reload warm and repeat the poll from step 3 (S1's warm open).
 *
 * Usage: node drive.mjs <url> <outDir> [--swiftshader]
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const [url, outDir, ...rest] = process.argv.slice(2);
if (!url || !outDir) {
  console.error('usage: node drive.mjs <url> <outDir> [--swiftshader]');
  process.exit(2);
}
const swiftshader = rest.includes('--swiftshader');
fs.mkdirSync(path.join(outDir, 'screenshots'), { recursive: true });

// Panel band at 390x844 CSS / DPR 2: CSS x 95..295, y 147..222.
const SHARED = { x: 195, y: 164 };
const PUZZLE = { x: 195, y: 205 };

const INJECT = `(() => {
  window.__panel = null;
  window.__paint = null;
  enum_console_placeholder
  const readBand = (gl, canvas) => {
    const x = 190, w = 400;
    const yTop = Math.max(0, canvas.height - 444);
    const h = Math.min(150, canvas.height - yTop);
    const buf = new Uint8Array(w * h * 4);
    gl.readPixels(x, yTop, w, h, gl.RGBA, gl.UNSIGNED_BYTE, buf);
    let dark = 0;
    for (let i = 0; i < buf.length; i += 4) {
      if (buf[i] + buf[i + 1] + buf[i + 2] < 300) { dark += 1; }
    }
    return dark;
  };
  const tick = () => {
    const canvas = document.querySelector('canvas');
    if (canvas && canvas.width >= 700 && canvas.height >= 1500) {
      const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
      if (gl) {
        try {
          if (window.__panel === null) {
            const dark = readBand(gl, canvas);
            if (dark > 40) window.__panel = { t: Math.round(performance.now()), dark };
          }
          if (window.__paint === null) {
            const w = 96, h = 208, buf = new Uint8Array(w * h * 4);
            gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, buf);
            let nonBlack = 0;
            for (let i = 0; i < buf.length; i += 4) {
              if (buf[i] || buf[i + 1] || buf[i + 2]) nonBlack += 1;
            }
            if (nonBlack > 0) window.__paint = { t: Math.round(performance.now()), nonBlack };
          }
        } catch (e) {}
      }
    }
    requestAnimationFrame(tick);
  };
  requestAnimationFrame(tick);
})();`.replace('enum_console_placeholder', `
  window.__logs = [];
  const realLog = console.log;
  console.log = function () {
    const args = Array.prototype.slice.call(arguments);
    try { window.__logs.push({ t: Math.round(performance.now()), text: args.map(String).join(' ') }); } catch (e) {}
    return realLog.apply(console, arguments);
  };`);

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

const width = 390;
const height = 844;
const dpr = 2;
const port = 9900 + Math.floor(Math.random() * 300);
const profile = fs.mkdtempSync(path.join(os.tmpdir(), `drive856-${port}-`));
const args = [
  '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
  '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
  `--window-size=${width},${height}`, `--force-device-scale-factor=${dpr}`,
  '--autoplay-policy=no-user-gesture-required',
];
if (swiftshader) args.push('--use-angle=swiftshader', '--enable-unsafe-swiftshader');
args.push('about:blank');
const chrome = spawn(CHROME, args, { stdio: ['ignore', 'pipe', 'pipe'] });
chrome.stderr.resume();

const wsUrl = await pageTarget(port);
if (!wsUrl) { chrome.kill('SIGKILL'); throw new Error('no page target'); }
const ws = new WebSocket(wsUrl);
await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });

let nextId = 1;
const pending = new Map();
const consoleLines = [];
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
    consoleLines.push(`console.${data.params.type} ${(data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ')}`);
  }
  if (data.method === 'Log.entryAdded') {
    consoleLines.push(`log.${data.params.entry.level} [${data.params.entry.source}] ${data.params.entry.text}`);
  }
  if (data.method === 'Runtime.exceptionThrown') {
    consoleLines.push(`exception ${data.params.exceptionDetails.exception?.description || data.params.exceptionDetails.text}`);
  }
};
const send = (method, params = {}) => new Promise((resolve, reject) => {
  const id = nextId++;
  pending.set(id, { resolve, reject });
  ws.send(JSON.stringify({ id, method, params }));
});
const evaluate = async (expression) => {
  const res = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
  return res.result?.value;
};
const shot = async (name) => {
  const captured = await send('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(path.join(outDir, 'screenshots', `${name}.png`), Buffer.from(captured.data, 'base64'));
  return `${name}.png`;
};
const tap = async (point) => {
  await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: point.x, y: point.y, id: 1 }] });
  await sleep(40);
  await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
};

await send('Runtime.enable');
await send('Log.enable');
await send('Page.enable');
await send('Network.enable');
await send('Network.setCacheDisabled', { cacheDisabled: true });
await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: dpr, mobile: true });
await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
await send('Page.addScriptToEvaluateOnNewDocument', { source: INJECT });

const result = { url, swiftshader, width, height, dpr, cold: {}, warm: {}, taps: [], shots: [] };
const renderer = () => evaluate(`(() => { const c = document.createElement('canvas'); const g = c.getContext('webgl2'); if (!g) return 'none'; const d = g.getExtension('WEBGL_debug_renderer_info'); return d ? g.getParameter(d.UNMASKED_RENDERER_WEBGL) : 'unknown'; })()`);

const started = Date.now();
await send('Page.navigate', { url });

// A tap on the band while the loading state is up, then a screenshot of it.
await sleep(300);
result.shots.push(await shot('s1-loading-300ms'));
await tap(SHARED);
result.taps.push({ at: 300, on: 'shared', phase: 'during loading' });
await sleep(200);
result.shots.push(await shot('s1-loading-600ms'));

const pollStart = Date.now();
let panel = null;
while (Date.now() - pollStart < 20000) {
  panel = await evaluate('window.__panel');
  if (panel) break;
  await sleep(25);
}
const panelSeenAt = Date.now() - started;
await sleep(120);
result.shots.push(await shot('s1-mode-pick'));
const state = await evaluate(`(() => ({ panel: window.__panel, paint: window.__paint,
  paintTiming: (() => { const o = {}; for (const e of performance.getEntriesByType('paint')) o[e.name] = Math.round(e.startTime); return o; })(),
  nav: (() => { const n = performance.getEntriesByType('navigation')[0]; return n ? { responseStart: Math.round(n.responseStart), dcl: Math.round(n.domContentLoadedEventEnd), load: Math.round(n.loadEventEnd) } : null; })(),
  logs: window.__logs }))()`);
result.cold = { panelSeenAt, ...state };

// Interactivity: the shared-game control routes.
await tap(SHARED);
await sleep(1200);
result.shots.push(await shot('s2-shared-game'));
result.taps.push({ at: panelSeenAt, on: 'shared', phase: 'after panel paint', shot: 's2-shared-game.png' });

// Back to mode pick, then the puzzle-stream control.
await send('Page.reload', { ignoreCache: true });
await sleep(6000);
result.shots.push(await shot('s3-mode-pick-again'));
await tap(PUZZLE);
await sleep(1200);
result.shots.push(await shot('s3-puzzle-stream'));
result.taps.push({ at: null, on: 'puzzle', phase: 'warm mode pick', shot: 's3-puzzle-stream.png' });

// Warm open (S1 second half): a reload with the cache on.
await send('Network.setCacheDisabled', { cacheDisabled: false });
await send('Page.reload', { ignoreCache: false });
await sleep(6000);
await send('Page.reload', { ignoreCache: false });
const warmStart = Date.now();
let warmPanel = null;
while (Date.now() - warmStart < 20000) {
  warmPanel = await evaluate('window.__panel');
  if (warmPanel) break;
  await sleep(25);
}
result.warm = await evaluate(`(() => ({ panel: window.__panel, paint: window.__paint,
  paintTiming: (() => { const o = {}; for (const e of performance.getEntriesByType('paint')) o[e.name] = Math.round(e.startTime); return o; })(),
  nav: (() => { const n = performance.getEntriesByType('navigation')[0]; return n ? { responseStart: Math.round(n.responseStart), dcl: Math.round(n.domContentLoadedEventEnd), load: Math.round(n.loadEventEnd) } : null; })(),
  logs: window.__logs }))()`);
result.warm.panelSeenAt = Date.now() - warmStart;
await sleep(120);
result.shots.push(await shot('s1-warm-mode-pick'));
result.renderer = await renderer();

fs.writeFileSync(path.join(outDir, 'drive.json'), JSON.stringify(result, null, 2));
fs.writeFileSync(path.join(outDir, 'logs', 'drive-console.log'), `${consoleLines.join('\n')}\n`);

ws.close();
await new Promise((resolve) => {
  if (chrome.exitCode !== null) { resolve(); return; }
  chrome.once('exit', resolve);
  chrome.kill('SIGKILL');
});
try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 }); } catch {}

console.log(JSON.stringify({
  renderer: result.renderer,
  cold: { panel: result.cold.panel, panelSeenAt: result.cold.panelSeenAt, paintTiming: result.cold.paintTiming, nav: result.cold.nav },
  warm: { panel: result.warm.panel, panelSeenAt: result.warm.panelSeenAt, paintTiming: result.warm.paintTiming },
  shots: result.shots,
}));
