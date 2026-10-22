# Headless verdicts

Verdicts for the headless acceptance playtest of #432 on build `95386d5` (merge of PR #489). Evidence and observations are in [`notes.md`](notes.md); results per protocol are in [`manifest.md`](manifest.md).

## Protocol verdicts

- **PTD-end-conditions (headless)**: every judged ending matched its `L*`/`D*` row, no wrong ending applied, clocks stopped on end (the `D5`/`L3` runs left `shared-play`). `W1`/`L4`–`L6` are puzzle-only and untouched by this deliverable. → **pass** (no screenshots required for a Design protocol).
- **PTU-shared-result (headless)**: every draw and the resign reaches `shared-result`; `P2` requires both environments, so the headless half is judged and the protocol is **not-judged** here until the graphical twin runs.

## Non-blocking

- `graphical-<run-id>/` still owes ≥1 result-screen screenshot of the same build for `PTU-shared-result` (`P2`). Per `procedures.md` this is Waiting, not a fail, and files no defect.
- The probe script is kept under `logs/` for reproducibility and was removed from `game/` after the run.
