// #557 durability legs — one run against the published release build.
//
// Reproduce from this folder alone:
//   npm install puppeteer-core@23
//   node driver.mjs
//
// The driver only navigates to PUBLISHED_URL. It never builds, exports, or
// serves anything locally, and it edits no repo file: the leg-3 fault is a
// browser-side wrapper over Storage.prototype.setItem.
//
// Each leg is driven through the UI, and the screen is identified from canvas
// pixels before a control is pressed (the game draws to one canvas, so the DOM
// carries no game text). A leg records `not-judged` only when the build never
// reached the state the leg compares.
import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const PUBLISHED_URL = 'https://waigore.github.io/simplechessv2/';
const PUBLISHED_COMMIT = process.env.BUILD_COMMIT || 'c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96';
const PUBLISHED_RUN = process.env.BUILD_RUN || '40118381611';
const STORAGE_KEY = 'simplechessv2.persist.v1';
const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const SETTLE_MS = Number(process.env.SETTLE_MS || 20000);

// Hit targets in CSS px on the 390x844 viewport (see setup.md).
const MODE_PICK = { shared: { x: 195, y: 168 }, puzzle: { x: 231, y: 205 } };
const SHARED_SETUP = { back: { x: 184, y: 324 }, clock: { x: 195, y: 199 } };
// Puzzle-play chrome.
const PUZZLE_PLAY = { leave_stream: { x: 312, y: 78 } };
// "Leave the puzzle stream?" confirm — confirm at left, Cancel at right.
const LEAVE_CONFIRM = { ok: { x: 166, y: 128 } };
const TAP_SETTLE = 3000;

const OUT = HERE;
for (const sub of ['screenshots', 'logs']) fs.mkdirSync(path.join(OUT, sub), { recursive: true });

const startedAt = new Date().toISOString();
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function shoot(page, name) {
  const file = path.join(OUT, 'screenshots', `${name}.png`);
  await page.screenshot({ path: file });
  const buf = fs.readFileSync(file);
  return { path: `screenshots/${name}.png`, bytes: buf.length, md5: crypto.createHash('md5').update(buf).digest('hex') };
}

// The document read the issue names. The screen half is the screenshot plus the console.
async function readDocument(page) {
  return page.evaluate((KEY) => {
    const raw = localStorage.getItem(KEY);
    let doc = null;
    if (raw !== null) { try { doc = JSON.parse(raw); } catch { doc = raw; } }
    const pick = (k) => (doc && doc[k] !== undefined ? doc[k] : null);
    return {
      key_present: raw !== null,
      document: doc,
      player_elo: pick('player_elo'),
      last_mode: pick('last_mode'),
      recent_solved: pick('recent_solved'),
      localStorage_keys: Object.keys(localStorage),
    };
  }, STORAGE_KEY);
}

const attachLog = (page, sink) => {
  page.on('console', (m) => sink.push(`${new Date().toISOString()} [${m.type()}] ${m.text()}`));
  page.on('pageerror', (e) => sink.push(`${new Date().toISOString()} [pageerror] ${e.message}`));
  page.on('requestfailed', (r) => {
    const t = r.failure()?.errorText || '';
    if (!t.includes('ERR_ABORTED')) sink.push(`${new Date().toISOString()} [requestfailed] ${r.url()} :: ${t}`);
  });
  page.on('response', (r) => {
    if (r.status() >= 400) sink.push(`${new Date().toISOString()} [http ${r.status()}] ${r.url()}`);
  });
};

async function openCold(browser, consoleLog) {
  const page = await browser.newPage();
  attachLog(page, consoleLog);
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });
  const t0 = Date.now();
  await page.goto(PUBLISHED_URL, { waitUntil: 'networkidle2', timeout: 90000 });
  await sleep(SETTLE_MS);
  return { page, open_ms: Date.now() - t0 };
}

const tap = async (page, target, settle = TAP_SETTLE) => {
  await page.mouse.click(target.x, target.y);
  await sleep(settle);
};

// Screen identification from canvas pixels. The game draws to one canvas, so
// each screen is told apart by a band only it paints:
//   puzzle play  → the dark board band (top ~60% otherwise blank)
//   shared setup → the seat/clock button rows under the title, no board
//   mode pick    → neither
// Returns the band values so a caller can record what it saw.
async function screenOf(page) {
  const png = await page.screenshot({ encoding: 'base64' });
  return page.evaluate(async (b64) => {
    const img = new Image();
    img.src = 'data:image/png;base64,' + b64;
    await img.decode();
    const c = document.createElement('canvas');
    c.width = img.width; c.height = img.height;
    const g = c.getContext('2d');
    g.drawImage(img, 0, 0);
    const at = (fx, fy) => {
      const d = g.getImageData(Math.round(img.width * fx), Math.round(img.height * fy), 1, 1).data;
      return d[0] + d[1] + d[2];
    };
    // Board band (puzzle play), and the setup button row (shared setup).
    return { board: at(0.5, 0.32), panelRow: at(0.5, 0.185), lowBand: at(0.5, 0.92) };
  }, png);
}

const SCREEN = { PUZZLE: 'puzzle-play', SETUP: 'shared-setup', MODE_PICK: 'mode-pick', UNKNOWN: 'unknown' };

// Classify, never guess. Measured bands on this build:
//   puzzle play  → 0.32 board surround ~92,58,42; 0.92 footer ~92,58,42
//   shared setup → 0.32 cream 247,241,232; 0.92 cream (no board, no footer)
//   mode pick    → 0.32 cream; 0.92 cream
// Shared setup and mode pick agree on the bands, so the setup row at 0.185
// (a bordered button) separates them.
async function classify(page) {
  const b = await screenOf(page);
  const darkBand = b.board < 400 || b.lowBand < 400; // board surround or footer
  const cls = darkBand ? SCREEN.PUZZLE : b.panelRow < 700 ? SCREEN.SETUP : SCREEN.MODE_PICK;
  return { cls, bands: b };
}

// Reach mode pick from wherever the build is, verifiably. Puzzle play asks
// "Leave the puzzle stream?" first, so leaving is a two-step: the control, then
// the confirm. The trail records each class the loop acted on.
async function landOnModePick(page) {
  const trail = [];
  let leaveAsked = false;
  for (let attempt = 0; attempt < 6; attempt += 1) {
    const seen = await classify(page);
    trail.push(seen.cls);
    if (seen.cls === SCREEN.MODE_PICK) return { ok: true, trail, bands: seen.bands };
    if (seen.cls === SCREEN.PUZZLE) {
      await tap(page, leaveAsked ? LEAVE_CONFIRM.ok : PUZZLE_PLAY.leave_stream);
      leaveAsked = !leaveAsked;
    } else if (seen.cls === SCREEN.SETUP) {
      await tap(page, SHARED_SETUP.back);
    } else break;
  }
  return { ok: false, trail, bands: await screenOf(page) };
}

// Silently drops writes to the persist key and counts them (leg 3). A
// browser-side wrapper over Storage.prototype.setItem; `restore` puts the native back.
const INSTALL_WRAPPER = (KEY) => {
  window.__durability = { attempts: 0, dropped: 0, restored: false };
  const native = Storage.prototype.setItem;
  Storage.prototype.setItem = function (k, v) {
    if (k === KEY && window.__durability.restored === false) {
      window.__durability.attempts += 1;
      window.__durability.dropped += 1;
      return; // silently drop: the build's round-trip read-back sees the old value
    }
    return native.call(this, k, v);
  };
  window.__durabilityState = () => ({ ...window.__durability });
  window.__durabilityRestore = () => {
    window.__durability.restored = true;
    Storage.prototype.setItem = native;
  };
};
const wrapperState = (page) => page.evaluate(() => (window.__durabilityState ? window.__durabilityState() : { installed: false }));

// The build's own report on the judged window, minus the missing-asset noise
// this task does not judge.
const JUDGED = /puzzle|persist|save|elo|commit|deal|warning|error/i;
const withoutAssetNoise = (lines) =>
  lines.filter((l) => JUDGED.test(l) && !/game_assets|vorbis|file_access|get_file_as_bytes|variant_utility/.test(l));

const userDataDir = fs.mkdtempSync(path.join(OUT, 'profile-'));
const browser = await puppeteer.launch({
  executablePath: CHROME,
  headless: true,
  userDataDir, // one profile → one origin store across every open and reopen
  args: ['--no-sandbox', '--window-size=390,844'],
});

const legs = [];

try {
  // ---------- Leg 1 — quit/reload ----------
  {
    const consoleLog = [];
    const open = await openCold(browser, consoleLog);
    await landOnModePick(open.page);
    const coldOpenShot = await shoot(open.page, 'leg-1-cold-open-mode-pick');
    const beforeDoc = await readDocument(open.page);

    await tap(open.page, MODE_PICK.puzzle, 5000);
    const puzzleShot = await shoot(open.page, 'leg-1-puzzle-play-before-close');
    const inPuzzleDoc = await readDocument(open.page);
    const dealt = consoleLog.some((l) => /puzzle\.dealt/.test(l));
    const dealFailed = consoleLog.filter((l) => /deal read failed|deal_failed/i.test(l));

    await landOnModePick(open.page);
    const landed = await landOnModePick(open.page);
    // A quit-path screenshot is only recorded when the build is verifiably at
    // mode pick; otherwise the capture would label puzzle play as the quit path.
    const atModePick = await classify(open.page);
    const quitConfirmShot = atModePick.cls === SCREEN.MODE_PICK
      ? await shoot(open.page, 'leg-1-mode-pick-before-quit')
      : null;
    await open.page.close();

    const reopen = await openCold(browser, consoleLog);
    const afterDoc = await readDocument(reopen.page);
    const afterShot = await shoot(reopen.page, 'leg-1-mode-pick-after-reopen');
    await reopen.page.close();

    fs.writeFileSync(path.join(OUT, 'logs', 'leg-1.console.log'), consoleLog.join('\n') + '\n');
    legs.push({
      leg: 1, name: 'quit/reload', open_ms: [open.open_ms, reopen.open_ms],
      cold_open_shot: coldOpenShot, before: beforeDoc, in_puzzle: inPuzzleDoc,
      dealt, deal_failed: dealFailed, puzzle_shot: puzzleShot,
      landed_on_mode_pick: landed, screen_before_quit: atModePick.cls,
      quit_path_screenshot_omitted: quitConfirmShot === null,
      quit_confirm_shot: quitConfirmShot, after: afterDoc, after_shot: afterShot,
      console_lines: consoleLog.length, console_judged: withoutAssetNoise(consoleLog),
    });
  }

  // ---------- Leg 2 — crash ----------
  //
  // The uncommitted mid-session value is a Last-mode selection that never
  // committed. Both mode-pick controls commit on press, so the abandons-able
  // state is the setup screen shown after that commit: a toggle never committed.
  {
    const consoleLog = [];
    const open = await openCold(browser, consoleLog);
    const landed = await landOnModePick(open.page);
    const beforeDoc = await readDocument(open.page);
    await tap(open.page, MODE_PICK.shared); // C1 commits shared, shows Shared setup
    await tap(open.page, SHARED_SETUP.clock, 800); // uncommitted mid-session change
    const abandonment = { screen: 'shared setup', uncommitted_action: 'clock toggle pressed, never committed' };
    const beforeShot = await shoot(open.page, 'leg-2-before-crash');
    const preCrashDoc = await readDocument(open.page);

    let crashed = false;
    try { await open.page.goto('chrome://crash'); } catch { crashed = true; }
    await sleep(1500);
    if (!open.page.isClosed()) {
      try { await open.page.evaluate(() => 1); } catch { crashed = true; }
    }

    const reopen = await openCold(browser, consoleLog);
    const afterDoc = await readDocument(reopen.page);
    const afterShot = await shoot(reopen.page, 'leg-2-mode-pick-after-reopen');
    await reopen.page.close();

    fs.writeFileSync(path.join(OUT, 'logs', 'leg-2.console.log'), consoleLog.join('\n') + '\n');
    legs.push({
      leg: 2, name: 'crash', open_ms: [open.open_ms, reopen.open_ms],
      before: beforeDoc, landed_on_mode_pick: landed, abandonment, crashed,
      pre_crash: preCrashDoc, before_shot: beforeShot, after: afterDoc, after_shot: afterShot,
      console_lines: consoleLog.length, console_judged: withoutAssetNoise(consoleLog),
    });
  }

  // ---------- Leg 3 — faulted session ----------
  //
  // The commit driven *changes* the value, so the dropped write is observable:
  // the wrapper silences setItem, PersistStore._web_set's round-trip still sees
  // the old payload, and `commit` returns false.
  {
    const consoleLog = [];
    const open = await openCold(browser, consoleLog);
    const landed = await landOnModePick(open.page);
    const beforeDoc = await readDocument(open.page);
    const beforeShot = await shoot(open.page, 'leg-3-before-fault');

    await tap(open.page, MODE_PICK.shared);
    await tap(open.page, SHARED_SETUP.back);
    const committedBeforeFault = await readDocument(open.page);

    await open.page.evaluate(INSTALL_WRAPPER, STORAGE_KEY);
    await tap(open.page, MODE_PICK.puzzle); // C2 commits puzzle: a different payload
    const attempted = await wrapperState(open.page);
    const faultShot = await shoot(open.page, 'leg-3-after-fault');
    const duringDoc = await readDocument(open.page);
    const restored = await open.page.evaluate(() => {
      if (!window.__durabilityRestore) return { restored: false };
      window.__durabilityRestore();
      return window.__durabilityState();
    });
    await open.page.close();

    const reopen = await openCold(browser, consoleLog);
    const afterDoc = await readDocument(reopen.page);
    const afterShot = await shoot(reopen.page, 'leg-3-mode-pick-after-reopen');
    await reopen.page.close();

    const failedWriteReported = consoleLog.some((l) => /write failed; prior commit kept/.test(l));
    fs.writeFileSync(path.join(OUT, 'logs', 'leg-3.console.log'), consoleLog.join('\n') + '\n');
    legs.push({
      leg: 3, name: 'faulted session', open_ms: [open.open_ms, reopen.open_ms],
      before: beforeDoc, landed_on_mode_pick: landed, before_shot: beforeShot,
      committed_before_fault: committedBeforeFault, wrapper: attempted,
      failed_write_reported: failedWriteReported, during: duringDoc, restored,
      fault_shot: faultShot, after: afterDoc, after_shot: afterShot,
      console_lines: consoleLog.length, console_judged: withoutAssetNoise(consoleLog),
    });
  }
} finally {
  await browser.close();
  fs.rmSync(userDataDir, { recursive: true, force: true });
}

// pass — the comparison ran and held. fail — it ran and did not hold.
// not-judged — the build never reached the state the leg compares.
const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);

const judge = (leg) => {
  if (leg.leg === 1) {
    if (!leg.before.key_present) return { result: 'not-judged', reason: 'no committed document before the close — no puzzle result could commit (the stream dealt nothing)' };
    if (!leg.dealt) return { result: 'not-judged', reason: 'no puzzle.dealt in the judged window, so no SEQ-puzzle-result-commit ran' };
    return same(leg.before.document, leg.after.document)
      ? { result: 'pass', reason: 'committed document survived the quit/reopen unchanged' }
      : { result: 'fail', reason: 'committed document changed across the quit/reopen' };
  }
  if (leg.leg === 2) {
    if (!leg.crashed) return { result: 'not-judged', reason: 'the renderer did not die — no crash occurred to compare against' };
    if (!leg.after.key_present) return { result: 'fail', reason: 'no document on reopen — the committed values were lost in the crash' };
    if (leg.after.last_mode !== leg.pre_crash.last_mode) {
      return { result: 'fail', reason: `reopen held Last mode ${leg.after.last_mode}, not the last committed ${leg.pre_crash.last_mode}` };
    }
    return { result: 'pass', reason: `renderer killed with the uncommitted ${leg.abandonment.uncommitted_action}; reopen at mode pick kept the last committed Last mode (${leg.after.last_mode}) and Player Elo (${leg.after.player_elo})` };
  }
  const writes = leg.wrapper && leg.wrapper.attempts !== undefined ? leg.wrapper.attempts : 0;
  if (writes === 0) return { result: 'not-judged', reason: 'the wrapper received 0 persist writes — the failed-write path (CTR-persist-document G2) was never reached' };
  if (!leg.failed_write_reported) return { result: 'not-judged', reason: `${writes} write(s) dropped but the build reported no failed write — the round-trip (G2) did not turn it into a failure` };
  if (!same(leg.committed_before_fault.document, leg.during.document)) {
    return { result: 'fail', reason: `${writes} write(s) forced to fail but the prior document changed` };
  }
  return same(leg.during.document, leg.after.document)
    ? { result: 'pass', reason: `${writes} forced write(s); the build reported "write failed; prior commit kept", the prior document stayed intact, and the reopen matched it` }
    : { result: 'fail', reason: 'prior document intact during the fault but changed on reopen' };
};
for (const leg of legs) leg.outcome = judge(leg);

const run = {
  run_id: path.basename(OUT),
  issue: 557,
  started_at: startedAt,
  finished_at: new Date().toISOString(),
  build: {
    url: PUBLISHED_URL, commit: PUBLISHED_COMMIT, web_release_run: PUBLISHED_RUN,
    source: 'published URL', session_id: null,
    session_id_reason: 'the release build strips CMP-playtest-seams (ADR-0004 G2), so it reports no TEL.3 id',
  },
  environment: { browser: 'headless Chrome via puppeteer-core@23', viewport: '390x844 CSS px, DPR 2', settle_ms: SETTLE_MS },
  storage_key: STORAGE_KEY,
  legs,
  screenshot_md5: Object.fromEntries(
    legs.flatMap((l) => [l.cold_open_shot, l.puzzle_shot, l.before_shot, l.fault_shot, l.after_shot].filter(Boolean).map((s) => [s.path, s.md5])),
  ),
};
fs.writeFileSync(path.join(OUT, 'run.json'), JSON.stringify(run, null, 2) + '\n');

console.log(`run ${run.run_id} written to ${OUT}`);
for (const leg of legs) console.log(`leg ${leg.leg} (${leg.name}): ${leg.outcome.result} — ${leg.outcome.reason}`);
