# Graphical notes

Judged `main` at `11309eb`.

Web Playtest export (`custom_features=playtest`, output `../build/web/index.html`) exited 0 and wrote non-empty `build/web/index.html`, `index.wasm`, and `index.pck`. Web Release export exited 0 to a scratch directory. `/build/web/` stays gitignored.

The host has no `libasound.so.2`, so Playwright Chromium 1248 exited 127 and could not open the Web build. The rendered session is the Godot X11 playtest window under Xvfb (1280×720), which `specs/technical/verification.md` S2 allows alongside Web/HTML5. Audio fell back to the dummy driver; that did not block the frame.

`screenshots/01-playtest-ready.png` shows `mode-pick-ready` and the debug panel: Pause, Resume, Inspect, stage id, Jump, Overlay. `screenshots/02-release-ready.png` is the same hook with `playtest_override` forced off before `_ready`: the hook remains, and the debug panel is absent.

Design and UX chess protocols stay out of scope for this foundation epic. This run proves the graphical playtest session the epic's goal names.
