# Component: Asset resolver

Authoring rules: [`.agents/specs/rules/technical/components.md`](../../../.agents/specs/rules/technical/components.md).

- **Layer**: L4 Edge
- **Module**: M1 `client`
- **Serves**: Load time; Instant play; [`ACC`](../../assets/access.md) G1 G2 G3
- **Informed by**: [`asset-access.md`](../asset-access.md); [`specs/assets/access.md`](../../assets/access.md)
- **ADRs**: [ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md), [ADR-0001](../../adr/decisions/0001-godot-engine.md)

## Responsibilities

| ID | Responsibility |
|----|----------------|
| R1 | Read generated asset manifest by asset ID only ([`AST.R1`](../asset-access.md)); Opus audio loads [`AST.O3`](../asset-access.md) |
| R2 | Preload Boot group before mode pick ready ([`AST.G1`](../asset-access.md)); a group that leaves an approved ID unresolved emits [`CTR-asset-resolve`](../contracts/asset-resolve.md) E4 with the count, logged, and never the ready event |
| R3 | Preload Play group on first play screen ([`AST.G2`](../asset-access.md)) |
| R4 | Handle unresolved IDs per [`AST.R3`](../asset-access.md) |
| R5 | Preload Ambient when mode pick becomes ready (`EX.loading` → ready, after boot ready), not on cold open ([`AST.G3`](../asset-access.md)) |

## Communication

| ID | Peer | Direction | Via contract | Notes |
|----|------|-----------|--------------|-------|
| C1 | [`CMP-session-router`](session-router.md) | emits to | [`CTR-asset-resolve`](../contracts/asset-resolve.md) | Boot ready, or Boot failure with the unresolved count (E4) |
| C2 | [`CMP-session-router`](session-router.md) | listens | [`CTR-asset-resolve`](../contracts/asset-resolve.md) | O1 resolve and O3 Play preload; L2 routes L1 asset needs |
| C3 | [`CMP-session-router`](session-router.md) | listens | [`CTR-asset-resolve`](../contracts/asset-resolve.md) | O4 Ambient preload and E3 |

## Owns / mutates

| Schema or state | Access |
|-----------------|--------|
| Loaded resource cache by asset ID | write |
| Manifest | read |

## Diagram

```mermaid
flowchart LR
  SR[CMP-session-router]
  AR[CMP-asset-resolver]
  M[manifest]
  SR -->|CTR-asset-resolve| AR
  AR --> M
```

## Failure / concurrency / persistence

[`failures.md`](../failures.md) T4; [`asset-access.md`](../asset-access.md).
