// #655 published-release observation driver.
// Boots the published build in headless Chrome, taps "Puzzle stream" on the mode
// pick, and captures console + network so the first deal's refusal is observed
// rather than inferred. Screenshots at 390x844 CSS px, DPR 2, mobile + touch.
//   node drive_published.mjs <url> <outDir> <label>
import { spawn } from "node:child_process";
import { writeFileSync } from "node:fs";

const url = process.argv[2], outDir = process.argv[3], label = process.argv[4];
const PORT = 9224;
const browser = spawn(
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  [
    "--headless=new", "--remote-debugging-port=" + PORT,
    "--user-data-dir=" + outDir + "/profile-" + label,
    "--window-size=390,844", "--no-first-run", "--no-default-browser-check",
    "--disable-gpu", "--enable-unsafe-swiftshader",
    "--autoplay-policy=no-user-gesture-required", "about:blank",
  ],
  { stdio: "ignore" },
);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function target() {
  for (let i = 0; i < 80; i++) {
    try {
      const list = await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json();
      const page = list.find((t) => t.type === "page");
      if (page) return page;
    } catch {}
    await sleep(250);
  }
  throw new Error("no devtools target");
}

function connect(wsUrl) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl);
    let id = 0;
    const pending = new Map();
    const events = [];
    ws.addEventListener("message", (e) => {
      const m = JSON.parse(e.data);
      if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
      else if (m.method) events.push(m);
    });
    ws.addEventListener("open", () => {
      const send = (method, params = {}) => new Promise((res) => {
        const i = ++id; pending.set(i, res);
        ws.send(JSON.stringify({ id: i, method, params }));
      });
      resolve({ send, events, close: () => ws.close() });
    });
    ws.addEventListener("error", reject);
  });
}

const t0 = Date.now();
const stamp = () => ((Date.now() - t0) / 1000).toFixed(2).padStart(6) + "s";
const c = await connect((await target()).webSocketDebuggerUrl);
for (const d of ["Runtime", "Log", "Page", "Network"]) await c.send(d + ".enable");
await c.send("Emulation.setDeviceMetricsOverride", { width: 390, height: 844, deviceScaleFactor: 2, mobile: true });
await c.send("Emulation.setTouchEmulationEnabled", { enabled: true, maxTouchPoints: 5 });
await c.send("Page.navigate", { url });

const shot = async (n) => {
  const r = await c.send("Page.captureScreenshot", { format: "png" });
  writeFileSync(`${outDir}/${n}.png`, Buffer.from(r.result.data, "base64"));
};
const tap = async (x, y) => {
  await c.send("Input.dispatchTouchEvent", { type: "touchStart", touchPoints: [{ x, y }] });
  await c.send("Input.dispatchTouchEvent", { type: "touchEnd", touchPoints: [] });
};

// ENV.1-class boot settle for the published build: #630 measured ~20 s to mode pick.
await sleep(32000);
console.log(stamp() + " MARK mode-pick ready");
await shot(label + "-1-mode-pick-390x844");
await tap(195, 205); // "Puzzle stream" on the mode pick (390x844 CSS px)
await sleep(8000);
console.log(stamp() + " MARK entered puzzle stream");
await shot(label + "-2-puzzle-play-390x844");

const out = [];
for (const e of c.events) {
  if (e.method === "Runtime.consoleAPICalled")
    out.push(`[console.${e.params.type}] ` + e.params.args.map((a) => a.value !== undefined ? a.value : (a.description ?? a.type)).join(" "));
  else if (e.method === "Runtime.exceptionThrown")
    out.push(`[exception] ${e.params.exceptionDetails.text} ${e.params.exceptionDetails.exception?.description ?? ""}`);
  else if (e.method === "Log.entryAdded")
    out.push(`[log.${e.params.entry.level}] ${e.params.entry.source}: ${e.params.entry.text}`);
  else if (e.method === "Network.requestWillBeSent")
    out.push(`[net.req] ${e.params.request.method} ${e.params.request.url}`);
}
writeFileSync(`${outDir}/${label}-run.log`, out.map((l) => `${stamp()} ${l}`).join("\n") + "\n");
c.close(); browser.kill("SIGKILL"); process.exit(0);
