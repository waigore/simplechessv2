/**
 * Cold-open the published release and record when it first paints, then walk it to a Shared
 * board — one run, one screencast, no assumption that a tap landed.
 *
 * Written for #403 for the cold-open rows (ADR-0001 *Cold open ≤3 s*, ADR-0003 *Cold open
 * includes sync read*) and the move rows (ADR-0001 *Move hitch ≤1 frame*, ADR-0002 *No
 * move-path hitch*): the same sitting has to show *when the first screen painted*, *which
 * screen it was*, and *that a move was taken on it*. The published build takes several
 * seconds to its first frame, so the route taps are each preceded by a wait long enough for
 * the build to be idle, and every mark records the WebGL readback so the manifest can say
 * which frame carried which screen.
 *
 * `analyse.py` scores the captures (first painted frame, per-square occupancy, header text).
 *
 * Usage:
 *     node capture_open_route.mjs <url> <outDir> <label> [--route] [--move=e2:e4]
 *
 * Writes `<label>-session.json` (marks, readbacks, frame windows), `<label>-frames.json`,
 * `<label>-console.log`, `<label>-NN-<mark>.png` and `cast/<label>-cast-NNN.jpg`.
 *
 * It records; it never judges a row.
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, tap, sleep, frameSummary, SAMPLER } from './cdp.mjs';

const args = process.argv.slice(2);
const positional = args.filter((arg) => !arg.startsWith('--'));
const named = Object.fromEntries(
  args.filter((arg) => arg.startsWith('--') && arg.includes('=')).map((arg) => {
    const [key, value] = arg.slice(2).split('=');
    return [key, value];
  }),
);
const flags = new Set(args.filter((arg) => arg.startsWith('--') && !arg.includes('=')));
const [url, outDir, label] = positional;
if (!url || !outDir || !label) {
  console.error('usage: node capture_open_route.mjs <url> <outDir> <label> [--route] [--move=e2:e4]');
  process.exit(2);
}

const withRoute = flags.has('--route');
/** Board square centres at 390×844 CSS px, read off the published build's screenshots. */
const BOARD = { fileA: 59.5, row8: 399.5, step: 38.75 };
const squarePoint = (square) => ({
  x: Math.round(BOARD.fileA + (square.charCodeAt(0) - 97) * BOARD.step),
  y: Math.round(BOARD.row8 + (8 - Number(square[1])) * BOARD.step),
});
const MODE_PICK_SHARED = { x: 195, y: 172 };
const SETUP_START = { x: 120, y: 312 };
const [fromSquare, toSquare] = (named.move || 'e2:e4').split(':');
const CAST_SUBDIR = 'cast';

/** The WebGL readback the build's own canvas gives: a cheap "is there a frame yet" probe. */
const READBACK = `(() => {
  const canvas = document.querySelector('canvas');
  if (!canvas) return { drawn: false, why: 'no canvas' };
  const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
  if (!gl) return { drawn: false, why: 'no gl' };
  const w = 96;
  const h = 208;
  const buf = new Uint8Array(w * h * 4);
  gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, buf);
  let sum = 0;
  for (let i = 0; i < buf.length; i += 4) sum += buf[i] + buf[i + 1] + buf[i + 2];
  return { drawn: sum > 0, mean: +(sum / (buf.length / 4) / 3).toFixed(1), size: [canvas.width, canvas.height] };
})()`;

await runCapture({
  url,
  outDir,
  label,
  callTimeoutMs: 90000,
  // The screencast only follows a route that will be shown frame by frame; a cold-open
  // timing run needs the frame timeline, not a JPEG stream that competes with it.
  screencast: withRoute,
  body: async (driver) => {
    const { send, on, evaluate, screenshot, close, castFrames } = driver;
    const started = Date.now();
    const marks = [];
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
    await sleep(120);
    if (withRoute) {
      await send('Page.startScreencast', { format: 'jpeg', quality: 30, maxWidth: 390, maxHeight: 844, everyNthFrame: 1 });
    }
    await sleep(150);
    await evaluate(SAMPLER);

    const mark = async (tag, extra = {}) => {
      const entry = {
        tag,
        atMs: Date.now() - started,
        readback: await evaluate(READBACK),
        shot: await screenshot(tag),
        castSoFar: castFrames.length,
        ...extra,
      };
      marks.push(entry);
      return entry;
    };

    // Poll for the first painted frame; the readback says when the build has one.
    const pollStart = Date.now();
    let firstDraw = null;
    for (let attempt = 0; attempt < 160; attempt++) {
      await sleep(250);
      const readback = await evaluate(READBACK);
      if (readback && readback.drawn) {
        firstDraw = { atMs: Date.now() - started, readback };
        break;
      }
    }
    await mark('first-painted', { firstDraw });

    if (withRoute) {
      await sleep(2500);
      await mark('mode-pick');
      await tap(send, MODE_PICK_SHARED.x, MODE_PICK_SHARED.y);
      await sleep(2500);
      await mark('shared-setup');
      await tap(send, SETUP_START.x, SETUP_START.y);
      await sleep(4000);
      const board = await mark('board');
      const onBoard = board.readback.drawn && board.readback.mean < 220; // a board, not a cream panel
      if (onBoard) {
        await sleep(2000);
        const from = squarePoint(fromSquare);
        const to = squarePoint(toSquare);
        await mark('pre-select', { square: fromSquare, point: from });
        const selectAt = Date.now() - started;
        await tap(send, from.x, from.y);
        await sleep(900);
        await mark('selected', { square: fromSquare, point: from });
        await sleep(1500);
        const moveAt = Date.now() - started;
        await tap(send, to.x, to.y);
        await sleep(250);
        await mark('move+250');
        await sleep(250);
        await mark('move+500');
        await sleep(1500);
        await mark('move+2000');
        await sleep(3000);
        await mark('move+5000', { selectAt, moveAt });
      }
    }
    await close();

    // Keep the frames around the measured moments; the route's loading frames go.
    const castFiles = fs.readdirSync(outDir).filter((name) => name.startsWith(`${label}-cast-`)).sort();
    const keepFrom = Math.max(0, castFiles.length - 120);
    fs.mkdirSync(path.join(outDir, CAST_SUBDIR), { recursive: true });
    castFiles.forEach((name, index) => {
      const target = path.join(outDir, CAST_SUBDIR, name);
      if (index >= keepFrom) fs.renameSync(path.join(outDir, name), target);
      else fs.rmSync(path.join(outDir, name), { force: true });
    });

    const frames = JSON.parse(await evaluate('JSON.stringify(window.__frames || [])'));
    const moveMark = marks.find((entry) => entry.tag === 'move+5000');
    const session = {
      url,
      label,
      route: withRoute,
      firstDraw,
      firstSampledFrameMs: frames.length ? +frames[0].toFixed(1) : null,
      overall: frameSummary(frames),
      moveWindow: moveMark
        ? frameSummary(frames.filter((ts) => ts >= moveMark.moveAt && ts <= moveMark.moveAt + 2000))
        : null,
      marks,
      screencast: { frames: castFrames.length, kept: castFiles.length - keepFrom },
    };
    fs.writeFileSync(path.join(outDir, `${label}-session.json`), `${JSON.stringify(session, null, 2)}\n`);
    fs.writeFileSync(path.join(outDir, `${label}-frames.json`), `${JSON.stringify(frames)}\n`);
    fs.writeFileSync(
      path.join(outDir, `${label}-console.log`),
      `${consoleLines.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.text}`).join('\n')}\n`,
    );
    return session;
  },
});
