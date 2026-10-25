/**
 * #693 mode-entry probe: does a tap on "Shared game" / "Puzzle stream" actually
 * enter the mode on the published build? Gate (a) requires "a mode can be entered
 * and played".
 *
 * Taps each control by canvas-relative position and reports whether the screen
 * changed away from mode pick.
 *
 * Usage: node entry_probe.cjs <outDir>
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
  const [outDir] = process.argv.slice(2);
  fs.mkdirSync(outDir, { recursive: true });
  const port = 9100 + Math.floor(Math.random() * 80);
  const profile = path.join(outDir, `.chrome-entry-${port}`);
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
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  await send('Page.navigate', { url: URL });
  await sleep(14000);

  const shots = [];
  const shot = async (label) => {
    const s = await send('Page.captureScreenshot', { format: 'png' });
    const name = `entry-${label}.png`;
    fs.writeFileSync(path.join(outDir, name), Buffer.from(s.data, 'base64'));
    shots.push(name);
  };

  // Compare frames to tell whether the screen changed.
  const frameHash = async () => {
    const s = await send('Page.captureScreenshot', { format: 'png' });
    const buf = Buffer.from(s.data, 'base64');
    return { b64: s.data, len: buf.length, head: buf.subarray(0, 64).toString('hex') };
  };

  const baseline = await frameHash();
  await shot('00-mode-pick');

  // Try the Shared game control at several y positions inside its drawn box.
  const attempts = [
    { label: 'shared-y331', x: 195, y: 331 },
    { label: 'shared-y320', x: 195, y: 320 },
    { label: 'puzzle-y405', x: 195, y: 405 },
  ];
  const results = [];
  for (const a of attempts) {
    const before = await frameHash();
    await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: a.x, y: a.y }] });
    await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await sleep(3000);
    const after = await frameHash();
    const changed = after.b64 !== before.b64;
    results.push({ ...a, changedFrame: changed });
    fs.writeFileSync(path.join(outDir, `entry-after-${a.label}.png`), Buffer.from(after.b64, 'base64'));
    shots.push(`entry-after-${a.label}.png`);
    if (changed) break;
    await sleep(500);
  }

  const lines = events.map(({ method, params }) => {
    if (method === 'Log.entryAdded') return `log.${params.entry.level} [${params.entry.source}] ${params.entry.text}`;
    if (method === 'Runtime.consoleAPICalled') return `console.${params.type} ${(params.args || []).map(x => x.value ?? x.description ?? x.type).join(' ')}`;
    return null;
  }).filter(Boolean);

  const summary = { url: URL, baselineHead: baseline.head, attempts: results, shots,
    unresolvedAssetIdWarnings: lines.filter(l => /Unresolved asset ID/.test(l)).length };
  fs.writeFileSync(path.join(outDir, 'entry-summary.json'), JSON.stringify(summary, null, 2));
  fs.writeFileSync(path.join(outDir, 'entry-events.log'), lines.join('\n') + '\n');
  console.log(JSON.stringify(summary, null, 2));

  ws.close();
  chrome.kill('SIGKILL');
  fs.rmSync(profile, { recursive: true, force: true });
}

main().catch((e) => { console.error(e); process.exit(1); });
