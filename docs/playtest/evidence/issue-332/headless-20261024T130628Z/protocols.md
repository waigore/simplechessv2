# Protocols — #332 acceptance headless run

Every row cites the `logs/scenario-run.log` assertion unless another log is named. Scope rationale is in [notes.md](notes.md).

| Protocol / story | Result |
|------------------|--------|
| `PTD-puzzle-stream` S2 — clean sequence; `END.W1` and the Elo rise follow, one next deal (K2–K3, `F-puzzle-catalog` I2) | pass — `S2 END.W1 follows the completed sequence`, `S2 Elo rises on a solve` (1000.0 → 1010.0), `S2 exactly one next deal after the cue`; the at-once reply and index step are covered by `_check_sequences` in `logs/gdscript-tests.log` |
| S7 — wrong move; same `puzzleId` returns to start, no next deal, second wrong move retryable (K2, W2.1) | pass — `S7 wrong move flagged`, `S7 same puzzle stays open`, `S7 index reset to the deal start`, `S7 no next deal`, `S7 a second wrong move is retryable` |
| S8 — reveal fails then deals; abandon fails with S = 0 (K2, W2.2–W2.3) | pass — `S8 reveal reports END.L5`, `S8 reveal scores S=0`, `S8 abandon reports END.L6`, `S8 abandon scores S=0` |
| S9 — leave; return to mode-pick, `GS.playerElo` kept, open puzzle unscored (K4/E1, W2.4) | pass — `S9 leave reports the mode and keeps Elo`, `S9 open puzzle unscored` |
| S10 — wrong move then completion; `END.L4`, Elo drops as `DIF.Y1` scores S = 0, one deal (K3, W1.4) | pass — `S10 END.L4 after the wrong move`, `S10 S=0 drops Elo` (1000.0 → 990.0), `S10 no recentSolved entry on a failure` |
| P2 — wrong move resets and never solves; reveal/abandon fail and deal once; leave exits unscored (K2–K4, `END.L4`–`L6`) | pass — the S7–S9 rows; `_check_one_ending_per_attempt` proves one ending and one Elo update per attempt |
| **Verdict `PTD-puzzle-stream`** | **pass** (headless) |
| `PTD-difficulty` S1 — solve raises Elo per DIF | pass — `DIF S1 solve raises Elo` (1000.0 → 1010.0, K=20, E=0.5) |
| S2 — fail lowers Elo per DIF | pass — `DIF S2 fail lowers Elo` (1000.0 → 990.0) |
| S3 — Shared results leave Player Elo unchanged | n/a — the Shared-game leaf (#34), not this task |
| **Verdict `PTD-difficulty`** | **pass** (headless, stream cases) |
| `PTD-progression` S1 — solve; reopen; Elo, Last mode and recent solved IDs committed (P1/P2/P3/M1) | pass — `PRG S1 Elo committed`, `PRG S1 last mode committed`, `PRG S1 reopen restores Elo`, `PRG S1 reopen restores recentSolved` |
| S2 — newest 20 kept past `CFG.ELO_RECENT_WINDOW`, oldest dropped (P3/M1) | pass — 23 solves → `PRG S2 window trimmed to 20`, `PRG S2 newest kept, oldest dropped` (`p3`…`p22`) |
| S3 — failure does not end the stream (F1) | pass — `PRG S3 failure does not end the stream`, `PRG S3 stream continues after a failure` |
| S4 — Shared game has no progression axis | n/a — the Shared-game leaf (#34) |
| **Verdict `PTD-progression`** | **pass** (headless, stream cases) |
