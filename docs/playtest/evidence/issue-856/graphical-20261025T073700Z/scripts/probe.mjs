/**
 * Cold-open probe for the #856 acceptance run.
 *
 * Cheap instrument on the page's own clock:
 *   - `PerformancePaintTiming` first-paint / first-contentful-paint (the #402
 *     reading) plus the navigation timing milestones;
 *   - WebGL context creation stamps (the shell's capability probe);
 *   - every `console` line stamped with performance.now();
 *   - a small `gl.readPixels` strip once per frame until it is non-black, which
 *     stamps the first engine-rendered frame without paying a full-canvas
 *     readback on every frame.
 *
 * Usage: node probe.mjs <url> <outDir> <label> [--swiftshader] [--shoot atMs,...] [--wait ms]
 * One fresh Chrome profile per invocation, HTTP cache disabled, no interaction.
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const [url, outDir, label, ...rest] = process.argv.slice(2);
if (!url || !outDir || !label) {
  console.error('usage: node probe.mjs <url> <outDir> <label> [--swiftshader] [--shoot atMs,...] [--wait ms]');
  process.exit(2);
}
const opt = (name, dflt) => (rest.includes(name) ? rest[rest.indexOf(name) + 1] : dflt);
const swiftshader = rest.includes('--swiftshader');
const shootAt = String(opt('--shoot', '')).split(',').filter(Boolean).map(Number);
const waitMs = Number(opt('--wait', '9000'));
const warm = rest.includes('--warm');

fs.mkdirSync(outDir, { recursive: true });

const INJECT = `(() => {
  window.__t0 = performance.now();
  window.__ctx = [];
  window.__paint = null;
  window.__panel = null;
  window.__frames = 0;
  window.__logs = [];
  const realGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function (kind) {
    const start = performance.now();
    const ctx = realGetContext.apply(this, arguments);
    const end = performance.now();
    if (kind === 'webgl2' || kind === 'webgl' || kind === 'webgpu') {
      window.__ctx.push({ kind, start, end, ok: !!ctx });
    }
    return ctx;
  };
  const realLog = console.log;
  console.log = function () {
    const args = Array.prototype.slice.call(arguments);
    try { window.__logs.push({ t: Math.round(performance.now()), text: args.map(String).join(' ') }); } catch (e) {}
    return realLog.apply(console, arguments);
  };
  // Device-pixel band that holds the mode-pick panel's two mode controls at a
  // 390x844 CSS / DPR 2 frame: CSS x 95..295, y 147..222 -> device x 190..590,
  // y 294..444 top-down. gl.readPixels counts y from the canvas bottom.
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
  const strip = () => {
    window.__frames += 1;
    const canvas = document.querySelector('canvas');
    // Skip a canvas that is not the engine surface: a readPixels past the drawing
    // buffer returns zeros, which would read as "all dark".
    if (canvas && window.__panel === null && canvas.width >= 700 && canvas.height >= 1500) {
      const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
      if (gl) {
        try {
          const dark = readBand(gl, canvas);
          window.__lastBandDark = dark;
          if (dark > 40) {
            window.__panel = { t: Math.round(performance.now()), dark,
              canvasW: canvas.width, canvasH: canvas.height };
          }
        } catch (e) { window.__bandError = String(e); }
      }
    }
    if (window.__paint === null) {
      const canvas2 = document.querySelector('canvas');
      if (canvas2) {
        const gl = canvas2.getContext('webgl2') || canvas2.getContext('webgl');
        if (gl) {
          const w = 96, h = 208;
          const buf = new Uint8Array(w * h * 4);
          try {
            gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, buf);
            let nonBlack = 0;
            for (let i = 0; i < buf.length; i += 4) {
              if (buf[i] || buf[i + 1] || buf[i + 2]) { nonBlack += 1; }
            }
            if (nonBlack > 0) {
              window.__paint = { t: Math.round(performance.now()), nonBlack, w, h,
                canvasW: canvas2.width, canvasH: canvas2.height };
            }
          } catch (e) {}
        }
      }
    }
    requestAnimationFrame(strip);
  };
  requestAnimationFrame(strip);
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

const width = 390;
const height = 844;
const dpr = 2;
const port = 9400 + Math.floor(Math.random() * 500);
const profile = fs.mkdtempSync(path.join(os.tmpdir(), `acc856-${port}-`));
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
    const text = (data.params.args || [])
      .map((arg) => arg.value ?? arg.description ?? arg.type).join(' ');
    consoleLines.push(`console.${data.params.type} ${text}`);
  }
  if (data.method === 'Log.entryAdded') {
    consoleLines.push(`log.${data.params.entry.level} [${data.params.entry.source}] ${data.params.entry.text}`);
  }
  if (data.method === 'Runtime.exceptionThrown') {
    const details = data.params.exceptionDetails;
    consoleLines.push(`exception ${details.exception?.description || details.text}`);
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
  fs.writeFileSync(path.join(outDir, `${name}.png`), Buffer.from(captured.data, 'base64'));
};

await send('Runtime.enable');
await send('Log.enable');
await send('Page.enable');
await send('Network.enable');
await send('Network.setCacheDisabled', { cacheDisabled: !warm });
await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: dpr, mobile: true });
await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
await send('Page.addScriptToEvaluateOnNewDocument', { source: INJECT });

let started = Date.now();
await send('Page.navigate', { url });
if (warm) {
  // S1's second half: the same profile reopening the same page with its cache.
  await sleep(waitMs);
  started = Date.now();
  await send('Page.reload', { ignoreCache: false });
}

for (const at of shootAt) {
  const wait = at - (Date.now() - started);
  if (wait > 0) await sleep(wait);
  try { await shot(`${label}-at${at}ms`); } catch (e) { consoleLines.push(`screenshot-fail ${at}ms ${e}`); }
}
const remain = waitMs - (Date.now() - started);
if (remain > 0) await sleep(remain);
if (shootAt.length === 0 || shootAt[shootAt.length - 1] < waitMs) {
  try { await shot(`${label}-final`); } catch (e) { consoleLines.push(`screenshot-fail final ${e}`); }
}

const probe = await evaluate(`(() => ({
  t0: window.__t0, paint: window.__paint, panel: window.__panel, lastBandDark: window.__lastBandDark, bandError: window.__bandError, ctx: window.__ctx,
  frames: window.__frames, logs: window.__logs, now: performance.now(),
  paintTiming: (() => { const out = {}; for (const e of performance.getEntriesByType('paint')) out[e.name] = Math.round(e.startTime); return out; })(),
  nav: (() => { const n = performance.getEntriesByType('navigation')[0]; return n ? { start: Math.round(n.startTime), responseStart: Math.round(n.responseStart), dcl: Math.round(n.domContentLoadedEventEnd), load: Math.round(n.loadEventEnd) } : null; })(),
  ua: navigator.userAgent,
}))()`);

const renderer = await evaluate(`(() => { const c = document.createElement('canvas'); const g = c.getContext('webgl2'); if (!g) return 'none'; const d = g.getExtension('WEBGL_debug_renderer_info'); return d ? g.getParameter(d.UNMASKED_RENDERER_WEBGL) : 'unknown'; })()`);

fs.writeFileSync(path.join(outDir, `${label}.json`), JSON.stringify({ label, url, swiftshader, warm, width, height, dpr, renderer, probe, chromeConsole: consoleLines }, null, 2));
fs.writeFileSync(path.join(outDir, `${label}-console.log`), `${consoleLines.join('\n')}\n`);

ws.close();
await new Promise((resolve) => {
  if (chrome.exitCode !== null) { resolve(); return; }
  chrome.once('exit', resolve);
  chrome.kill('SIGKILL');
});
try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 }); } catch {}

console.log(JSON.stringify({
  label, renderer, paint: probe.paint, firstCtx: probe.ctx[0] || null,
  panel: probe.panel, paintTiming: probe.paintTiming, nav: probe.nav,
}));
