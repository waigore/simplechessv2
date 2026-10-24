# Notes — #402 quality-row sweep on the shipped release build

## What was run

Four cold opens of `https://waigore.github.io/simplechessv2/` (commit `98d3473`, run `39991174434`) in Chrome at a 390×844 phone viewport, 25 s each. One control: the same commit exported with `python3 .github/scripts/web_export.py --preset "Web Release"`, served from `build/web/`.

The sweep is `critical-only`: it judged the cold-open path and stopped where the first judgeable row failed in a way that makes every later row unobservable.

## Timeline of one cold open (`logs/release-cold-open.log`)

| t (ms) | Event |
|---|---|
| 719 | first WebGL canvas (engine scaffolding; still `EX.loading`) |
| 1728 | `Godot Engine v4.7.2.stable.official` |
| 2160 | `ERROR: Preload boot left 9 approved IDs unresolved` |
| 25000 | capture ended; screen still `Loading…` |

9 `ERROR: Error opening file 'game_assets/…'` lines precede the preload failure (15 individual open failures across the `boot` group). `game/asset_resolver.gd:127–129` returns from `_preload` without `done.emit()` when an approved ID is unresolved, and `boot_ready` is the only transition out of `STAGE_LOADING` (`game/session_router.gd:145–152`, `:352`). The stall is structural, not a slow load.

## Why the asset root is missing

`game_assets/` is the repo-root sibling of the Godot project (ADR-0005) and the resolver opens assets by disk path. The published `index.pck` is 221 228 bytes with none of the 38 cataloged files, and every asset URL `404`s. `logs/preset-attempts.log` records every export-preset route tried on the same commit; none pack the asset root, because Godot 4.7.2 drops export paths outside the project tree, and `export_files` overrides the asset scan so no scripts ship. Serving the assets loose beside `index.html` also fails: the browser requested no asset file (`logs/local-release-asset-requests.log`).

Packing the asset root needs a mechanism chosen in `specs/` — ADR-0005 and ADR-0007 say nothing about how the repo-root asset root reaches the browser build — plus a build-time check that fails the export when the shipped tree carries no assets. Filed as #630; fixed nothing inside the gate.

## Why not a defect per row

`quality-regression-owners.md` files a defect against the owning wave per failing row. Here ten rows are unobservable for one screen-wide cause; splitting it would put one export defect across #34, #35, and #37 and still leave the export unowned. The record files one defect, #630, and names the rows it blocks.

## Unblocking

#630 unblocks the screen-behind rows. After it: Performance needs release-side capture (#544 seam, #506 verdict shape); Observability is not #630's — it judges the playtest-certified build (`SIT.5` over `E1`), and needs #506's build envelope rather than a release-side `TEL.*` (#729); Reliability and Save durability need #557 / #558 on the shipped build; legibility needs the 390×844 read (#546 seam); shape, color, and Localization need the reviews #536 and `PTU-localization` (#494) name.

Marked, not judged: advice readiness (Advice Off, no board) and the shape/color claims, which `tools-situational.md` places outside playtest and cannot be judged on a build that renders no piece.
