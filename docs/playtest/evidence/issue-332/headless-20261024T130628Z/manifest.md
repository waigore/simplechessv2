# Manifest

- **Issue**: 332 — Implement the puzzle stream session: sequence judging, outcomes, and Elo
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf, `origin/main` `a5b35ae` ("Sync upstream template to 92aff83d9f87 (#779)"), clean worktree off `origin/main`. Acceptance scenario run session `TEL.3` `sess-1792847390005-17920-playtest-185755`, `TEL.4` `mode-pick`, `TEL.5` `pass`.
- **Coverage mode**: in-scope only — `CMP-puzzle-session` R2–R4 (sequence judging, outcomes, Elo, commit, leave) and the stream loop `L-puzzle-stream` K2–K4 / E1. All five selected protocols (`PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression`, plus the `PTD-game-state` and `END` cases cited by the issue) are **Design** protocols, so Headless is the only required environment. No graphical run is required and none was made: this task owns no screen — the puzzle-play screen, mode-pick entry and journey are #333, and the `UI-puzzle-play` S1–S5 surface is judged once that screen exists. **No UX protocol is in scope for this issue.**
- **Defects**: none — no protocol failed.
- **Screenshots**: not required. All selected protocols are Design (Headless only, no screenshots).

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTD-puzzle-stream` S2 — play the sequence with no wrong move; confirm `END.W1` and the Elo rise follow, and one next deal (`L-puzzle-stream` K2–K3, `F-puzzle-catalog` I2) | pass — `S2 END.W1 follows the completed sequence`, `S2 Elo rises on a solve` (1000.0 → 1010.0), `S2 exactly one next deal after the cue`; the at-once reply and index step are covered by `_check_sequences` in `logs/gdscript-tests.log` |
| `PTD-puzzle-stream` S7 — play a wrong move; confirm the same `puzzleId` returns to its start with no next deal, and a second wrong move is retryable (K2, W2.1) | pass — `S7 wrong move flagged`, `S7 same puzzle stays open`, `S7 index reset to the deal start`, `S7 no next deal`, `S7 a second wrong move is retryable` |
| `PTD-puzzle-stream` S8 — reveal fails then deals; abandon fails with S = 0 (K2, W2.2–W2.3) | pass — `S8 reveal reports END.L5`, `S8 reveal scores S=0`, `S8 abandon reports END.L6`, `S8 abandon scores S=0` |
| `PTD-puzzle-stream` S9 — leave; return to mode-pick, `GS.playerElo` kept, open puzzle unscored (K4/E1, W2.4) | pass — `S9 leave reports the mode and keeps Elo`, `S9 open puzzle unscored` |
| `PTD-puzzle-stream` S10 — after a wrong move, complete the sequence; confirm `END.L4`, Elo dropping as `DIF.Y1` scores S = 0, and one deal (K3, W1.4) | pass — `S10 END.L4 after the wrong move`, `S10 S=0 drops Elo` (1000.0 → 990.0), `S10 no recentSolved entry on a failure` |
| `PTD-puzzle-stream` P2 — wrong move resets and never solves; reveal/abandon fail and deal once; leave exits unscored (K2–K4, `END.L4`–`L6`) | pass — the S7/S8/S9 rows above; `_check_one_ending_per_attempt` in `logs/gdscript-tests.log` proves one ending and one Elo update per attempt |
| **Verdict `PTD-puzzle-stream`** | **pass** (headless) |
| `PTD-difficulty` S1 — solve a puzzle; confirm the Elo direction per DIF after solve | pass — `DIF S1 solve raises Elo` (1000.0 → 1010.0, K=20, E=0.5) |
| `PTD-difficulty` S2 — fail a puzzle; confirm the Elo direction per DIF after fail | pass — `DIF S2 fail lowers Elo` (1000.0 → 990.0) |
| `PTD-difficulty` S3 — Shared results leave Player Elo unchanged | n/a — the Shared-game leaf (#34), not this task |
| **Verdict `PTD-difficulty`** | **pass** (headless, stream cases) |
| `PTD-progression` S1 — solve; reopen; confirm Elo, Last mode and recent solved IDs committed (P1/P2/P3/M1) | pass — `PRG S1 Elo committed`, `PRG S1 last mode committed`, `PRG S1 reopen restores Elo`, `PRG S1 reopen restores recentSolved` |
| `PTD-progression` S2 — solve past `CFG.ELO_RECENT_WINDOW`; confirm the newest 20 IDs kept, oldest dropped (P3/M1) | pass — 23 solves → `PRG S2 window trimmed to 20`, `PRG S2 newest kept, oldest dropped` (`p3`…`p22`) |
| `PTD-progression` S3 — fail a puzzle; confirm the stream continues (F1) and Elo commit rules | pass — `PRG S3 failure does not end the stream`, `PRG S3 stream continues after a failure` |
| `PTD-progression` S4 — Shared game has no progression axis | n/a — the Shared-game leaf (#34) |
| **Verdict `PTD-progression`** | **pass** (headless, stream cases) |

Supporting runs in `logs/`: 28 headless unit tests passed, statement-line coverage 86.4% (4653/5383, threshold 80), `gdformat`/`gdlint` clean, headless smoke `TEL.5` `pass`.

## Paths

- `notes.md`
- `logs/scenario-run.log` — the acceptance scenario run behind every row above
- `logs/gdscript-tests.log` — 28 headless unit tests passed
- `logs/gdscript-coverage.log` — 86.4% statement-line coverage, threshold 80
- `logs/format.log` — `gdformat --check game` clean, 62 files unchanged
- `logs/lint.log` — `gdlint game` no problems
- `logs/headless-smoke.log` — `TEL.4` `mode-pick`, `TEL.5` `pass`
- Screenshots: none required (Design protocols only).
