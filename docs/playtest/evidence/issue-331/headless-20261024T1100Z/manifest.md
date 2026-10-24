# Manifest

- **Issue**: 331
- **Environment**: headless (`ENV.1`)
- **Build / session id**: Godot 4.7.2.stable.official.ed1daf0bf, `origin/main` `ff87566`. Smoke `TEL.3`: `sess-1792833435027-2307840-playtest-1020563`, `TEL.4` `mode-pick`, `TEL.5` `pass`.
- **Coverage mode**: in-scope only — `CMP-puzzle-session` R1 (deal) and `PuzzleStream` (the production deal source). No graphical run: the component owns no screen and both cited protocols are Design (headless only). The puzzle-play screen is #333.
- **Defects**: none — no protocol failed.
- **Screenshots**: not required. Both protocols' Evidence row reads "Default evidence rules (Headless: no screenshots)."

## Results

| Protocol / story | Result |
|------------------|--------|
| `PTD-difficulty` S1 / P1 (`DIF.Y1`, I1) — prefers a Rating within ±`CFG.ELO_MATCH_RANGE` (100) of `GS.playerElo`, skipping ids in the last `CFG.ELO_RECENT_WINDOW` (20) of `GS.recentSolved` when alternatives exist | pass — `_check_deal_within_window`, `_check_deal_skips_recent`; acceptance probe `_check_ac6_dif_y1_selector` |
| `PTD-difficulty` S1 / P1 (`DIF.Y1`, `D1`) — relax widens by `CFG.ELO_BAND_WIDEN` (50), allows a recent solve, then still deals a far record; no authored band | pass — `_check_deal_widens`, `_check_deal_allows_recent`, `_check_deal_still_deals_when_only_far` |
| `PTD-puzzle-stream` S1 / K1 — deal yields a puzzle: first UCI move applied; `GS.puzzleId` / `puzzleElo` / `solvingSide` / `sequenceIndex` written | pass — `_check_first_move_is_applied`, `_check_deal_read_record_deals`; acceptance probe `_check_ac1_first_move_and_sequence`, `_check_ac2_fields` (5-move record read through `CatalogWireReader`) |
| `F-puzzle-catalog` R3 / I2 — `GS.requiredSequence` is later moves only, odd steps the Solving side, length ≥ 1 | pass — `_check_x1_empty_solution`, `_check_deal_read_record_deals`, `_check_ac1_first_move_and_sequence` |
| `F-puzzle-catalog` R4–R5 / F13, I3 — only `mateIn1` arms the step; the recorded mate solves (`END.W1`) with the recorded list unchanged; a legal non-mating move is a Wrong move resetting to the dealt position; an unmarked record is not armed | pass — `PuzzleSessionMateTest` (`_check_mate_in_one_mark`, `_check_mate_in_one_accepts_recorded_mate`, `_check_mate_in_one_rejects_non_mating`, `_check_illegal_move_is_not_a_wrong_move`, `_check_unmarked_record_is_not_armed`); `_check_ac3_mate_in_one`, `_check_ac3_unarmed_record_is_not_dealt_any_other_mate` |
| `F-puzzle-catalog` X1 — moves empty after the first deals nothing; `GS.puzzleId` stays none | pass — `_check_x1_empty_solution`, `_check_ac4_x1_x2` |
| `F-puzzle-catalog` X2 — no record (a failed read reported by the caller) deals nothing; `GS.playerElo` unchanged | pass — `_check_x2_failed_read`, `PuzzleStreamTest._check_failed_read_deals_nothing`, `_check_missing_peer_fails_without_dealing`, `_check_failure_leaves_the_open_puzzle_untouched`, `_check_ac4_x1_x2` |
| ADR-0008 — production path reads one record from the catalog service, no snapshot, no bundled catalog bytes, off the move path | pass — `PuzzleStream` consumes only `CatalogDealClient` (G1/G2); `_select` is reachable only through `deal(records)`; no catalog file under `game/` |
| `PTD-puzzle-stream` S2–S6 / K2–K4, `PTD-difficulty` S2 | n/a — the stream leaf (#332) |
| `PTD-difficulty` S3 / P2 — Shared endings leave Player Elo unchanged | n/a — the Shared-game leaf |
| **Verdict `PTD-difficulty`** | **pass** (headless, deal cases) |
| **Verdict `PTD-puzzle-stream`** | **pass** (headless, K1) |

## Paths

- `notes.md`
- `logs/gdscript-tests.log` — 28 headless unit tests passed
- `logs/gdscript-coverage.log` — not measured in this run (`gdtoolkit` absent); see notes
- `logs/lint.log` — `gdformat --check game` clean, `gdlint game` no problems
- `logs/spec-lint.log` — 0 errors, 1 pre-existing warning (`Diagram` in two glossaries)
- `logs/headless-smoke.log` — `TEL.4` `mode-pick`, `TEL.5` `pass`
