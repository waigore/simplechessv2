/**
 * Capture the release build's console, network, and frame timing over CDP.
 *
 * Written for #402's quality-row re-record. It drives a real headless Chrome with no
 * third-party dependency: it starts Chrome with a debugging port, attaches to the
 * page target, enables Runtime/Log/Page/Network, samples requestAnimationFrame
 * deltas (SIT.4), and screenshots on a fixed schedule.
 *
 * Usage:
 *     node capture_release.js <url> <outDir> <label> <windowMs>
 *
 * Writes <label>-events.log, <label>-frames.json, and <label>-<nn>-<t>ms.png into
 * <outDir>. The manifest cites the build; this script never picks it.
 */

const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const CHROME = process.env.CHROME_BIN
  || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const MARKS = [500, 1000, 2000, 3000, 5000, 10000, 15000, 20000, 25000, 30000, 45000, 60000];
const SAMPLER = `(() => {
  window.__frames = [];
  const tick = (ts) => { window.__frames.push(ts); if (window.__frames.length < 40000) requestAnimationFrame(tick); };
  requestAnimationFrame(tick);
  return 'sampling';
})()`;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function pageTarget(port) {
  for (let attempt = 0; attempt < 100; attempt++) {
    await sleep(100);
    try {
      const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const page = pages.find((candidate) => candidate.type === 'page');
      if (page) return page.webSocketDebuggerUrl;
    } catch {}
  }
  return null;
}

function frameSummary(frames) {
  const deltas = frames.slice(1).map((ts, index) => +(ts - frames[index]).toFixed(2));
  const sorted = [...deltas].sort((a, b) => a - b);
  const at = (q) => (sorted.length ? sorted[Math.floor(q * sorted.length)] : null);
  const span = frames.length ? +(frames[frames.length - 1] - frames[0]).toFixed(1) : 0;
  return {
    frames: frames.length,
    spanMs: span,
    fps: span ? +(((frames.length - 1) / span) * 1000).toFixed(2) : null,
    p50: at(0.5), p95: at(0.95), p99: at(0.99),
    max: sorted.length ? sorted[sorted.length - 1] : null,
    deltasOverOneFrameAt60: deltas.filter((delta) => delta > 16.7).length,
  };
}

async function main() {
  const [url, outDir, label, windowArg] = process.argv.slice(2);
  const windowMs = Number(windowArg || 25000);
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9300 + Math.floor(Math.random() * 500);
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
  if (!wsUrl) {
    chrome.kill('SIGKILL');
    throw new Error('Chrome exposed no page target');
  }
  const ws = new WebSocket(wsUrl);
  await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });

  let nextId = 1;
  const pending = new Map();
  const events = [];
  const started = Date.now();
  const stamp = () => (Date.now() - started) / 1000;

  ws.onmessage = (message) => {
    const data = JSON.parse(message.data);
    if (data.id && pending.has(data.id)) {
      const { resolve, reject } = pending.get(data.id);
      pending.delete(data.id);
      if (data.error) reject(new Error(JSON.stringify(data.error)));
      else resolve(data.result);
      return;
    }
    if (data.method) events.push({ t: stamp(), method: data.method, params: data.params });
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });

  await send('Runtime.enable');
  await send('Log.enable');
  await send('Page.enable');
  await send('Network.enable');
  await send('Emulation.setDeviceMetricsOverride', {
    width: 390, height: 844, deviceScaleFactor: 2, mobile: true,
  });
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  await send('Page.navigate', { url });

  const shots = [];
  let elapsed = 0;
  while (elapsed < windowMs) {
    elapsed = Math.min(Math.min(...MARKS.filter((mark) => mark > elapsed), windowMs), windowMs);
    await sleep(Math.max(0, elapsed - (stamp() * 1000)));
    if (elapsed >= 500 && !shots.length) {
      await send('Runtime.evaluate', { expression: SAMPLER, returnByValue: true });
    }
    const shot = await send('Page.captureScreenshot', { format: 'png' });
    const name = `${label}-${String(shots.length + 1).padStart(2, '0')}-${elapsed}ms.png`;
    fs.writeFileSync(path.join(outDir, name), Buffer.from(shot.data, 'base64'));
    shots.push(name);
    const probe = await send('Runtime.evaluate', {
      expression: `JSON.stringify({
        canvas: !!document.querySelector('canvas'),
        bodyText: (document.body ? document.body.innerText : '').slice(0, 300),
        frames: (window.__frames || []).length
      })`,
      returnByValue: true,
    });
    events.push({ t: elapsed, method: 'driver.probe', params: JSON.parse(probe.result.value) });
  }

  const frames = await send('Runtime.evaluate', {
    expression: 'JSON.stringify(window.__frames || [])', returnByValue: true,
  });
  const summary = frameSummary(JSON.parse(frames.result.value));

  const lines = events.map((event) => {
    const { method, params, t } = event;
    if (method === 'Runtime.consoleAPICalled') {
      const text = (params.args || []).map((arg) => arg.value ?? arg.description ?? arg.type).join(' ');
      return `${t.toFixed(3)}s console.${params.type} ${text}`;
    }
    if (method === 'Log.entryAdded') {
      return `${t.toFixed(3)}s log.${params.entry.level} [${params.entry.source}] ${params.entry.text} ${params.entry.url || ''}`;
    }
    if (method === 'Runtime.exceptionThrown') {
      return `${t.toFixed(3)}s exception ${JSON.stringify(params.exceptionDetails.exception?.description || params.exceptionDetails.text)}`;
    }
    if (method === 'Network.responseReceived') {
      return `${t.toFixed(3)}s net ${params.response.status} ${params.response.url}`;
    }
    if (method === 'Network.loadingFailed') {
      return `${t.toFixed(3)}s net FAILED ${params.errorText} ${params.type}`;
    }
    if (method === 'driver.probe') {
      return `${t.toFixed(3)}s DRIVER probe canvas=${params.canvas} frames=${params.frames} text=${JSON.stringify(params.bodyText)}`;
    }
    return null;
  }).filter(Boolean);

  fs.writeFileSync(path.join(outDir, `${label}-events.log`), `${lines.join('\n')}\n`);
  fs.writeFileSync(path.join(outDir, `${label}-frames.json`), `${JSON.stringify(summary, null, 2)}\n`);
  console.log(JSON.stringify({ shots, summary }, null, 2));

  ws.close();
  chrome.kill('SIGKILL');
  fs.rmSync(profile, { recursive: true, force: true });
}

main().catch((error) => { console.error(error); process.exit(1); });
