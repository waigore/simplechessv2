# Manifest — #767 acceptance run (headless)

| Field | Value |
|-------|-------|
| Issue | #767 — Promote shared-game keep list into main code (`type:task`, parent #34, Wave 1) |
| Environment | `ENV.1` headless — no display (`DisplayServer=headless`), Godot `4.7.2.stable.official.ed1daf0bf`, playtest build (`PlaytestGate.is_playtest()` true) |
| Build / session id | `origin/main` @ **`41f36e4`** (contains every linked PR: #791, #800, #809, #817, #819), clean detached worktree at `/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/accept767`; `TEL.3` session `sess-1792875843481-24410-playtest-604827` |
| Coverage mode | `full` (intersected with the issue's scope: the check cue this task built) |
| Protocols | `PTU-shared-play` (`UI-shared-play.US2.7` via step S4) |
| Drive | [`drive_headless.gd`](drive_headless.gd) — `godot --headless --path game -s` |

## Scope

The issue's only code deliverable is the `PER.R6` check cue (`game/check_marks.gd`, `board_presentation.gd`, `shared_play_panel.gd`). The UX row that judges it is `UI-shared-play.US2.7`, reached by `PTU-shared-play` step S4 ("Confirm coordinates / advice affordances per screen story"). The run drives S1/S2 (both seats) to reach the check and then S4's read of the cue.

`VS2.4` / `VS2.4b` are **view** stories and are out of playtest scope ([`playtest.md`](../../../../../specs/playtest/playtest.md): "View stories are out of scope"); the run records their readings as corroboration of `US2.7`, never as a protocol verdict.

## Results

| Story row | Judging protocol | Outcome |
|-----------|------------------|---------|
| `UI-shared-play.US2.7` (`shared-play-regions.md#US2.7`, "R2 shows the word Check and the PAL.C8 mark") | `PTU-shared-play` S4 | **pass** |
| Protocol `PTU-shared-play` | — | **pass** (scope: the S4 read of the check cue; see Notes) |

Readings behind `US2.7` `pass` (all in [`logs/drive.log`](logs/drive.log)):

| Reading | Value |
|---|---|
| Word shown in R2 while in check | `label='Check'`, localized via `StringTable.shared_play("check","en")` |
| PAL.C8 mark on the checked King | `CheckMarks.marked_square='e8'`, `strokes=2`, colour `#C28A86` (= `PAL.C8`) |
| Chip keyline | `border=c28a86`, `border_w=4` px (≥ UIS.I1 1.5 px) |
| Contrast of the word on its chip | **6.39:1** (≥ 4.5:1); readings recorded, not a `quality.md` claim |
| Word wrapping | `lines=1`; `chip 91.0 >= text 51.0` |
| Exactly one mark | `Overlays=[Selection,LegalMarks,CheckMarks,RejectFlash,PromoteChoice,AdviceMarks]` — no duplicate `CheckMark` node |
| Mark stroke on screen | `px_per_unit=72.00`, `stroke=4.32 px` (≥ 1.5 px) |
| Clears with the check | after `4.Kxf7`: chip hidden, `strokes=0`, `_in_check_now()==false` |
| Not shown out of check | before `3.Qxf7+`: chip hidden, `strokes=0` |
| `TEL.*` correlation | `{"TEL.1":"shared.check","TEL.2":…,"TEL.3":"sess-…-604827","TEL.4":"UI-shared-play.US2","TEL.5":"shown"}` — verdict `pass` |

## Paths

- [`logs/drive.log`](logs/drive.log) — the judged window (`STEP` lines, all 30 checks `ok:`, `FAILURES []`, `DONE failures=0`)
- [`logs/import.log`](logs/import.log) — project import before the run
- [`logs/playtest-headless.log`](logs/playtest-headless.log) — `ENV.1` smoke of the same build, exit 0
- [`logs/pocs-import-check.log`](logs/pocs-import-check.log) — `grep -rn "pocs/" game/` → 0 lines (AC2)
- [`logs/unit-tests.log`](logs/unit-tests.log) — 32 headless unit tests passed
- [`logs/coverage.log`](logs/coverage.log) — statement coverage 86.7% (4776/5508), threshold 80
- [`logs/gdformat-check.log`](logs/gdformat-check.log), [`logs/gdlint.log`](logs/gdlint.log) — clean
- [`logs/spec-lint.log`](logs/spec-lint.log) — 0 errors, 1 pre-existing glossary warning
- [`logs/asset-citation.log`](logs/asset-citation.log) — manifest/asset citation audit for AC5
- `screenshots/01-ready-not-in-check.png` — **waiting on the graphical run**
- `screenshots/02-white-gives-check.png` — **waiting on the graphical run**
- `screenshots/03-check-answered.png` — **waiting on the graphical run**

Per [`evidence.md`](../../../../../specs/playtest/evidence.md), the headless omission of screenshots is not a fail; the graphical run of the same build writes them.

## Defects

None filed from this run.
