# Notes — #630 re-run on the published build

## What made this run different

Every earlier dispatch of #630 ended blocked or failed at verification for one reason: the published tree never carried #647's route, because `Web release` had not run on a `main` commit after the route merged. The served `index.pck` was still the 01:25 UTC, 252 144-byte artifact.

This run changed that precondition instead of recording it again: it dispatched the existing `Web release` workflow on `main` (`40096272525`), a normal repository operation and not a code or workflow change. It concluded `success` and deployed. The `index.pck` became 9 561 236 B with `last-modified` 13:00:58 GMT.

## What was done

1. **Gates on `main` `a5b35ae`**: `web_export.py --preset "Web Release"` rc 0; `--check-assets` rc 0 (35/35 files, 15 `audio_runtime/` copies); `--check-boot` rc 0 (14/14 boot IDs); `gdscript_tests.py test` → 28 passed.
2. **Control before redeploy**: the published URL at 390×844 showed 9 unresolved boot IDs, 14 asset open failures, still `Loading...` after 12 s.
3. **Published the route**: dispatched `Web release` on `main`, which passed and deployed.
4. **After redeploy**: no `Preload boot` line, no asset open failure, mode pick rendered, `/game_assets/icons/quit.svg` → 200.
5. **The check's red direction**: `probe/630-assetless-probe` (`232bfa0`), `main` minus every file under `game_assets/`, failed *Export Web release* with `the shipped tree carries no game_assets/ asset file` (run `40096643098`).

## Two things for their owners

- **ADR-0014 records the packed location, but the loose copy is what the browser fetches.** The pack carries `res://game_assets/…` and the exported tree also has `game_assets/` beside `index.html`. The resolver reads through `ResourceLoader` and succeeds either way, but the served HTTP path used this run is the loose copy, which the Decision does not name (#636, #647).
- **`--check-assets` alone is not the guard.** On a tree stripped of the loose directory but keeping the pack it stays green because it reads pack bytes; only `--check-boot` reddens. A future gate that trims the shipped tree should rely on `--check-boot`.

## What is not claimed

- No `quality.md` row is cleared. The board is reachable, not measured: the timed row, the sitting, save durability and localization each need their own run.
- The `ambient` group still fails on both builds (2 IDs) — #715.
- One cold open per phase; not a soak (#626).
