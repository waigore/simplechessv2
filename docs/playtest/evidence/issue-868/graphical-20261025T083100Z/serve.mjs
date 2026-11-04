/**
 * Serves the acceptance export and the evidence run folder side by side on
 * localhost, so a browser run can load the game and this run's own PNG decoder.
 *
 *   node serve.mjs <exportRoot> <evidenceRoot>
 *
 * `/build/web/*` → <exportRoot>/build/web, `/evidence/*` → <evidenceRoot>.
 * Read-only; nothing is written.
 */
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';

const [exportRoot, evidenceRoot] = process.argv.slice(2);
if (!exportRoot || !evidenceRoot) {
  console.error('usage: node serve.mjs <exportRoot> <evidenceRoot>');
  process.exit(2);
}

const TYPES = {
  '.html': 'text/html', '.js': 'text/javascript', '.wasm': 'application/wasm',
  '.pck': 'application/octet-stream', '.png': 'image/png', '.json': 'application/json',
  '.mjs': 'text/javascript',
};

const roots = {
  '/build/web/': path.join(exportRoot, 'build', 'web'),
  '/evidence/': evidenceRoot,
};

const server = http.createServer((request, response) => {
  const url = new URL(request.url, 'http://127.0.0.1');
  const prefix = Object.keys(roots).find((key) => url.pathname.startsWith(key));
  if (!prefix) {
    response.writeHead(404).end('not found');
    return;
  }
  const root = roots[prefix];
  const relative = decodeURIComponent(url.pathname.slice(prefix.length));
  const file = path.resolve(root, relative);
  if (!file.startsWith(path.resolve(root))) {
    response.writeHead(403).end('forbidden');
    return;
  }
  fs.readFile(file, (error, data) => {
    if (error) {
      response.writeHead(404).end('not found');
      return;
    }
    response.writeHead(200, {
      'Content-Type': TYPES[path.extname(file)] || 'application/octet-stream',
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
    });
    response.end(data);
  });
});

server.listen(0, '127.0.0.1', () => {
  console.log(`http://127.0.0.1:${server.address().port}/build/web/index.html`);
});
