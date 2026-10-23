# Playtest Traceability

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../.agents/specs/rules/playtest/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play | vision | [`design/move-advice.md`](design/move-advice.md), [`tools.md`](tools.md) |
| Cafe calm | vision | [`ux/shared-session.md`](ux/shared-session.md) and [`ux/puzzle-session.md`](ux/puzzle-session.md) judge the two journeys; [`procedures.md`](procedures.md). Quality-row exception: vision item 3's supports-it clause is audio ("Cafe ambient music plays for the whole session, including blitz and rapid"), served by the presentation/audio surface, and no playtest protocol, tool, or evidence file judges audio playback |
| Clear board | vision | Out of playtest protocol scope; no playtest protocol or tool judges piece readability from shape. Upstream: `vision.md` item 2, "Clear board — Every piece type is readable at a glance. A casual player can name each piece from its shape alone"; judged outside playtest ([`definition/quality.md`](../definition/quality.md) Accessibility: `PER.R1`, verified outside playtest) |
| Shared two-player + puzzle stream scope | definition | [`design/shared-game.md`](design/shared-game.md), [`design/puzzle-stream.md`](design/puzzle-stream.md), [`ux/shared-session.md`](ux/shared-session.md), [`ux/puzzle-session.md`](ux/puzzle-session.md) |
| Optional Stockfish advice | definition | [`design/move-advice.md`](design/move-advice.md) |
| Observability quality | definition/quality | Quality-row exception: the quality is served by the evidence surface ([`tools.md`](tools.md), [`evidence.md`](evidence.md)) because a run's captured logs carry `TEL.1`–`TEL.5` — event, timestamp, session/build id, story ID, outcome/severity ([`tools.md`](tools.md) Telemetry) — and [`evidence.md`](evidence.md) requires those logs under `logs/` in the run folder; asserted via `SIT.5` ([`tools-situational.md`](tools-situational.md)) and `PTU-shared-play` S6. No design or UX protocol cites the quality itself; their **Cites** name design/UX stories |
| Design stories (full) | design | All [`design/`](design/) protocols; playtest set selection [`coverage.md`](coverage.md) |
| UX journeys and screens (full) | ux | All [`ux/`](ux/) protocols; playtest set selection [`coverage.md`](coverage.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Tools (debug UI, telemetry) | [`tools.md`](tools.md) | Applies |
| Environments (headless, graphical) | [`playtest.md`](playtest.md), [`tools.md`](tools.md) | Applies |
| Procedures | [`procedures.md`](procedures.md) | Applies |
| Evidence | [`evidence.md`](evidence.md) | Applies |
| Coverage mode | [`coverage.md`](coverage.md), [`playtest.md`](playtest.md) | Applies |
| Design protocols | [`design/`](design/) | Applies |
| UX protocols | [`ux/`](ux/) | Applies |
| ADR / technical constraints | [`tools.md`](tools.md), hub architecture constraints | Applies |
