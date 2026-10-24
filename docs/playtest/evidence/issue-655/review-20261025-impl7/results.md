# Results — #655 re-run on `064f134`

Detail split out of [`manifest.md`](manifest.md); the row verdicts stay there.

## Criteria 1–4

- **C1.** `git grep -n -i "ships enabled\|release status\|published release" origin/main -- specs/`
  → no match on `064f134`. `specs/technical/configuration.md` `T9`/`T10` still
  *"Set per deployment"*, `B5` still only *"every deal fails"*. Writing the
  sentence is #648 AC2; criterion 8 forbids it here.
- **C2.** `X655 B5 endpoint=<> key_set=false is_available=false`.
  `game/session_router.gd:33-34` still `""`; the only assignment in `game/` is
  the test seam `advice_ui_test.gd:40-41`.
- **C3.** `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>`
  — neither `K1` dealt nor `F-puzzle-catalog.X2` absence met.
- **C4 (observable only).** `GS.playerElo` 1000.00 before and after, no puzzle
  id set, `last_failure=<status>` on `PuzzleStream`, and
  `puzzle stream: deal read failed (status)` in both the probe stdout and the
  published console log.

## Criterion 5 — `C5` → `EX.confirm` → Cancel on the entered `S1`

`X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true`,
`X655 CANCEL state=S1 has_puzzle=false`,
`X655 ROUTER … after_confirm=mode-pick flow_left=true`; `puzzle.confirm` /
`puzzle.leave` telemetry; byte-identical to the `review-20261025-impl2` reading.

## Criterion 6 — published rows

A cold open reaches the entered stream with **5 own-origin requests and zero to
any catalog or advice route**, then refuses. `index.pck` unchanged since
2026-10-24 13:00:58Z (run 40096272525, `a5b35ae`). The sequencing note's
condition ("while #648's sentence and #479's decision are unlanded") is true,
but past passes measured rather than held, so this pass keeps the stricter
reading. Log: [`logs/published-deal-log.txt`](logs/published-deal-log.txt).

## Criteria 7–9

- **C7.** `docs/playtest/evidence/issue-550/headless-20261024T000000Z/manifest.md:8`
  still names #655; that sweep has not re-run.
- **C8.** This pass adds only this folder (`git status` on the worktree).
- **C9.** No native edge to #332 / #333 / #335 added or implied.

## Build checks

- **Unit suite** — `GODOT_BIN=/opt/homebrew/bin/godot python3 .github/scripts/gdscript_tests.py test`
  → 29 headless tests pass. The import failures earlier passes hit did not
  reproduce.
- **Import + smoke** — import exit 0; smoke reaches `mode-pick`
  (`TEL.3` `sess-1792860021308-8289-playtest-193222`, `TEL.4 mode-pick`,
  `TEL.5 pass`).

## Protocol verdicts on this build

`PTD-puzzle-stream` **fail** (`K1`), `PTU-puzzle-play` **fail** (`US1`),
`PTU-puzzle-session` **pass** (`S2`–`S3`).
