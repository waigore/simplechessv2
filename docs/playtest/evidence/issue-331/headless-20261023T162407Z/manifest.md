# Manifest

- **Issue**: 331
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf, `16b34ab` on `main`. That build carries every `CMP-puzzle-session` R1 deliverable: the deal (PR #514 `463e19c`), mate-in-one coverage and the Wrong-move reset (PR #526 `84cb848`), the catalog read feeding `deal()` (PR #591 `d55836e`), and the stream leaf (PR #533 `ed5f005`). Smoke `TEL.3`: `sess-1792772659544-34851-playtest`.
- **Coverage mode**: in-scope only — `CMP-puzzle-session` R1 (deal). No graphical run: this component owns no screen, and both cited protocols are Design (headless only). The puzzle-play screen is #333.
- **Defects**: none — no protocol failed.
- **Screenshots**: not required. Both protocols' Evidence row reads "Default evidence rules (Headless: no screenshots)."

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTD-difficulty` S1 / P1 (`DIF.Y1`, I1) — prefers a Rating within ±`CFG.ELO_MATCH_RANGE` of `GS.playerElo`, skipping ids in the last `CFG.ELO_RECENT_WINDOW` of `GS.recentSolved` when alternatives exist | pass — `_check_deal_within_window`, `_check_deal_skips_recent` |
| `PTD-difficulty` S1 / P1 (`DIF.Y1`, `D1`) — relax widens by `CFG.ELO_BAND_WIDEN`, allows a recent solve, then still deals a far record; no authored band | pass — `_check_deal_widens`, `_check_deal_allows_recent`, `_check_deal_still_deals_when_only_far` |
| `PTD-puzzle-stream` S1 / K1 — deal yields a puzzle: first UCI move applied; `GS.puzzleId` / `puzzleElo` / `solvingSide` / `sequenceIndex` written | pass — `_check_first_move_is_applied`, `_check_deal_read_record_deals` |
| `F-puzzle-catalog` R3 / I2 — `GS.requiredSequence` is later moves only, odd steps the Solving side, length ≥ 1 | pass — `_check_x1_empty_solution`, `_check_deal_read_record_deals` |
| `F-puzzle-catalog` R4–R5 / F13, I3 — only `mateIn1` arms the step; the recorded mate solves (`END.W1`); a legal non-mating move is a Wrong move resetting to the dealt position; unmarked is not armed | pass — `_check_mate_in_one_accepts_recorded_mate`, `_check_mate_in_one_rejects_non_mating`, `_check_unmarked_record_is_not_armed` |
| `F-puzzle-catalog` X1 — moves empty after the first deals nothing; `GS.puzzleId` stays none | pass — `_check_x1_empty_solution` |
| `F-puzzle-catalog` X2 — no record (a failed read reported by the caller) deals nothing; `GS.playerElo` unchanged | pass — `_check_x2_failed_read` |
| ADR-0008 — no catalog bytes bundled; the production read is #528's, off the move path | pass — `_check_deal_read_record_deals` consumes the one record `CatalogWireReader` validated; no snapshot in `game/` |
| `PTD-puzzle-stream` S2–S6 / K2–K4, `PTD-difficulty` S2 | n/a — the stream leaf (#332 / #533) |
| `PTD-difficulty` S3 / P2 — Shared endings leave Player Elo unchanged | n/a — the Shared-game leaf |
| **Verdict `PTD-difficulty`** | **pass** (headless, deal cases) |
| **Verdict `PTD-puzzle-stream`** | **pass** (headless, K1) |

## Paths

- `notes.md`
- `logs/import.log`
- `logs/gdscript-tests.log` — 21 headless unit tests passed
- `logs/gdscript-coverage.log` — 85.7% (3794/4428), threshold 80
- `logs/lint.log` — `gdformat --check game` clean, `gdlint game` no problems
- `logs/spec-lint.log` — 0 errors, 1 pre-existing warning (`Diagram` in two glossaries)
- `logs/headless-smoke.log` — `TEL.4` `mode-pick`, `TEL.5` `pass`
