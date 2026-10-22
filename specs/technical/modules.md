# Modules

Authoring rules: [`.agents/specs/rules/technical/modules.md`](../../.agents/specs/rules/technical/modules.md).

- **Serves**: Instant play; Web ship; Advice without client Stockfish
- **Informed by**: [ADR-0001](../adr/decisions/0001-godot-engine.md), [ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md), [ADR-0004](../adr/decisions/0004-dual-playtest-environments.md), [ADR-0006](../adr/decisions/0006-layered-client-architecture.md), [ADR-0011](../adr/decisions/0011-local-stockfish-invocation.md)

## Modules

| ID | Name | Contains | Boundary rule |
|----|------|----------|---------------|
| M1 | `client` | Godot 4.7.2 Web app under `game/`: all L1–L4 components; playtest build flags | No Stockfish; no UCI |
| M2 | `advice-backend` | One Python server: invokes Stockfish locally; streams eval/best-move to M1 ([ADR-0011](../adr/decisions/0011-local-stockfish-invocation.md)) | Client never imports engine. No network hop to Stockfish |

Godot project root: `game/` at the repo root (sibling of `asset_catalog/`, `game_assets/`, `specs/`) ([ADR-0001](../adr/decisions/0001-godot-engine.md)).

## Boundaries

| ID | From | To | Allowed | Forbidden |
|----|------|----|---------|-----------|
| B1 | M1 | M2 | Position request; streamed advice until `CFG.ADVICE_TIME_MS`; cancel | Direct Stockfish or UCI |
| B2 | M2 | Stockfish | Local UCI inside the same Python server | A network connection to Stockfish; exposing Stockfish to M1 |
| B3 | M1 | Browser | `localStorage`; Web export APIs | Server-side save ([ADR-0003](../adr/decisions/0003-localstorage-persistence.md)) |

## Diagram

```mermaid
flowchart LR
  M1[M1 client]
  M2[M2 advice-backend]
  SF[Stockfish]
  M1 -->|advice stream| M2
  M2 -->|local UCI| SF
```
