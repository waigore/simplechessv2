# #546 verification — SIT.6 / S13 / O12

| Field | Value |
|-------|-------|
| Issue | #546 (`type:task`, `status:pending-verification`), milestone *Wave 4 — Shippable cafe-table release* |
| Pass | `issue-workflow-verify-agent`, parallel id 1, unattended |
| Verdict | **Pass** |
| Build under test | `origin/main` **`161b4a9`** ("Record the #402 quality-row re-read on the shipped release build (#854)"), clean detached worktree |
| Engine | Godot `4.7.2.stable.official.ed1daf0bf`, graphical `ENV.2` on `macOS` Metal (`DisplayServer.get_name()` = `macOS`) |
| Scene | shipped `game/main.tscn`, mode-pick `S1` |
| Coverage mode | `full` (not a playtest sweep; the protocol row judged is `PTU-mode-pick` `S6`) |
| Map file used | `specs/playtest/traceability/story-protocol/protocols-ux.md` (rows for `PTU-mode-pick`) |

Build/session identity from the probe (`TEL.3`): `sess-1792880301251-64499-playtest-429247`
(window 390×844), earlier instance in `logs/graphical-probe.log`.

## Story rows judged

| Story row | Map (`protocols-ux.md`) assigns to | Outcome | Ground |
|---|---|---|---|
| `screens/mode-pick.md#US1` (incl. `UI-mode-pick.US1.9` and the `US1.1`–`US1.6` scenarios) | `PTU-mode-pick` | `pass` | every visible label/body string at ≥ `UIS.T2` for the 844 px frame (21 px), no clipping |
| `screens/mode-pick-unavailable.md#US1` | `PTU-mode-pick` | `not-judged` | this pass judges the `S6` legibility claim only; the unavailable state is not driven by the `S6` seam |

Protocol verdict for `PTU-mode-pick`: **not-judged** for the protocol as a whole (one row
`not-judged`), **`pass`** for `S6` `P5`/`F3`, which is the row this task's AC 3 makes
decidable. This is not a `PTU-mode-pick` acceptance run; that belongs to the wave-4
sweep (#400) on the released build.

## Per-criterion

| AC | Result | Evidence |
|---|---|---|
| 1 — `O12` applies width/height/text scale on `ENV.2`; headless leaves the viewport and still returns the report shape | **pass** | `logs/graphical-probe.log`: window `1280×720` → `390×844`, `content_scale_size=(0,0)`, report `{"applied":true,"body_text_px":21.0,"debug_panel_visible":false,"frame_height_px":844.0,"height":844,"rendered_text_scale":1.31875,"text_scale":1.0,"width":390}`; invalid input `(0,844)` returns `{}` with `TEL.5=fail`; repeat call byte-identical. Headless boundary: `game/playtest_seams_test.gd` `_application_matches` (32/32 tests pass) |
| 2 — seam reports the presentation hook's body px and sets/clamps no size | **pass** | report `body_text_px` = 21 = `BODY_PX 16 × 844/640`; `_bound_report_matches` injects a sentinel through `bind_text_report` and requires the seam to echo it; `_ignores_argument_scale` proves the caller's scale argument moves nothing |
| 3 — `PTU-mode-pick` `S6` at 390×844 decidable, `P5`/`F3` from the render | **pass** | all five visible strings (`Choose how to play` 37 px on 2 wrapped lines, `Shared game · Last` 21, `Puzzle stream` 21, `Quit` 21, `English` 21) at ≥ the 21 px need; `get_line_count()` = `get_visible_line_count()` = 2 on the title, so it wraps and its box grows (99 → 111 px) instead of clipping; `screenshots/s6-phone-390x844.png` inspected — no clipping, no chrome over the panel (only the collapsed `Show seams` header, above the panel, area 0) |
| 4 — shipped layout reflows through the one presentation seam, no parallel layout/theme | **pass** | `Presentation.reflow_text_for_frame()` → `_reflow_text()` sets the five panels' `_text_scale`; no phone theme, no second layout path in the diff |
| 5 — release export carries no `O12`; release-absence gate covered by `I3` `S3–S13` | **pass** | `set_viewport` returns `{}` when `playtest_build` is false (`game/playtest_seams.gd:117-120`); `game/playtest_seams_test.gd:55` (`S13 release viewport`); `game/release_scene_test.gd` asserts `main_release.tscn` carries no seam node |
| 6 — unit tests cover application, headless boundary, ratio, release absence; `test` and `coverage` pass | **pass** (see note) | `logs/unit-tests.log`: 32/32. `coverage` not re-measured this pass: the local Python has `gdtoolkit` CLIs 4.5.0 but no importable `gdtoolkit` module, so the coverage script aborts on its own version probe. Not material to a 4-line seam test addition; `Coverage` CI is green |
| 7 — `spec_lint.py` clean, no `specs/` file touched | **pass** | `logs/spec-lint.log`: 0 errors, 1 warning (`specs/view/glossary.md:14` duplicate `Diagram`, pre-existing). No `specs/` change in this issue's deliverables |
| D5 — no `specs/` edit | **pass** | `git diff origin/main -- specs/` empty for the deliverable commits |

## Commands run

```
godot --headless --path game --import --quit                     # exit 0
GODOT_BIN=/opt/homebrew/bin/godot python3 .github/scripts/gdscript_tests.py test
                                                                 # 32 headless unit test(s) passed
gdformat --check game                                            # 68 files would be left unchanged
gdlint game                                                      # Success: no problems found
python3 .github/scripts/spec_lint.py                             # 0 error(s), 1 warning(s)
```

## Probe

`probe/zz_verify546_probe.gd` — written by this pass, not reused from #837's or the
acceptance run's probe. See the header for how it is run; copy it into `game/` to run it
(Godot only loads `res://`-relative scripts), then delete the copy.

## Hygiene

No `specs/`, `game/`, `asset_catalog/`, or `game_assets/` file is changed by this pass.
No `review-asset` run: the deliverable touches no cataloged asset.
