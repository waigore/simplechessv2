/**
 * Record a Shared-game move on the published release, and the frame timeline around it.
 *
 * Written for #403. The rows it feeds are ADR-0001 *Move hitch ≤1 frame* and ADR-0002
 * *No move-path hitch* (quality.md Performance: frame-time capture during piece movement)
 * — the move has to be real, so this drives the shipped build's own pointer path: tap the
 * piece's square, then the destination square. A legal place turns the header from
 * `White to move` to `Black to move`, which is what `analyse.mjs` reads off the screenshots.
 *
 * Usage:
 * `--no-cast` drops the screencast: a frame timeline read while a JPEG stream competes for the
 * same frames is not a clean reading of the move window, so the measured run goes without it.
 *
 *     node play_move.mjs <url> <outDir> <label> [--move=e2:e4]
 *
 * Writes `<label>-timeline.json`, `<label>-frames.json`, `<label>-console.log`,
 * `<label>-NN-*.png`, `move-cast/` (the screencast frames around the move, plus
 * `<label>-cast-index.json`).
 *
 * It records; it never judges a row.
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, installHook, tap, sleep, frameSummary, SAMPLER } from './cdp.mjs';
import { SCREEN_HOOK } from './screen_hook.mjs';

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
  console.error('usage: node play_move.mjs <url> <outDir> <label> [--move=e2:e4] [--no-cast]');
  process.exit(2);
}

/** Board square centres at 390×844 CSS px, read off the published build's screenshots. */
const BOARD = { fileA: 59.5, row8: 399.5, step: 38.75 };
const squarePoint = (square) => ({
  x: Math.round(BOARD.fileA + (square.charCodeAt(0) - 97) * BOARD.step),
  y: Math.round(BOARD.row8 + (8 - Number(square[1])) * BOARD.step),
});

/** `Shared game` on the mode pick, and `Start` on the shared setup panel. */
const MODE_PICK_SHARED = { x: 195, y: 172 };
const SETUP_START = { x: 120, y: 312 };

const [fromSquare, toSquare] = (named.move || 'e2:e4').split(':');
/** Where the kept screencast frames go: `move-cast/`, so a run's top level stays readable. */
const CAST_SUBDIR = 'move-cast';

await runCapture({
  url,
  outDir,
  label,
  // A measured move window is read without the screencast competing for the frame budget.
  screencast: !flags.has('--no-cast'),
  body: async (driver) => {
    const { send, on, evaluate, screenshot, close, castFrames } = driver;
    const started = Date.now();
    const marks = [];
    const console_ = [];
    on((data) => {
      const t = +((Date.now() - started) / 1000).toFixed(3);
      if (data.method === 'Runtime.consoleAPICalled') {
        const text = (data.params.args || []).map((a) => a.value ?? a.description ?? a.type).join(' ');
        console_.push({ t, kind: `console.${data.params.type}`, text });
      }
      if (data.method === 'Runtime.exceptionThrown') {
        console_.push({
          t,
          kind: 'exception',
          text: String(data.params.exceptionDetails.exception?.description || data.params.exceptionDetails.text),
        });
      }
    });

    await installHook(send, SCREEN_HOOK);
    const screens = async () => {
      try {
        return JSON.parse(await evaluate('JSON.stringify(window.__screens || {})'));
      } catch {
        return {};
      }
    };

    // The clock every mark and frame window is measured on: navigation start. Screencast
    // starts just after the request, so the loading screen is in the stream too.
    await send('Page.navigate', { url });
    await sleep(100);
    await send('Page.startScreencast', { format: 'jpeg', quality: 40, maxWidth: 390, maxHeight: 844, everyNthFrame: 1 })
      .catch(() => {});
    await sleep(150);
    await evaluate(SAMPLER);

    const mark = async (tag, extra = {}) => {
      const entry = {
        tag,
        atMs: Date.now() - started,
        page: await screens(),
        shot: await screenshot(tag),
        castSoFar: castFrames.length,
        ...extra,
      };
      marks.push(entry);
      return entry;
    };

    // Cold open, then route: mode pick → Shared game setup → board. The waits are generous
    // because the published build takes ~4 s to its first painted frame on this machine.
    await sleep(8000);
    await mark('mode-pick');
    await tap(send, MODE_PICK_SHARED.x, MODE_PICK_SHARED.y);
    await sleep(2500);
    await mark('shared-setup');
    await tap(send, SETUP_START.x, SETUP_START.y);
    await sleep(3000);
    await mark('board');

    // Settle, then the move: the piece's square, a confirmed press, the destination.
    await sleep(2000);
    const from = squarePoint(fromSquare);
    const to = squarePoint(toSquare);
    await mark('pre-select', { square: fromSquare, point: from });
    const selectAt = Date.now() - started;
    await tap(send, from.x, from.y);
    await sleep(900);
    await mark('selected', { square: fromSquare, point: from, touchSeen: (await screens()).touches });
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
    await mark('move+5000');
    await close();

    // The frame timeline is the reading; the screencast exists to show it, so only the
    // move window's frames are kept (a whole route is ~250 JPEGs and says nothing extra).
    const castFiles = fs.existsSync(outDir)
      ? fs.readdirSync(outDir).filter((name) => name.startsWith(`${label}-cast-`)).sort()
      : [];
    const castKeep = new Set(castFiles.slice(Math.max(0, castFiles.length - 80)));
    if (castKeep.size) fs.mkdirSync(path.join(outDir, CAST_SUBDIR), { recursive: true });
    for (const name of castFiles) {
      if (castKeep.has(name)) fs.renameSync(path.join(outDir, name), path.join(outDir, CAST_SUBDIR, name));
      else fs.rmSync(path.join(outDir, name), { force: true });
    }
    if (castKeep.size) fs.writeFileSync(
      path.join(outDir, CAST_SUBDIR, `${label}-cast-index.json`),
      `${JSON.stringify({ kept: [...castKeep], of: castFiles.length, moveAtMs: moveAt }, null, 2)}\n`,
    );

    const frames = JSON.parse(await evaluate('JSON.stringify(window.__frames || [])'));
    const windowOf = (fromMs, toMs) => frameSummary(frames.filter((ts) => ts >= fromMs && ts <= toMs));
    const timeline = {
      url,
      label,
      move: `${fromSquare}${toSquare}`,
      selectAtMs: selectAt,
      moveAtMs: moveAt,
      page: await screens(),
      windows: {
        idle: windowOf(moveAt - 1200, moveAt - 50),
        'move+0..1000': windowOf(moveAt, moveAt + 1000),
        'move+0..2000': windowOf(moveAt, moveAt + 2000),
        moveAll: windowOf(moveAt - 50, moveAt + 5000),
      },
      overall: frameSummary(frames),
      marks,
      screencastFrames: castFrames.length,
    };

    fs.writeFileSync(path.join(outDir, `${label}-timeline.json`), `${JSON.stringify(timeline, null, 2)}\n`);
    fs.writeFileSync(path.join(outDir, `${label}-frames.json`), `${JSON.stringify(frames)}\n`);
    fs.writeFileSync(
      path.join(outDir, `${label}-console.log`),
      `${console_.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.text}`).join('\n')}\n`,
    );
    return timeline;
  },
});
