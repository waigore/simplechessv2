# Notes — #655, 2026-10-24 implement pass (parallel id 2), `ddaca90`

## Which answer this run was judged under

**Catalog enabled in the published release** — the [product-owner comment on #648](https://github.com/waigore/simplechessv2/issues/648#issuecomment-6381343549).

The `specs/` sentence that states it is still **absent**. `git grep -n -i "ships enabled\|release status\|published release" origin/main -- specs/` on `ddaca90` → **no match**. `specs/technical/configuration.md` `T9`/`T10` still read *"Set per deployment"* and `B5` still only *"T9 or T10 missing: every deal fails (`FAIL.T14`); Elo kept; log"*. That sentence is #648 AC2; #655's criterion 8 forbids writing it here. **Criterion 1 stays unmet.**

## What is new in this run

**#479's decision is written, and it closes the delivery question the wrong way for this defect.** See [`finding-479.md`](finding-479.md).

## What this run measured, not inherited

- **`main` moved, nothing relevant did.** Worktree on `ddaca90` (previous pass: `4e50418`). `game/session_router.gd:33-34` still initialise `advice_endpoint` / `advice_api_key` to `""`; the only assignment in `game/` is the test seam `game/advice_ui_test.gd:40`.
- **The published artefact has not moved.** `index.pck` `last-modified` 2026-10-24 13:00:58 GMT, 9561236 bytes, `etag "6adcac0a-91e494"` — the same artefact #782 measured, so its rows are unchanged and criterion 6 is correctly **held**, per *Expected behavior*'s sequencing note.
- **The `C5` leg is still green**, re-measured not inherited, on a fresh `TEL.3` `sess-1792860958076-14788-playtest-192056`.
- **The environment is healthy**: import and the unit suite run clean; 29/29.

## Why this pass writes no code

The defect's item 4 clause is the only `game/` change it may own — *"If, and only if, item 4's `C5`/`S1` leg fails on measurement"*. It measures conforming (repaired in #694), so no repair is owed. The deal half is not this issue's to write:

| Need | Owner | Why not here |
|---|---|---|
| The one `specs/` release-status sentence | #648 AC2 | criterion 8: no `specs/` change on this issue |
| A published client carrying real `T9`/`T10` | **nobody, after #806** — #479 records the exclusion | #479 AC1: no `specs/` file may name a mechanism, and no `game/` change |
| A code defect once a pair exists and the deal still fails | a new tracker | the body files that *against the code*, not against #648 |

## Rows this run does not settle

| Criterion | State | Owner |
|---|---|---|
| 1 — quoted `specs/` release-status sentence | **unmet** — absent on `ddaca90` | #648 AC2 (itself `blocked_by` #479) |
| 2 — no `B5` empty-value refusal | **fail** | a deploy-path task (see above) |
| 3 — one named outcome | **fail** | with 2 |
| 6 — published rows | **held** — artefact unchanged, prerequisites unlanded | with 2 |

No `specs/`, `game/`, `asset_catalog/`, or `game_assets/` file is changed by this run.
