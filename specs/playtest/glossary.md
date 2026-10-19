# Playtest Glossary

Authoring rules: [`.agents/specs/rules/playtest/glossary.md`](../../.agents/specs/rules/playtest/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Coverage mode | Whether playtesting covers all in-scope design stories and UX journeys (`full`) or only marked critical IDs (`critical-only`). | [`coverage.md`](coverage.md), [`playtest.md`](playtest.md) |
| Design playtest | A Headless-only playtest level that proves the build against one design story or element per protocol. | [`design/`](design/), [`playtest.md`](playtest.md) |
| Evidence run | One issue/environment/run folder under `docs/playtest/evidence/` with manifest, notes, logs, and the screenshots [`evidence.md`](evidence.md) requires. | [`evidence.md`](evidence.md) |
| Graphical environment | Full rendered playtest session used for UX protocols (with Headless). | [`playtest.md`](playtest.md), [`tools.md`](tools.md) |
| Headless environment | Playtest session with no graphics display; used for Design protocols and UX protocols. | [`playtest.md`](playtest.md), [`tools.md`](tools.md) |
| Manifest | The `manifest.md` index of story results and artifact paths for an evidence run. | [`evidence.md`](evidence.md) |
| Playtest protocol | A named agent procedure that cites upstream story IDs, required tools, steps, and pass/fail. | [`design/`](design/), [`ux/`](ux/) |
| Situational tool | A capability required only when a protocol cites it (seed, replay, state dump). | [`tools.md`](tools.md) |
| Telemetry event | A playtest-relevant runtime signal with the Must fields in `tools.md`. | [`tools.md`](tools.md) |
| UX playtest | A playtest level that proves the build against one UX story or journey per protocol; runs Headless and Graphical. | [`ux/`](ux/), [`playtest.md`](playtest.md) |
