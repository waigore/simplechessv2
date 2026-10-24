# Notes — #630 re-run of the reproduction

## What was re-run

The issue's **Reproduction steps**, unchanged, against both the local `Web Release` export and the
published URL, at 390×844 with a headless Chrome. Step 6 (`curl` the asset path) was re-measured on
both trees.

## What the local release build shows

- Boot no longer stalls. There is no `Preload boot` line at all: every `boot` ID resolved, so the
  resolver emitted `boot_ready`, `SessionRouter` left `STAGE_LOADING`, and the mode pick is on screen.
- The asset root is present and served loose beside `index.html` (`game_assets/`, 39 files), which is
  the ADR-0014 route `#647` landed (`.github/scripts/web_export.py` `prepare_asset_root` +
  `asset_resolver.gd` reading the source path on Web). `index.pck` is 9 561 236 B, not the
  221 228-byte asset-less size the defect measured.
- `--check-assets` prints `35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)` and
  `--check-boot` prints `14 of 14 boot asset file(s) resolved`. Removing `game_assets/` from a copy
  of the tree makes `--check-boot` fail with `0 of 14 boot asset file(s) resolved — no route serves`,
  naming all 14 IDs.
- **Caveat on the "red" direction**: `--check-assets` takes the same shipped tree, reads the PCK's
  bytes, and the PCK still carries `game_assets/…` import sidecars, so `--check-assets` stays green
  on a tree whose loose `game_assets/` is gone. Only `--check-boot` reddens. Since `#647`
  deliberately kept the packed entries, `--check-assets` alone is not the guard the issue assumed;
  `--check-boot` is. Recorded here as an observation for `#647`/`#715`, not acted on by this defect.

## What the published build still shows

Unchanged from the original report: `Preload boot left 9 approved IDs unresolved`, 14 asset open
failures, and `Loading...` still on screen after a settle. Its `index.pck` is dated
2026-10-24 01:25 UTC and carries no loose `game_assets/`, i.e. it was published from a commit that
predates `#647`'s route and has not been redeployed since.

## Why this defect cannot observe its published-build criteria yet

The `Web release` workflow has not produced a run on a `main` commit after `#647`'s route merged
(`e41a6f5`): the last `Web release` run is from 05:08 UTC on the day, and the workflow has no run at
all on the current `main` tip. The published tree therefore cannot carry the fix until that workflow
runs. This is the "blocked on `#647` landing" condition the issue's *Dependencies* names: the
correct recorded state is a fail of the published-build acceptance criteria, on `#647`, not a fresh
issue and not a spec, code or workflow change from this defect.

## Ambient

`music/cafe-ambient-a.ogg` and `music/cafe-ambient-b.ogg` do not resolve on the local release build
either (`Preload ambient left 2 approved IDs unresolved`). They are the `ambient` group, they do not
hold the loading screen, and they are #715's object.
