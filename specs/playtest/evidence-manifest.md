# Playtest evidence manifest

Authoring rules: [`.agents/specs/rules/playtest/evidence.md`](../../.agents/specs/rules/playtest/evidence.md).

Field list for a run's `manifest.md`. Schema and outcomes: [`evidence.md`](evidence.md).

| Field | Content |
|-------|---------|
| Issue | GitHub issue number |
| Environment | `headless` or `graphical` |
| Build / session id | The build under test by commit, the source it was read from (published URL, or the release export path with the reason it was used — [`procedures.md`](procedures.md) Prep), and the `TEL.3` session id |
| Timing (`SIT.4` runs) | Device and browser, and the repeat count of the timings; a single sample is not evidence |
| Coverage mode | `full` or `critical-only` from the hub |
| Results | One row per selected story row and one row per protocol verdict, using the outcomes in [`evidence.md`](evidence.md) |
| Paths | Relative paths to screenshots, `notes.md`, and log file(s). A headless run marks each screenshot path as waiting on a graphical run |

Worked example: a protocol judges four story rows; one run records three `pass` and one `fail`. Its protocol verdict is `fail`, so the folder is not acceptable.
