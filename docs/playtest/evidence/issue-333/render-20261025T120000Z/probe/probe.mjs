/**
 * #333 probe — do the S2 prompts (Leave, Abandon, Reveal) paint over the board?
 *
 * Usage: node probe.mjs <url> <runDir> <tag>
 *
 * Enter puzzle-play through the shipped C2 path, then raise each prompt once
 * and read it: the prompt rect's fill, a band scan across four rows through the
 * panel (board squares show up as wide cream/brown runs), and the ink contrast
 * of the prompt's body copy. Cancel returns to S1 (B1) between prompts.
 *
 * `tag` (before / after) names the run's files only.
 */
import fs from 'node:fs';
import path from 'node:path';
import { connect } from './cdp.mjs';
import { decodePng } from './png.mjs';

const [url, runDir, tag = 'run'] = process.argv.slice(2);
if (!url || !runDir) {
  console.error('usage: node probe.mjs <url> <runDir> <tag>');
  process.exit(2);
}
const shotsDir = path.join(runDir, 'screenshots');
const logDir = path.join(runDir, 'logs');
fs.mkdirSync(shotsDir, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

const FRAME = { width: 1280, height: 720, dpr: 1 };
const MODE_PICK_PUZZLE = { x: 640, y: 304 };
const ACTIONS = {
  leave: { x: 1059, y: 92 },
  abandon: { x: 640, y: 92 },
  reveal: { x: 220, y: 92 },
};
const CONFIRM = { x: 583, y: 306 };
const CANCEL = { x: 697, y: 306 };
// `Presentation.place_centered_over_board(box, 220)`: 280 wide, centred.
const PROMPT_RECT = { left: 500, right: 780, top: 220, bottom: 360 };
const SCAN_ROWS = [240, 262, 306, 345];

const COLOR_BG = [247, 241, 232];
const COLOR_MUTED = [92, 87, 78];
const DARK_SQUARE = [139, 90, 60];
const LIGHT_SQUARE = [232, 213, 181];

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const driver = await connect({ ...FRAME, url, outDir: shotsDir, logDir, label: `probe333-${tag}` });
const taps = [];

const tap = async (name, at) => {
  taps.push({ name, ...at });
  await driver.tap(at.x, at.y);
};
const shot = async (name, settleMs = 700) => {
  await sleep(settleMs);
  return path.basename(await driver.shot(name));
};
const near = (c, t, tol) => Math.abs(c[0] - t[0]) <= tol && Math.abs(c[1] - t[1]) <= tol && Math.abs(c[2] - t[2]) <= tol;

function luminance([r, g, b]) {
  const f = (v) => {
    const s = v / 255;
    return s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
  };
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
}
const contrast = (a, b) => {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return Number(((hi + 0.05) / (lo + 0.05)).toFixed(2));
};

/** Colour runs wider than 4 px along one row inside the prompt rect. */
function bands(image, y) {
  const out = [];
  let current = null;
  for (let x = PROMPT_RECT.left; x < PROMPT_RECT.right; x++) {
    const c = image.at(x, y);
    const key = `${c[0]},${c[1]},${c[2]}`;
    if (current && current.rgb === key) {
      current.px++;
      current.to = x;
    } else {
      current = { rgb: key, px: 1, from: x, to: x };
      out.push(current);
    }
  }
  const wide = out.filter((b) => b.px > 4);
  const asRgb = (b) => b.rgb.split(',').map(Number);
  return {
    y,
    wide_bands: wide,
    board_bands: wide.filter((b) => near(asRgb(b), DARK_SQUARE, 10) || near(asRgb(b), LIGHT_SQUARE, 6)),
  };
}

/** What the prompt rect paints on one capture. */
function measure(file, label) {
  const image = decodePng(file);
  const colors = new Map();
  let bg = 0;
  let board = 0;
  let total = 0;
  for (let y = PROMPT_RECT.top; y < PROMPT_RECT.bottom; y++) {
    for (let x = PROMPT_RECT.left; x < PROMPT_RECT.right; x++) {
      const c = image.at(x, y);
      total++;
      const key = `${c[0]},${c[1]},${c[2]}`;
      colors.set(key, (colors.get(key) ?? 0) + 1);
      if (near(c, COLOR_BG, 2)) bg++;
      else if (near(c, DARK_SQUARE, 10) || near(c, LIGHT_SQUARE, 6)) board++;
    }
  }
  const ranked = [...colors.entries()].sort((a, b) => b[1] - a[1]).slice(0, 4);
  const rows = SCAN_ROWS.map((y) => bands(image, y));
  return {
    label,
    file: path.basename(String(file)),
    raised: board / total < 0.1 && bg / total > 0.5,
    rect_px: total,
    color_bg_px: bg,
    board_paint_px: board,
    board_paint_pct: Number(((board / total) * 100).toFixed(2)),
    top_colors: ranked.map(([k, n]) => ({ rgb: k, px: n })),
    muted_contrast_on_bg: contrast(COLOR_MUTED, COLOR_BG),
    rows_with_board_bands: rows.filter((r) => r.board_bands.length > 0).map((r) => r.y),
    rows,
  };
}

const readings = { tag, frame: FRAME, url, prompt_rect: PROMPT_RECT, scan_rows: SCAN_ROWS };

/** Raise one prompt and read both the frame right after the tap and the settled one. */
async function raise(kind, name, reopen = false) {
  // Skip mode-pick's entry transition (UiChrome.transition_in, 0.2 s) before a
  // prompt raise: a raise inside it lands on a screen still fading in.
  if (reopen) await shot(`${name}-pre-open`, 600);
  await tap(`${name}-open`, ACTIONS[kind]);
  const immediateFile = path.basename(await driver.shot(`${name}-immediate`));
  const settledFile = await shot(`${name}-settled`, 900);
  return {
    immediate: measure(path.join(shotsDir, immediateFile), `${name} immediate`),
    settled: measure(path.join(shotsDir, settledFile), `${name} settled`),
  };
}

await sleep(4500);
await shot('01-mode-pick', 300);
await tap('mode-pick-c2', MODE_PICK_PUZZLE);
await sleep(2500);
await shot('02-puzzle-play-s1', 900);

// Leave, then back to S1 (B1 Cancel), then the other two prompts.
// The seams peer deals no record here (C2 → puzzle-play, `no_record`), so
// nothing is open and only C5 (which needs no puzzle) raises; S1's Reveal and
// Abandon stay disabled. The instance count is recorded on the final capture.
readings.leave = await raise('leave', '03-s2-leave');
readings.leave2 = await raise('leave', '03b-s2-leave-again');
await tap('03b-cancel', CANCEL);
await shot('03b-after-cancel', 700);
readings.leave3 = await raise('leave', '03c-s2-leave-third');
await tap('03c-cancel', CANCEL);
await shot('03c-after-cancel', 700);
await tap('03-cancel', CANCEL);
await shot('03-after-cancel', 700);
// Confirm Leave from S1 returns to mode-pick (NAV.T9) — proves the prompt path
// is live, not merely painted.
readings.leave_confirm = await raise('leave', '06-s2-leave-confirm', true);
await tap('06-confirm', CONFIRM);
await shot('06-mode-pick', 1400);

readings.taps = taps;
{
  const image = decodePng(path.join(shotsDir, '06-mode-pick.png'));
  const colors = new Map();
  for (let y = 0; y < image.height; y++) {
    for (let x = 0; x < image.width; x++) {
      const c = image.at(x, y);
      colors.set(`${c[0]},${c[1]},${c[2]}`, (colors.get(`${c[0]},${c[1]},${c[2]}`) ?? 0) + 1);
    }
  }
  readings.mode_pick_after_leave = {
    colors: [...colors.entries()].sort((a, b) => b[1] - a[1]).slice(0, 8)
      .map(([rgb, px]) => ({ rgb, px })),
    accent_c5_border_px: [...colors.entries()]
      .filter(([rgb]) => rgb === '184,148,12')
      .reduce((sum, [, px]) => sum + px, 0),
  };
}
fs.writeFileSync(path.join(runDir, 'readings.json'), `${JSON.stringify(readings, null, 2)}\n`);
await driver.close();
for (const [kind, legs] of Object.entries(readings)) {
  if (!legs || !legs.settled) continue;
  for (const phase of ['immediate', 'settled']) {
    const v = legs[phase];
    console.log(`${kind}/${phase}: raised=${v.raised} bg=${v.color_bg_px} board=${v.board_paint_px} (${v.board_paint_pct}%) top=${v.top_colors[0].rgb} board-rows=${v.rows_with_board_bands.join(',') || 'none'} k4=${v.muted_contrast_on_bg}:1`);
  }
}
