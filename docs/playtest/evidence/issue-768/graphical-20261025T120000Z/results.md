# Results — per-step outcomes

### `PTD-puzzle-stream` (Design, headless only)

| Step | Story cites | Outcome | Notes |
|------|-------------|---------|-------|
| S1 | `K1`, `R1`–`R3`, `W1.1`, `W1.2` | **pass** | C2 from mode-pick; dealt id/rating/solving side/sequence match the served record; bottom seat faces the solver; S1 painted. `screenshots/s1-dealt-first-record.png` |
| S2 | `R4`, `I2`, `K3`, `W1.3`, `W1.4` | **pass** | `END.W1`, S = 1, `cue_solved`, Elo 1000 → 1010, `due=true`, one next deal (`accept768-s2-next`). `screenshots/s2-solved-cue.png` |
| S3 | `R5` | **pass** | mateIn1 accepts the recorded mate; `requiredSequence` not rewritten; S = 1. `screenshots/s3-mate-in-one-solved.png` |
| S4 | `I1` | **pass** | The O1 read carries `recent_solved`; the deal's own `candidate_set` skips the solved id for the unsolved one. |
| S5 | `I1`, `D1` | **pass** | A +400 offer still widens and deals; no authored band replaces the rating (1429 kept). `screenshots/s5-widened-deal.png` |
| S6 | `X1`, `X2` | **pass** | One-move record → `empty_solution`, nothing dealt; unreadable route → failed read, nothing dealt; Elo kept in both. `screenshots/s6-unreadable-nothing-dealt.png` |
| S7 | `K2`, `W2.1` | **pass** | Same `puzzleId`, index 0, `cue_wrong`, no next deal, second wrong move retryable, board reset. `screenshots/s7-wrong-move-reset.png` |
| S8 | `K2`, `W2.2`, `W2.3` | **pass** | Reveal `END.L5` S = 0 → one deal (store commits); Abandon `END.L6` S = 0. `screenshots/s8-reveal-confirm.png`, `screenshots/s8-reveal-result-then-deal.png` |
| S9 | `K4`/`E1`, `W2.4` | **pass** | Leave confirmed → mode-pick; open puzzle unscored; Elo, `recentSolved` and committed Elo unchanged. `screenshots/s9-leave-confirm.png`, `screenshots/s9-back-on-mode-pick.png` |
| S10 | `K3`, `W1.4` | **pass** | Complete after a wrong move → `END.L4`, S = 0, Elo drops. `screenshots/s10-end-l4.png` |

**Protocol verdict: `pass`** — P1, P2, P3 hold; no F1–F4.

### `PTD-difficulty` (Design, headless only)

| Step | Outcome | Notes |
|------|---------|-------|
| S1 (solve) | **pass** | delta = `ELO_K × (1 − E)` exactly (15.2461 at E = 0.23770, K = 20) |
| S2 (fail) | **pass** | delta = `ELO_K × (0 − E)` exactly (−5.0793 at E = 0.25396); `END.L6` as the fail |
| S3 (shared path) | **pass** | The Shared game leaves the committed Puzzle Elo unchanged |

**Protocol verdict: `pass`** — P1, P2 hold; no F1.
