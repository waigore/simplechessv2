# Playtest Glossary

Authoring rules: [`.agents/specs/rules/playtest/glossary.md`](../../.agents/specs/rules/playtest/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Coverage mode | Whether playtesting covers all in-scope design stories and UX journeys (`full`) or only marked critical IDs (`critical-only`). | [`coverage.md`](coverage.md), [`playtest.md`](playtest.md) |
| Design playtest | An agent protocol that proves the build against a design story or element. | [`design/`](design/) |
| Evidence run | One issue/run folder under `docs/playtest/evidence/` with manifest, notes, screenshots, and logs. | [`evidence.md`](evidence.md) |
| Manifest | The `manifest.md` index of story results and artifact paths for an evidence run. | [`evidence.md`](evidence.md) |
| Playtest protocol | A named agent procedure that cites upstream story IDs, required tools, steps, and pass/fail. | [`design/`](design/), [`ux/`](ux/) |
| Situational tool | A capability required only when a protocol cites it (seed, replay, state dump). | [`tools.md`](tools.md) |
| Telemetry event | A playtest-relevant runtime signal with the Must fields in `tools.md`. | [`tools.md`](tools.md) |
| UX playtest | An agent protocol that proves the build against a UX story or journey. | [`ux/`](ux/) |
