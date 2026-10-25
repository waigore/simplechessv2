/**
 * #625 build prober: loads a served export in a fresh Chrome profile at phone metrics
 * (390x844 CSS, DPR 2, touch) and records what the console says.
 *
 *     node scripts/probe.mjs <web-dir> <out-dir> [url]
 *
 * Starts `python3 -m http.server` over <web-dir> on 127.0.0.1:8625 (already running is
 * fine), opens a fresh `--user-data-dir`, reads CDP over that profile's DevToolsActivePort,
 * screenshots six samples 1.5 s apart, and writes:
 *
 *   probe-result.json, probe-console.log, probe-network.log, probe-frame-NN.png
 *
 * It records; it never judges a row. It looks for no `TEL.3` line (the release strips the
 * seam) and mints none.
 */

import { spawn } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const [web, out] = process.argv.slice(2);
const url = process.argv[4] || "http://127.0.0.1:8625/";
const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
fs.mkdirSync(out, { recursive: true });

const server = spawn("python3", ["-m", "http.server", "8625", "--bind", "127.0.0.1"], {
  cwd: web,
  stdio: "ignore",
  detached: false,
});
await new Promise((r) => setTimeout(r, 1200));

const profile = fs.mkdtempSync(path.join(process.env.TMPDIR || "/tmp", "probe625-"));
const chrome = spawn(
  CHROME,
  [
    "--headless=new",
    "--remote-debugging-port=0",
    `--user-data-dir=${profile}`,
    "--no-first-run",
    "--use-gl=swiftshader",
    "--enable-unsafe-swiftshader",
    "about:blank",
  ],
  { stdio: "ignore" },
);

let cdp = null;
for (let i = 0; i < 60 && !cdp; i++) {
  await new Promise((r) => setTimeout(r, 250));
  const f = path.join(profile, "DevToolsActivePort");
  if (fs.existsSync(f)) {
    const [p, ws] = fs.readFileSync(f, "utf8").split("\n");
    if (p && ws) cdp = { port: Number(p), wsPath: ws };
  }
}
if (!cdp) {
  console.error("chrome never opened a DevTools port");
  server.kill();
  chrome.kill("SIGKILL");
  process.exit(2);
}

const target = await (
  await fetch(`http://127.0.0.1:${cdp.port}/json/new?about:blank`, { method: "PUT" })
).json();
const sock = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => sock.addEventListener("open", r));

let n = 0;
const pending = new Map();
const events = [];
sock.addEventListener("message", (m) => {
  const msg = JSON.parse(m.data);
  if (msg.id && pending.has(msg.id)) {
    const { resolve, reject } = pending.get(msg.id);
    pending.delete(msg.id);
    msg.error ? reject(new Error(JSON.stringify(msg.error))) : resolve(msg.result);
  } else if (msg.method) {
    events.push(msg);
  }
});
const send = (method, params = {}) =>
  new Promise((resolve, reject) => {
    const i = ++n;
    pending.set(i, { resolve, reject });
    sock.send(JSON.stringify({ id: i, method, params }));
  });

await send("Page.enable");
await send("Runtime.enable");
await send("Log.enable");
await send("Network.enable");
await send("Emulation.setDeviceMetricsOverride", {
  width: 390,
  height: 844,
  deviceScaleFactor: 2,
  mobile: true,
});
await send("Emulation.setTouchEmulationEnabled", { enabled: true, maxTouchPoints: 5 });

const result = {
  url,
  webDir: web,
  startedAt: new Date().toISOString(),
  profile,
  loaderHtml: null,
  engineFiles: [],
  samples: [],
};
for (const f of ["index.html", "index.js", "index.wasm", "index.pck"]) {
  const p = path.join(web, f);
  result.engineFiles.push({ file: f, bytes: fs.existsSync(p) ? fs.statSync(p).size : null });
}
for (const d of ["game_assets", "audio_runtime"]) {
  const p = path.join(web, d);
  result.engineFiles.push({ dir: d, present: fs.existsSync(p) });
}

const t0 = Date.now();
await send("Page.navigate", { url });
await new Promise((r) => setTimeout(r, 16000));

for (let i = 0; i < 6; i++) {
  const shot = await send("Page.captureScreenshot", { format: "png" });
  fs.writeFileSync(
    path.join(out, `probe-frame-${String(i + 1).padStart(2, "0")}.png`),
    Buffer.from(shot.data, "base64"),
  );
  const probe = await send("Runtime.evaluate", {
    expression: `JSON.stringify({t:${Date.now() - t0},status:document.querySelector('#status')?.className??null,progress:document.querySelector('#status-progress-status')?.textContent??null,splash:document.querySelector('#status-splash')?.className??null})`,
    returnByValue: true,
  });
  result.samples.push(JSON.parse(probe.result.value));
  await new Promise((r) => setTimeout(r, 1500));
}

const finalState = await send("Runtime.evaluate", {
  expression: `JSON.stringify({href:location.href,canvas:!!document.querySelector('#canvas'),ls:Object.fromEntries(Object.entries(localStorage))})`,
  returnByValue: true,
});
result.finalState = JSON.parse(finalState.result.value);
result.elapsedMs = Date.now() - t0;

const consoleLines = events
  .filter((e) =>
    ["Runtime.consoleAPICalled", "Log.entryAdded", "Runtime.exceptionThrown"].includes(e.method),
  )
  .map((e) => `${e.method} ${JSON.stringify(e.params)}`);
fs.writeFileSync(path.join(out, "probe-console.log"), consoleLines.join("\n") + "\n");
const net = events
  .filter((e) => e.method === "Network.responseReceived")
  .map((e) => `${e.params.response.status} ${e.params.response.url}`);
fs.writeFileSync(path.join(out, "probe-network.log"), net.join("\n") + "\n");

result.consoleLineCount = consoleLines.length;
result.consoleLines = consoleLines.slice(0, 40);
result.telLines = consoleLines.filter((l) => /TEL\.\d/.test(l)).length;
result.assetRequests = net.filter((l) => /game_assets|audio_runtime/.test(l));
result.failures = net.filter((l) => /^(4|5)\d\d /.test(l));
fs.writeFileSync(path.join(out, "probe-result.json"), JSON.stringify(result, null, 2));

console.log(
  JSON.stringify(
    {
      samples: result.samples,
      finalState: result.finalState,
      consoleLineCount: result.consoleLineCount,
      telLines: result.telLines,
      failures: result.failures,
      assetRequests: result.assetRequests.length,
      engineFiles: result.engineFiles,
    },
    null,
    2,
  ),
);

sock.close();
chrome.kill("SIGKILL");
server.kill();
setTimeout(() => process.exit(0), 300);
