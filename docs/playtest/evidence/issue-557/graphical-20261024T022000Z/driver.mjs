// #557 durability legs — one run against the published release build.
//
// Reproduce from this folder, with nothing else checked out:
//   npm install puppeteer-core@23
//   node driver.mjs 20000
//
// Every artifact this run records is written by this process: the console
// logs, the screenshots, `run.json`, and the stdin transcript the browser
// store wrapper keeps. The driver only ever navigates to PUBLISHED_URL; it
// never builds, exports, or serves anything locally, and it reads no repo
// code (AC7: no game/ edit; the leg-3 fault is a browser-side wrapper).
import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const PUBLISHED_URL = 'https://waigore.github.io/simplechessv2/';
const PUBLISHED_COMMIT = process.env.BUILD_COMMIT || 'fb1e57e3a07a573ec2f5c08a1bb24e22c43d07c1';
const PUBLISHED_RUN = process.env.BUILD_RUN || '40053375882';
const STORAGE_KEY = 'simplechessv2.persist.v1';
const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const SETTLE_MS = Number(process.argv[2] || 20000);

const OUT = HERE;
fs.mkdirSync(path.join(OUT, 'screenshots'), { recursive: true });
fs.mkdirSync(path.join(OUT, 'logs'), { recursive: true });

const runId = new Date().toISOString().replace(/[-:]/g, '').replace(/\.\d+Z$/, 'Z');
const startedAt = new Date().toISOString();
const legs = [];

// ---- helpers --------------------------------------------------------------

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function attachLog(page, sink) {
  page.on('console', (m) => sink.push(`${new Date().toISOString()} [${m.type()}] ${m.text()}`));
  page.on('pageerror', (e) => sink.push(`${new Date().toISOString()} [pageerror] ${e.message}`));
  page.on('requestfailed', (r) => {
    const t = r.failure()?.errorText || '';
    if (!t.includes('ERR_ABORTED')) sink.push(`${new Date().toISOString()} [requestfailed] ${r.url()} :: ${t}`);
  });
  page.on('response', (r) => {
    if (r.status() >= 400 && r.url().startsWith(PUBLISHED_URL)) {
      sink.push(`${new Date().toISOString()} [http ${r.status()}] ${r.url()}`);
    }
  });
}

// The document read the issue names, plus the screen the build is showing.
// Godot renders into one canvas, so the DOM carries no screen text; the
// screen half is the screenshot plus the console's stage errors.
async function readDocument(page) {
  return page.evaluate((KEY) => {
    const raw = localStorage.getItem(KEY);
    let doc = null;
    if (raw !== null) { try { doc = JSON.parse(raw); } catch { doc = raw; } }
    return {
      key_present: raw !== null,
      document: doc,
      localStorage_keys: Object.keys(localStorage),
      body_text_length: (document.body?.innerText || '').trim().length,
      canvas_count: document.querySelectorAll('canvas').length,
    };
  }, STORAGE_KEY);
}

async function shoot(page, name) {
  const file = path.join(OUT, 'screenshots', `${name}.png`);
  await page.screenshot({ path: file });
  const buf = fs.readFileSync(file);
  return { path: `screenshots/${name}.png`, bytes: buf.length, md5: crypto.createHash('md5').update(buf).digest('hex') };
}

async function openCold(browser, console_) {
  const page = await browser.newPage();
  attachLog(page, console_); // before the first navigation, or the boot log is missed
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });
  const t0 = Date.now();
  await page.goto(PUBLISHED_URL, { waitUntil: 'networkidle2', timeout: 60000 });
  await sleep(SETTLE_MS);
  return { page, console_, open_ms: Date.now() - t0 };
}

// Silently drops writes to the persist key and counts them (leg 3). It is a
// browser-side wrapper over Storage.prototype.setItem; nothing in the build
// knows about it, and `restore` puts the native method back.
const INSTALL_WRAPPER = (KEY) => {
  window.__durability = { attempts: 0, dropped: 0, other_writes: 0, restored: false };
  const native = Storage.prototype.setItem;
  Storage.prototype.setItem = function (k, v) {
    if (k === KEY) {
      window.__durability.attempts += 1;
      if (window.__durability.restored === false) {
        window.__durability.dropped += 1;
        return; // silently drop: the build's round-trip read-back sees the old value
      }
    } else {
      window.__durability.other_writes += 1;
    }
    return native.call(this, k, v);
  };
  window.__durabilityState = () => ({ ...window.__durability });
  window.__durabilityRestore = () => { window.__durability.restored = true; Storage.prototype.setItem = native; };
};

// ---- browser --------------------------------------------------------------

const userDataDir = fs.mkdtempSync(path.join(OUT, 'profile-'));
const browser = await puppeteer.launch({
  executablePath: CHROME,
  headless: true,
  userDataDir, // one profile → one origin store across every open and reopen
  args: ['--no-sandbox', '--window-size=390,844'],
});

let legIndex = 1;

try {
  // ---------- Leg 1 — quit/reload ----------
  {
    const console_ = [];
    const open = await openCold(browser, console_);
    const before = await readDocument(open.page);
    const beforeShot = await shoot(open.page, 'leg-1-before-close');
    // A puzzle result can only commit after a puzzle is dealt. Report what the
    // build did instead of assuming a commit happened.
    await open.page.close();
    const reopen = await openCold(browser, console_);
    const after = await readDocument(reopen.page);
    const afterShot = await shoot(reopen.page, 'leg-1-after-reopen');
    fs.writeFileSync(path.join(OUT, 'logs', 'leg-1.console.log'), console_.join('\n') + '\n');
    legs.push({ leg: 1, name: 'quit/reload', open_ms: [open.open_ms, reopen.open_ms], before, beforeShot, after, afterShot, console_lines: console_.length });
    await reopen.page.close();
    legIndex = 2;
  }

  // ---------- Leg 2 — crash ----------
  {
    const console_ = [];
    const open = await openCold(browser, console_);
    const before = await readDocument(open.page);
    const beforeShot = await shoot(open.page, 'leg-2-before-crash');
    try { await open.page.goto('chrome://crash'); } catch { /* the renderer dies under us */ }
    await sleep(1500);
    const reopen = await openCold(browser, console_);
    const after = await readDocument(reopen.page);
    const afterShot = await shoot(reopen.page, 'leg-2-after-reopen');
    fs.writeFileSync(path.join(OUT, 'logs', 'leg-2.console.log'), console_.join('\n') + '\n');
    legs.push({ leg: 2, name: 'crash', open_ms: [open.open_ms, reopen.open_ms], before, beforeShot, after, afterShot, console_lines: console_.length });
    await reopen.page.close();
    legIndex = 3;
  }

  // ---------- Leg 3 — faulted session ----------
  {
    const console_ = [];
    const open = await openCold(browser, console_);
    const before = await readDocument(open.page);
    const beforeShot = await shoot(open.page, 'leg-3-before-fault');
    await open.page.evaluateOnNewDocument(INSTALL_WRAPPER, STORAGE_KEY);
    await open.page.evaluate(INSTALL_WRAPPER, STORAGE_KEY);
    // Drive the commit if a screen exists to drive; otherwise the window is
    // the honest measurement of "no write was attempted".
    await sleep(SETTLE_MS);
    const during = await open.page.evaluate(() => (window.__durabilityState ? window.__durabilityState() : { installed: false }));
    const faultShot = await shoot(open.page, 'leg-3-after-fault');
    const duringDoc = await readDocument(open.page);
    const restored = await open.page.evaluate(() => (window.__durabilityRestore ? (window.__durabilityRestore(), window.__durabilityState()) : { restored: false }));
    await open.page.close();
    const reopen = await openCold(browser, console_);
    const after = await readDocument(reopen.page);
    const afterShot = await shoot(reopen.page, 'leg-3-after-reopen');
    fs.writeFileSync(path.join(OUT, 'logs', 'leg-3.console.log'), console_.join('\n') + '\n');
    legs.push({ leg: 3, name: 'faulted session', open_ms: [open.open_ms, reopen.open_ms], before, beforeShot, during, duringDoc, restored, faultShot, after, afterShot, console_lines: console_.length });
    await reopen.page.close();
  }
} finally {
  await browser.close();
  fs.rmSync(userDataDir, { recursive: true, force: true });
}

// ---- the verdict each leg supports ---------------------------------------
//
// A leg is `pass` only when its comparison ran and matched, `fail` when it
// ran and did not, and `not-judged` when the build never reached the state
// the leg compares (specs/playtest/evidence.md). The comparison a durability
// leg needs is a committed document — without T9/T10 the release deals no
// puzzle, so none exists, and a leg that never reached it supports nothing.

const outcome = (leg) => {
  const hadDoc = leg.before.key_present && leg.before.document;
  const stillThere = leg.after.key_present && JSON.stringify(leg.before.document) === JSON.stringify(leg.after.document);
  if (!hadDoc) return { result: 'not-judged', reason: 'no committed document existed before the open — no puzzle result could commit' };
  if (stillThere) return { result: 'pass', reason: 'committed document survived the leg unchanged' };
  return { result: 'fail', reason: 'committed document changed across the leg' };
};
for (const leg of legs) leg.outcome = outcome(leg);

const run = {
  run_id: runId,
  issue: 557,
  started_at: startedAt,
  finished_at: new Date().toISOString(),
  build: {
    url: PUBLISHED_URL,
    commit: PUBLISHED_COMMIT,
    web_release_run: PUBLISHED_RUN,
    source: 'published URL',
    session_id: null,
    session_id_reason: 'the release build strips CMP-playtest-seams (ADR-0004 G2), so it reports no TEL.3 id',
  },
  environment: {
    browser: 'headless Chrome via puppeteer-core',
    viewport: '390x844 CSS px, DPR 2',
    settle_ms: SETTLE_MS,
    opens: legs.reduce((n, l) => n + 2, 0),
  },
  storage_key: STORAGE_KEY,
  legs,
  screenshot_distinct_md5_count: new Set(legs.flatMap((l) => [l.beforeShot, l.faultShot, l.afterShot].filter(Boolean).map((s) => s.md5))).size,
};
fs.writeFileSync(path.join(OUT, 'run.json'), JSON.stringify(run, null, 2) + '\n');

console.log(`run ${runId} written to ${OUT}`);
for (const leg of legs) console.log(`leg ${leg.leg} (${leg.name}): ${leg.outcome.result} — ${leg.outcome.reason}`);
