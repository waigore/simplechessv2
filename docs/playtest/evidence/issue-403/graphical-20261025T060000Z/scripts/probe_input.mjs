/**
 * The input-reach probe for #403.
 *
 * The published release renders a Shared board, and the pointer path is live by static
 * reading (`Presentation.handle_gui_input` → `_on_pointer_down`: a press on the side-to-move's
 * piece starts a drag follow). But a `tap` that lands and a `tap` that the page never saw
 * look identical in a screenshot, so this script asks the page directly: install a
 * capture-phase listener on `window` for `pointer*`/`touch*`/`mouse*`, dispatch one of each
 * kind of input at a given point, and report which events the DOM received and on which
 * target. It never judges a row; it says whether the harness can drive the build at all.
 *
 * Usage:
 *     node probe_input.mjs <url> <outDir> <label> --at=x,y [--wait=8000] [--kinds=touch,pointer,mouse]
 */

import fs from 'node:fs';
import path from 'node:path';
import { runCapture, installHook, sleep } from './cdp.mjs';

const args = process.argv.slice(2);
const positional = args.filter((arg) => !arg.startsWith('--'));
const named = Object.fromEntries(
  args.filter((arg) => arg.startsWith('--') && arg.includes('=')).map((arg) => {
    const [key, value] = arg.slice(2).split('=');
    return [key, value];
  }),
);
const [url, outDir, label] = positional;
if (!url || !outDir || !label || !named.at) {
  console.error('usage: node probe_input.mjs <url> <outDir> <label> --at=x,y [--wait=8000] [--kinds=touch,pointer,mouse]');
  process.exit(2);
}
const [atX, atY] = named.at.split(',').map(Number);
const waitMs = Number(named.wait || 8000);
const kinds = (named.kinds || 'touch,pointer,mouse').split(',');

/** Log every input-ish DOM event with its target, in order, tagged by which dispatch it saw. */
const INPUT_LOG = `(() => {
  window.__inputLog = [];
  window.__inputTag = 'load';
  const record = (event) => {
    const target = event.target;
    window.__inputLog.push({
      tag: window.__inputTag,
      type: event.type,
      target: target && target.tagName ? target.tagName + (target.id ? '#' + target.id : '') : String(target),
      x: event.clientX !== undefined ? event.clientX : (event.changedTouches && event.changedTouches[0] ? event.changedTouches[0].clientX : null),
      y: event.clientY !== undefined ? event.clientY : (event.changedTouches && event.changedTouches[0] ? event.changedTouches[0].clientY : null),
    });
  };
  for (const type of ['pointerdown', 'pointerup', 'touchstart', 'touchend', 'mousedown', 'mouseup', 'click']) {
    window.addEventListener(type, record, true);
  }
  return 'logging';
})()`;

await runCapture({
  url,
  outDir,
  label,
  callTimeoutMs: 90000,
  body: async (driver) => {
    const { send, evaluate, screenshot, close } = driver;
    await installHook(send, INPUT_LOG);
    await send('Page.navigate', { url });
    await sleep(waitMs);
    const before = await screenshot('before');
    const results = [];

    for (const kind of kinds) {
      await evaluate(`window.__inputTag = ${JSON.stringify(kind)}; window.__inputLog.length = 0;`);
      if (kind === 'touch') {
        await send('Input.dispatchTouchEvent', {
          type: 'touchStart',
          touchPoints: [{ x: atX, y: atY, radiusX: 8, radiusY: 8, force: 1, id: 1 }],
        });
        await sleep(60);
        await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      } else if (kind === 'pointer' || kind === 'mouse') {
        await send('Input.dispatchMouseEvent', { type: 'mousePressed', x: atX, y: atY, button: 'left', clickCount: 1, buttons: 1 });
        await sleep(60);
        await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: atX, y: atY, button: 'left', clickCount: 1, buttons: 0 });
      }
      await sleep(600);
      const log = await evaluate('JSON.stringify(window.__inputLog)');
      const shot = await screenshot(`after-${kind}`);
      results.push({ kind, events: JSON.parse(log || '[]'), shot });
      await sleep(600);
    }
    await close();

    const out = { url, label, at: [atX, atY], waitMs, before, results };
    fs.writeFileSync(path.join(outDir, `${label}-input.json`), `${JSON.stringify(out, null, 2)}\n`);
    return out;
  },
});
