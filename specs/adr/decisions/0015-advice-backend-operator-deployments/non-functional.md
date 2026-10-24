# ADR-0015: Non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0015](../0015-advice-backend-operator-deployments.md) per [`decision.md`](../../../../.agents/specs/rules/adr/decision.md). The posture is in that ADR's Decision.

## Context

N/A — the forces are in the parent ADR.

## Purpose

N/A — this file holds the parent ADR's non-functional tables only.

## Decision

N/A — see the parent ADR's Decision.

## Reasoning

N/A — see the parent ADR's Reasoning.

## Rejected alternatives

N/A — see the parent ADR's Rejected alternatives.

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | No runtime code or geometry changes |
| Load time / latency | No effect | Timing stays ADR-0002 and `quality.md`; this fixes no backend to time |
| Reliability | No effect | Failure paths (`FAIL.T1`, no deal) are unchanged |
| Observability | No effect | No new telemetry, logs, or story IDs |
| Save durability | No effect | The project persists no server state |
| Accessibility | No effect | No player-facing copy or control changes |
| Localization | No effect | No player-facing copy |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | No project fee or hosting cost; the operator bears both (ADR-0012) |
| Maintainability | Removes a deploy surface the project would otherwise keep current |
| Testability | Backend tests stay local and headless; no hosted environment to automate |
| Portability | The backend runs wherever an operator runs Python with Stockfish |
| Security and privacy | The project exposes no endpoint; no player data leaves the operator's machine |

## Imposes

N/A — see the parent ADR's Imposes.

## Validation

N/A — see the parent ADR's Validation.
