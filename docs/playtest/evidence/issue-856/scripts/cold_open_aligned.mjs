/**
 * Cold open with the browser and the engine on one clock (#856).
 *
 * The #403 runner forces `--use-angle=swiftshader`. That keeps the *browser's* GL context
 * real but makes the browser's own fetch of any `rel=preload` link invisible to the page's
 * Resource Timing, so a page-level `link` shows no request while the engine's `fetch()`
 * re-requests the same bytes. This runner is the same reading without that flag: the page's
 * `gl.readPixels` probe, the page's Resource Timing, and the app's console lines, all on
 * `performance.now()`.
 *
 * Usage: node cold_open_aligned.mjs <page-url> <out.json> <label> [wait-ms] [runs]
 */

import fs from 'node:fs';
import { runCapture, installHook, sleep } from './cdp_aligned.mjs';

const [url, outPath, label, waitArg, runsArg] = process.argv.slice(2);
if (!url || !outPath) {
  console.error('usage: node cold_open_aligned.mjs <page-url> <out.json> <label> [wait-ms] [runs]');
  process.exit(2);
}
const waitMs = Number(waitArg || 20000);
const runs = Number(runsArg || 1);

const PROBE = `(() => {
  window.__draws = [];
  window.__contexts = [];
  window.__fetches = [];
  const realGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function (kind) {
    const start = Math.round(performance.now());
    const context = realGetContext.apply(this, arguments);
    window.__contexts.push([kind, start, Math.round(performance.now())]);
    return context;
  };
  const realFetch = window.fetch;
  window.fetch = function (input) {
    const name = typeof input === 'string' ? input.split('/').pop() : String(input && input.url).split('/').pop();
    window.__fetches.push([name, Math.round(performance.now())]);
    return realFetch.apply(window, arguments);
  };
  const realLog = console.log;
  console.log = function () {
    if (typeof arguments[0] === 'string') {
      const args = Array.prototype.slice.call(arguments);
      args[0] = Math.round(performance.now()) + 'ms ' + args[0];
      realLog.apply(console, args);
      return;
    }
    realLog.apply(console, arguments);
  };
  const probe = () => {
    const canvas = document.querySelector('canvas');
    if (canvas) {
      const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
      if (gl) {
        const buf = new Uint8Array(96 * 208 * 4);
        gl.readPixels(0, 0, 96, 208, gl.RGBA, gl.UNSIGNED_BYTE, buf);
        let sum = 0;
        for (let i = 0; i < buf.length; i += 4) sum += buf[i] + buf[i + 1] + buf[i + 2];
        window.__draws.push([Math.round(performance.now()), sum > 0 ? Math.round(sum / (buf.length / 4) / 3) : 0]);
      }
    }
    if (window.__draws.length < 4000) requestAnimationFrame(probe);
  };
  const waitForCanvas = () => {
    if (!document.querySelector('canvas')) { setTimeout(waitForCanvas, 50); return; }
    probe();
  };
  waitForCanvas();
  return 'probing';
})()`;

const REPORT = `(() => {
  const first = (window.__draws || []).find(([, mean]) => mean > 0) || null;
  const nav = performance.getEntriesByType('navigation')[0];
  const resources = performance.getEntriesByType('resource').map((entry) => ({
    name: entry.name.split('/').pop(),
    initiatorType: entry.initiatorType,
    startMs: Math.round(entry.startTime),
    endMs: Math.round(entry.startTime + entry.duration),
    transferredBytes: entry.transferSize,
    encodedBytes: entry.encodedBodySize,
    decodedBytes: entry.decodedBodySize,
  }));
  return {
    firstPaintedMs: first ? first[0] : null,
    domContentLoadedMs: nav ? Math.round(nav.domContentLoadedEventEnd) : null,
    contexts: window.__contexts || [],
    fetches: window.__fetches || [],
    resources,
  };
})()`;

const rows = [];
for (let index = 1; index <= runs; index++) {
  const report = await runCapture({
    url: 'about:blank',
    outDir: outPath.replace(/[^/]+$/, '') || '.',
    label: `${label}-${index}`,
    callTimeoutMs: 180000,
    screencast: false,
    body: async ({ send, evaluate, on }) => {
      const consoleLines = [];
      on((data) => {
        if (data.method === 'Runtime.consoleAPICalled') {
          consoleLines.push((data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' '));
        }
      });
      await installHook(send, PROBE);
      await send('Network.setCacheDisabled', { cacheDisabled: true });
      await send('Page.navigate', { url });
      await sleep(waitMs);
      const result = await evaluate(REPORT);
      result.console = consoleLines;
      return result;
    },
  });
  const pck = report.resources.find((r) => r.name === 'index.pck');
  const wasm = report.resources.find((r) => r.name === 'index.wasm');
  const probe = report.contexts[0];
  rows.push({
    run: index,
    url,
    firstPaintedMs: report.firstPaintedMs,
    probeContextMs: probe ? probe[2] - probe[1] : null,
    probeContextEndMs: probe ? probe[2] : null,
    engineBanner: report.console.find((l) => l.includes('Godot Engine v')) || null,
    appLines: report.console.filter((l) => !(l.includes('Godot Engine v') || /^\d+ms /.test(l))),
    pck: pck && { startMs: pck.startMs, endMs: pck.endMs, initiatorType: pck.initiatorType, transferredBytes: pck.transferredBytes, decodedBytes: pck.decodedBytes },
    wasm: wasm && { startMs: wasm.startMs, endMs: wasm.endMs, transferredBytes: wasm.transferredBytes, decodedBytes: wasm.decodedBytes },
    domContentLoadedMs: report.domContentLoadedMs,
    console: report.console,
  });
}
fs.writeFileSync(outPath, JSON.stringify({ runner: 'aligned', label, rows }, null, 2));
console.log(JSON.stringify(rows.map((r) => ({ run: r.run, paint: r.firstPaintedMs, ctx: r.probeContextEndMs, pck: r.pck, banner: r.engineBanner }))));
