# Build observations — #557 graphical run `20261023T230618Z`

What the published build did on a cold open, and the shortest path to re-observe it.

## Cold open

- Cold open, 30 s settle (`logs/leg-0-driver.log`): WebGL context and Godot banner present; `ERROR: Preload boot left 9 approved IDs unresolved`; screen still reading "Loading…" (`screenshots/leg-0-cold-open-390x844.png`).
- The published `index.pck` is **252 080 bytes**. It carries the catalog's asset *paths* as manifest text (11 `.svg`, 5 `.woff2` strings) but no asset bytes, and `GET game_assets/icons/quit.svg` answers **404** (`logs/leg-0-driver.log`).
- No DOM surface exposes the engine: `Engine` and `JavaScriptBridge` are undefined in page scope, so a leg cannot be driven past the canvas by script. That is a property of the release export, not a finding.

## Reproduce

Three cold opens of the published URL, 30 s settle each, in Chrome with a viewport of 390×844 @ DPR 2:

1. Open the URL; read `localStorage.getItem("simplechessv2.persist.v1")` → expected default document. **Observed `null`.**
2. Screenshot the screen → expected mode pick. **Observed `Loading…`.**
3. Confirm a panel is reachable: `fetch('game_assets/icons/quit.svg')` → expected 200. **Observed 404.**

The three legs each stop at step 2: no mode pick means no puzzle result, no commit, no reopen comparison.
