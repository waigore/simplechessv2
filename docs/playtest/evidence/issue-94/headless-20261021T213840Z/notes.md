# Headless notes

Judged the verification-fix build for #94 (shared-play choice states after PR #358 failed verification).

## Prep

- Godot 4.7.2 headless (`ENV.1`). Import, unit tests, coverage, `shared_play_test.gd`, `shared_game_session_test.gd`, and a short headless smoke.
- Drove deselect (B8/B9/B11), refused-place S5, promotion S4, and draw-offer S6 through the existing headless shared-play suite (extended with destination-bound promote overlay assertion).

## Judgement

| Area | Result |
|------|--------|
| Select-clear / bad-drop | pass — selection cleared, no cue; `IN.cancel` remains dialog-only |
| Refused place | pass — S5 + reject square; flash ends → S1; clock/side unchanged |
| Promotion | pass — S4 waits on C6; deselect leaves pawn; commit places promoted unit; overlay sprites within destination |
| Draw offer | pass — confirm → S6; Decline / Withdraw / lapse → S1; Accept → END.D2 → shared-result |
| Suites | pass — 14 headless unit tests; coverage ≥ threshold |

Display server was headless. Graphical twin under `../graphical-20261021T213840Z/`.
