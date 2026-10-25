/**
 * Force a storage write to fail on the published release and record what survives.
 *
 * ADR-0003 *Failed write keeps prior* / quality.md Save durability: "a failed write leaves the
 * previous commit intact".
 *
 * The build writes one document under `simplechessv2.persist.v1` through
 * `Storage.prototype.setItem` (`game/persist_store.gd` `_web_set`). The reading needs three
 * facts in order:
 *
 *   1. a **real prior commit** — the build itself commits `last_mode: shared` when the player
 *      picks Shared game, so the script seats that choice first and reads it back;
 *   2. the forced write **really failed** — `setItem` is then made to throw, and the build's
 *      own `PersistStore: write failed; prior commit kept` error is the confirmation;
 *   3. storage is **unchanged** and play **continues**.
 *
 * Clearing storage would prove nothing about a *failed* write, so the fault is injected as a
 * throw (the quota case the code comments name), never as an erase.
 *
 * Usage:
 *     node forced_write.mjs <url> <outDir> <label>
 *
 * Writes `<label>-forced-write.json`, `<label>-console.log` and `<label>-NN-*.png`.
 *
 * It records; it never judges a row.
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, tap, sleep } from './cdp.mjs';

const [url, outDir, label] = process.argv.slice(2);
if (!url || !outDir || !label) {
  console.error('usage: node forced_write.mjs <url> <outDir> <label>');
  process.exit(2);
}

/** The build's own key (`persist_store.gd` `STORAGE_KEY`). */
const STORAGE_KEY = 'simplechessv2.persist.v1';

const READ_DOC = `(() => {
  const raw = localStorage.getItem(${JSON.stringify(STORAGE_KEY)});
  if (raw === null) return { present: false };
  let doc = null;
  try { doc = JSON.parse(raw); } catch { doc = null; }
  return { present: true, raw, doc };
})()`;

/** The document the build will write next: its own committed doc with `last_mode` changed. */
const SEED_PRIOR_COMMIT = `(() => {
  const KEY = ${JSON.stringify(STORAGE_KEY)};
  const raw = localStorage.getItem(KEY);
  const doc = raw ? JSON.parse(raw) : { version: 1, player_elo: 800, last_mode: 'none', recent_solved: [] };
  doc.last_mode = 'shared';
  localStorage.setItem(KEY, JSON.stringify(doc));
  return { seeded: true, doc };
})()`;

/** Arm the fault: every later setItem throws, the way a full quota would. */
const ARM_FAULT = `(() => {
  window.__fwWrites = 0;
  Storage.prototype.setItem = function () {
    window.__fwWrites++;
    throw new DOMException('QuotaExceededError (forced by #403)', 'QuotaExceededError');
  };
  return { armed: true };
})()`;

const FAULT_STATE = `({ failedWrites: window.__fwWrites || 0 })`;

const MODE_PICK_SHARED = { x: 195, y: 172 };
const MODE_PICK_PUZZLE = { x: 195, y: 204 };

await runCapture({
  url,
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
    try {
      await send('Runtime.enable', {});
    } catch {
      /* already enabled */
    }

    await send('Page.navigate', { url });

    // The page must be the game's own origin before any storage call is legitimate.
    let origin = '';
    for (let attempt = 0; attempt < 80; attempt++) {
      await sleep(250);
      try {
        const href = String(await evaluate('location.href'));
        if (href.startsWith('http')) {
          origin = href;
          break;
        }
      } catch {
        /* document still swapping */
      }
    }
    // Let the build settle its own open, then seat a real prior commit it would make itself.
    await sleep(9000);
    const opened = await evaluate(READ_DOC);
    await screenshot(`${label}-01-opened`);
    const seeded = await evaluate(SEED_PRIOR_COMMIT);
    const before = await evaluate(READ_DOC);
    await screenshot(`${label}-02-prior-commit`);

    // Fault in, then the build's own next write: choosing Puzzle stream changes `last_mode`.
    const armed = await evaluate(ARM_FAULT);
    await tap(send, MODE_PICK_PUZZLE.x, MODE_PICK_PUZZLE.y);
    await sleep(4000);
    const fault = await evaluate(FAULT_STATE);
    const after = await evaluate(READ_DOC);
    await screenshot(`${label}-03-after-failed-write`);
    await sleep(2500);
    await screenshot(`${label}-04-play-continued`);
    await close();

    const record = {
      url,
      label,
      origin,
      storageKey: STORAGE_KEY,
      opened,
      seeded,
      armed,
      before,
      after,
      fault,
      unchanged: before.raw === after.raw,
      beforeLastMode: before.doc ? before.doc.last_mode : null,
      afterLastMode: after.doc ? after.doc.last_mode : null,
      writeFailedLine: consoleLines.filter((line) => /PersistStore: write failed; prior commit kept/.test(line.text)),
    };
    fs.writeFileSync(path.join(outDir, `${label}-forced-write.json`), `${JSON.stringify(record, null, 2)}\n`);
    fs.writeFileSync(
      path.join(outDir, `${label}-console.log`),
      `${consoleLines.map((line) => `${line.t.toFixed(3)}s ${line.kind} ${line.text}`).join('\n')}\n`,
    );
    console.log(JSON.stringify({
      origin,
      openedLastMode: opened.doc ? opened.doc.last_mode : null,
      beforeLastMode: record.beforeLastMode,
      afterLastMode: record.afterLastMode,
      fault,
      unchanged: record.unchanged,
      writeFailedLine: record.writeFailedLine.map((line) => `${line.t}s ${line.text}`),
    }, null, 2));
    return record;
  },
});
