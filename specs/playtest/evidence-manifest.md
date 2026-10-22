# Playtest evidence manifest

Authoring rules: [`.agents/specs/rules/playtest/evidence.md`](../../.agents/specs/rules/playtest/evidence.md).

Field list for a run's `manifest.md`. Schema and outcomes: [`evidence.md`](evidence.md).

| Field | Content |
|-------|---------|
| Issue | GitHub issue number |
| Environment | `headless` or `graphical` |
| Build / session id | Matches `TEL.3` where possible |
| Coverage mode | `full` or `critical-only` from the hub |
| Results | One row per cited story and one row per protocol verdict, using the outcomes in [`evidence.md`](evidence.md) |
| Paths | Relative paths to screenshots, `notes.md`, and log file(s). A headless run marks each screenshot path as waiting on a graphical run |
