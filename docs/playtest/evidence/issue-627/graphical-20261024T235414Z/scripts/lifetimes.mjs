/**
 * #627 cue-lifetime probe — does the browser ever get asked to play a cue?
 *
 * The cue driver reached mode pick in one configuration and not another, so it
 * cannot stand as the record. This probe is the smallest thing that answers the
 * audio question on a *known-good* screen sequence, and it says which screen it
 * is on instead of assuming:
 *
 *  - no input is dispatched at all (the published build's puzzle entry was
 *    proven reachable earlier; here the run only needs the shared board);
 *  - every `AudioBufferSourceNode.start` the build makes is logged with the
 *    decoded buffer's length, so a 0.1 s select tap is distinguishable from a
 *    180 s bed;
 *  - `--autoplay-policy=no-user-gesture-required` so a silence can never be
 *    blamed on the browser's gesture gate in this probe.
 *
 * Usage: node lifetimes.mjs <url> <outDir> <label> <sequence>
 *   sequence: `mode-pick` (cold open only) | `puzzle` (enters puzzle stream)
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const TRACE = `(() => {
  const out = window.__starts = [];
  const t0 = performance.now();
  const AC = window.AudioContext || window.webkitAudioContext;
  if (!AC) { window.__noAC = true; return; }
  const Orig = AC;
  const origCreate = Orig.prototype.createBufferSource;
  Orig.prototype.createBufferSource = function () {
    const node = origCreate.call(this);
    node.addEventListener('ended', () => out.push({
      t: +((performance.now() - t0) / 1000).toFixed(3), kind: 'ended',
      bufferSec: node.buffer ? +node.buffer.duration.toFixed(3) : null,
    }));
    return node;
  };
  const origStart = AudioBufferSourceNode.prototype.start;
  AudioBufferSourceNode.prototype.start = function (when, offset, dur) {
    const b = this.buffer;
    out.push({
      t: +((performance.now() - t0) / 1000).toFixed(3), kind: 'start',
      bufferSec: b ? +b.duration.toFixed(3) : null,
      channels: b ? b.numberOfChannels : null,
      loop: this.loop,
      ctxState: window.__ctx ? window.__ctx.state : null,
    });
    return origStart.call(this, when ?? 0, offset ?? 0, dur);
  };
  window.AudioContext = function (...a) {
    const ctx = new Orig(...a);
    window.__ctx = ctx;
    return ctx;
  };
  window.AudioContext.prototype = Orig.prototype;
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
  const [url, outDir, label, sequence = 'mode-pick'] = process.argv.slice(2);
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `od627l-${port}-`));
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
  };
  const send = (method, params = {}) => new Promise((res, rej) => {
    const n = id++; pend.set(n, { resolve: res, reject: rej });
    ws.send(JSON.stringify({ id: n, method, params }));
  });
  await send('Runtime.enable');
  await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 3, mobile: true });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  await send('Page.addScriptToEvaluateOnNewDocument', { source: TRACE });
  await send('Page.navigate', { url });
  const shot = async (name) => {
    const c = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(path.join(outDir, `${label}-${name}.png`), Buffer.from(c.data, 'base64'));
  };

  await sleep(26000);
  await shot('01-mode-pick');
  if (sequence === 'puzzle') {
    // Puzzle stream, the entry proven reachable in the earlier probe.
    await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: 195, y: 285, id: 1 }] });
    await sleep(120);
    await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await sleep(9000);
    await shot('02-puzzle');
    await sleep(9000);
    await shot('03-puzzle-later');
  }
  const r = await send('Runtime.evaluate', { expression: 'JSON.stringify({starts: window.__starts||[], noAC: !!window.__noAC, ctx: window.__ctx ? window.__ctx.state : null})', returnByValue: true });
  fs.writeFileSync(path.join(outDir, `${label}-${sequence}-starts.json`), r.result.value);
  fs.writeFileSync(path.join(outDir, `${label}-${sequence}-console.json`), JSON.stringify(logs, null, 1));
  ws.close();
  await new Promise((resolve) => {
    if (chrome.exitCode !== null) { resolve(); return; }
    chrome.once('exit', resolve); chrome.kill('SIGKILL');
  });
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 }); } catch {}
}
main().catch((e) => { console.error(e); process.exit(1); });
