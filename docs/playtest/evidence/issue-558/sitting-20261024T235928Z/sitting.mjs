// #558 sitting soak + Advice-Off / offline legs on the release Web build.
// Player-facing controls only: every point is measured from the run's own screenshot,
// so a layout change fails loudly instead of tapping a stale coordinate.
//
//   node sitting.mjs <run-dir> [--fast]
//
// Wall clock is recorded from the first page open to the final close, including the
// quit-and-reopen. `--fast` is for a harness rehearsal only; a real run never uses it.
import fs from 'node:fs';
import path from 'node:path';
import { openBrowser, sleep } from './drive.mjs';
import { textBands, modePickRows, setupRows, boardRect } from './ui.mjs';

const URL = process.env.SITTING_URL || 'http://127.0.0.1:8765/';
const OUT = process.argv[2];
if (!OUT) throw new Error('usage: node sitting.mjs <run-dir> [--fast]');
const FAST = process.argv.includes('--fast');
const RUN_DIR = path.resolve(OUT);
const LOG = path.join(RUN_DIR, 'logs', 'sitting.log');
const EVENTS = path.join(RUN_DIR, 'logs', 'browser-events.log');
fs.mkdirSync(path.join(RUN_DIR, 'screenshots'), { recursive: true });
fs.mkdirSync(path.join(RUN_DIR, 'logs'), { recursive: true });
fs.writeFileSync(LOG, '');

const startWall = new Date();
const startedMs = Date.now();
const elapsed = () => (Date.now() - startedMs) / 1000;
function log(kind, data = {}) {
  const line = JSON.stringify({ t: elapsed().toFixed(1), at: new Date().toISOString(), kind, ...data });
  fs.appendFileSync(LOG, line + '\n');
  console.log(line);
}
const minutes = (m) => (FAST ? 50 : m * 60000);

let browser = await openBrowser({ url: URL, outDir: RUN_DIR, label: 'sitting' });
await browser.goto(URL, 2500);
log('sitting.start', { url: URL, wall: startWall.toISOString(), fast: FAST });

const nBands = (f) => textBands(f).length;
async function shot(name) {
  const file = await browser.shot(name);
  log('screenshot', { name, file: path.relative(RUN_DIR, file) });
  return file;
}
async function waitFor(pred, name, timeoutMs = 45000) {
  const t0 = Date.now();
  while (Date.now() - t0 < timeoutMs) {
    const f = await shot(`${name}-wait`);
    if (pred(f)) return f;
    await sleep(1000);
  }
  throw new Error(`timeout waiting for ${name}`);
}
async function tapPoint(p, what) {
  await browser.tap(p.x, p.y);
  log('tap', { what, x: Number(p.x.toFixed(1)), y: Number(p.y.toFixed(1)) });
}
async function clickModeRow(which) {
  const f = await shot(`mode-pick-${which}`);
  const rows = modePickRows(f);
  await tapPoint(rows[which], `mode-pick.${which}`);
  await sleep(2200);
}
async function openSharedSetup({ adviceOff }) {
  await clickModeRow('shared');
  let f = await shot('shared-setup');
  let rows = setupRows(f);
  if (adviceOff) {
    await tapPoint(rows.advice, 'shared-setup.advice-off');
    await sleep(1600);
    f = await shot('shared-setup-advice-off');
    rows = setupRows(f);
  }
  return { f, rows };
}
async function startShared() {
  const f = await shot('shared-setup-before-start');
  const rows = setupRows(f);
  await tapPoint(rows.start, 'shared-setup.start');
  await sleep(2000);
  return waitFor((x) => boardRect(x) != null, 'shared-play');
}
async function move(from, to, tag) {
  const before = await shot(`${tag}-before`);
  const g = boardRect(before);
  await tapPoint(g.at(from), `${tag}.select-${from}`);
  await sleep(700);
  await tapPoint(g.at(to), `${tag}.place-${to}`);
  await sleep(1400);
  return shot(`${tag}-after`);
}
async function clickTopControl(index, tag) {
  const f = await shot(`${tag}-controls`);
  const bands = textBands(f).filter((x) => x.cy < 200);
  const band = bands.find((x) => x.boxes.length >= 3) || bands[bands.length - 1];
  await tapPoint({ x: band.boxes[index].cx, y: band.cy }, tag);
  await sleep(1400);
  return shot(`${tag}-after`);
}
async function confirmDialog(tag) {
  const f = await shot(`${tag}-dialog`);
  const bands = textBands(f).filter((x) => x.cy < 260);
  const band = bands.at(-1);
  // Confirm/Cancel sit in one merged text band; Confirm is the left button.
  await tapPoint({ x: band.boxes[0].left / 2 + 22, y: band.cy }, `${tag}.confirm`);
  await sleep(2200);
  return shot(`${tag}-confirmed`);
}
async function idle(ms, tag) {
  const until = Date.now() + ms;
  let beat = 0;
  while (Date.now() < until) {
    await sleep(Math.min(30000, Math.max(0, until - Date.now())));
    beat++;
    let alive = false;
    try {
      alive = (await browser.evaluate('document.visibilityState')) != null;
    } catch (err) {
      log('heartbeat.error', { tag, beat, error: String(err) });
    }
    log('heartbeat', { tag, beat, alive, storage: await browser.storage().catch(() => null) });
    if (beat % 2 === 0 || Date.now() >= until) await shot(`${tag}-heartbeat-${String(beat).padStart(2, '0')}`);
  }
}

// ---- phase 1: cold open, Advice Off shared game, full to checkmate ----------
let f = await waitFor((x) => nBands(x) >= 5, '01-cold-open');
log('phase', { name: 'mode-pick', bands: nBands(f), storage: await browser.storage() });
await shot('01-mode-pick');
await idle(minutes(0.5), '01-mode-pick-idle');

let setup = await openSharedSetup({ adviceOff: true });
log('advice_off.setup', { bands: nBands(setup.f) });
await shot('02-advice-off-setup');
f = await startShared();
await shot('03-advice-off-play');
log('advice_off.play', { board: boardRect(f)?.css });
await move('f2', 'f3', '04-f3');
await move('e7', 'e5', '05-e5');
await move('g2', 'g4', '06-g4');
await move('d8', 'h4', '07-qh4');
await sleep(2500);
f = await shot('08-game-over');
log('advice_off.game_over', { bands: nBands(f), board: boardRect(f) != null });
await idle(minutes(1.5), '08-game-over-idle');
// Stop -> mode pick (last band of the result screen is Stop).
let tb = textBands(await shot('09-result-before-stop'));
await tapPoint({ x: tb.at(-1).boxes.at(-1).cx, y: tb.at(-1).cy }, 'result.stop');
await sleep(2200);
f = await shot('09-mode-pick-after-shared');
log('phase', { name: 'mode-pick-after-shared', bands: nBands(f) });

// ---- phase 2: puzzle stream attempt ---------------------------------------
await clickModeRow('puzzle');
f = await waitFor((x) => nBands(x) >= 3, '10-puzzle');
log('puzzle.open', { bands: nBands(f), board: boardRect(f) != null });
await shot('10-puzzle-open');
// Attempt one move on the dealt position, whatever its side to move.
{
  const g = boardRect(f);
  if (g) {
    await tapPoint(g.at('e2'), 'puzzle.select-e2');
    await sleep(700);
    await tapPoint(g.at('e4'), 'puzzle.place-e4');
    await sleep(1400);
  }
}
f = await shot('11-puzzle-attempt');
log('puzzle.attempt', { board: boardRect(f) != null });
await idle(minutes(1), '11-puzzle-idle');
// Leave stream -> confirm -> mode pick.
{
  const top = textBands(await shot('12-puzzle-leave-before')).find((x) => x.cy < 200 && x.boxes.some((y) => y.cx > 250));
  await tapPoint({ x: top.boxes.at(-1).cx, y: top.cy }, 'puzzle.leave');
  await sleep(1200);
  await confirmDialog('12-puzzle-leave');
}
f = await shot('12-mode-pick-after-puzzle');
log('phase', { name: 'mode-pick-after-puzzle', bands: nBands(f) });

// ---- phase 3: quit and reopen inside the sitting --------------------------
const beforeQuit = await browser.storage();
log('reopen.before', { storage: beforeQuit });
const profile = browser.profile;
await browser.close({ keepProfile: true });
await sleep(3000);
browser = await openBrowser({ url: URL, outDir: RUN_DIR, label: 'sitting-reopen', profile });
await browser.goto(URL, 2500);
f = await waitFor((x) => nBands(x) >= 5, '20-reopen');
await shot('20-reopen-mode-pick');
const afterQuit = await browser.storage();
log('reopen.after', { storage: afterQuit, same: afterQuit === beforeQuit });
log('phase', { name: 'reopen', bands: nBands(f) });
await idle(minutes(2), '20-reopen-idle');

// ---- phase 4: Advice On with the build offline ----------------------------
await browser.send('Network.enable');
await browser.send('Network.emulateNetworkConditions', {
  offline: true, latency: 0, downloadThroughput: 0, uploadThroughput: 0,
});
log('offline.enabled', { method: 'Network.emulateNetworkConditions', offline: true });
setup = await openSharedSetup({ adviceOff: false });
log('offline.setup', { bands: nBands(setup.f) });
await shot('30-advice-on-setup');
f = await startShared();
await shot('31-advice-on-play');
log('offline.play', { board: boardRect(f)?.css });
await move('e2', 'e4', '32-offline-e4');
await sleep(2500);
await shot('33-offline-after-wait');
await move('e7', 'e5', '34-offline-e5');
await idle(minutes(2), '34-offline-idle');
// Resign -> Confirm -> result, then Stop.
{
  const top = textBands(await shot('35-resign-before')).filter((x) => x.cy < 200);
  const ctl = top.find((x) => x.boxes.length >= 3);
  await tapPoint({ x: ctl.boxes[1].cx, y: ctl.cy }, 'play.resign');
  await sleep(1400);
  await confirmDialog('35-resign');
}
f = await shot('36-result-after-resign');
log('offline.result', { bands: nBands(f), board: boardRect(f) != null });
{
  const tb2 = textBands(await shot('36-result-before-stop'));
  await tapPoint({ x: tb2.at(-1).boxes.at(-1).cx, y: tb2.at(-1).cy }, 'result.stop');
  await sleep(2200);
}
f = await shot('37-mode-pick-after-offline');
log('phase', { name: 'mode-pick-final', bands: nBands(f) });

// ---- phase 5: sit on mode pick until the window is met --------------------
while (elapsed() < (FAST ? 0 : 15.2 * 60)) {
  await idle(minutes(1), '38-sitting');
}
f = await shot('39-final-mode-pick');
log('sitting.end', {
  wall: new Date().toISOString(),
  seconds: Number(elapsed().toFixed(1)),
  bands: nBands(f),
  storage: await browser.storage(),
  events: browser.events.length,
});
fs.writeFileSync(EVENTS, browser.events.map(({ t, method, params }) => JSON.stringify({ t, method, params })).join('\n') + '\n');
await browser.close();
