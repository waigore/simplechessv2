# Notes — #402 quality-row sweep on the shipped release build

## What was run

Four cold opens of `https://waigore.github.io/simplechessv2/` (commit `98d3473`, published by
run `39991174434`) in Chrome at a 390×844 phone viewport, waiting 25 s each. One local control:
the same commit exported with `python3 .github/scripts/web_export.py --preset "Web Release"` and
served with `python3 -m http.server` from `build/web/`.

## What was judged

The sweep is `critical-only`: it judged only the cold-open path, and stopped there because the
first row it could judge failed in a way that makes every later row unobservable.

Timeline of one cold open (`logs/release-cold-open.log`):

| t (ms) | Event |
|---|---|
| 719 | first WebGL canvas exists (engine scaffolding, still `EX.loading`) |
| 1728 | `Godot Engine v4.7.2.stable.official` |
| 2160 | `ERROR: Preload boot left 9 approved IDs unresolved` |
| 25000 | capture ended; screen still `Loading…` |

9 `ERROR: Error opening file 'game_assets/…'` lines precede the preload failure; 15 individual
open failures are logged across the `boot` group. `game/asset_resolver.gd:127–129` returns from
`_preload` without `done.emit()` when any approved ID is unresolved, and `boot_ready` is the only
transition out of `STAGE_LOADING` (`game/session_router.gd:145–152`, `:352`). The stall is
therefore structural, not a slow load.

## Why the asset root is missing

`game_assets/` is the repo-root sibling of the Godot project (ADR-0005), and the resolver opens
assets by disk path. The published `index.pck` is 221 228 bytes and contains none of the 38
cataloged files; the page returns `404` for every asset URL. `logs/preset-attempts.log` records
every export-preset route tried against the same commit; none of them pack the asset root,
because Godot 4.7.2 drops export paths outside the project tree, and `export_files` (the one field
that would accept them) overrides the asset scan so no scripts ship. Serving the assets loose
beside `index.html` is also not enough: the browser issued no request for any asset file
(`logs/local-release-asset-requests.log`).

Packing the asset root into the Web build therefore needs a mechanism chosen in `specs/` — ADR-0005
and ADR-0007 say nothing about how the repo-root asset root reaches the browser build — plus a
build-time check that fails the export when the shipped tree carries no assets. That is filed as
the blocking defect #630; nothing was fixed inside the gate.

## Why this is not a defect per row

`specs/definition/quality-regression-owners.md` files a defect against the owning wave per failing
row. Here ten rows are unobservable for one shared, screen-wide cause; filing ten defects against
#34, #35, and #37 would split one export defect into three wave owners and still leave the export
nobody's. The record files **one** defect against the Web export and cites it once for every row
it blocks, and says so explicitly on #402.

## What unblocks each row

| Row | Unblocked by |
|---|---|
| Load time — board playable ≤ 3 s | the export defect |
| Performance | the export defect, then `SIT.4`-equivalent capture on the release build (the seam is absent from the release export; #544 owns the seam, #506 owns the release-side verdict shape) |
| Observability | the export defect + the release-side observability verdict (#506); the release export emits no `TEL.*` lines today, which the captured log shows |
| Reliability, Save durability | the export defect, then #557 / #558 on the shipped build |
| Accessibility — legibility | the export defect, then the 390×844 hand read (#546 owns the seam) |
| Accessibility — shape / color, Localization | the export defect, then the reviews / `PTU-localization` spot-check #536 and #494 name |

## Marked, not judged

- Advice readiness is `not-judged` rather than `pass`: Advice is Off in the shipped build, and the
  board is unreachable, so no reading was taken.
- The piece-shape and color claims are review methods outside playtest (`tools-situational.md`);
  this run cannot judge them on a build that renders no piece, and marks them as such rather than
  passing them by proxy.
