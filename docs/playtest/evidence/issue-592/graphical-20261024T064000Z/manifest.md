# Manifest — defect #592 graphical acceptance evidence

- **Issue**: #592 — `demos/shared-game: coordinate labels paint inside the 8x8 and half below 4.5:1`
- **Build**: `main` (`d07ec30` worktree, demo tree identical to `origin/main` `42e0218`)
- **Engine**: Godot 4.7.2 stable web export (`gl_compatibility`), 720×1280, in
  Google Chrome `--headless=new` with SwiftShader WebGL (no `xvfb-run` on this host)
- **Platform**: macOS/arm64, browser-rendered graphical frame (not headless Godot)
- **Environment**: scratch export copy of `demos/shared-game/` with the cataloged
  assets bundled; two web-only asset-loading shims, no change to board or
  coordinate drawing. Detail: `setup.md`.
- **Capture tooling**: the capture script ran from a temp directory outside the
  repo and is not kept; `setup.md` records the commands and browser flags.
- **Commands**: import, `--export-release "Web Demo"`, `python3 -m http.server 8791`,
  Chrome + puppeteer-core capture (splash cleared + 8 s settle)
- **Screenshots**
  - `screenshots/demo-shared-game-full.png` — full 720×1280 frame
  - `screenshots/board-2x.png` — board clip at deviceScaleFactor 2
  - `screenshots/coordinate-band-2x.png` — bottom coordinate band at deviceScaleFactor 2
- **Logs**
  - `logs/browser.log` — console (asset warnings, errors, failed requests): all 0
- **Notes**: `notes.md` — graphical pass/fail per `PER.R7`; `setup.md` — build, export copy, commands
