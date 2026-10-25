/**
 * #627 locked-autoplay probe — the reading AC 2 asks for.
 *
 * Question: from the first gesture, how long until a sitting hears ambience?
 * The policy under test is the *browser's own*: no
 * `--autoplay-policy=no-user-gesture-required` flag, so Web Audio starts
 * suspended exactly as it does on a phone until the page has been touched.
 *
 * The probe records, on one timeline:
 *  - when the `AudioContext` is created and when it reaches `running`;
 *  - the one gesture dispatched (a plain tap, not an audio-resume call);
 *  - when the build starts its first `AudioBufferSourceNode`, and its length.
 *
 * Nothing is instrumented inside Godot: only browser APIs are wrapped, so the
 * build behaves as it ships.
 *
 * Usage: node locked.mjs <url> <outDir> <label> [gestureDelayMs]
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const TRACE = `(() => {
  const out = window.__audio = [];
  const t0 = performance.now();
  const at = () => +((performance.now() - t0) / 1000).toFixed(3);
  const AC = window.AudioContext || window.webkitAudioContext;
  if (!AC) { window.__noAC = true; return; }
  const Orig = AC;
  const origStart = AudioBufferSourceNode.prototype.start;
  window.AudioContext = function (...a) {
    const ctx = new Orig(...a);
    window.__ctx = ctx;
    out.push({ t: at(), kind: 'ctx.create', state: ctx.state });
    ctx.addEventListener('statechange', () => out.push({ t: at(), kind: 'ctx.state', state: ctx.state }));
    return ctx;
  };
  window.AudioContext.prototype = Orig.prototype;
  AudioBufferSourceNode.prototype.start = function (when, offset, dur) {
    out.push({
      t: at(), kind: 'source.start',
      bufferSec: this.buffer ? +this.buffer.duration.toFixed(3) : null,
      ctxState: window.__ctx ? window.__ctx.state : null,
    });
    return origStart.call(this, when ?? 0, offset ?? 0, dur);
  };
  for (const type of ['pointerdown', 'touchstart', 'click']) {
    document.addEventListener(type, () => out.push({ t: at(), kind: 'gesture', type }), { capture: true, passive: true });
  }
})();`;

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
  const [url, outDir, label, delayArg = '30000'] = process.argv.slice(2);
  const gestureDelay = Number(delayArg);
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `od627k-${port}-`));
  // No autoplay flag: the browser's default gesture gate is the subject.
  const chrome = spawn(CHROME, [
    '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
    '--window-size=390,844', '--force-device-scale-factor=3',
    '--use-angle=swiftshader', '--enable-unsafe-swiftshader', 'about:blank',
  ], { stdio: ['ignore', 'pipe', 'pipe'] });
  chrome.stderr.resume();
  const ws = new WebSocket(await target(port));
  await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
  let id = 1; const pend = new Map(); const logs = [];
  ws.onmessage = (m) => {
    const d = JSON.parse(m.data);
    if (d.id && pend.has(d.id)) {
      const { resolve, reject } = pend.get(d.id); pend.delete(d.id);
      if (d.error) reject(new Error(JSON.stringify(d.error))); else resolve(d.result);
    }
    if (d.method === 'Runtime.consoleAPICalled') {
      logs.push({ at: new Date().toISOString(), kind: d.params.type,
        text: (d.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ') });
    }
    if (d.method === 'Log.entryAdded') {
      logs.push({ at: new Date().toISOString(), kind: `log.${d.params.entry.level}`, text: d.params.entry.text });
    }
  };
  const send = (method, params = {}) => new Promise((res, rej) => {
    const n = id++; pend.set(n, { resolve: res, reject: rej });
    ws.send(JSON.stringify({ id: n, method, params }));
  });
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 3, mobile: true });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  await send('Page.addScriptToEvaluateOnNewDocument', { source: TRACE });
  await send('Page.navigate', { url });
  const shot = async (name) => {
    const c = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(path.join(outDir, `${label}-${name}.png`), Buffer.from(c.data, 'base64'));
  };

  await sleep(gestureDelay);
  await shot('01-before-gesture');
  const beforeGesture = await send('Runtime.evaluate', {
    expression: 'JSON.stringify({audio: window.__audio, ctx: window.__ctx ? window.__ctx.state : null})',
    returnByValue: true,
  });
  // The gesture: one plain tap on the page, the same shape a person makes.
  await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: 195, y: 600, id: 1 }] });
  await sleep(80);
  await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await sleep(12000);
  await shot('02-after-gesture');
  const afterGesture = await send('Runtime.evaluate', {
    expression: 'JSON.stringify({audio: window.__audio, ctx: window.__ctx ? window.__ctx.state : null, now: window.__ctx ? +window.__ctx.currentTime.toFixed(3) : null})',
    returnByValue: true,
  });
  fs.writeFileSync(path.join(outDir, `${label}-locked.json`), JSON.stringify({
    url, gestureDelayMs: gestureDelay,
    beforeGesture: JSON.parse(beforeGesture.result.value),
    afterGesture: JSON.parse(afterGesture.result.value),
  }, null, 2));
  fs.writeFileSync(path.join(outDir, `${label}-locked-console.json`), JSON.stringify(logs, null, 1));
  ws.close();
  await new Promise((resolve) => {
    if (chrome.exitCode !== null) { resolve(); return; }
    chrome.once('exit', resolve); chrome.kill('SIGKILL');
  });
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 }); } catch {}
}
main().catch((e) => { console.error(e); process.exit(1); });
