// #402: confirm whether a legal move can be made at all, and where the hit region sits.
// 1) tap the painted centre of e2 and record what gets selected;
// 2) select e2 at the y that empirically works (640) and tap the painted e4 centre;
// 3) select e2 again and tap e4 at the shifted y (543) to see if a move commits.
// Usage: node confirmmove.mjs <url> <outDir> <label>
import { openBrowser, sleep } from './drive.mjs';
import { inkBoxes, goldRing, boardGrid } from './locator.mjs';

const [url, outDir, label] = process.argv.slice(2);
const b = await openBrowser({ url, outDir, label });
await b.goto(url);
const pick = await b.shot('01-mode-pick');
const shared = inkBoxes(pick).filter((x) => x.w / 2 > 180).sort((a, c) => a.css.top - c.css.top)[0];
await b.click(shared.css.x, shared.css.y);
const setup = await b.shot('02-shared-setup');
const start = goldRing(setup);
await b.click(start.css.centreX, start.css.centreY);
const play = await b.shot('03-shared-play');
const grid = boardGrid(play);
const P = (n) => { const f = n.charCodeAt(0) - 97, r = Number(n[1]); return { x: grid.css.left + grid.squareCss * (f + 0.5), y: grid.css.top + grid.squareCss * (8 - r + 0.5) }; };
const out = { painted_e2: P('e2'), painted_e4: P('e4'), painted_e1: P('e1') };

await b.tap(P('e2').x, P('e2').y);
out.ring_after_painted_e2 = goldRing(await b.shot('04-painted-e2'))?.css ?? null;
await b.tap(P('e2').x, P('e2').y);
await b.shot('05-deselect');

await b.tap(P('e2').x, 640);
out.ring_after_y640 = goldRing(await b.shot('06-y640-selected'))?.css ?? null;
await b.tap(P('e4').x, P('e4').y);
await sleep(900);
out.ring_after_painted_e4 = goldRing(await b.shot('07-tap-painted-e4'))?.css ?? null;

await b.tap(P('e2').x, 640);
await b.shot('08-reselect');
await b.tap(P('e4').x, 543);
await sleep(900);
await b.shot('09-move-shifted-destination');
await b.writeLogs('confirmmove');
await b.close();
console.log(JSON.stringify(out, null, 2));
