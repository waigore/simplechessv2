# Manifest

- **Issue**: 768 — Promote puzzle-stream keep list into main code
- **Environment**: `ENV.1` headless and `ENV.2` graphical. Godot
  `4.7.2.stable.official.ed1daf0bf`; graphical leg on macOS arm64 (Apple M5), Metal
  Compatibility renderer, native window 1280×720. Both legs run the shipped scene
  `game/main.tscn` from the same build.
- **Build / session id**: `origin/main` `c4202bb`. Headless `TEL.3`
  `sess-1792888538783-39186-playtest-787279` (`logs/headless-run.log`); graphical
  `TEL.3` `sess-1792888543128-39292-playtest-587977` (`logs/graphical-run.log`). Each
  leg exits 0 with `FAILURES=[]`, 70 checks passing.
- **Coverage mode**: partial — this task's two protocols only (`PTD-puzzle-stream`,
  `PTD-difficulty`). Every other Design protocol is `not-judged` here.
- **Deal source**: the production path. `PuzzleStream.request()` →
  `CatalogDealClient` → `Accept768CatalogPeer` (an answer-capable peer on the shipped
  `FakeCatalogTransport` seam, ADR-0013 Testability) → `PuzzleStream.poll()` →
  `PuzzleSession.deal()`. The record comes from a real catalog read carrying
  `player_elo` and `recent_solved`, not from `deal([...])` injection. The persisted
  document is the store's own memory backend.
- **Probe seam**: 11 lines added to `game/session_router.gd` install the peer through
  the existing `_puzzle_sim_factory()` hook (`probe/session-router-install-seam.diff`).
  No product behaviour is changed; `game/puzzle_play_flow.gd` and every Domain file are
  byte-identical to `origin/main`.
- **Screenshots**: `screenshots/`, from the graphical leg of this build. See
  `notes.md` for the two cue shots whose pixels do not show the transient R2 cue.

## Results

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

## Defects

- None. No protocol failed; no `type:defect` filed.

## Paths

- `notes.md`
- `logs/headless-run.log`, `logs/headless-repeat-run-{1,2,3}.log`, `logs/graphical-run.log`
- `screenshots/` (10)
- `probe/` — throwaway harness: `accept768_work.gd`, `accept768_catalog_peer.gd`,
  `session-router-install-seam.diff`
