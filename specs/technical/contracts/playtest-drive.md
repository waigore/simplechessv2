# Contract: Playtest drive

Authoring rules: [`.agents/specs/rules/technical/contracts.md`](../../../.agents/specs/rules/technical/contracts.md).

- **Kind**: API — drive and observe playtest sessions
- **Provider**: [`CMP-playtest-seams`](../components/playtest-seams.md)
- **Consumers**: Playtest harness / agent (`ENV.1` `ENV.2`); [`CMP-session-router`](../components/session-router.md) subscribes E2
- **Serves**: Must `DBG.*` `TEL.*`; Observability
- **Informed by**: [`specs/playtest/tools.md`](../../playtest/tools.md); [`verification.md`](../verification.md)
- **ADRs**: [ADR-0004](../../adr/decisions/0004-dual-playtest-environments.md)

## Operations

| ID | Name | Input | Output / effect | When |
|----|------|-------|-----------------|------|
| O1 | pause | — | Halt session clocks/input without ending | `DBG.1` |
| O2 | resume | — | Continue session | `DBG.1` |
| O3 | inspect | field keys | Snapshot of requested play-state fields | `DBG.2` |
| O4 | jump | scenario/stage id | Publishes E2; the router enters that start state | `DBG.3` |
| O5 | set_overlay | on/off + story ids | Show/hide story-ID overlay | `DBG.4` |

## Events

| ID | Name | Payload | When emitted | Who may subscribe |
|----|------|---------|--------------|-------------------|
| E1 | tel_event | `TEL.1–5` fields | Playtest-relevant outcomes | Harness sink |
| E2 | jump_requested | scenario/stage id | O4 called | Session router (D5–D6) |

## Guarantees

| ID | Guarantee |
|----|-----------|
| G1 | O1–O5 and E1 available in playtest builds on Headless and Graphical |
| G2 | Release Web export strips or no-ops O1–O5 and overlay |
| G3 | Drive path must not redefine the 60 fps player move path |

## Errors

| Condition | Result |
|-----------|--------|
| Called in release | No-op / compile-out ([`FAIL.T5`](../failures.md)) |
| Unknown jump id | Error to harness; state unchanged |

## Diagram

None — small surface.
