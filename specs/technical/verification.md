# Verification

Authoring rules: [`.agents/specs/rules/technical/verification.md`](../../.agents/specs/rules/technical/verification.md).

- **Serves**: Observability; playtest Must `ENV.*` `DBG.*` `TEL.*`
- **Informed by**: [`specs/playtest/tools.md`](../playtest/tools.md); quality Observability
- **ADRs**: [ADR-0004](../adr/decisions/0004-dual-playtest-environments.md), [ADR-0001](../adr/decisions/0001-godot-engine.md), [ADR-0003](../adr/decisions/0003-localstorage-persistence.md)

## Seams

| ID | Seam | Purpose | How to drive |
|----|------|---------|--------------|
| S1 | Headless runner | `ENV.1` Design/UX without display | Godot `--headless` playtest build |
| S2 | Graphical Web runner | `ENV.2` screenshots and rendered UX | Web/HTML5 or editor display playtest build |
| S3 | Pause / resume | `DBG.1` | [`CTR-playtest-drive`](contracts/playtest-drive.md) O1/O2 via [`CMP-playtest-seams`](components/playtest-seams.md) |
| S4 | Inspect play state | `DBG.2` | O3; key [`SCH-play-state`](schemata/play-state.md) fields |
| S5 | Jump scenario / stage | `DBG.3` | O4 named entry |
| S6 | Story-ID overlay | `DBG.4` | O5; playtest builds only |
| S7 | Telemetry emit | `TEL.1–5` | E1 `tel_event` |

## Invariants to assert

| ID | Invariant | Level | When checked |
|----|-----------|-------|--------------|
| I1 | Local move completes with no await on advice I/O | Integration | During Shared play with Advice On |
| I2 | Persist failed write leaves prior document | Integration | Forced `localStorage` failure |
| I3 | DBG/TEL overlay absent in release Web export | Smoke | Release export review |
| I4 | Headless and Graphical both expose S3–S7 | Integration | Playtest protocol smoke |

## Harness expectations

| ID | Expectation |
|----|-------------|
| H1 | Playtest build flag compiles S3–S7; release strips or no-ops them |
| H2 | CI can launch S1; Graphical evidence via S2 when UX protocol requires screenshots |
| H3 | Telemetry sink: one JSON object per line on stdout (NDJSON); fields match playtest `TEL.*` ids |
| H4 | Smoke path: [`SEQ-playtest-headless-smoke`](sequences/playtest-headless-smoke.md) |

## Diagram

None — dual runners share seams.
