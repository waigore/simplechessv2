# Setup and drives

Build: `fix/375-advice-ink-and-s3-play` off `origin/main` `abc6469`. Environment `ENV.2` (graphical). Back to [`notes.md`](notes.md).

## Prep

- Godot 4.7.2 (`ed1daf0bf`), Linux x86_64, `xvfb-run -a` at 1280×720, `gl_compatibility` (llvmpipe). No browser and no exported Web build were reachable, so the run is the desktop window on the shipped release scene graph.
- `godot --headless --path game --import --quit` → exit 0.
- `gdscript_tests.py test` → 21 suites pass; `coverage` → 85.6% (threshold 80).
- `gdlint game`, `gdformat --check game` → clean; `spec_lint.py` → 0 errors, 1 pre-existing glossary warning.

## Why the shipped graph, and how art reaches it

Both criteria are about what a player sees, and `main_release.tscn` has no `PlaytestSeams`, so `_advice_sim_factory()` returns `null` and `AdviceStreamTransport` is the only advice path; each drive asserts `release_scene_has_no_seams`. The release graph binds no art on its own — it asks L2 for piece and font IDs (E3/O5) — so each drive plays L2: `AssetResolver.resolve_ids` over the `play` group, every `BoardPresentation.PIECE_IDS` value, `BOARD_BG_ID` and `UiChrome.FONT_LATIN`, handed to `Presentation.provide_assets`. Without that the board has no pieces and the S3 drive's first pass rendered blank screens.

## Running

From the repo root, with a display (`xvfb-run -a` when there is none):

```
cp docs/playtest/evidence/issue-375/graphical-20261024T033000Z/logs/ink_probe.gd game/tmp_ink.gd
godot --path game -s tmp_ink.gd          # AC4; ~4 min, 12 pieces × 3 frames
cp docs/playtest/evidence/issue-375/graphical-20261024T033000Z/logs/gesture_probe.gd game/tmp_gesture.gd
godot --path game -s tmp_gesture.gd      # AC6/AC10 S3 leg; writes screenshots/
```

Each drive prints one JSON line per check and exits with its failure count. File headers describe the steps.

## Limits

- Desktop window, not the published Web build (ADR-0004 keeps them apart); verdicts are about the scene graph the Web Release export instantiates.
- The drives send press → move → release one event per frame, so they exercise a finger's timing rather than a slow human drag — which is what surfaced the pointer defect.
- `s3-error.png` and `s3-played.png` are identical: the S3 leg's moves were refused, so the board is unchanged between them.
