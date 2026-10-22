# Headless notes

Acceptance playtest for #432 (record a no-cue rule for draw endings; silence the accept-draw path) on build `f943fb3`, which includes the deliverable merge `95386d5` (PR #489).

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `GODOT_BIN=godot python3 .github/scripts/gdscript_tests.py test` — 15 headless unit tests passed (includes `presentation_audio_test.gd` with the new `C7` accept-draw case)
- `python3 .github/scripts/spec_lint.py` — 0 errors, 1 pre-existing warning (`specs/view/glossary.md` `Diagram`)
- Coverage not measurable locally: `gdtoolkit` (4.5.0) is not importable from the script interpreter here; CI `Coverage` on PR #489 was green.
- `godot --headless --path game -s res://accept432_playtest.gd` — exit 0, `ISSUE432_ACCEPT pass` (standalone harness from an external worktree; not committed)

## Scope

The deliverable changes playable behavior (end cue on the accept-draw path), so playtesting applies. Mapping per [`procedures.md`](../../../../specs/playtest/procedures.md):

- `END.D2` (agreed draw) and `END.L2`/`L3` (resign, clock loss) are `END` design stories → `PTD-end-conditions` (Design, headless only).
- Every ending reaches the result screen → `PTU-shared-result` (UX, headless **and** graphical) for the S1 "reach shared-result after a game end" step.
- `PTD-end-conditions` S3 covers D1–D4; S4 covers L3 vs D5. It cites no audio story, so the cue itself is judged from the probe (`SND.X4` mapping) and the unit/CI suite rather than a protocol pass/fail.

## Judgement (headless)

| ID | Outcome | Evidence |
|----|---------|----------|
| PTD-end-conditions S3/S4 (D1–D5, L2, L3 classification) | pass | probe: `_is_loss_end(END.D5)=false`, `_is_loss_end(END.L3)=true`, `_is_loss_end(END.L1/D1)` pinned false by `presentation_audio_test.gd`; `shared_game_session_test.gd` D2 cases pass in the 15-test run |
| PTD-end-conditions (cue/no-cue consequence) | pass (non-protocol observation) | probe: accept-draw (`C7`, `END.D2`) reaches `shared-result` with `cue delta=0`; resign (`END.L2`) raises exactly one `SND.X4` (`last=01a151f8-b7d8-7fe3-b94f-e3a562395d96`) |
| PTU-shared-result S1 (headless) | pass | draw ending reaches `shared-result`; telemetry `shared.draw`/`shared.end` `TEL.5=END.D2` |
| PTU-shared-result S1 (graphical) | pass | see [`../graphical-20261023T061200Z/notes.md`](../graphical-20261023T061200Z/notes.md) |
| PTU-shared-result S2/S3 (Play again / Stop) | not-judged | out of the change's blast radius; PTU-shared-result P1 is unrelated to this defect |

No protocol failure. Draw endings are uniformly silent (`D1`–`D5`), and the win/loss end cue is unchanged.

## Spot checks outside the protocols

- `SND.X4` context cell still reads "checkmate, resign, or clock loss"; no `X*` row added, `L1`/`L2` untouched.
- `SND.X5` untouched (still unbound in the shared flow).
- `specs/assets/kinds/sound-effects.md` (`V4`, `S1`) unchanged.

Display server was headless (`ENV.1`). Graphical twin: `../graphical-20261023T061200Z/`.
