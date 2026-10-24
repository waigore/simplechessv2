# Evidence — defect #592 acceptance, graphical re-run (2026-10-24T06:40Z)

Environment and build for the graphical re-run. Frames and readings: [notes.md](notes.md).

Graphical environment for defect #592: the shared-game demo rendered in a real
browser (Godot 4.7.2 web export in Google Chrome, headless=new with SwiftShader
WebGL 2). `xvfb-run` is not installed on this host, so the browser is the
graphical display used instead of an X virtual framebuffer.

- **Build**: `main` `42e0218` = `origin/main` `d07ec30` at the time of the
  verification comment plus the #63 acceptance evidence merge; the demo tree is
  identical to `origin/main`. The worktree checkout is `/private/var/folders/.../acc592`
  (detached at `d07ec30`), exported from `demos/shared-game/`.
- **Engine**: Godot `4.7.2.stable.official.ed1daf0bf`, Web build
  (`gl_compatibility`), 720×1280 portrait, `canvas_items` stretch.

## Why a scratch export copy

`demos/shared-game/` is a standalone project with no export preset, and its
`DemoAssetLoader` resolves assets from the repo sibling roots (`game_assets/`,
`audio_runtime/`) through absolute filesystem paths, which do not exist inside a
web pack. To get a real rendered frame without changing any tracked file, an
**untracked scratch copy** of the demo was exported:

1. copy `demos/shared-game/` to a temp dir, plus a temp `export_presets.cfg`
   (Web, 720×1280) and a `project.godot` with `run/main_scene="res://main.tscn"`;
2. copy `game_assets/` (minus license `.txt`) and `audio_runtime/` next to it so
   they are bundled;
3. two-scope-only shims for the browser build: `DemoAssetLoader._init` uses
   `res://` as the asset root on web, and `_load_one` loads through
   `ResourceLoader` (import remaps) instead of `FileAccess` on web.

None of this touches the demo's board, coordinate or drawing code: labels come
from `BoardView.CoordLabels` unchanged, so the rendered labels are the shipped
geometry. The shims only make the same cataloged assets load in the browser.

## Commands

```
godot --headless --path <scratch>/demo --import --quit
godot --headless --path <scratch>/demo --export-release "Web Demo" <scratch>/build/demo/index.html
cd <scratch>/build/demo && python3 -m http.server 8791
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --no-sandbox \
  --use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader --ignore-gpu-blocklist \
  ...   # driven with puppeteer-core (temp install): wait for the loader splash to clear + 8 s
```

Screenshots: dsf 1 full frame, dsf 2 board clip (x 0..720, y 150..800) and dsf 2
coordinate-band clip (x 0..720, y 900..1000).
