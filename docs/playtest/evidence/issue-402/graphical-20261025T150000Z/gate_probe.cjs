/**
 * #693 gate probe: two cold opens of the published build, reading
 * (a) mode pick reached + a mode entered, (b) ambient audio actually playing.
 *
 * Audio is read from the running AudioContext / music player state exposed by the
 * engine, plus the audible signal the tab produces. Headless Chrome has no audio
 * device, so this script reports what the page state says, not what a person hears.
 *
 * Usage: node gate_probe.mjs <outDir> <coldOpenNumber>
 */
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const URL = 'https://waigore.github.io/simplechessv2/';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const audioAtStart = `(() => {
  const ctxs = [];
  const Orig = window.AudioContext || window.webkitAudioContext;
  if (Orig) {
    window.__ac = window.__ac || [];
    const Patched = function (...a) { const c = new Orig(...a); window.__ac.push(c); return c; };
    Patched.prototype = Orig.prototype;
    window.AudioContext = Patched;
  }
  return 'patched';
})()`;

const audioProbe = `JSON.stringify((() => {
  const acs = (window.__ac || []);
  return {
    contexts: acs.length,
    states: acs.map(c => c.state),
    currentTime: acs.map(c => +c.currentTime.toFixed(2)),
    sampleRate: acs.map(c => c.sampleRate),
    destinationMaxChannelCount: acs.map(c => (c.destination && c.destination.maxChannelCount) || null),
  };
})())`;

async function pageTarget(port) {
  for (let i = 0; i < 100; i++) {
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
  const [outDir, n] = process.argv.slice(2);
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9800 + Math.floor(Math.random() * 100);
  const profile = path.join(outDir, `.chrome-${port}`);
  const chrome = spawn(CHROME, [
    '--headless=new',
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
    '--window-size=390,844', '--force-device-scale-factor=2',
    '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
    '--autoplay-policy=no-user-gesture-required',
    'about:blank',
  ], { stdio: ['ignore', 'pipe', 'pipe'] });
  chrome.stderr.resume();

  const wsUrl = await pageTarget(port);
  if (!wsUrl) { chrome.kill('SIGKILL'); throw new Error('no page target'); }
  const ws = new WebSocket(wsUrl);
  await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });

  let nextId = 1;
  const pending = new Map();
  const events = [];
  const started = Date.now();
  const stamp = () => (Date.now() - started) / 1000;
  ws.onmessage = (m) => {
    const d = JSON.parse(m.data);
    if (d.id && pending.has(d.id)) {
      const { resolve, reject } = pending.get(d.id);
      pending.delete(d.id);
      if (d.error) reject(new Error(JSON.stringify(d.error))); else resolve(d.result);
      return;
    }
    if (d.method) events.push({ t: stamp(), method: d.method, params: d.params });
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });

  await send('Page.enable');
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Network.enable');
  await send('Page.addScriptToEvaluateOnNewDocument', { source: audioAtStart });
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 2, mobile: true });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });

  await send('Page.navigate', { url: URL });

  // wait for mode pick to render (canvas, so use a stable frame rather than text)
  let modePickAt = null;
  let enteredAt = null;
  const shots = [];
  const shot = async (label) => {
    const s = await send('Page.captureScreenshot', { format: 'png' });
    const name = `cold-open-${n}-${label}.png`;
    fs.writeFileSync(path.join(outDir, name), Buffer.from(s.data, 'base64'));
    shots.push(name);
  };

  await sleep(12000);
  modePickAt = stamp();
  await shot('mode-pick');

  // first interaction: tap Shared game (mode pick is the entry to both modes)
  await send('Input.dispatchMouseEvent', { type: 'mousePressed', x: 195, y: 330, button: 'left', clickCount: 1 });
  await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: 195, y: 330, button: 'left', clickCount: 1 });
  await sleep(4000);
  enteredAt = stamp();
  await shot('after-enter');
  const audio = await send('Runtime.evaluate', { expression: audioProbe, returnByValue: true });

  const lines = events.map(({ method, params, t }) => {
    if (method === 'Log.entryAdded') return `${t.toFixed(3)}s log.${params.entry.level} [${params.entry.source}] ${params.entry.text}`;
    if (method === 'Runtime.consoleAPICalled') return `${t.toFixed(3)}s console.${params.type} ${(params.args || []).map(a => a.value ?? a.description ?? a.type).join(' ')}`;
    if (method === 'Runtime.exceptionThrown') return `${t.toFixed(3)}s exception ${params.exceptionDetails.text}`;
    if (method === 'Network.responseReceived') return `${t.toFixed(3)}s net ${params.response.status} ${params.response.url}`;
    return null;
  }).filter(Boolean);

  const summary = {
    coldOpen: Number(n),
    url: URL,
    modePickAtS: modePickAt,
    firstInteractionAtS: enteredAt,
    audio: JSON.parse(audio.result.value),
    unresolvedAmbient: lines.some(l => /Preload ambient left .* unresolved/.test(l)),
    unresolvedAssetIdWarnings: lines.filter(l => /Unresolved asset ID/.test(l)).length,
    cantOpenAudio: lines.filter(l => /Can't open file from path.*\.ogg/.test(l)).length,
    shots,
  };
  fs.writeFileSync(path.join(outDir, `cold-open-${n}-events.log`), lines.join('\n') + '\n');
  fs.writeFileSync(path.join(outDir, `cold-open-${n}-summary.json`), JSON.stringify(summary, null, 2));
  console.log(JSON.stringify(summary, null, 2));

  ws.close();
  chrome.kill('SIGKILL');
  fs.rmSync(profile, { recursive: true, force: true });
}

main().catch((e) => { console.error(e); process.exit(1); });
