// Reads the SERVED published build's bytes and records what a browser would load.
// No browser involved: this is the artifact half of the row readings.
// Usage: node read-pck.mjs <outDir>
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const outDir = process.argv[2] || '.';
const BASE = 'https://waigore.github.io/simplechessv2/';
const out = { base: BASE, at: new Date().toISOString(), files: {} };

async function grab(name) {
  const r = await fetch(BASE + name, { redirect: 'follow' });
  const buf = Buffer.from(await r.arrayBuffer());
  out.files[name] = {
    status: r.status,
    bytes: buf.length,
    contentLength: r.headers.get('content-length'),
    lastModified: r.headers.get('last-modified'),
    sha256: crypto.createHash('sha256').update(buf).digest('hex'),
  };
  return buf;
}

const html = (await grab('index.html')).toString('utf8');
const pck = await grab('index.pck');
await grab('index.wasm');

const cfg = html.match(/const GODOT_CONFIG = (\{.*?\});/s);
out.godotConfig = cfg ? JSON.parse(cfg[1]) : null;

const u32 = (o) => pck.readUInt32LE(o);
const s = pck.toString('latin1');

// Every `res://` path whose 4 preceding bytes carry its own length appears in the pack's
// path table. Collect them (each once) — this is the export's file list, as the engine
// reads it from `index.pck`.
const rows = new Map();
let i = -1;
while ((i = s.indexOf('res://', i + 1)) !== -1) {
  const len = u32(i - 4);
  if (!(len > 3 && len < 400)) continue;
  const name = s.substr(i, len);
  if (!/^res:\/\/[\x20-\x7e]+$/.test(name)) continue;
  rows.set(name, i);
}
const unique = [...rows.keys()].sort();
const assetPaths = unique.filter((n) => n.startsWith('res://game_assets/'));

// The pack's own size is the only bound available on stored bytes; the served export
// names every asset file the catalog root holds, so the group is carried either way.
const config = out.godotConfig || {};
out.pck = {
  magic: s.slice(0, 4),
  packFormat: u32(4),
  engine: [u32(8), u32(12), u32(16)],
  pathRows: rows.size,
  gameAssetPaths: assetPaths.length,
  importedRemaps: unique.filter((n) => n.startsWith('res://.godot/imported/')).length,
  scriptPaths: unique.filter((n) => n.endsWith('.gd')).length,
  audioRuntimePaths: unique.filter((n) => n.startsWith('res://audio_runtime/')).length,
  assetPathSample: assetPaths.slice(0, 6),
  servedIndexPck: out.files['index.pck']?.bytes,
  configuredIndexPck: config.fileSizes?.['index.pck'],
  configuredIndexWasm: config.fileSizes?.['index.wasm'],
};
fs.writeFileSync(path.join(outDir, 'logs', 'served-build.json'), JSON.stringify(out, null, 2));
console.log(JSON.stringify(out.pck, null, 2));
console.log(JSON.stringify(out.files, null, 2));
