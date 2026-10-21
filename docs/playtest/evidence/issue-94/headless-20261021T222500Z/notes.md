# Headless notes

Verification-fail pass for #94: C6 chrome row no longer overflows into R1.

## Prep

- `GODOT_BIN` Godot 4.7.2; `python3 .github/scripts/gdscript_tests.py test`.
- Extended `_layout_reserves_chrome` asserts every visible `PlayChrome` child stays above `PLAY_CHROME_TOP_PX` in S1, S4 untimed, S4 blitz, and S6 (16:9 and 9:16).

## Judgement

All 14 headless unit tests passed, including the new chrome-reserve assertions and existing focus-order / promotion / draw flows.
