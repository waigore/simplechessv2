# Readings — #557 graphical run `20261024T022315Z`

Every value below is a read the driver made, not a transcription. `run.json` holds the same numbers; `logs/` holds the console each open produced.

## Committed values the legs compare

The release build cannot produce a committed document on this commit: with `T9`/`T10` unset, `PuzzleStream` refuses every deal, so no `SEQ-puzzle-result-commit` runs and Elo never changes. These reads record that nothing existed to compare.

| Leg | Read | Before | After | Verdict the read supports |
|---|---|---|---|---|
| 1 — quit/reload | `localStorage` keys | `[]` | `[]` | `not-judged` |
| 1 | `simplechessv2.persist.v1` present | `false` | `false` | `not-judged` |
| 1 | mode-pick Last-mode affordance on screen | not rendered (screenshot `leg-1-before-close.png`) | not rendered (`leg-1-after-reopen.png`) | `not-judged` |
| 2 — crash | `localStorage` keys | `[]` | `[]` | `not-judged` |
| 2 | uncommitted Last-mode selection made | none — mode pick never rendered | — | `not-judged` |
| 2 | renderer killed via `chrome://crash`, no quit path | — | page replaced, reopen clean | `not-judged` |
| 3 — faulted session | wrapper `attempts` / `dropped` | `0` / `0` | `0` / `0` (restored) | `not-judged` |
| 3 | `EX.save-failure` surface (`UI-mode-pick.S4` / `UI-puzzle-play.S3`) | never shown (`leg-3-after-fault.png`) | — | `not-judged` |
| 3 | document intact after the fault | `[]` | `[]` | `not-judged` (vacuous: no write attempted) |

## Screen reads

Godot renders into one canvas; the DOM carries no game text (`body_text_length: 0` on every open). The screen half of each row is the screenshot plus the console. Every capture is `Loading…`, md5 `7ba3b2c7…`.

## Console, identical on all six opens

```
ERROR: Error opening file 'game_assets/icons/advice.svg'.                    ×2
ERROR: Error opening file 'game_assets/icons/back.svg'.                      ×2
ERROR: Error opening file 'game_assets/icons/mode-puzzle.svg'.               ×2
ERROR: Error opening file 'game_assets/icons/mode-shared.svg'.               ×2
ERROR: Error opening file 'game_assets/icons/quit.svg'.                      ×2
ERROR: Error opening file 'game_assets/icons/style-anchor-sheet.svg'.        ×2
ERROR: Error opening file 'game_assets/interface-art/chip-surface.svg'.      ×2
ERROR: Error opening file 'game_assets/interface-art/panel-surface.svg'.     ×2
ERROR: Error opening file 'game_assets/interface-art/style-anchor-sheet.svg'. ×2
ERROR: Preload boot left 9 approved IDs unresolved
   at: push_error (core/variant/variant_utility.cpp:1023)
```

Nine distinct paths, each retried once: 18 open failures. Counted from `logs/leg-1.console.log`; `leg-2` and `leg-3` are the same set.

`game/asset_resolver.gd` returns from `_preload` without emitting `boot_ready` when any approved ID is unresolved, and `SessionRouter._on_boot_ready` is the only exit from `STAGE_LOADING`. No `boot_ready`, no mode pick, no puzzle, no store write — on any build of this commit.

## What a `pass` leg would have required

1. A dealt puzzle and a real result commit, so a committed document exists to survive — blocked by **#655 / #648 / #479**.
2. Mode pick rendered so the Last-mode affordance can be read after each reopen and leg 2 has a selection to abandon — blocked by **#630**, whose repair **#677** is not publishable.
3. Leg 3 reaching `_web_set`'s round-trip check with `EX.save-failure` shown — needs (1) and (2) first.
