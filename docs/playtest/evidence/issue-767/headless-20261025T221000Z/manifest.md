# Manifest — #767 acceptance run (headless)

| Field | Value |
|-------|-------|
| Issue | #767 — Promote shared-game keep list into main code (`type:task`, parent #34, Wave 1) |
| Environment | `ENV.1` headless — no display (`DisplayServer=headless`), Godot `4.7.2.stable.official.ed1daf0bf`, playtest build |
| Build / session id | `origin/main` @ **`41f36e4`** (contains #791, #800, #809, #817, #819), clean detached worktree at `/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/accept767`; `TEL.3` `sess-1792875843481-24410-playtest-604827` |
| Coverage mode | `full` (intersected with the issue's scope) |
| Protocol | `PTU-shared-play` (`UI-shared-play.US2.7`, step S4) |
| Drive | [`drive_headless.gd`](drive_headless.gd) |

## Scope

The issue's only code deliverable is the `PER.R6` check cue. The row judging it is `UI-shared-play.US2.7`, reached by `PTU-shared-play` S4. `VS2.4`/`VS2.4b` are **view** stories — out of playtest scope — and are read only as corroboration, never as a verdict.

## Results

| Story row | Judging protocol | Outcome |
|-----------|------------------|---------|
| `UI-shared-play.US2.7` | `PTU-shared-play` S4 | **pass** |
| Protocol `PTU-shared-play` | — | **pass** (S4 read of the check cue) |

Readings behind the verdict (in [`logs/drive.log`](logs/drive.log)):

| Reading | Value |
|---|---|
| Word in R2 while in check | `Check`, localized key via `StringTable` |
| Chip keyline | `#c28a86` = `PAL.C8`, 4 px |
| Board mark | `marked_square='e8'`, `strokes=2`, `PAL.C8`, 4.32 px |
| Mark on the checked King only | yes — `e8` is Black's King |
| Contrast of word on chip | 6.39:1 |
| Word wrapping | `lines=1`; `chip 91.0 >= text 51.0` |
| One mark only | `Overlays` holds `CheckMarks`, no `CheckMark` |
| Absent out of check, cleared after `Kxf7` | yes |
| `TEL.*` | `shared.check` → `TEL.4=UI-shared-play.US2`, `TEL.5=shown`, verdict `pass` |

## Paths

- [`notes.md`](notes.md) — judgement and limits
- [`logs/drive.log`](logs/drive.log) — judged window, 30 `ok:`, `FAILURES []`
- [`logs/import.log`](logs/import.log) — project import
- [`logs/playtest-headless.log`](logs/playtest-headless.log) — `ENV.1` smoke, exit 0
- [`logs/pocs-import-check.log`](logs/pocs-import-check.log) — `grep -rn "pocs/" game/` → 0
- [`logs/unit-tests.log`](logs/unit-tests.log) — 32 passed
- [`logs/coverage.log`](logs/coverage.log) — 86.7% (4776/5508), threshold 80
- [`logs/gdformat-check.log`](logs/gdformat-check.log), [`logs/gdlint.log`](logs/gdlint.log) — clean
- [`logs/spec-lint.log`](logs/spec-lint.log) — 0 errors
- [`logs/asset-citation.log`](logs/asset-citation.log) — AC5 audit
- `screenshots/01-ready-not-in-check.png`, `02-white-gives-check.png`, `03-check-answered.png` — **waiting on the graphical run**

## Defects

None filed.
