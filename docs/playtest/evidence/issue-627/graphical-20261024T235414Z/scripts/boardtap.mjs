/**
 * #627 card probe — can the board itself take a press on this frame?
 *
 * The cue driver's mode-pick presses landed in some sessions and not others, so
 * before grading any cue this probe answers one narrow question on the *current*
 * published frame: does a press inside the shared board reach the game?
 *
 * It screenshots, presses inside the board at three points, screenshots after
 * each, and the caller compares the images. A press that does nothing on the
 * board is a reachability problem (reported, not graded); a press that moves a
 * piece is a cue context.
 *
 * Usage: node boardtap.mjs <url> <outDir> <label>
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const TRACE = `(() => {
  window.__g = [];
  for (const t of ['pointerdown', 'touchstart', 'touchend', 'click']) {
    document.addEventListener(t, (e) => window.__g.push({
      t, x: Math.round(e.clientX ?? 0), y: Math.round(e.clientY ?? 0),
    }), { capture: true, passive: true });
  }
  const AC = window.AudioContext || window.webkitAudioContext;
  window.__starts = [];
  if (AC) {
    const origStart = AudioBufferSourceNode.prototype.start;
    AudioBufferSourceNode.prototype.start = function (when, offset, dur) {
      window.__starts.push({ t: +performance.now().toFixed(0), bufferSec: this.buffer ? +this.buffer.duration.toFixed(3) : null });
      return origStart.call(this, when ?? 0, offset ?? 0, dur);
    };
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
  const [url, outDir, label] = process.argv.slice(2);
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), `od627bt-${port}-`));
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
      logs.push({ kind: d.params.type, text: (d.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ') });
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
    return `${label}-${name}.png`;
  };
  const tap = async (x, y, hold = 120) => {
    await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y, id: 1 }] });
    await sleep(hold);
    await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await sleep(1500);
  };

  const steps = [];
  await sleep(30000);
  steps.push(await shot('00-mode-pick'));
  await tap(150, 185);
  steps.push(await shot('01-after-shared'));
  await tap(150, 185);
  steps.push(await shot('02-after-second-press'));
  await sleep(2500);
  steps.push(await shot('03-settled'));

  const state = await send('Runtime.evaluate', {
    expression: 'JSON.stringify({gestures: window.__g, starts: window.__starts})', returnByValue: true,
  });
  fs.writeFileSync(path.join(outDir, `${label}-boardtap.json`),
    JSON.stringify({ url, steps, ...JSON.parse(state.result.value) }, null, 1));
  fs.writeFileSync(path.join(outDir, `${label}-boardtap-console.json`), JSON.stringify(logs, null, 1));
  ws.close();
  await new Promise((resolve) => {
    if (chrome.exitCode !== null) { resolve(); return; }
    chrome.once('exit', resolve); chrome.kill('SIGKILL');
  });
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 }); } catch {}
}
main().catch((e) => { console.error(e); process.exit(1); });
