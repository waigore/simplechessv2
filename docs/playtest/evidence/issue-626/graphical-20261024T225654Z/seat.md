# The seat — #626 mobile-browser sitting

What this machine can and cannot reach. Build provenance in [builds.md](builds.md); the readings
themselves in [manifest.md](manifest.md); method findings in
[notes-method.md](notes-method.md).

## Hardware and browser

Headless Chrome **156.0.8078.47** on macOS 27.0.1 arm64, viewport **390×844 CSS px** at
**DPR 2** with touch emulation — a phone-class viewport, not a phone.

**No phone is attached.** What the seat does reach:

- the published build's own responsive layout and its touch hit areas at a phone width;
- one continuous sitting with real wall-clock time passing;
- **background → foreground** through the browser's tab lifecycle (a second tab takes the
  foreground, the game tab is activated again);
- **quit → reopen** in a persistent origin store, and a cache-ignoring **reload**;
- the page's own `localStorage` document, read in the page's origin — no desktop devtools path;
- a **renderer death** (`chrome://crash`) — that leg is read in #557's desktop folder, not here.

## What only a handset can reach, and is therefore `not-judged`

- the mobile OS suspending or killing the browser process;
- `localStorage` eviction under device storage pressure;
- tab discard under memory pressure;
- battery/thermal throttling, and a real cellular network's latency.

These stay `not-judged` — never `pass`. The residual risk they carry is named, not covered.

## Why the lifecycle freeze is not the background leg

The first two attempts froze the page with `Page.setWebLifecycleState: frozen` and resumed with
`active`. That path **does not resume in this headless build**: after resume the page keeps
`document.hidden: true`, `requestAnimationFrame` never fires, and every later input dispatch
hangs (`logs/probes/resume-path.json`). The driver then switched to a real second-tab
backgrounding (`logs/probes/background-tab.json`), which is what a phone's app switch looks like
from the page's side. Neither attempt is used as a row.
