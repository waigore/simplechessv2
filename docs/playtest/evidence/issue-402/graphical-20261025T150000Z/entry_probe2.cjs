/**
 * #693 gate (a) retry: enter a mode using in-button press points measured by #879's run.
 *
 * #879 measured mode pick's button boxes on published 69a03d4 as
 *   C1 "Shared game · Last" y 144.83–181.67, C2 "Puzzle stream" y 185.83–223.00,
 *   panel x 87.3–302.3,
 * and 28/28 in-button presses activated. Earlier #693 taps at y>=320 were below the
 * panel, i.e. in empty page, not on a control.
 *
 * Usage: node entry_probe2.cjs <outDir> <n>
 */
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const URL = 'https://waigore.github.io/simplechessv2/';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

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
  const port = 9200 + Math.floor(Math.random() * 80);
  const profile = path.join(outDir, `.chrome-entry2-${port}`);
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
  ws.onmessage = (m) => {
    const d = JSON.parse(m.data);
    if (d.id && pending.has(d.id)) {
      const { resolve, reject } = pending.get(d.id); pending.delete(d.id);
      if (d.error) reject(new Error(JSON.stringify(d.error))); else resolve(d.result); return;
    }
    if (d.method) events.push(d);
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++; pending.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });

  await send('Page.enable');
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 2, mobile: true });
  await send('Page.addScriptToEvaluateOnNewDocument', { source: `
    window.__gestures = [];
    for (const t of ['pointerdown','pointerup','touchstart','touchend']) {
      document.addEventListener(t, (e) => window.__gestures.push(t + '@' + Math.round(e.clientX||0) + ',' + Math.round(e.clientY||0)), true);
    }` });
  await send('Page.navigate', { url: URL });
  await sleep(15000);

  const shots = [];
  const shot = async (label) => {
    const s = await send('Page.captureScreenshot', { format: 'png' });
    const name = `entry2-${n}-${label}.png`;
    fs.writeFileSync(path.join(outDir, name), Buffer.from(s.data, 'base64'));
    shots.push(name);
    return s.data;
  };

  const frame = async () => (await send('Page.captureScreenshot', { format: 'png' })).data;

  const before = await shot('00-mode-pick');
  const arms = [
    // inside C1 "Shared game · Last" (y 144.83-181.67), x inside panel 87.3-302.3
    { label: 'c1-195-163', x: 195, y: 163, holdMs: 200 },
    // inside C2 "Puzzle stream" (y 185.83-223.00)
    { label: 'c2-195-204', x: 195, y: 204, holdMs: 200 },
  ];
  const results = [];
  for (const a of arms) {
    const pre = await frame();
    await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: a.x, y: a.y }] });
    await sleep(a.holdMs);
    await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await sleep(3500);
    const post = await shot(`after-${a.label}`);
    const changed = post !== pre;
    const gestures = (await send('Runtime.evaluate', { expression: 'JSON.stringify(window.__gestures||[])', returnByValue: true })).result.value;
    results.push({ ...a, changedFrame: changed, gestures: JSON.parse(gestures) });
    if (changed) break;
  }

  const lines = events.map(({ method, params }) => {
    if (method === 'Log.entryAdded') return `log.${params.entry.level} [${params.entry.source}] ${params.entry.text}`;
    if (method === 'Runtime.consoleAPICalled') return `console.${params.type} ${(params.args || []).map(x => x.value ?? x.description ?? x.type).join(' ')}`;
    return null;
  }).filter(Boolean);

  const summary = { url: URL, coldOpen: Number(n), arms: results, shots,
    unresolvedAssetIdWarnings: lines.filter(l => /Unresolved asset ID/.test(l)).length,
    unresolvedAmbient: lines.some(l => /Preload ambient left .* unresolved/.test(l)) };
  fs.writeFileSync(path.join(outDir, `entry2-${n}-summary.json`), JSON.stringify(summary, null, 2));
  fs.writeFileSync(path.join(outDir, `entry2-${n}-events.log`), lines.join('\n') + '\n');
  console.log(JSON.stringify(summary, null, 2));

  ws.close();
  chrome.kill('SIGKILL');
  fs.rmSync(profile, { recursive: true, force: true });
}

main().catch((e) => { console.error(e); process.exit(1); });
