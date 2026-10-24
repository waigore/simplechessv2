# Setup and drives

Build: `fix/375-advice-ink-and-s3-play` off `origin/main` `abc6469`. Environment `ENV.2` (graphical). Back to [`notes.md`](notes.md).

## Prep

- Godot 4.7.2 (`ed1daf0bf`), Linux x86_64, `xvfb-run -a` at 1280×720, `gl_compatibility` (llvmpipe). No browser and no exported Web build were reachable, so the run is the desktop window on the shipped release scene graph.
- `godot --headless --path game --import --quit` → exit 0 before either drive.
- `python3 .github/scripts/gdscript_tests.py test` → 21 suites pass
- `python3 .github/scripts/gdscript_tests.py coverage` → 85.6% (threshold 80), gdtoolkit 4.5.0
- `gdlint game`, `gdformat --check game` → clean; `python3 .github/scripts/spec_lint.py` → 0 errors, 1 pre-existing glossary warning

## Why the shipped release graph

Both criteria are about what a player sees. `main_release.tscn` has no `PlaytestSeams`, so `_advice_sim_factory()` returns `null` and `AdviceStreamTransport` — the real HTTP/NDJSON transport — is the only advice path; the drives assert `release_scene_has_no_seams`. The release graph binds no art on its own: it asks L2 for the piece and font IDs (E3/O5). Each drive plays the L2 role it would have on the published build, resolving the `play` group plus every `BoardPresentation.PIECE_IDS` value and `UiChrome.FONT_LATIN` through `AssetResolver.resolve_ids` and handing them to `Presentation.provide_assets`. Without that the board has no pieces and no readable copy — the first pass of the S3 drive rendered blank screens for exactly that reason.

## Cockpit: `logs/ink_probe.gd` (AC4)

1. Instantiate `main_release.tscn`, `provide_assets`, enter `mode-pick C1` → `shared-setup C5` with `router.advice_on = false`.
2. For each of the twelve piece types: `render_position` an empty board, the one piece on e4, then the same position again with `render_advice({"from": "e4", "to": "e2"})`; read the frame back after `frame_post_draw`.
3. Classify pixels into ink / body / overlap and report coverage. Exit code = failed checks.

Run: `godot --path game -s <this folder>/logs/ink_probe.gd` from the repo root (with `xvfb-run -a` when there is no display). Copy the drive into `game/` first if the console resolves `-s` against the project: `cp logs/ink_probe.gd game/tmp_ink_probe.gd && godot --path game -s tmp_ink_probe.gd`.

**Do not** call `render_advice` before `render_position`: the presentation re-applies the advice fields on every position render, so marks set first are overwritten with `null` and the probe measures nothing.

## Cockpit: `logs/gesture_probe.gd` (AC6 / AC10)

1. Instantiate `main_release.tscn`, `provide_assets`, `advice_on = true`, `advice_endpoint = http://127.0.0.1:1/advice` (a closed port stands in for a stopped backend), `locale = en`, `last_mode = none`; enter play through `mode-pick C1` → `shared-setup C5`.
2. Wait for `session.advice_error`, then 400 ms for the park: `online == false`, `advice_client.failed()`, `play_ui_state == S3`, `EX.error` panel visible. Screenshot `s3-error.png`.
3. Drive gestures through `Presentation._accept_pointer` — the same handler `handle_gui_input` feeds for a touch: drag `g1f3`, drag `g8f6`, tap-select + tap-destination `e2e4`. Screenshot `s3-played.png`.
4. Press `AdviceErrorDismiss`, check S1 and the panel hidden, drag `d7d5`. Screenshot `after-dismiss.png`.

Run the same way; a display is required for the screenshots.

## Limits

- Desktop window, not the published Web build (ADR-0004 keeps them separate). Verdicts here are about the shipped scene graph, the same object the Web Release export instantiates.
- The pointer-drive finding is filed on its own `type:defect`; the probe drives press → move → release one event per frame, so it exercises a finger's timing rather than a slow human drag.
- `s3-error.png` and `s3-played.png` are identical frames: the S3 legs' moves were refused (filed), so the board is unchanged between them.
