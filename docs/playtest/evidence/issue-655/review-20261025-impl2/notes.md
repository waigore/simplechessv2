# Notes — #655, 2026-10-25 implement pass (parallel id 2), `4e50418`

## Which answer this run was judged under

**Catalog enabled in the published release** — the [product-owner comment on #648](https://github.com/waigore/simplechessv2/issues/648#issuecomment-6381343549).

The `specs/` sentence that states it is still **absent**. `git grep -n -i "ships enabled\|release status\|published release" origin/main -- specs/` on `4e50418` → **no match**. `specs/technical/configuration.md` `T9`/`T10` still read *"Set per deployment"* and `B5` still only *"T9 or T10 missing: every deal fails (`FAIL.T14`); Elo kept; log"*. That sentence is #648's AC2; #655's criterion 8 forbids writing it here. **Criterion 1 stays unmet.**

## What is new in this run

Nothing about the defect's substance. That is the finding: a full pass later, on a newer `main`, the measurement is identical.

- **`main` moved, nothing relevant did.** The worktree is on `4e50418` (previous pass: `8cdfd45`). `game/session_router.gd:33-34` still initialise `advice_endpoint` / `advice_api_key` to `""`; the only assignment in `game/` is the test seam `game/advice_ui_test.gd:40`.
- **The published artefact has not moved.** `index.pck` `last-modified` is still 2026-10-24 13:00:58 GMT, 9561236 bytes — the same artefact #782 measured. Its rows cannot have changed.
- **The `C5` leg is still green**, re-measured not inherited, on a new `TEL.3` session.
- **The environment is healthy**: import and the unit suite run clean; the suite is 29/29.

## Why this pass writes no code

The defect's item 4 clause is the only `game/` change it may own — *"If, and only if, item 4's `C5`/`S1` leg fails on measurement"*. It measures conforming, so no repair is owed. The deal half is not this issue's to write:

| Need | Owner | Why not here |
|---|---|---|
| The one `specs/` release-status sentence | #648 AC2 | criterion 8: no `specs/` change on this issue |
| Real `T9`/`T10` in a published client | #479 → the deploy path | #479's body: *"Client delivery is a deploy-time decision, out of scope here"*; its AC requires that no `specs/` file name a delivery mechanism and that no `game/` file change |
| A code defect if the deal still fails once those land | a new tracker | the body files that *against the code*, not against #648 |

Live check: `gh pr list --state all --search "648 in:title"` and `"479 in:title"` → **no PR in either**, open or merged; both issues are `status:pending-implementation`.

## Rows this run does not settle

| Criterion | State | Owner |
|---|---|---|
| 1 — quoted `specs/` release-status sentence | **unmet** — absent on `4e50418` | #648 AC2 |
| 2 — no `B5` empty-value refusal | **fail** | #479 + publish step |
| 3 — one named outcome | **fail** | with 2 |
| 6 — published rows | **fail** — measured, not held | with 2 |

No `specs/`, `game/`, `asset_catalog/`, or `game_assets/` file is changed by this run.
