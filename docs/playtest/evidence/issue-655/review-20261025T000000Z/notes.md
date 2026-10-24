# Notes — #655, 2026-10-25 implement pass (parallel id 2)

## Which answer this run was judged under

**Catalog enabled in the published release** — the [product-owner comment on #648](https://github.com/waigore/simplechessv2/issues/648#issuecomment-6381343549). The `specs/` sentence that states it has **not** landed: on `origin/main` `8cdfd45`, `specs/technical/configuration.md` `T9`/`T10` read *"Set per deployment"* and `B5` only *"T9 or T10 missing: every deal fails (FAIL.T14); Elo kept; log"*. `git grep -n "ships enabled\|release status" origin/main -- specs/` → no match. That sentence is #648's AC2; criterion 8 forbids writing it here. Criterion 1 stays **unmet**.

## What is new in this run

Nothing here changes the defect's substance; that is the point of recording it.

- **The published build has not moved.** `index.pck` `last-modified` is still 2026-10-24 13:00:58 GMT, so this run measured the same artefact (`a5b35ae`, run 40096272525) as #782. A fresh cold open reproduces the same outcome: **zero outbound catalog or advice requests** — the `index.*` bundle and one blob, then `puzzle stream: deal read failed (status)`. That is `B5`'s empty-value guard, not a transport failure.
- **The source has not moved either.** `game/session_router.gd:33-34` still initialise `advice_endpoint` / `advice_api_key` to `""`; the only assignment in `game/` is the test seam in `game/advice_ui_test.gd:40`.
- **The `C5` leg is still green** on a clean `8cdfd45` worktree, byte-identical to the recorded probe log, on a new `TEL.3` session: `J-puzzle-session.S1` → `puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`J-puzzle-session.S2`).
- **The environment is healthy here**: import, headless smoke, and the probe all run clean on `8cdfd45`; the verify pass's import failure did not reproduce.

## What this pass did not do

It wrote no code, because there is nothing in scope to write: the `C5` repair landed in #694, and the deal half is #648's and #479's. It did not move the issue by its own summary, and changed no other issue. The disposition proposal is in [`disposition.md`](disposition.md).

## Rows this run does not settle

| Criterion | State | Owner |
|---|---|---|
| 1 — quoted `specs/` release-status sentence | **unmet** — absent on `8cdfd45` | #648 AC2 |
| 2 — no `B5` empty-value refusal | **fail** | #479 + publish step |
| 3 — one named outcome | **fail** | with 2 |
| 4 — `FAIL.T14` absence observables | **holds** | — |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** | — |
| 6 — published rows | **fail** — measured, not held | with 2 |
| 7 — `#550` manifest rows | **not owed** — no re-run | — |
| 8 — scope | **holds** | — |
| 9 — #332/#333/#335 | **holds** | — |

No `specs/`, `game/`, `asset_catalog/`, or `game_assets/` file is changed by this run.

## Ambient / play-group preloads — unchanged, not claimed

The published cold open again logs `Preload ambient left 2 approved IDs unresolved`, and `Preload play left 5 approved IDs unresolved` on entering the stream — the known #715 object, out of scope here.
