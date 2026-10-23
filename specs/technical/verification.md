# Verification

Authoring rules: [`.agents/specs/rules/technical/verification.md`](../../.agents/specs/rules/technical/verification.md).

- **Serves**: Observability; Performance; Load time; Accessibility; playtest Must `ENV.*` `DBG.*` `TEL.*`; cited `SIT.1`–`SIT.6`
- **Informed by**: [`specs/playtest/tools.md`](../playtest/tools.md), [`tools-situational.md`](../playtest/tools-situational.md); quality Observability
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
| S8 | Deterministic seed | `SIT.1` repeatable start on `ENV.1` and `ENV.2` | O6 via [`CMP-playtest-seams`](components/playtest-seams.md) |
| S9 | Input record / replay | `SIT.2` recorded input on `ENV.1` and `ENV.2` | O7 record and O8 replay |
| S10 | Full state dump | `SIT.3` snapshot beyond `DBG.2` on `ENV.1` and `ENV.2` | O9 |
| S11 | Frame-time / latency capture | `SIT.4` frame times over one move, and `EX.loading` start to ready | O10 |
| S12 | Telemetry read assertion | `SIT.5` assert the run's own `TEL.1`–`TEL.5` events and their story IDs | O11 over the E1 sink |
| S13 | Phone-width viewport at smallest text size | `SIT.6` legibility at [`UIS.T2`](../aesthetics/ui-style.md) | O12 |

## Invariants to assert

| ID | Invariant | Level | When checked |
|----|-----------|-------|--------------|
| I1 | Local move completes with no await on advice I/O ([`CTR-local-move.G1`](contracts/local-move.md)) | Integration | During Shared play with Advice On |
| I2 | Persist failed write leaves prior document ([`CTR-persist-document.G2`](contracts/persist-document.md)) | Integration | Forced `localStorage` failure |
| I3 | Debug UI and story-ID overlay, plus S3–S13 drive ops, absent from the release Web export ([`CTR-playtest-drive.G2`](contracts/playtest-drive.md)) | Smoke | Release export review |
| I4 | Headless and Graphical both expose S3–S7 ([`CTR-playtest-drive.G1`](contracts/playtest-drive.md)) | Integration | Playtest protocol smoke |
| I5 | Headless and Graphical both expose S8–S10 (`SIT.1`–`SIT.3`) | Integration | Playtest builds (`ENV.1`, `ENV.2`) |
| I6 | Headless and Graphical both expose S11–S13 (`SIT.4`–`SIT.6`); each timing report carries device, browser, build id, and repeat count ([`evidence-manifest.md`](../playtest/evidence-manifest.md)) | Integration | `PTU-shared-play`, `PTU-puzzle-play`, `PTU-mode-pick` |

## Harness expectations

| ID | Expectation |
|----|-------------|
| H1 | Playtest build flag compiles S3–S13; release strips or no-ops them |
| H2 | CI can launch S1; Graphical evidence via S2 when a UX protocol requires screenshots |
| H3 | Telemetry sink: NDJSON, one object per line on stdout; fields match `TEL.*` |
| H4 | Smoke path: [`SEQ-playtest-headless-smoke`](sequences/playtest-headless-smoke.md) |
| H5 | Logs and screenshots land under `docs/playtest/evidence/` as `issue-<n>/{headless,graphical}-<run-id>/` ([`evidence.md`](../playtest/evidence.md)) |

## Diagram

None — dual runners share seams.
