/**
 * #693 deep audio probe: is the ambient bed actually feeding the destination,
 * or is the AudioContext merely "running"?
 *
 * Taps every AudioNode connection to measure real signal level (RMS/peak) at
 * destination, and reads the engine's music-player state when exposed.
 *
 * Usage: node audio_probe.cjs <outDir> <n>
 */
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const URL = 'https://waigore.github.io/simplechessv2/';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Patch AudioNode.connect so every node feeding destination is also tapped by an Analyser.
const patch = `(() => {
  window.__taps = [];
  const OrigAC = window.AudioContext || window.webkitAudioContext;
  const OrigConnect = AudioNode.prototype.connect;
  AudioNode.prototype.connect = function (dest, ...rest) {
    try {
      if (dest && dest instanceof AudioDestinationNode) {
        const ac = this.context;
        const an = ac.createAnalyser();
        an.fftSize = 2048;
        OrigConnect.call(this, an);
        window.__taps.push(an);
      }
    } catch (e) {}
    return OrigConnect.call(this, dest, ...rest);
  };
  return 'patched';
})()`;

const measure = `JSON.stringify((() => {
  const taps = window.__taps || [];
  const reads = taps.map((an) => {
    const buf = new Float32Array(an.fftSize);
    an.getFloatTimeDomainData(buf);
    let peak = 0, sum = 0;
    for (let i = 0; i < buf.length; i++) { const v = Math.abs(buf[i]); if (v > peak) peak = v; sum += buf[i] * buf[i]; }
    return { peak: +peak.toFixed(5), rms: +Math.sqrt(sum / buf.length).toFixed(5) };
  });
  return { tapCount: taps.length, reads };
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
  const port = 9900 + Math.floor(Math.random() * 90);
  const profile = path.join(outDir, `.chrome-deep-${port}`);
  const chrome = spawn(CHROME, [
    '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars',
    '--window-size=390,844', '--force-device-scale-factor=2',
    '--use-angle=swiftshader', '--enable-unsafe-swiftshader',
    '--autoplay-policy=no-user-gesture-required', 'about:blank',
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
  await send('Page.addScriptToEvaluateOnNewDocument', { source: patch });
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 2, mobile: true });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  await send('Page.navigate', { url: URL });

  await sleep(14000);
  const shots = [];
  const shot = async (label) => {
    const s = await send('Page.captureScreenshot', { format: 'png' });
    const name = `deep-${n}-${label}.png`;
    fs.writeFileSync(path.join(outDir, name), Buffer.from(s.data, 'base64'));
    shots.push(name);
  };
  await shot('mode-pick');

  // Sample the bed at mode pick over 3 x 1s windows before any interaction.
  const preInteraction = [];
  for (let i = 0; i < 3; i++) { await sleep(1000); preInteraction.push(JSON.parse((await send('Runtime.evaluate', { expression: measure, returnByValue: true })).result.value)); }

  // Tap Shared game button by its real canvas hit region.
  const boxes = JSON.parse((await send('Runtime.evaluate', {
    expression: `JSON.stringify((() => {
      const c = document.querySelector('canvas');
      if (!c) return null;
      const r = c.getBoundingClientRect();
      return { x: r.x, y: r.y, w: r.width, h: r.height };
    })())`, returnByValue: true,
  })).result.value);
  const tapX = boxes ? boxes.x + boxes.w * 0.5 : 195;
  const tapY = boxes ? boxes.y + boxes.h * 0.36 : 320;
  for (const type of ['mousePressed', 'mouseReleased']) {
    await send('Input.dispatchMouseEvent', { type, x: tapX, y: tapY, button: 'left', clickCount: 1 });
  }
  await sleep(5000);
  await shot('after-enter');
  const postInteraction = [];
  for (let i = 0; i < 3; i++) { await sleep(1000); postInteraction.push(JSON.parse((await send('Runtime.evaluate', { expression: measure, returnByValue: true })).result.value)); }

  const lines = events.map(({ method, params, t }) => {
    if (method === 'Log.entryAdded') return `${t.toFixed(3)}s log.${params.entry.level} [${params.entry.source}] ${params.entry.text}`;
    if (method === 'Runtime.consoleAPICalled') return `${t.toFixed(3)}s console.${params.type} ${(params.args || []).map(a => a.value ?? a.description ?? a.type).join(' ')}`;
    return null;
  }).filter(Boolean);

  const summary = { coldOpen: Number(n), url: URL, canvas: boxes, tap: { x: tapX, y: tapY }, preInteraction, postInteraction, shots,
    unresolvedAssetIdWarnings: lines.filter(l => /Unresolved asset ID/.test(l)).length,
    unresolvedAmbient: lines.some(l => /Preload ambient left .* unresolved/.test(l)) };
  fs.writeFileSync(path.join(outDir, `deep-${n}-events.log`), lines.join('\n') + '\n');
  fs.writeFileSync(path.join(outDir, `deep-${n}-audio.json`), JSON.stringify(summary, null, 2));
  console.log(JSON.stringify(summary, null, 2));

  ws.close();
  chrome.kill('SIGKILL');
  fs.rmSync(profile, { recursive: true, force: true });
}

main().catch((e) => { console.error(e); process.exit(1); });
