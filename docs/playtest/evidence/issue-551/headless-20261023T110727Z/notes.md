# Headless notes — #551

Acceptance playtest for #551 (Player Elo must use `CFG.ELO_K` = 20, not a local `32.0`).
Prep commands and the acceptance-criteria table are in
[`prep-and-criteria.md`](prep-and-criteria.md).

## Scope

The deliverable is code that changes playable behaviour (the `DIF.Y1` Elo update), so
playtesting applies. Intersecting the `full` coverage set with the IDs this defect can
affect:

- `PTD-difficulty` (Design, cites `DIF`, headless only) — the Elo update direction and size.
- `PTD-game-state` (Design, cites `GS` persist fields `playerElo` / `lastMode` /
  `recentSolved`, headless only) — those fields across reopen, and the failed-write path.

The K factor changes no screen, control, copy, or journey step, so **no UX protocol is in
scope** and no graphical run is required. Both selected protocols are Design protocols
whose Evidence row reads "Default evidence rules (Headless: no screenshots)", so this
headless run is sufficient for acceptance.

## How the run drove the session

`probe/accept551_probe.gd` (copied into `game/` for the run, then removed) drives
`PuzzleSession` through the verbs the puzzle-play screen binds — `deal`, `place`, and
`request_confirm` with `C3` (reveal) / `C4` (abandon) followed by `confirm` — and judges
the literal numbers the design stories state. It is an acceptance probe, not a re-run of
the PR's tests: the assertions are written against
`specs/design/stories/difficulty.md`,
`specs/design/stories/end-conditions/conditions-puzzle.md`, and
`specs/design/stories/game-state/fields-persist.md`, not against
`game/puzzle_session_test.gd`.

## Judgement (headless)

| ID | Outcome | Evidence |
|----|---------|----------|
| `PTD-difficulty` S1 / P1 — `PS1.1` `END.W1` at equal ratings reaches 1000 + 20 × 0.5 | pass | `1010.0`; `elo_k=20.0` |
| `PTD-difficulty` S2 / P1 — `PS1.2` `END.L6` (abandon, `C4`) at equal ratings reaches 990 | pass | `990.0` |
| `PTD-difficulty` S2 / P1 — `END.L5` (reveal, `C3`) at equal ratings reaches 990 | pass | `990.0` |
| `PTD-difficulty` F1 — Elo does not move opposite `DIF` | pass | win `1010.0` > start; loss `990.0` < start |
| `PTD-difficulty` P1 — the defect's K=32 numbers (1016 / 984) are gone | pass | `no K=32 drift (win=1010.0 abandon=990.0)` |
| `PTD-difficulty` S3 / P2 — Shared endings leave Player Elo unchanged | pass | Shared game exposes no Player Elo field; `PuzzleSession` mutates `player_elo` only in `_apply_outcome` |
| `PTD-game-state` S5 / P2 — `playerElo` survives reopen | pass | committed `3010.0` read back by a fresh session via `restore(load_document())` |
| `PTD-game-state` S5 — `lastMode` survives reopen | pass | `puzzle` |
| `PTD-game-state` S5 — `recentSolved` survives reopen | pass | `["p1"]` |
| `PTD-game-state` P2 / `EX.save-failure` — a failed write keeps the prior commit | pass | `save_failed` raised; committed Elo stays `3010.0` |
| `fields-persist` PS1.7 — no Elo cap at high rating | pass | `3000 → 3010.0` |

Protocol verdicts: `PTD-difficulty` **pass**, `PTD-game-state` **pass**, both headless
(`ENV.1`). No defect filed: no protocol failed.
