# Notes — #630 re-run of the reproduction on the published build

## What made this run different

Every earlier dispatch of #630 ended "blocked" or "failed at verification" for one reason: the
published tree never carried `#647`'s route, because the `Web release` workflow had not run on a
`main` commit after the route merged. That was still true when this run started — the served
`index.pck` was the 01:25 UTC, 252 144-byte artifact.

This run changed that precondition rather than recording it again: it dispatched the existing
`Web release` workflow on `main` (`gh workflow run web-release.yml --ref main`, run
[`40096272525`](https://github.com/waigore/simplechessv2/actions/runs/40096272525)), which is a
normal repository operation, not a code or workflow change. It concluded `success` and deployed.

## What was done

1. **Gates on `main` `a5b35ae`.** `web_export.py --preset "Web Release"` rc 0;
   `--check-assets` rc 0 (`35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)`);
   `--check-boot` rc 0 (`14 of 14 boot asset file(s) resolved`);
   `gdscript_tests.py test` → `28 headless unit test(s) passed`.
2. **Control before redeploy.** Published URL driven at 390×844 → `Preload boot left 9 approved IDs
   unresolved`, 14 asset open failures, `Loading...` on screen after 12 s. This is the defect as
   filed, re-measured, not copied.
3. **Published the route.** Dispatched `Web release` on `main`; it passed and deployed
   (`index.pck` → 9 561 236 B, `last-modified 13:00:58 GMT`).
4. **Published URL after redeploy.** Driven again at 390×844 → no `Preload boot` line, no asset open
   failure, mode pick rendered. `GET /game_assets/icons/quit.svg` → 200.
5. **The check's red direction.** Pushed a throwaway branch (`probe/630-assetless-probe`, `232bfa0`)
   that is `main` `a5b35ae` minus every file under `game_assets/`, and dispatched `Web release` on it.
   Run [`40096643098`](https://github.com/waigore/simplechessv2/actions/runs/40096643098) failed at
   *Export Web release* with **`the shipped tree carries no game_assets/ asset file`**.

`#647`'s units were all confirmed on `main` before any of this: `boot_failed`, the `_preload` failure
path, `prepare_asset_root`/`discard_asset_root`, `--check-assets` + `--check-boot` in
`web-release.yml`, and `_check_boot_failure_surfaced` replacing the old stall-asserting
`_check_preload_gap`.

## Two things worth recording for their owners

- **ADR-0014 records the packed location, but the loose copy is what the browser fetches.**
  `prepare_asset_root` stages `game_assets/` into the project, the pack carries `res://game_assets/…`,
  and the exported tree *also* has `game_assets/` beside `index.html`. The resolver reads through
  `ResourceLoader`, which succeeds either way, but the served HTTP path the browser actually used
  this run is the loose copy — which ADR-0014's Decision does not name. Recorded, not graded (#636,
  #647).
- **`--check-assets` alone is not the guard.** On a tree stripped of the loose `game_assets/` but
  keeping the pack, `--check-assets` stays green because it also reads pack bytes; only
  `--check-boot` reddens. The CI failure above is the real check (`--check-assets`), and the red run
  produced the correct message — but a future gate that trims the tree should rely on `--check-boot`.

## What is not claimed

- No `quality.md` row is claimed cleared. The board is now *reachable*; "board playable within 3 s"
  still needs its own timed run, and the sitting, save-durability and localization rows need theirs.
- The `ambient` group still fails on both builds (`music/cafe-ambient-a.ogg`,
  `music/cafe-ambient-b.ogg`, 2 IDs). That is #715's object.
- One cold open per phase. Not a soak (#626).
