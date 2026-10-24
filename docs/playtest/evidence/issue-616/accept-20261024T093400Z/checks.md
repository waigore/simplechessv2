# Checks — issue #616, independent acceptance re-run

Index: [`manifest.md`](manifest.md) · Reproduction of the graphical half: [`reproduction.md`](reproduction.md).

Commands below were run in this session on `origin/main` `4e4b724`, clean detached worktree, with
`GODOT_BIN=/home/waigore/godot-cache/Godot_v4.7.2-stable_linux.x86_64`.

## AC4 — one placement model

The one rule is `Presentation.place_centered` (`game/presentation.gd`): 0.5 x anchors, offsets written
from `custom_minimum_size`, `GROW_DIRECTION_BOTH`, top pinned from the caller's `top_px`.

| Site | Call |
|---|---|
| `ModePick` | `_place_centred_column(_mode_pick, 80.0)` → `place_centered` |
| `SharedSetup` | `_place_centred_column(_shared_setup, 60.0)` |
| `SharedResult` | `_place_centred_column(_shared_result, 120.0)` |
| `ResignConfirm` | `place_centered(_confirm_box, 200.0)` |
| `StreamConfirm` | `place_centered(_confirm_box, 220.0)` |
| `SaveFailure` | `place_centered(_save_box, 220.0)` |

`grep -n "PRESET_CENTER" presentation.gd shared_play_panel.gd puzzle_play_panel.gd` → no matches, so no
panel declares a centered preset and then overrides it with an absolute `position`.

## AC5 — the guard runs, and it fails a fixed x

Suite: `python3 .github/scripts/gdscript_tests.py test` → `28 headless unit test(s) passed`, exit 0.

Mutant (this run): `place_centered` body replaced with the filed pattern —
`set_anchors_preset(PRESET_TOP_LEFT)` + `position = Vector2(40.0, top_px)` — then
`godot --headless --path game -s res://chrome_placement_test.gd`:

```
ERROR: ModePick drawn centre x off by 440.0 px at (1280.0, 720.0) (drawn width=320.0, placed width=320.0)
exit=1
```

The file was restored with `git checkout`; the worktree ends clean apart from this folder.

## AC6 — lint, tests, coverage

- `gdlint game` → `Success: no problems found`
- `gdformat --check game` → `62 files would be left unchanged`
- Unit tests → 28/28, exit 0
- Coverage → `statement-line coverage 86.5% (4654/5383); threshold 80`, exit 0

Recorded logs: [`logs/chrome-placement-guard.log`](logs/chrome-placement-guard.log),
[`logs/unit-tests.log`](logs/unit-tests.log), [`logs/coverage.log`](logs/coverage.log).

## AC7 — scope

- `git diff --stat eb72873..origin/main -- specs/` → empty: no spec change since the implementation
  pass that acceptance is judging.
- PR #695 touches `game/presentation.gd` and `game/chrome_placement_test.gd`; PR #700 touches
  `game/chrome_placement_test.gd` and `game/presentation_test.gd`. No board/play-region file, no
  panel-content file, no node rename.
- `python3 .github/scripts/spec_lint.py` → `0 error(s), 1 warning(s)`; the warning is the
  pre-existing glossary duplicate for `Diagram`, unrelated to this issue.
- `#617` (piece orientation) was merged, accepted and closed before this run; nothing in the judged
  diffs touches piece sprites.
