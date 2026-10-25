# #546 verification — SIT.6 / S13 / O12

| Field | Value |
|-------|-------|
| Issue | #546 (`type:task`, `status:pending-verification`), milestone *Wave 4 — Shippable cafe-table release* |
| Pass | `issue-workflow-verify-agent`, parallel id 1, unattended |
| Verdict | **Pass** |
| Build | `origin/main` **`161b4a9`**, clean detached worktree |
| Engine | Godot `4.7.2.stable.official.ed1daf0bf`, graphical `ENV.2`, `macOS` Metal |
| Scene | shipped `game/main.tscn`, mode-pick `S1` |
| Type | `type:task`, not a PoC |
| Coverage mode | `full` |
| Map file used | `specs/playtest/traceability/story-protocol/protocols-ux.md` |

Session identity (`TEL.3`): `sess-1792880301251-64499-playtest-429247` at 390×844.

## Story rows judged

| Story row | Outcome | Ground |
|---|---|---|
| `screens/mode-pick.md#US1` (incl. `UI-mode-pick.US1.9`, `US1.1`–`US1.6`) | `pass` | every visible label/body string ≥ `UIS.T2` for an 844 px frame (21 px), no clipping |
| `screens/mode-pick-unavailable.md#US1` | `not-judged` | this pass judges the `S6` legibility leg only; that state is not driven by `S13` |

`PTU-mode-pick` as a whole is `not-judged` (one row not reached); its `S6` `P5`/`F3` legs
are `pass`, which is the decidable outcome this task's AC 3 asks for. The protocol's own
acceptance run belongs to the wave-4 sweep (#400).

## Per-criterion

| AC | Result | Evidence |
|---|---|---|
| 1 — `O12` applies width/height/text scale on `ENV.2`; headless leaves the viewport and keeps the report shape | **pass** | `logs/graphical-probe.log`: window `1280×720` → `390×844`, `content_scale_size=(0,0)`, report `applied:true`, `frame_height_px:844.0`, `rendered_text_scale:1.31875`, `body_text_px:21.0`; `(0,844)` → `{}` with `TEL.5=fail`; repeat call identical |
| 2 — seam reports the presentation hook's body px, sets/clamps no size | **pass** | `body_text_px` = 21 = `BODY_PX 16 × 844/640`; `_bound_report_matches` sentinel test; `_ignores_argument_scale` |
| 3 — `S6` at 390×844 decidable, `P5`/`F3` from the render | **pass** | `Title` 37 px on 2 lines, `Shared game · Last` / `Puzzle stream` / `Quit` / `English` 21 px; `get_line_count()` = `get_visible_line_count()` = 2; `screenshots/s6-phone-390x844.png` inspected |
| 4 — reflow through the one presentation seam, no parallel layout/theme | **pass** | `Presentation.reflow_text_for_frame()` → `_reflow_text()` over the five panels; no phone theme, no second layout |
| 5 — release export carries no `O12` (`I3` `S3–S13`) | **pass** | `game/playtest_seams.gd:117-120`; `game/playtest_seams_test.gd:55`; `game/release_scene_test.gd` |
| 6 — tests cover application, headless boundary, ratio, release absence | **pass** | `logs/unit-tests.log` 32/32; `Coverage` CI SUCCESS on the delivering PRs (see `notes.md` for the local gap) |
| 7 — `spec_lint.py` clean, no `specs/` edit | **pass** | `logs/spec-lint.log`: 0 errors, 1 pre-existing warning; no `specs/` path in the deliverable |

D5 (no `specs/` edit): holds. Command log: `notes.md`. Probe: `probe/zz_verify546_probe.gd`.
Delegated review: `review-code.md` — **Pass**.
