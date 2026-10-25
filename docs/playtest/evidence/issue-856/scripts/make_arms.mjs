/**
 * #856 harness-local arms. Each is the shipped export's own pages with one thing changed,
 * served by the same static server as `index.html`, so an arm measures the change alone:
 *
 *   index_probe_later.html  — the shell's WebGL2 capability probe (`Engine.getMissingFeatures`)
 *                             runs after `engine.startGame()`, so the engine's fetches are
 *                             issued before the probe blocks the main thread.
 *   index_preload.html      — the shipped page plus three `<link rel="preload">` tags (the
 *                             tags Godot's headless (PWA) export template writes): index.js,
 *                             index.wasm, index.pck.
 *   index_preload_worklet.html — as `index_preload.html`, with the audio worklets preloaded
 *                             too (`as="script"`); a `as="fetch"` link is not an as-destination
 *                             the fetch spec knows, so the browser never starts it.
 *
 * Usage: node make_arms.mjs <build/web directory> <output directory>
 *
 * The arm pages are throw-away build output; they are not committed and not shipped.
 */

import fs from 'node:fs';

const [buildDir, outDir] = process.argv.slice(2);
if (!buildDir || !outDir) {
  console.error('usage: node make_arms.mjs <build/web directory> <output directory>');
  process.exit(2);
}

const index = fs.readFileSync(`${buildDir}/index.html`, 'utf8');
const probeBlock = `\tconst missing = Engine.getMissingFeatures({
\t\tthreads: GODOT_THREADS_ENABLED,
\t});
`;
if (!index.includes(probeBlock)) throw new Error('shell probe block not found');

// Arm 1: probe after startGame. startGame() returns the load promise; probing inside it
// would block the task that issues the fetches, so the probe is handed to a timer. The
// stock shell's own startGame/progress/failure lines stay byte-for-byte.
let later = index.replace(probeBlock, '\tconst missing = []; // probe deferred (arm page only)\n');
const lateProbe = `\t\tsetTimeout(() => {\n\t\t\tconst late = Engine.getMissingFeatures({ threads: GODOT_THREADS_ENABLED });\n\t\t\tif (late.length !== 0) { displayFailureNotice('Missing features: ' + late.join(', ')); }\n\t\t}, 0);\n`;
const anchor = "\t\t}, displayFailureNotice);\n\t}\n}());";
if (!later.includes(anchor)) throw new Error('startGame tail not found');
later = later.replace(anchor, `\t\t}, displayFailureNotice);\n${lateProbe}\t}\n}());`);

// Arms 2 and 3: preload links in <head>.
const links = (withWorklets) => {
  const parts = [
    '<link rel="preload" href="index.js" as="script">',
    '<link rel="preload" href="index.wasm" as="fetch" crossorigin>',
    '<link rel="preload" href="index.pck" as="fetch" crossorigin>',
  ];
  if (withWorklets) {
    parts.push('<link rel="preload" href="index.audio.worklet.js" as="script">');
    parts.push('<link rel="preload" href="index.audio.position.worklet.js" as="script">');
  }
  return `${parts.join('\n\t\t')}\n\t</head>`;
};
const preloaded = index.replace('\t</head>', links(false));
const preloadedWorklets = index.replace('\t</head>', links(true));

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(`${outDir}/index_probe_later.html`, later);
fs.writeFileSync(`${outDir}/index_preload.html`, preloaded);
fs.writeFileSync(`${outDir}/index_preload_worklet.html`, preloadedWorklets);
console.log(`wrote 3 arm pages to ${outDir}`);
