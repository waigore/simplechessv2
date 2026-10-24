# Playtest Glossary

Authoring rules: [`.agents/specs/rules/playtest/glossary.md`](../../.agents/specs/rules/playtest/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Coverage mode | Coverage of every in-scope design row and UX row, journey rows included (`full`), or of marked critical IDs only (`critical-only`). | [`coverage.md`](coverage.md) |
| Design playtest | An agent protocol proving the build against a design story or element. | [`design/`](design/) |
| Evidence run | One issue/run folder under `docs/playtest/evidence/` with manifest, notes, logs, and screenshots when captured. | [`evidence.md`](evidence.md) |
| Graphical run | A session with a display that re-runs protocols and captures screenshots of the judged state for the same build. | [`evidence.md`](evidence.md) |
| Headless run | A session with no display that may judge protocols and record outcomes, notes, and logs. | [`evidence.md`](evidence.md) |
| Manifest | The `manifest.md` index of story outcomes, protocol verdicts, and artifact paths for an evidence run. | [`evidence.md`](evidence.md) |
| `not-judged` | A story outcome for a run that could not judge the story; never `pass`, and it makes its protocol `not-judged` there. | [`evidence.md`](evidence.md) |
| Playtest protocol | A named agent procedure with cited story IDs, required tools, steps, and pass/fail. | [`procedures.md`](procedures.md) |
| Protocol verdict | A protocol's outcome for one environment: `pass` only when every cited story is `pass`. | [`evidence.md`](evidence.md) |
| Situational tool | A capability required only when a protocol cites it (seed, replay, state dump, timing, telemetry read, legibility viewport). | [`tools-situational.md`](tools-situational.md) |
| Story outcome | The per-row judgement a run records: `pass`, `fail`, `not-judged`, or `none`. | [`evidence.md`](evidence.md) |
| Story row | One design story heading, one UX story heading, or one journey: the unit a run judges. A row no protocol judges records `none` with a linked defect. | [`story-rows.md`](story-rows.md) |
| Telemetry event | A playtest-relevant runtime signal with the Must fields in [`tools.md`](tools.md). | [`tools.md`](tools.md) |
| UX playtest | A level proving the build against one UX story or journey per protocol, Headless and Graphical. | [`ux/`](ux/) |
