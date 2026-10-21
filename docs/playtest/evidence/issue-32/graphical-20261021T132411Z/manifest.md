# Playtest evidence manifest

| Field | Content |
|-------|---------|
| Issue | 32 |
| Environment | graphical |
| Build / session id | Editor-display playtest build (`DISPLAY=X11`). `TEL.3` is emitted by the headless harness and by debug actions; this capture did not press those controls. Web export session id was not captured: the host Chromium binary cannot load `libasound.so.2`. |
| Coverage mode | `full` (intersected with this epic: scaffold session only; chess design and UX protocols are out of scope) |
| Godot | 4.7.2.stable.official.ed1daf0bf |
| Commit | `11309eb5c6cd70d6d488b11049b17cd3265a0e32` |

## Results

| Story or protocol | Result |
|-------------------|--------|
| `ENV.2` rendered playtest session (`mode-pick-ready` plus `DBG` panel) | pass |
| Release render (no debug panel) | pass |
| Web/HTML5 export artifacts (`index.html`, `index.wasm`, `index.pck`) | pass |

## Paths

- Screenshots: `screenshots/01-playtest-ready.png`, `screenshots/02-release-ready.png`
- Notes: `notes.md`
- Logs: `logs/graphical-playtest.log`, `logs/graphical-release.log`
