/**
 * Probe capture for #882: load the probe build (the acceptance export scene set
 * plus a page-level console capture and `--script res://probe882web.gd`), wait,
 * then write the captured page console and a final screenshot.
 *
 *     node scripts/probe.mjs <url> <outDir> [waitMs]
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect, sleep } from './cdp.mjs';

const [url, out, waitMs = '60000'] = process.argv.slice(2);
const page = await connect({
  width: 390, height: 844, dpr: 3, url, outDir: path.join(out, 'screenshots'),
  logDir: path.join(out, 'logs'), label: 'probe', touch: true,
});
await sleep(Number(waitMs));
await page.shot('probe-final', path.join(out, 'screenshots'));
const captured = await page.evaluate("document.getElementById('__probe-capture')?.textContent ?? ''");
fs.writeFileSync(path.join(out, 'logs', 'probe-page.log'), String(captured ?? ''));
fs.writeFileSync(path.join(out, 'logs', 'probe-console.log'), `${page.consoleLogs.join('\n')}\n`);
await page.close();
console.log(`captured ${String(captured ?? '').split('\n').length} page lines`);
