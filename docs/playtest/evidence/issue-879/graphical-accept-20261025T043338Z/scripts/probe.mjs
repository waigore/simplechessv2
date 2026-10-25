/**
 * Raw CDP against one page target, no session state carried between calls.
 * Isolates when Chrome detaches during the #879 acceptance run. Not part of the
 * evidence; a diagnostic.
 *
 *     node scripts/probe.mjs <url>
 */
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const url = process.argv[2];
const CHROME = process.env.CHROME_BIN;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const port = 9911;
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'a879-probe-'));
const chrome = spawn(CHROME, [
  '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
  '--no-first-run', '--hide-scrollbars', '--window-size=390,844', '--force-device-scale-factor=3',
  '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--no-sandbox', 'about:blank',
], { stdio: ['ignore', 'pipe', 'pipe'] });
chrome.stderr.resume();

async function target() {
  for (let i = 0; i < 150; i++) {
    await sleep(100);
    try {
      const list = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const page = list.find((t) => t.type === 'page');
      if (page) return { ws: page.webSocketDebuggerUrl, id: page.id };
    } catch {}
  }
  throw new Error('no target');
}

async function cmd(method, params = {}) {
  const { ws: wsUrl, id: targetId } = await target();
  const ws = new WebSocket(wsUrl);
  await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
  const id = 1;
  const p = new Promise((resolve, reject) => {
    ws.onmessage = (m) => {
      const d = JSON.parse(m.data);
      if (d.id === id) { if (d.error) reject(new Error(JSON.stringify(d.error))); else resolve(d.result); }
    };
  });
  ws.send(JSON.stringify({ id, method, params }));
  try { return await p; } finally { ws.close(); }
}

const steps = [];
async function step(name, fn) {
  const t = Date.now();
  try {
    const out = await fn();
    steps.push({ name, ok: true, ms: Date.now() - t, out });
    console.log(`ok   ${name} (${Date.now() - t} ms)`);
  } catch (error) {
    steps.push({ name, ok: false, ms: Date.now() - t, error: error.message });
    console.log(`FAIL ${name}: ${error.message}`);
  }
}

await step('enable', () => cmd('Page.enable'));
await step('metrics', () => cmd('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 3, mobile: true }));
await step('touch', () => cmd('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 }));
await step('navigate', () => cmd('Page.navigate', { url }));
for (const wait of [1500, 3000, 6000]) {
  await sleep(wait);
  await step(`shot-${wait}`, async () => ((await cmd("Page.captureScreenshot", { format: "png" })).data.length));
  const { id } = await target();
  await step(`target-${wait}`, async () => id);
}
fs.writeFileSync('/tmp/opencode/probe-steps.json', `${JSON.stringify(steps, null, 2)}\n`);
chrome.kill('SIGKILL');
