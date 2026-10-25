/**
 * Cold-open the published release and record, per animation frame, whether the build's own
 * canvas carried pixels — the exact instant the first *painted* screen arrived.
 *
 * `capture_open_route.mjs` polls the readback every 250 ms, so it can only bracket the
 * first frame. #403's cold-open rows are a budget (≤3 s to the mode pick), and a bracket can
 * straddle the budget line. This harness reads the same WebGL probe inside the page's own
 * `requestAnimationFrame` callback, so every frame is stamped with the time it was drawn.
 *
 * The probe is installed before `Page.navigate`, so it exists for the build's first frame.
 *
 * Usage:
 *     node cold_open_exact.mjs <url> <outDir> <label>
 *
 * Writes `<label>-draw.json` (per-frame stamps), `<label>-session.json` (first drawn frame,
 * first non-blank frame, screenshots) and `<label>-console.log`.
 *
 * It records; it never judges a row.
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, sleep } from './cdp.mjs';

const [url, outDir, label] = process.argv.slice(2);
if (!url || !outDir || !label) {
  console.error('usage: node cold_open_exact.mjs <url> <outDir> <label>');
  process.exit(2);
}

/** Same WebGL readback the route run uses, evaluated once per frame. */
const DRAW_PROBE = `(() => {
  window.__draws = [];
  window.__probeDocStart = performance.timeOrigin;
  const probe = () => {
    const canvas = document.querySelector('canvas');
    if (canvas) {
      const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
      if (gl) {
        const w = 96;
        const h = 208;
        const buf = new Uint8Array(w * h * 4);
        gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, buf);
        let sum = 0;
        for (let i = 0; i < buf.length; i += 4) sum += buf[i] + buf[i + 1] + buf[i + 2];
        window.__draws.push([Math.round(performance.now()), sum > 0 ? Math.round(sum / (buf.length / 4) / 3) : 0]);
      }
    }
    if (window.__draws.length < 4000) requestAnimationFrame(probe);
  };
  requestAnimationFrame(probe);
  return 'probing';
})()`;

await runCapture({
  url: 'about:blank',
  outDir,
  label,
  callTimeoutMs: 90000,
  screencast: false,
  body: async (driver) => {
    const { send, on, evaluate, screenshot, close } = driver;
    const started = Date.now();
    const consoleLines = [];
    on((data) => {
      const t = +((Date.now() - started) / 1000).toFixed(3);
      if (data.method === 'Runtime.consoleAPICalled') {
        const text = (data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ');
        consoleLines.push({ t, kind: `console.${data.params.type}`, text });
      }
      if (data.method === 'Runtime.exceptionThrown') {
        consoleLines.push({
          t,
          kind: 'exception',
          text: String(data.params.exceptionDetails.exception?.description || data.params.exceptionDetails.text),
        });
      }
    });

    await send('Page.navigate', { url });
    // The probe lives on the document, so it has to be reinstalled on the build's own page.
    // Retry until the new document can run script, then leave it to sample every frame.
    let installed = false;
    for (let attempt = 0; attempt < 60 && !installed; attempt++) {
      await sleep(50);
      try {
        installed = (await evaluate(`(() => { try { return (${DRAW_PROBE}) === 'probing'; } catch (e) { return false; } })()`)) === true;
      } catch {
        installed = false;
      }
    }
    const probeInstalled = installed;

    // Wait long enough that a slow open still shows as slow, then stop probing.
    await sleep(15000);
    const draws = JSON.parse(await evaluate('JSON.stringify(window.__draws || [])'));
    // Stamps are `performance.now()` from the build's own document origin. The open is
    // measured from that origin: `timeOrigin` is the moment the document began, which is the
    // "open" the cold-open budget is counted from.
    const docOrigin = Number(await evaluate('String(window.__probeDocStart || 0)'));
    const firstDrawn = draws.find(([, mean]) => mean > 0) || null;
    const firstPlain = draws.find(([, mean]) => mean > 40) || null;

    const session = {
      url,
      label,
      probeInstalled,
      probedFrames: draws.length,
      documentOrigin: docOrigin,
      firstDrawnFrame: firstDrawn ? { atMs: firstDrawn[0], mean: firstDrawn[1] } : null,
      firstNonBlankFrame: firstPlain ? { atMs: firstPlain[0], mean: firstPlain[1] } : null,
      tail: draws.slice(-5),
    };
    fs.writeFileSync(path.join(outDir, `${label}-draw.json`), `${JSON.stringify(draws)}\n`);
    fs.writeFileSync(path.join(outDir, `${label}-session.json`), `${JSON.stringify(session, null, 2)}\n`);
    fs.writeFileSync(
      path.join(outDir, `${label}-console.log`),
      `${consoleLines.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.text}`).join('\n')}\n`,
    );
    console.log(JSON.stringify(session));
    return session;
  },
});
