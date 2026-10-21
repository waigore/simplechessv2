# Headless playtest — issue 94 (C4/C5 from S4/S5)

Verification fix after PR #372: Resign (C4) and Offer draw (C5) now open `EX.confirm` from S4 and S5, matching `shared-play-controls.md` availability (never S2/S6).

## Commands

- `GODOT_BIN` Godot 4.7.2; `python3 .github/scripts/gdscript_tests.py test`.
- `godot --headless --path game -s res://shared_play_test.gd`.

## Results

| Check | Result |
|-------|--------|
| Unit tests | pass (see `logs/gdscript-tests.log`) |
| Shared-play incl. S4 C5 / S5 C4 → S2; S6 closed | pass (`logs/shared-play-test.log`) |
| TEL.3 | `sess-1792622702680-29717-playtest` |

Commit recorded in `logs/build-id.txt` (branch tip of this PR).
