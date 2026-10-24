/**
 * Cold open, arms on one clock (#856). One run per page per arm, in the aligned runner
 * (`cdp_aligned.mjs`: the #403 driver without `--use-angle=swiftshader`, so a `link`
 * preload's own fetch is visible to the page's Resource Timing).
 *
 *   shipped              index.html               the page as exported
 *   probe-later          index_probe_later.html   probe moved after startGame() (make_arms.mjs)
 *   preload              index_preload.html       + <link rel=preload> for js / wasm / pck
 *   preload-worklets     index_preload_worklet.html  + the two audio worklets
 *
 * Usage: node cold_open_arms.mjs <base-url> <out directory> [runs-per-arm]
 *
 * Writes `<out>/<arm>-<run>.json` (summary) and `<out>/<arm>-<run>-console.log`.
 */

import fs from 'node:fs';
import { runCapture, installHook, sleep } from './cdp_aligned.mjs';

const [baseUrl, outDir, runsArg] = process.argv.slice(2);
if (!baseUrl || !outDir) {
  console.error('usage: node cold_open_arms.mjs <base-url> <out directory> [runs-per-arm]');
  process.exit(2);
}
const runs = Number(runsArg || 3);
const arms = {
  shipped: 'index.html',
  'probe-later': 'index_probe_later.html',
  preload: 'index_preload.html',
  'preload-worklets': 'index_preload_worklet.html',
};

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

fs.mkdirSync(outDir, { recursive: true });
for (const [arm, page] of Object.entries(arms)) {
  for (let run = 1; run <= runs; run++) {
    const url = `${baseUrl}/${page}`;
    const report = await runCapture({
      url: 'about:blank',
      outDir,
      label: `${arm}-${run}`,
      callTimeoutMs: 180000,
      screencast: false,
      body: async ({ send, evaluate, on }) => {
        const consoleLines = [];
        on((data) => {
          if (data.method === 'Runtime.consoleAPICalled') {
            consoleLines.push((data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' '));
          }
          if (data.method === 'Runtime.exceptionThrown') {
            const details = data.params.exceptionDetails;
            consoleLines.push(`exception ${String(details.exception?.description || details.text)}`);
          }
        });
        await installHook(send, PROBE);
        await send('Network.setCacheDisabled', { cacheDisabled: true });
        await send('Page.navigate', { url });
        await sleep(20000);
        const result = await evaluate(REPORT);
        result.console = consoleLines;
        return result;
      },
    });
    const pck = report.resources.find((r) => r.name === 'index.pck');
    const probe = report.contexts[0];
    const summary = {
      arm,
      run,
      url,
      firstPaintedMs: report.firstPaintedMs,
      probeContextMs: probe ? probe[2] - probe[1] : null,
      probeContextEndMs: probe ? probe[2] : null,
      engineBanner: report.console.find((l) => l.includes('Godot Engine v')) || null,
      firstFetchMs: report.fetches.find((f) => f[0] === 'index.pck')?.[1] ?? null,
      pck: pck && { startMs: pck.startMs, endMs: pck.endMs, initiatorType: pck.initiatorType, transferredBytes: pck.transferredBytes },
      domContentLoadedMs: report.domContentLoadedMs,
    };
    fs.writeFileSync(`${outDir}/${arm}-${run}.json`, JSON.stringify(summary, null, 2));
    fs.writeFileSync(`${outDir}/${arm}-${run}-console.log`, `${report.console.join('\n')}\n`);
    console.log(JSON.stringify(summary));
  }
}
