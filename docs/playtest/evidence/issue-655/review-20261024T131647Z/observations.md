# Observations beyond the #655 rows

## Ambient and play-group preload failures, not claimed

Every published cold open logs `Preload ambient left 2 approved IDs unresolved` (`cafe-ambient-a.ogg`, `cafe-ambient-b.ogg`). This is the known #715 object, identical to `issue-630/local-release-20261024T093842Z/notes.md`, and it does not hold the loading screen.

Entering Puzzle stream adds `Preload play left 5 approved IDs unresolved`. The five are sound-effects IDs — `asset_catalog/01a151f8-b7d8-759c-89c5-e1be5eecb2b2.json` is `sound-effects/puzzle-fail`, which the published tree **does** serve (`GET game_assets/sound-effects/puzzle-fail.ogg` → `200`, 1 908 B; a sibling `puzzle-solved.ogg` → `404`).

The root cause is that the published tree serves no `asset_manifest.json` at the path the resolver reads — `res://asset_manifest.json` → `404` at the site root and under `game_assets/` — so every group resolves empty. Recorded here as an observation for the asset/catalog owner. **Not filed as a defect by this run**: this defect's AC9 keeps it to #332 / #333 / #335, and none of them owns the manifest route.

## Rows this run does not settle

| Criterion | State | Owner |
|---|---|---|
| 1 — quoted `specs/` release-status sentence | **unmet** — no such sentence on `a5b35ae` | #648 AC2 |
| 2 — deal path reaches the resolver on the published build | **fail** — no catalog request leaves the client | #479 + the publish step that carries the pair |
| 3 — one named outcome | **fail** — K1 not met, and the absence branch is not this answer | with 2 |
| 4 — absence recorded as `FAIL.T14` | n/a — answer is *enabled* | — |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** | — |
| 6 — published-release rows with build / session id | **recorded, and they fail** — the rows above are the published build's | with 2 |
| 7 — `#550` manifest rows | **not owed** — sweep has not re-run; `Defects` lines still name #655 | — |
| 8 — no `specs/` / asset change; `game/` only item 4 | **holds** — only this evidence folder is added | — |
| 9 — #332 / #333 / #335 relationship | **holds** — no edge added or implied | — |

No `specs/`, `game/`, `asset_catalog/`, or `game_assets/` file is changed by this run.
