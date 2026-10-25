/**
 * Cold open, per layer (#856) — one run per invocation, in the #403 runner: headless
 * Chrome 390×844 CSS / DPR 2, `--use-angle=swiftshader`, HTTP cache disabled.
 *
 * `cold_open_exact.mjs` answers *when* the first painted screen arrived; this answers
 * *where the seconds went*. It keeps the same in-page `gl.readPixels` per-frame probe
 * and adds the page's own Resource Timing for every request (index.js / index.wasm /
 * index.pck), every WebGL2 context the page creates (the shell's capability probe
 * first), the engine banner, and the app's own console lines. App lines are placed on
 * the page clock by the in-page shim below, so they are comparable with the resource
 * stamps; no harness-side clock is mixed in.
 *
 * Usage: node cold_open_layers.mjs <page-url> <out.json> <label> [wait-ms]
 *
 * Writes `<out.json>` (summary: paint stamp, probe span, resource spans, paints) and
 * `<out>-console.log` (the page's console lines with their page-clock stamps).
 *
 * It records; it never judges a row.
 *
 * `--use-angle=swiftshader` (the #403 runner's flag) keeps the browser's own GL init real
 * but hides the browser's fetch of a `rel=preload` resource from Resource Timing; when the
 * page's preloads are what you are reading, use `cold_open_aligned.mjs` — same reading,
 * without that flag — and say so in the manifest.
 */

import fs from 'node:fs';
import { runCapture, installHook, sleep } from '../../issue-403/graphical-20261025T060000Z/scripts/cdp.mjs';

const [url, outPath, label, waitArg] = process.argv.slice(2);
if (!url || !outPath) {
  console.error('usage: node cold_open_layers.mjs <page-url> <out.json> <label> [wait-ms]');
  process.exit(2);
}
const waitMs = Number(waitArg || 20000);

/** The #403 readback, plus a GL-context stamp and a page-clock prefix on console lines. */
const PROBE = `(() => {
  window.__draws = [];
  window.__contexts = [];
  const realGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function (kind) {
    const start = Math.round(performance.now());
    const context = realGetContext.apply(this, arguments);
    window.__contexts.push([kind, start, Math.round(performance.now())]);
    return context;
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
    if (!document.querySelector('canvas')) {
      setTimeout(waitForCanvas, 50);
      return;
    }
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
    encodedBytes: entry.encodedBodySize,
    transferredBytes: entry.transferSize,
    decodedBytes: entry.decodedBodySize,
  }));
  const paints = performance.getEntriesByType('paint').map((p) => ({
    name: p.name,
    startMs: Math.round(p.startTime),
  }));
  return {
    firstPaintedMs: first ? first[0] : null,
    framesProbed: (window.__draws || []).length,
    domContentLoadedMs: nav ? Math.round(nav.domContentLoadedEventEnd) : null,
    contexts: window.__contexts || [],
    resources,
    paints,
  };
})()`;

const report = await runCapture({
  url: 'about:blank',
  outDir: outPath.replace(/[^/]+$/, '') || '.',
  label,
  callTimeoutMs: 180000,
  screencast: false,
  body: async ({ send, evaluate, on }) => {
    const consoleLines = [];
    on((data) => {
      if (data.method === 'Runtime.consoleAPICalled') {
        const text = (data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ');
        consoleLines.push(text);
      }
      if (data.method === 'Runtime.exceptionThrown') {
        const details = data.params.exceptionDetails;
        consoleLines.push(`exception ${String(details.exception?.description || details.text)}`);
      }
    });
    await installHook(send, PROBE);
    await send('Network.setCacheDisabled', { cacheDisabled: true });
    await send('Page.navigate', { url });
    await sleep(waitMs);
    const result = await evaluate(REPORT);
    result.url = url;
    result.label = label;
    result.console = consoleLines;
    return result;
  },
});

const wasm = report.resources.find((r) => r.name === 'index.wasm');
const pck = report.resources.find((r) => r.name === 'index.pck');
const firstContext = report.contexts[0];
const engineBanner = report.console.find((line) => line.includes('Godot Engine v')) || null;
const summary = {
  label,
  firstPaintedMs: report.firstPaintedMs,
  probeContextMs: firstContext ? firstContext[2] - firstContext[1] : null,
  probeContextEndMs: firstContext ? firstContext[2] : null,
  engineBanner,
  wasmRequestedMs: wasm ? wasm.startMs : null,
  wasmDownloadedMs: wasm ? wasm.endMs - wasm.startMs : null,
  pckRequestedMs: pck ? pck.startMs : null,
  pckDownloadedMs: pck ? pck.endMs - pck.startMs : null,
  domContentLoadedMs: report.domContentLoadedMs,
  paints: report.paints,
};
fs.writeFileSync(outPath, JSON.stringify(summary, null, 2));
fs.writeFileSync(outPath.replace(/\.json$/, '-console.log'), `${report.console.join('\n')}\n`);
console.log(JSON.stringify(summary));
