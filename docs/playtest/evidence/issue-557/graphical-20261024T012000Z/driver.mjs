// #557 durability legs against the published release build.
// Every artifact this driver writes comes from the same live URL and the same
// browser session, so logs, screenshots and readings cannot disagree.
import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import crypto from 'node:crypto';

const URL = 'https://waigore.github.io/simplechessv2/';
const OUT = process.argv[2];
const SETTLE_MS = Number(process.argv[3] || 25000);
const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

fs.mkdirSync(`${OUT}/screenshots`, { recursive: true });
fs.mkdirSync(`${OUT}/logs`, { recursive: true });

const started = new Date().toISOString();
const legs = [];

// --- helpers ---------------------------------------------------------------

function newSession() {
  const s = { console: [], failed: [], errors: [] };
  return s;
}

async function attach(page, s) {
  page.on('console', m => s.console.push(`[${m.type()}] ${m.text()}`));
  page.on('pageerror', e => s.errors.push(`[pageerror] ${e.message}`));
  page.on('requestfailed', r => {
    // index.pck aborts on the successful fetch path; only record real failures
    const t = r.failure()?.errorText || '';
    if (!t.includes('ERR_ABORTED')) s.failed.push(`FAILED ${r.url()} :: ${t}`);
  });
  page.on('response', r => {
    if (r.url().includes('game_assets/') && r.status() >= 400) {
      s.failed.push(`HTTP ${r.status()} ${r.url()}`);
    }
  });
}

// Reads the persist document exactly as the issue names it, plus a screen read.
async function readState(page) {
  return page.evaluate(() => {
    const KEY = 'simplechessv2.persist.v1';
    const raw = localStorage.getItem(KEY);
    let doc = null;
    if (raw !== null) { try { doc = JSON.parse(raw); } catch { doc = raw; } }
    const dialogs = [...document.querySelectorAll('[role=dialog], .dialog')]
      .map(e => (e.textContent || '').trim()).filter(Boolean);
    const bodyText = (document.body?.innerText || '').trim().slice(0, 400);
    return {
      key_present: raw !== null,
      doc,
      localStorage_keys: Object.keys(localStorage),
      visible_text: bodyText,
      dialogs,
      has_loading: /Loading/i.test(bodyText),
      has_mode_pick: /Puzzle|Shared/i.test(bodyText),
    };
  });
}

async function shoot(page, name) {
  const path = `${OUT}/screenshots/${name}.png`;
  await page.screenshot({ path });
  const buf = fs.readFileSync(path);
  return {
    path: `screenshots/${name}.png`,
    bytes: buf.length,
    md5: crypto.createHash('md5').update(buf).digest('hex'),
  };
}

// --- browser ---------------------------------------------------------------

const browser = await puppeteer.launch({
  executablePath: CHROME,
  headless: true,
  args: ['--no-sandbox', '--window-size=390,844'],
});

async function coldOpen(legName) {
  const s = newSession();
  const page = await browser.newPage();
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });
  await attach(page, s);
  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await new Promise(r => setTimeout(r, SETTLE_MS));
  return { s, page };
}

// --- leg 1: quit/reload ----------------------------------------------------

{
  const s = newSession();
  const page = await browser.newPage();
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });
  await attach(page, s);
  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await new Promise(r => setTimeout(r, SETTLE_MS));

  const before = await readState(page);
  const beforeShot = await shoot(page, 'leg1-before-close');

  // Reachability gate: without mode pick there is no puzzle to play and no
  // commit to survive. Record that rather than seeding storage and calling it
  // survival (a seeded value is not a survival observation).
  let outcome, reason;
  if (!before.has_mode_pick) {
    outcome = 'not-judged';
    reason = 'mode pick never rendered, so no puzzle result could commit and no R2 Elo could be read before the close';
  } else {
    outcome = 'not-judged';
    reason = 'mode pick rendered but the puzzle stream was not verified in this run; see notes';
  }

  await page.close();
  await new Promise(r => setTimeout(r, 500));

  // Reopen through a normal cold open, same browser profile (same origin store).
  const re = await coldOpen('leg1-reopen');
  const after = await readState(re.page);
  const afterShot = await shoot(re.page, 'leg1-after-reopen');
  await re.page.close();

  fs.writeFileSync(`${OUT}/logs/leg-1.console.log`,
    `## leg 1 quit/reload — ${URL}\n` +
    s.console.join('\n') +
    '\n\n--- failed requests ---\n' + s.failed.join('\n') +
    '\n\n--- reopen console ---\n' + re.s.console.join('\n') +
    '\n\n--- reopen failed requests ---\n' + re.s.failed.join('\n'));

  legs.push({
    leg: 1, name: 'quit/reload', outcome, reason,
    before: { document: before, screenshot: beforeShot },
    after: { document: after, screenshot: afterShot },
  });
}

// --- leg 2: crash ----------------------------------------------------------

{
  const { s, page } = await coldOpen('leg 2');
  const before = await readState(page);
  const beforeShot = await shoot(page, 'leg2-before-crash');

  let outcome, reason;
  if (!before.has_mode_pick) {
    outcome = 'not-judged';
    reason = 'mode pick never rendered, so no Last-mode selection could be made and then abandoned; there is no uncommitted mid-session value to test';
  } else {
    outcome = 'not-judged';
    reason = 'mode pick rendered, but no uncommitted Last-mode selection path was verified in this run';
  }

  // Kill the renderer with no quit path.
  try {
    const cdp = await page.createCDPSession();
    await cdp.send('Page.crash').catch(() => {});
  } catch { /* expected: the target dies */ }

  await new Promise(r => setTimeout(r, 1500));
  try { await page.close(); } catch { /* already gone */ }

  const re = await coldOpen('leg 2 reopen');
  const after = await readState(re.page);
  const afterShot = await shoot(re.page, 'leg2-after-reopen');
  await re.page.close();

  fs.writeFileSync(`${OUT}/logs/leg-2.console.log`,
    `## leg 2 crash (CDP Page.crash) — ${URL}\n` +
    s.console.join('\n') +
    '\n\n--- failed requests ---\n' + s.failed.join('\n') +
    '\n\n--- reopen console ---\n' + re.s.console.join('\n'));

  legs.push({
    leg: 2, name: 'crash', outcome, reason,
    before: { document: before, screenshot: beforeShot },
    after: { document: after, screenshot: afterShot },
  });
}

// --- leg 3: faulted session ------------------------------------------------

{
  const { s, page } = await coldOpen('leg 3');
  const before = await readState(page);
  const beforeShot = await shoot(page, 'leg3-before-fault');

  // Install the devtools wrapper: writes to the persist key silently drop.
  // This is the browser-side mechanism the issue names; it edits no game file.
  await page.evaluate(() => {
    const KEY = 'simplechessv2.persist.v1';
    const orig = Storage.prototype.setItem;
    window.__persistWrites = [];
    window.__origSetItem = orig;
    Storage.prototype.setItem = function (k, v) {
      if (k === KEY) {
        window.__persistWrites.push({ key: k, at: Date.now(), dropped: true });
        return; // silently drop: the round-trip check then fails
      }
      return orig.call(this, k, v);
    };
  });

  const writesBefore = await page.evaluate(() => window.__persistWrites.length);

  // Give the build every chance to attempt a commit within the window.
  await new Promise(r => setTimeout(r, SETTLE_MS));

  const writeLog = await page.evaluate(() => window.__persistWrites.slice());
  const writesAfter = writeLog.length;
  const afterFault = await readState(page);
  const faultShot = await shoot(page, 'leg3-after-fault');

  // Restore before the reopen.
  await page.evaluate(() => { Storage.prototype.setItem = window.__origSetItem; });

  const saveFailureShown = await page.evaluate(() =>
    /save|couldn't|could not|failed to save/i.test(document.body?.innerText || ''));

  let outcome, reason;
  if (writesAfter === writesBefore) {
    outcome = 'not-judged';
    reason = 'the wrapper was installed and restored, but the build never attempted a persist write, so PersistStore._web_set reached no round-trip check and EX.save-failure never had a chance to show';
  } else {
    outcome = 'not-judged';
    reason = 'writes were attempted but the round-trip outcome was not observable in this run';
  }

  await page.close();
  await new Promise(r => setTimeout(r, 500));

  const re = await coldOpen('leg 3 reopen');
  const after = await readState(re.page);
  const afterShot = await shoot(re.page, 'leg3-after-reopen');
  await re.page.close();

  fs.writeFileSync(`${OUT}/logs/leg-3.console.log`,
    `## leg 3 faulted session (Storage.prototype.setItem wrapper) — ${URL}\n` +
    `wrapper installed; persist writes observed: ${writesAfter}\n` +
    JSON.stringify(writeLog, null, 2) +
    `\nsave-failure surface shown: ${saveFailureShown}\n` +
    s.console.join('\n') +
    '\n\n--- failed requests ---\n' + s.failed.join('\n') +
    '\n\n--- reopen console ---\n' + re.s.console.join('\n'));

  legs.push({
    leg: 3, name: 'faulted session', outcome, reason,
    before: { document: before, screenshot: beforeShot },
    after: { document: after, screenshot: afterShot },
    fault: {
      writes_before: writesBefore,
      writes_after: writesAfter,
      writes: writeLog,
      save_failure_shown: saveFailureShown,
      post_fault_document: afterFault,
      screenshot: faultShot,
    },
  });
}

await browser.close();

const md5s = legs.flatMap(l => [l.before.screenshot.md5, l.after.screenshot.md5]
  .concat(l.fault ? [l.fault.screenshot.md5] : []));
const distinct = new Set(md5s).size;

const report = {
  url: URL,
  started_at: started,
  finished_at: new Date().toISOString(),
  settle_ms: SETTLE_MS,
  browser: await (async () => {
    const b = await puppeteer.launch({
      executablePath: CHROME, headless: true, args: ['--no-sandbox'],
    });
    const v = await b.version(); await b.close(); return v;
  })(),
  legs,
  screenshot_md5_all: md5s,
  screenshot_distinct_md5_count: distinct,
};
fs.writeFileSync(`${OUT}/run.json`, JSON.stringify(report, null, 2));
console.log(JSON.stringify({
  legs: legs.map(l => ({ leg: l.leg, name: l.name, outcome: l.outcome, reason: l.reason })),
  distinct_screenshots: distinct,
  total_screenshots: md5s.length,
  md5s: [...new Set(md5s)],
}, null, 2));
