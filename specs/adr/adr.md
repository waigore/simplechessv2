# Architecture

Authoring rules: [`.agents/specs/rules/adr/adr.md`](../../.agents/specs/rules/adr/adr.md).

## Overview

The game is a Godot Web client ([ADR-0001](decisions/0001-godot-engine.md)) that runs Shared game and Puzzle stream on-device. Optional Advice goes to an advice backend that alone runs Stockfish and streams results ([ADR-0002](decisions/0002-stockfish-advice-backend.md)). Player Elo, Last mode, and recent solves persist in origin `localStorage` ([ADR-0003](decisions/0003-localstorage-persistence.md)). Agent playtesting uses Godot `--headless` and Graphical Web sessions with Must debug/telemetry seams in playtest builds ([ADR-0004](decisions/0004-dual-playtest-environments.md)). Catalog entries live in `asset_catalog/` and files in `game_assets/` ([ADR-0005](decisions/0005-asset-catalog-roots.md)); visual generate is Recraft-only.

## Stack

| Area | Choice | ADR |
|------|--------|-----|
| Engine | Godot 4.7.2, GDScript, Web export | [ADR-0001](decisions/0001-godot-engine.md) |
| Frameworks | N/A — Godot is the runtime; no separate web framework | — |
| Libraries | N/A — no third-party runtime library chosen yet | — |
| Data storage | Origin `localStorage` JSON document | [ADR-0003](decisions/0003-localstorage-persistence.md) |
| Integrations | Advice backend ↔ Stockfish; dual playtest environments; asset catalog/roots | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0005](decisions/0005-asset-catalog-roots.md) |
| Game architecture | None yet | — |

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`traceability.md`](traceability.md). Superseded and deprecated decisions: [`archive/`](archive/README.md).

- **Decisions**: [ADR-0001: Godot 4.7.2 engine](decisions/0001-godot-engine.md) — Accepted; [ADR-0002: Stockfish advice via backend](decisions/0002-stockfish-advice-backend.md) — Accepted; [ADR-0003: localStorage persistence](decisions/0003-localstorage-persistence.md) — Accepted; [ADR-0004: Dual playtest environments](decisions/0004-dual-playtest-environments.md) — Accepted; [ADR-0005: Asset catalog and asset roots](decisions/0005-asset-catalog-roots.md) — Accepted
