# Headless notes

Acceptance playtest for #432 (draw endings play no end cue) on build `95386d5` (merge of PR #489). Run in a separate session from both the implementation summary and the verification comment.

## Scope

#432 changes playable sound behavior: `specs/aesthetics/sound.md` now records "draw endings play no end cue (`D1`–`D5`)", and `game/session_router.gd` `_on_shared_play_control` guards `CUE_END` with `_is_loss_end` instead of `ended` alone.

Intersection of `full` coverage with the playable IDs the deliverable can affect:

- **Design**: `PTD-end-conditions` — cites `END` (`L1`–`L6`, `D1`–`D5`, `W1`, `P1`). The changed contract is exactly how each shared ending cues, so this protocol is in scope. Headless only; no screenshots required.
- **UX**: `PTU-shared-result` — cites `UI-shared-result`; the no-cue rule hands the draw outcome to the `result_draw` copy on this screen. Headless and Graphical both required.

`PTD-shared-game` sound scope (`SND.X1`–`X4` wiring) was also spot-checked for cue plumbing, as in `docs/playtest/evidence/issue-60`.

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `GODOT_BIN=$(which godot) python3 .github/scripts/gdscript_tests.py test` — 15 passed
- `godot --headless --path game` — smoke exit 0 (pause/resume, inspect `TEL.5: pass`)
- `python3 .github/scripts/spec_lint.py` — 0 errors, 1 pre-existing warning (`specs/view/glossary.md` `Diagram`)

Display server was headless (`ENV.1`). Drive used the real `SessionRouter` control/input paths (`mode-pick` `C1` → `shared-setup` `C5` → `shared-play` `C5`/`confirm`/`C7`/`C4`, `handle_input_commit`, `_process`) and `DBG.3`-style position entry via `ChessRules.load_position` (`SIT.1` seed not needed — positions are fixed). Observations came from `PresentationAudio.cue_play_count` / `last_cue_id` (`DBG.2`) and `shared.end` telemetry (`TEL.1`–`TEL.5`).

The probe (`logs/accept-432-probe.gd`) is independent of `game/presentation_audio_test.gd`: it does not reuse that test's assertions and drives each router path directly.

## Judgement

| Step | Observation |
|------|-------------|
| `END.D2` accept-draw (`C7`) | `shared-result`, `end_reason=END.D2`, `cue_play_count 0→0`, `last_cue` unchanged → **draw, no end cue** |
| Cue plumbing | select `X1` (`…09f6`), move `X2` (`…fd63`) each play exactly once on the same session → audio path live, so silence above is real |
| `END.L2` resign | `shared-result`, `end_reason=END.L2`, `cue_play_count 2→3`, `last_cue=SND.X4` (`…5d96`) → **loss, X4 plays** |
| `END.D5` clock expiry | K vs K (`possible_checkmate(black)=false`), blitz clock driven to zero via `_process`; `shared-result`, `end_reason=END.D5`, `cue_play_count 3→3` → **draw, no end cue** |
| `END.L3` clock loss | First clock run from the opening (mate material available) ended `END.L3` and played one `SND.X4` → **loss, X4 plays** |
| `END.D1` stalemate | `Kd6` waiting move from `Ka8`/`Qb6`/`Kc6`; `shared-result`, `end_reason=END.D1`, cue delta = 1 and that one is `X2` (the move cue), `last_cue=X2` → **draw, no end cue on top of the move** |
| `END.D3` / `END.D4` | `_is_loss_end` returns false for both; `result_copy_key` maps them to `result_draw`; the guarded tick / move-commit / control paths therefore cue nothing. Pinned by `game/presentation_audio_test.gd` and the repo suite. |
| Classification | `_is_loss_end` false for `D1`–`D5`, true for `L1`–`L3` |

Telemetry for the judged window (`TEL.3` = `sess-1792706600555-10297-playtest`):

- `shared.draw` ×3 → `shared.end` `TEL.5=END.D2`
- `shared.resign` ×2 → `shared.end` `TEL.5=END.L2`
- `shared.end` `TEL.5=END.D5`
- `shared.end` `TEL.5=END.D1`

## Protocol verdicts

- **PTD-end-conditions (headless)**: every judged ending matched its `L*`/`D*` row, no wrong ending applied, clocks stopped on end (the `D5`/`L3` runs left `shared-play`). `W1`/`L4`–`L6` are puzzle-only and untouched by this deliverable. → **pass** (no screenshots required for a Design protocol).
- **PTU-shared-result (headless)**: every draw and the resign reaches `shared-result`; `P2` requires both environments, so the headless half is judged and the protocol is **not-judged** here until the graphical twin runs.

## Non-blocking

- `graphical-<run-id>/` still owes ≥1 result-screen screenshot of the same build for `PTU-shared-result` (`P2`). Per `procedures.md` this is Waiting, not a fail, and files no defect.
- The probe script is kept under `logs/` for reproducibility and was removed from `game/` after the run.
