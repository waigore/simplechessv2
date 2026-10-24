// #402: map the release build's tap-to-square response along the e-file.
// Taps a vertical sweep of CSS y values on the e-file x and records the gold ring
// (selected square) after each tap, then deselects. Produces a table of
// "tap y -> selected square bounds", which shows the effective input mapping.
// Usage: node ymap.mjs <url> <outDir> <label>
import fs from 'node:fs';
import { openBrowser, sleep } from './drive.mjs';
import { inkBoxes, goldRing } from './locator.mjs';

const [url, outDir, label] = process.argv.slice(2);
const b = await openBrowser({ url, outDir, label });
await b.goto(url);
const pick = await b.shot('01-mode-pick');
const shared = inkBoxes(pick).filter((x) => x.w / 2 > 180).sort((a, b2) => a.css.top - b2.css.top)[0];
await b.click(shared.css.x, shared.css.y);
const setup = await b.shot('02-shared-setup');
const start = goldRing(setup);
await b.click(start.css.centreX, start.css.centreY);
await b.shot('03-shared-play');

const X = 214.5;
const rows = [];
for (let y = 340; y <= 730; y += 10) {
  await b.tap(X, y);
  const f = await b.shot(`04-tap-y${y}`);
  const ring = goldRing(f);
  rows.push({ tapY: y, ring: ring ? { top: +ring.css.top.toFixed(0), bottom: +ring.css.bottom.toFixed(0) } : null });
  if (ring) { await b.tap(X, y); await sleep(300); } // deselect so the next tap starts clean
}
fs.writeFileSync(`${outDir}/logs/${label}-ymap.json`, JSON.stringify(rows, null, 2));
await b.writeLogs('ymap');
await b.close();
const hit = rows.filter((r) => r.ring);
console.log('tapY -> ring top/bottom');
for (const r of hit) console.log(` ${r.tapY}  -> ${r.ring.top}-${r.ring.bottom}`);
console.log('misses:', rows.filter((r) => !r.ring).map((r) => r.tapY).join(','));
