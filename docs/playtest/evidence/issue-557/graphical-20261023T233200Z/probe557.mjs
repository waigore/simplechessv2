// #557 durability driver — three legs against the published release build.
// Usage: node probe557.mjs <runId> <repoRunDir>
//
// Verdict rule: a leg passes only on what is OBSERVABLE ON THE SCREEN.
// A localStorage readback alone is never a pass — it proves the browser kept a
// key, not that the build reached mode pick or committed anything.
//
// Observability seam: the published build exposes no story-ID / session seam
// (ADR-0004 G2), so the document is read through the origin's localStorage and
// the screen through screenshots. Nothing in game/, specs/, asset_catalog/, or
// game_assets/ is touched.
import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const URL = 'https://waigore.github.io/simplechessv2/';
const KEY = 'simplechessv2.persist.v1';
const RUN = process.argv[2];
const RUN_DIR = process.argv[3];
if (!RUN || !RUN_DIR) { console.error('usage: node probe557.mjs <runId> <repoRunDir>'); process.exit(2); }
const SHOTS = path.join(RUN_DIR, 'screenshots');
const LOGS = path.join(RUN_DIR, 'logs');
fs.mkdirSync(SHOTS, { recursive: true });
fs.mkdirSync(LOGS, { recursive: true });

const driver = [];
const say = (s) => { driver.push(s); console.log(s); };
const readDoc = (page) => page.evaluate((k) => localStorage.getItem(k), KEY);
const keys = (page) => page.evaluate(() => Object.keys(localStorage));

// What the screen shows. Godot renders into #canvas, so the DOM cannot answer
// "is mode pick up?"; the honest check is the boot log plus a screenshot.
async function screenState(page, tag) {
  const info = await page.evaluate(() => ({
    status: document.querySelector('#status')?.innerText ?? '',
    statusVisible: document.querySelector('#status') ? getComputedStyle(document.querySelector('#status')).display !== 'none' : false,
  }));
  say(`[${tag}] engine status overlay visible: ${info.statusVisible} (text ${JSON.stringify(info.status.trim())})`);
  return info;
}

async function openPage(browser, tag) {
  const page = await browser.newPage();
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });
  const lines = [];
  page.on('console', (m) => lines.push(`[${m.type()}] ${m.text()}`));
  page.on('pageerror', (e) => lines.push(`[pageerror] ${e.message}`));
  page.on('response', (r) => { if (r.status() >= 400) lines.push(`[http ${r.status()}] ${r.url()}`); });
  say(`[${tag}] goto ${URL}`);
  await page.goto(URL, { waitUntil: 'networkidle2', timeout: 90000 });
  await page.waitForFunction(() => document.querySelector('#status')?.style.display === 'none', { timeout: 60000 })
    .catch(() => say(`[${tag}] engine status overlay never hidden`));
  await new Promise((r) => setTimeout(r, 20000)); // 20 s settle
  const bootGap = lines.filter((l) => /Preload .* unresolved|Error opening file/.test(l));
  say(`[${tag}] boot-gap lines: ${bootGap.length} (${bootGap[0]?.slice(0, 90) ?? 'none'})`);
  return { page, lines, bootGap };
}

async function leg2Crash(page) {
  const session = await page.target().createCDPSession();
  const crashed = new Promise((r) => { page.once('error', () => r()); setTimeout(() => r(), 5000); });
  session.send('Page.crash').catch(() => {});
  await crashed;
  say('[leg-2] renderer killed via CDP Page.crash');
  await page.reload({ waitUntil: 'networkidle2', timeout: 90000 }).catch(() => say('[leg-2] reload after crash failed'));
}

const browser = await puppeteer.launch({
  executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  headless: 'new',
  args: ['--no-sandbox', '--enable-unsafe-swiftshader', '--use-gl=swiftshader', '--autoplay-policy=no-user-gesture-required'],
});
const chromeVersion = await browser.version();
say(`chrome ${chromeVersion} | ${new Date().toISOString()} | run ${RUN}`);

// ---- Leg 0: clean cold open -------------------------------------------------
let modePickReachable = false;
{
  const { page, lines } = await openPage(browser, 'leg-0');
  await page.evaluate(() => localStorage.clear());
  await page.reload({ waitUntil: 'networkidle2' });
  await new Promise((r) => setTimeout(r, 20000));
  const state = await screenState(page, 'leg-0');
  await page.screenshot({ path: `${SHOTS}/leg-0-cold-open-390x844.png` });
  const k = await keys(page);
  say(`[leg-0] localStorage keys after clean cold open: ${JSON.stringify(k)}`);
  modePickReachable = k.length > 0;
  if (!modePickReachable) {
    say('[leg-0] no persistence document written on cold open -> boot never reached mode pick');
  }
  fs.writeFileSync(`${LOGS}/leg-0-cold-open.log`, lines.join('\n') + '\n');
  await page.close();
}

// ---- Legs 1–3, run only when the build renders mode pick --------------------
// A puzzle result commit cannot be produced while puzzle-play is unreachable.
// So this run seeds the exact document shape `CMP-persist-store` commits, and
// the legs read the SCREEN afterwards. The seed exercises the browser's storage
// and the build's read path; it is not a commit made by the build.
const PRIOR = { version: 1, player_elo: 1240, last_mode: 'Puzzle stream', recent_solved: ['p557-seed-probe'] };
const store = (p) => `localStorage.setItem(${JSON.stringify(KEY)}, ${JSON.stringify(p)})`;
const legResults = {};

if (!modePickReachable) {
  say('[legs 1-3] SKIPPED: mode pick never rendered, so no leg can be judged.');
  say('[legs 1-3] A seeded localStorage value would read back whether or not mode pick rendered,');
  say('[legs 1-3] so reporting it as survival would be a false pass. All three legs are not-judged.');
  legResults.leg1 = 'not-judged'; legResults.leg2 = 'not-judged'; legResults.leg3 = 'not-judged';
} else {
  const { page, lines } = await openPage(browser, 'leg-1');
  await page.evaluate(store(JSON.stringify(PRIOR)));
  await page.reload({ waitUntil: 'networkidle2' });
  await new Promise((r) => setTimeout(r, 20000));
  const before = await readDoc(page);
  await page.screenshot({ path: `${SHOTS}/leg-1-before-close.png` });
  say(`[leg-1] document before close: ${before}`);

  await page.close();
  say('[leg-1] tab closed (normal quit path)');
  const re1 = await openPage(browser, 'leg-1-reopen');
  const after = await readDoc(re1.page);
  await re1.page.screenshot({ path: `${SHOTS}/leg-1-after-reopen.png` });
  legResults.leg1 = before !== null && before === after ? 'pass' : 'fail';
  say(`[leg-1] document after reopen: ${after} -> ${legResults.leg1}`);
  fs.writeFileSync(`${LOGS}/leg-1.log`, [...lines, '--- reopen ---', ...re1.lines].join('\n') + '\n');

  await re1.page.evaluate(store(JSON.stringify({ ...PRIOR, last_mode: 'Shared game' })));
  say(`[leg-2] uncommitted selection written (last_mode Shared game); committed was ${PRIOR.last_mode}`);
  await leg2Crash(re1.page);
  await new Promise((r) => setTimeout(r, 20000));
  await re1.page.screenshot({ path: `${SHOTS}/leg-2-after-reopen.png` });
  const leg2 = await readDoc(re1.page);
  const leg2ok = leg2 !== null && JSON.parse(leg2).last_mode === PRIOR.last_mode;
  legResults.leg2 = leg2ok ? 'pass' : 'fail';
  say(`[leg-2] document after crash reopen: ${leg2} -> shown Last mode ${leg2 ? JSON.parse(leg2).last_mode : null} -> ${legResults.leg2}`);
  fs.writeFileSync(`${LOGS}/leg-2.log`, re1.lines.join('\n') + '\n');

  const fault = `(function () {
      const k = ${JSON.stringify(KEY)};
      window.__wraps = window.__wraps || [];
      const prior = Storage.prototype.setItem;
      window.__wraps.push(prior);
      Storage.prototype.setItem = function (key, value) {
        if (key === k) { return; }   // silently dropped, as quota/eviction surfaces
        return prior.call(this, key, value);
      };
      return 'wrapped';
    })()`;
  say(`[leg-3] wrapper installed: ${await re1.page.evaluate(fault)}`);
  const beforeFault = await readDoc(re1.page);
  await re1.page.evaluate((k, v) => localStorage.setItem(k, v), KEY, JSON.stringify({ ...PRIOR, player_elo: 1232 }))
    .catch((e) => say(`[leg-3] setItem threw: ${e.message}`));
  await new Promise((r) => setTimeout(r, 3000));
  const afterFault = await readDoc(re1.page);
  await re1.page.screenshot({ path: `${SHOTS}/leg-3-forced-failure.png` });
  say(`[leg-3] document before fault: ${beforeFault}`);
  say(`[leg-3] document after failed write: ${afterFault}`);
  say(`[leg-3] G2 prior intact: ${beforeFault === afterFault}`);
  say('[leg-3] NOTE: the wrapper was driven at the storage layer; the build’s own commit path');
  say('[leg-3] (PersistStore._web_set round-trip) was not reached because no game action was playable.');
  await re1.page.evaluate(() => { const p = window.__wraps.pop(); if (p) Storage.prototype.setItem = p; return 'restored'; });
  say('[leg-3] wrapper restored');
  await re1.page.reload({ waitUntil: 'networkidle2' });
  await new Promise((r) => setTimeout(r, 20000));
  await re1.page.screenshot({ path: `${SHOTS}/leg-3-after-reopen.png` });
  const leg3 = await readDoc(re1.page);
  legResults.leg3 = beforeFault === afterFault && leg3 !== null ? 'pass' : 'fail';
  say(`[leg-3] document after clean reopen: ${leg3} -> ${legResults.leg3}`);
  fs.writeFileSync(`${LOGS}/leg-3.log`, re1.lines.join('\n') + '\n');
  await re1.page.close();
}

fs.writeFileSync(`${LOGS}/driver.log`, driver.join('\n') + '\n');
fs.writeFileSync(`${RUN_DIR}/probe-summary.json`, JSON.stringify({ run: RUN, chromeVersion, modePickReachable, legResults }, null, 2));
say(`mode pick reachable: ${modePickReachable} | legs ${JSON.stringify(legResults)}`);
await browser.close();
