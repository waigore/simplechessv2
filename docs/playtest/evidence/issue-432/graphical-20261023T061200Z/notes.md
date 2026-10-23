# Graphical notes

Acceptance playtest for #432 (draw endings play no end cue) on build `f943fb3` (includes `95386d5`, PR #489).

## Prep

- `godot --headless --path game --import --quit` — exit 0 (same build)
- `python3 .github/scripts/gdscript_tests.py test` — 15 passed (log alongside)
- `godot --path game --resolution 1920x1080 -s res://accept432_capture.gd` — graphical session on macOS / Metal (OpenGL Compatibility)

## Scope

UX `PTU-shared-result` S1 (reach shared-result after a game end). The change silences the end cue on the accept-draw path, so the draw ending must still present the outcome — the `result_draw` copy is the feedback vehicle per `sound.md` and `feedback.md`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-shared-result-draw.png` | `stage=shared-result` after accepting a draw (`C7`, `END.D2`); card reads "Game over / Draw / Shared game" with Play again and Stop; `cue_delta=0` — copy carries the outcome, no end cue |

`PTU-shared-result` S1: pass. No protocol failure; the graphical run confirms the same build and the result-copy vehicle.

Capture log ends with `ISSUE432_GRAPHICAL pass`.
