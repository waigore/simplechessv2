// Browser probe: can this host open the published build at all? Run BEFORE any row is read.
// Records the exact failure and exits non-zero, so a row that cannot be read says why.
// Usage: node probe-browser.mjs <outDir>
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { CHROME, sleep } from './drive.mjs';

const outDir = process.argv[2] || '.probe';
const URL_UNDER_TEST = 'https://waigore.github.io/simplechessv2/';
fs.mkdirSync(path.join(outDir, 'logs'), { recursive: true });

const report = { chrome: CHROME, exists: fs.existsSync(CHROME), attempts: [], outcome: 'unknown' };

// A. Does the binary start at all? `--version` is the smallest possible Chrome run.
for (const flags of [[], ['--no-sandbox'], ['--headless=new', '--no-sandbox', '--disable-gpu']]) {
  const r = spawnSync(CHROME, [...flags, '--version'], { encoding: 'utf8', timeout: 20000 });
  report.attempts.push({ kind: 'version', flags, status: r.status, signal: r.signal, stdout: (r.stdout || '').trim(), stderr: (r.stderr || '').trim().slice(0, 400) });
  if (r.status === 0) break;
}
fs.writeFileSync(path.join(outDir, 'logs', 'browser-probe.json'), JSON.stringify(report, null, 2));

const versionOk = report.attempts.some((a) => a.status === 0);
if (!versionOk) {
  report.outcome = 'binary-cannot-start';
  fs.writeFileSync(path.join(outDir, 'logs', 'browser-probe.json'), JSON.stringify(report, null, 2));
  console.log(`OUTCOME ${report.outcome}`);
  process.exit(2);
}

// B. Can it host the build's page and run its script (WebGL2 + wasm)?
const { openBrowser } = await import('./drive.mjs');
const b = await openBrowser({ url: URL_UNDER_TEST, outDir, label: 'probe' });
await b.send('Network.enable');
await b.send('Network.setCacheDisabled', { cacheDisabled: true });
await b.send('Page.navigate', { url: URL_UNDER_TEST });
const samples = [];
for (let i = 0; i < 30; i++) {
  await sleep(1000);
  try {
    const s = JSON.parse(await b.evaluate(`(() => {
      const c = document.createElement('canvas');
      const gl = c.getContext('webgl2');
      const renderer = gl ? gl.getParameter(gl.RENDERER) : null;
      const notice = document.getElementById('status-notice');
      return JSON.stringify({
        canvas: !!document.getElementById('canvas'),
        webgl2: !!gl,
        renderer,
        engineLoaded: typeof window.Engine !== 'undefined',
        notice: notice ? (notice.innerText || '').slice(0, 200) : null,
        statusVisible: document.getElementById('status') ? getComputedStyle(document.getElementById('status')).visibility : null,
        animations: document.getAnimations ? document.getAnimations().length : null,
      });
    })()`));
    samples.push({ t: i + 1, ...s });
    if (s.notice && s.notice.trim()) break;
  } catch (e) {
    samples.push({ t: i + 1, error: String(e).slice(0, 200) });
  }
}
await b.shot('published-cold-open-390x844');
const logs = b.writeLogs('cold-open');
const nav = await b.evaluate(`(() => { const n = performance.getEntriesByType('navigation')[0]; return JSON.stringify({ dcl: Math.round(n.domContentLoadedEventEnd), responseEnd: Math.round(n.responseEnd) }); })()`).catch(() => null);
await b.close();
report.outcome = 'page-ran';
report.coldOpen = { samples, nav, consoleLines: logs.slice(0, 40) };
fs.writeFileSync(path.join(outDir, 'logs', 'browser-probe.json'), JSON.stringify(report, null, 2));
console.log(`OUTCOME ${report.outcome} samples=${samples.length}`);
console.log(JSON.stringify(samples.at(-1)));
