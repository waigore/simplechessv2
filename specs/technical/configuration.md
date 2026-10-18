# Configuration (technical)

Authoring rules: [`.agents/specs/rules/technical/configuration.md`](../../.agents/specs/rules/technical/configuration.md).

- **Serves**: Design tunables bound into client code
- **Informed by**: [`specs/design/configuration.md`](../design/configuration.md)
- **ADRs**: [ADR-0001](../adr/decisions/0001-godot-engine.md)
- **Design config**: [`specs/design/configuration.md`](../design/configuration.md)

## Sources

| ID | Source | Format / shape | Loaded when | Owner |
|----|--------|----------------|-------------|-------|
| S1 | Design tunables table | Compile-time / data constants mirroring `CFG.*` | Client boot | Session / Domain consumers |
| S2 | Persist document | JSON via [`CTR-persist-document`](contracts/persist-document.md) | Cold open | [`CMP-persist-store`](components/persist-store.md) |
| S3 | Runtime options | In-memory `GS.*` configuration fields | Mode setup / play | Shared / puzzle sessions |

## Tables and tunables

| ID | Name | Maps to design param | Type | Default / range |
|----|------|----------------------|------|-----------------|
| T1 | blitz_start | `CFG.BLITZ_START` | int seconds | 60 |
| T2 | rapid_start | `CFG.RAPID_START` | int seconds | 600 |
| T3 | elo_k | `CFG.ELO_K` | int | 20 |
| T4 | elo_match_range | `CFG.ELO_MATCH_RANGE` | int Elo | 100 |
| T5 | elo_start | `CFG.ELO_START` | int Elo | 1000 |
| T6 | advice_time_ms | `CFG.ADVICE_TIME_MS` | int ms | 2000 |

## Binding

| ID | Consumer | Reads | Fail if missing |
|----|----------|-------|-----------------|
| B1 | [`CMP-shared-game-session`](components/shared-game-session.md) | T1 T2 T6; S3 clock options | Use design defaults; log |
| B2 | [`CMP-puzzle-session`](components/puzzle-session.md) | T3 T4 T5; S2 Elo | Use T5 on T3 persist fail |
| B3 | [`CMP-advice-client`](components/advice-client.md) | T6 | Cap at 2000 if missing |

## Diagram

None — flat constant bind.
