# Notes — #478 headless run `20261025T205500Z`

Unattended `issue-workflow-implement-agent` run for #478.

One tree, one commit, one `TEL.3` session, one row set: the eight wave-1 design
protocols and the nine wave-1 UX protocols. The
[graphical run](../graphical-20261025T205830Z/notes.md) re-runs the nine UX protocols on
the same commit. Rows: [manifest.md](manifest.md).

## Result

**5 pass, 2 fail, 10 not-judged** over the seventeen protocols; 36 pass, 2 fail,
14 not-judged over their 52 row cells. `errors=[]`, no `SCRIPT ERROR`, 267 `TEL.*`
lines.

Both failures are one story row, `screens/mode-pick-unavailable.md#US1`, so both
protocols that cite it (`PTU-mode-pick`, `PTU-localization`) fail. Filed as **#846**.

## Why this run exists

#478's evidence first landed at `34ac59e` (#836) recording 0 fail and 5 not-judged.
`game/puzzle_session.gd` and `game/puzzle_progression.gd` then changed (`0fd4640`,
#768 — `CMP-puzzle-progression` wired into the session), so that reading no longer
describes the wave-1 surface. This run re-reads the same seventeen protocols at
`d34050f` and supersedes that verdict set.

It also separates the three causes of `not-judged`: scenarios needing a **crafted
position**, one needing a **display** or **non-touch device**, and rows that are **spec
reviews** rather than run states (`LOC.US1.1`, `LOC.US2`). Nothing changed in `specs/`
or player-facing code (AC 7).

## Defect #846 — mode pick S3

Given S3 quit confirm, activating C1 (or C2, or C4) must leave the screen on mode pick
with the confirm up. At `d34050f` C1 leaves for `shared-setup`, C2 for `puzzle-play`,
and C4 switches `en` → `zh-Hant` and drops the confirm. Cause: `_on_mode_pick_control`
matches the control id only and never reads the panel's `ui_state`; the panel hides
C1–C4 in S3 but does not disable them, so the input rail still delivers their ids.
Detail and reproduction: #846.

## How rows were judged

Every row came from a driver step driving the shipped controls, then reading the
resulting state; none was inferred from source. Two rows were re-judged after a driver
artefact was removed: `pieces.md#PS1` (compared kinds to FEN letters) and
`conditions-puzzle.md#PS1` L4 (settled a puzzle W1 had already solved — not the L4
path; on a fresh record it settles **END.L4** with the Elo falling, per `END-move.P2`).

`screens/mode-pick-unavailable.md#US1` was re-read against the opposite hypothesis by
reading the panel node directly: the panel does hide the mode buttons in S3, so the
still screen is correct. The failure is in the input rail — what an unattended runner
drives and what a queued tap hits.

## AC 8 — art opened at run time

From `logs/static.json` (`TEL.*` `report.assets`), read before protocol step 1: `boot`
**11 of 11 opened**, `play` **19 of 19 opened**, unresolved **0** in both;
`boot_outcome` `0`, `session_playable` `true`, `log_counts` `{}`. Piece and board rows
are judged on what rendered, not on files in `game_assets/`.

`logs/w400_sweep.gd` is the run's driver, kept verbatim:

```
W400_KIND=headless W400_OUT=<dir> godot --headless --path game --script res://_w400/w400_sweep.gd
```

A per-run artefact, not part of the game tree.
