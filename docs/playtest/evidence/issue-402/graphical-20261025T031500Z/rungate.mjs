// #402 gate readings on the PUBLISHED release build (no seams), final driver.
// Entry path verified on this build: Enter activates the focused mode-pick row; the
// shared-setup Start button is then clicked at its gold fill. Every transition is
// verified from a screenshot before continuing.
// Usage: node rungate.mjs <url> <outDir> <label> [block]
//   block: all | load | loc | dur | perf | board
import fs from 'node:fs';
import { openBrowser, sleep } from './drive.mjs';
import { inkBoxes, goldRing, boardGrid } from './locator.mjs';

const [url, outDir, label, blockArg] = process.argv.slice(2);
const block = blockArg || 'all';
const SAMPLER = `(() => { window.__frames = []; const tick = (ts) => { window.__frames.push(ts); if (window.__frames.length < 200000) requestAnimationFrame(tick); }; requestAnimationFrame(tick); return 'sampling'; })()`;
const q = (a, p) => (a.length ? a[Math.min(a.length - 1, Math.floor(p * a.length))] : null);
const sum = (a) => { const s = a.slice().sort((x, y) => x - y); return { n: s.length, p50: q(s, 0.5), p95: q(s, 0.95), max: s.at(-1) ?? null, over16_7: s.filter((d) => d > 16.7).length, over33_4: s.filter((d) => d > 33.4).length }; };
const out = { url, label, block, load: [], localization: [], durability: {}, recovery: {}, perf: [], board: {} };
const file = `${outDir}/logs/${label}-rungate-${block}.json`;
const save = () => fs.writeFileSync(file, JSON.stringify(out, null, 2));

const isPlay = (png) => { try { return boardGrid(png).squareCss > 30; } catch { return false; } };
const wideRows = (png) => inkBoxes(png).filter((x) => x.w / 2 > 120).sort((a, c) => a.css.top - c.css.top);

const enterPlay = async (b, tag, navigate = true) => {
  if (navigate) await b.goto(url, 8000);
  await b.shot(`${tag}-1-mode-pick`);
  await b.key('Enter', 13);
  await sleep(1200);
  const setup = await b.shot(`${tag}-2-shared-setup`);
  const gold = goldRing(setup);
  if (!gold) return { ok: false, shot: setup };
  await b.click(gold.css.centreX, gold.css.centreY);
  await sleep(1800);
  const play = await b.shot(`${tag}-3-shared-play`);
  return { ok: isPlay(play), shot: play, gold };
};
const enterPuzzle = async (b, tag) => {
  await b.goto(url, 8000);
  const pick = await b.shot(`${tag}-1-mode-pick`);
  const rows = wideRows(pick);
  if (rows.length < 2) return { ok: false };
  await b.click(rows[1].css.x, rows[1].css.y);
  await sleep(1800);
  const s = await b.shot(`${tag}-2-puzzle-stream`);
  return { ok: !isPlay(s) && inkBoxes(s).length > 2, shot: s };
};

// ---------- A. Load ----------
if (block === 'all' || block === 'load') {
  for (let i = 1; i <= 3; i++) {
    const b = await openBrowser({ url, outDir, label: `A${i}` });
    await b.send('Network.enable');
    await b.send('Network.setCacheDisabled', { cacheDisabled: true });
    const t0 = Date.now();
    await b.send('Page.navigate', { url });
    await sleep(9000);
    const shot = await b.shot('mode-pick');
    const nav = JSON.parse(await b.evaluate(`(() => { const n = performance.getEntriesByType('navigation')[0]; const p = performance.getEntriesByType('paint').map(e => [e.name, Math.round(e.startTime)]); return JSON.stringify({ responseEnd: n ? Math.round(n.responseEnd) : null, domContentLoaded: n ? Math.round(n.domContentLoadedEventEnd) : null, loadEvent: n ? Math.round(n.loadEventEnd) : null, paints: p }); })()`));
    // Is the mode-pick card actually painted by 9 s?
    const boxes = inkBoxes(shot).filter((x) => x.css.left > 60 && x.css.left < 340 && x.css.top < 420);
    out.load.push({ run: i, at9s: Date.now() - t0, nav, modePickPaintedAt9s: boxes.length >= 4, shot: shot.split('/').pop() });
    save();
    await b.writeLogs(`load${i}`);
    await b.close();
  }
}

// ---------- B. Localization ----------
if (block === 'all' || block === 'loc') {
  // Locale is chosen with the mode-pick control; clicking it once per step moves
  // en -> zh-Hant -> ja. Each step is verified by the control label changing.
  const bottomSig = (png) => inkBoxes(png).filter((x) => x.css.top > 330).map((x) => Math.round(x.w / 2)).join(',');
  for (const [idx, loc] of ['en', 'zh-Hant', 'ja'].entries()) {
    const b = await openBrowser({ url, outDir, label: `B-${loc}` });
    await b.goto(url, 8000);
    for (let step = 0; step < idx; step++) {
      let before = bottomSig(await b.shot('cycle-before'));
      for (let attempt = 0; attempt < 4; attempt++) {
        const pick = await b.shot('cycle-pick');
        const bottom = inkBoxes(pick).filter((x) => x.css.top > 330).sort((a, c) => a.css.top - c.css.top);
        const btn = bottom[bottom.length - 1];
        if (!btn) break;
        await b.click(btn.css.x, btn.css.y);
        await sleep(1200);
        const after = bottomSig(await b.shot('cycle-after'));
        if (after !== before) break;
        before = after;
      }
    }
    await b.goto(url, 6000);
    await b.shot(`${loc}-1-mode-pick`);
    await b.key('Enter', 13);
    await sleep(1200);
    const setup = await b.shot(`${loc}-2-shared-setup`);
    const gold = goldRing(setup);
    let playOk = false;
    if (gold) {
      await b.click(gold.css.centreX, gold.css.centreY);
      await sleep(1800);
      playOk = isPlay(await b.shot(`${loc}-3-shared-play`));
    }
    await b.goto(url, 6000);
    const pick2 = await b.shot(`${loc}-4-mode-pick`);
    const rows2 = wideRows(pick2);
    let puzzleOk = false;
    if (rows2.length > 1) {
      await b.click(rows2[1].css.x, rows2[1].css.y);
      await sleep(1800);
      puzzleOk = !isPlay(await b.shot(`${loc}-5-puzzle-stream`));
    }
    out.localization.push({ locale: loc, sharedSetup: !!gold, sharedPlay: playOk, puzzleStream: puzzleOk });
    save();
    await b.writeLogs(`loc-${loc}`);
    await b.close();
  }
}

// ---------- C. Durability + recovery ----------
if (block === 'all' || block === 'dur') {
  const b = await openBrowser({ url, outDir, label: 'C' });
  await b.goto(url, 8000);
  const read = async () => JSON.parse(await b.evaluate('JSON.stringify(Object.fromEntries(Object.entries(localStorage)))'));
  out.durability.before = await read();
  const puzzle = await enterPuzzle(b, 'c');
  out.durability.afterPuzzleOpen = await read();
  await b.goto(url, 7000);
  out.durability.afterReload = await read();
  await b.shot('c-reload-mode-pick');
  await b.evaluate(`(() => { window.__origSetItem = Storage.prototype.setItem; Storage.prototype.setItem = function () { throw new Error('forced write failure (#402 evidence)'); }; return 'patched'; })()`);
  await b.key('Enter', 13);            // activate the focused mode row -> attempts a commit
  await sleep(1500);
  await b.shot('c-after-failed-write-attempt');
  await b.evaluate(`(() => { Storage.prototype.setItem = window.__origSetItem; return 'restored'; })()`);
  out.durability.afterFailedWrite = await read();
  save();
  await b.writeLogs('durability');
  const profile = b.profile;
  await Promise.race([b.send('Page.crash').catch(() => {}), sleep(4000)]);
  out.recovery.crashed = true;
  await b.close({ keepProfile: true });
  const b2 = await openBrowser({ url, outDir, label: 'C2', profile });
  await b2.goto(url, 8000);
  const reopen = await b2.shot('c-reopen-after-crash');
  out.recovery.afterReopen = JSON.parse(await b2.evaluate('JSON.stringify(Object.fromEntries(Object.entries(localStorage)))'));
  out.recovery.reopenedAtModePick = inkBoxes(reopen).filter((x) => x.css.left > 60 && x.css.left < 340 && x.css.top < 420).length >= 4;
  save();
  await b2.writeLogs('recovery');
  await b2.close();
}

// ---------- D. Performance ----------
if (block === 'all' || block === 'perf') {
  for (let r = 1; r <= 2; r++) {
    const b = await openBrowser({ url, outDir, label: `D${r}` });
    await b.goto(url, 8000);
    await b.evaluate(SAMPLER);
    const play = await enterPlay(b, 'd', false);
    if (!play.ok) { out.perf.push({ repeat: r, error: 'shared play not reached' }); save(); await b.close(); continue; }
    const grid = boardGrid(play.shot);
    const P = (n) => { const f = n.charCodeAt(0) - 97, rk = Number(n[1]); return { x: grid.css.left + grid.squareCss * (f + 0.5), y: grid.css.top + grid.squareCss * (8 - rk + 0.5) }; };
    await sleep(1200);
    const idleMark = await b.evaluate('performance.now()');
    await sleep(1500);
    const moveMark = await b.evaluate('performance.now()');
    await b.tap(P('e2').x, 640);
    await b.tap(P('e4').x, P('e4').y);
    await sleep(1600);
    const after = await b.shot('d-4-after-move');
    const frames = JSON.parse(await b.evaluate('JSON.stringify(window.__frames || [])'));
    const deltas = frames.slice(1).map((ts, i) => ({ ts, d: +(ts - frames[i]).toFixed(1) }));
    const idle = deltas.filter((x) => x.ts >= idleMark && x.ts <= idleMark + 1500).map((x) => x.d);
    const move = deltas.filter((x) => x.ts >= moveMark - 200 && x.ts <= moveMark + 1400).map((x) => x.d);
    out.perf.push({ repeat: r, shot: after.split('/').pop(), idle: sum(idle), move: sum(move), whole: sum(deltas.map((x) => x.d)) });
    save();
    await b.writeLogs('perf');
    await b.close();
  }
}

// ---------- E. Board mapping ----------
if (block === 'all' || block === 'board') {
  const b = await openBrowser({ url, outDir, label: 'E' });
  const play = await enterPlay(b, 'e');
  if (play.ok) {
    const grid = boardGrid(play.shot);
    const P = (n) => { const f = n.charCodeAt(0) - 97, rk = Number(n[1]); return { x: grid.css.left + grid.squareCss * (f + 0.5), y: grid.css.top + grid.squareCss * (8 - rk + 0.5) }; };
    out.board.paintedE1 = P('e1');
    out.board.paintedE2 = P('e2');
    await b.tap(P('e2').x, P('e2').y);
    out.board.ringAfterVisibleE2Tap = goldRing(await b.shot('e-4-tap-visible-e2'))?.css ?? null;
    await b.tap(P('e2').x, P('e2').y);
    await b.tap(P('e2').x, 640);
    out.board.ringAfterY640Tap = goldRing(await b.shot('e-5-tap-y640'))?.css ?? null;
    await b.tap(P('e4').x, P('e4').y);
    await sleep(900);
    await b.shot('e-6-after-visible-e4-tap');
  }
  save();
  await b.writeLogs('board');
  await b.close();
}

save();
console.log(JSON.stringify(out, null, 2));
