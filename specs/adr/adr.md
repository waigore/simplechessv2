# Architecture

Authoring rules: [`.agents/specs/rules/adr/adr.md`](../../.agents/specs/rules/adr/adr.md).

## Overview

The game is a Godot Web client ([ADR-0001](decisions/0001-godot-engine.md)) that runs Shared game and Puzzle stream on-device. Optional Advice goes to an advice backend that alone runs Stockfish and streams results ([ADR-0002](decisions/0002-stockfish-advice-backend.md)). Player Elo, Last mode, and recent solves persist in origin `localStorage` ([ADR-0003](decisions/0003-localstorage-persistence.md)). Agent playtesting uses Godot `--headless` and Graphical Web sessions with Must debug/telemetry seams in playtest builds ([ADR-0004](decisions/0004-dual-playtest-environments.md)). Catalog entries live in `asset_catalog/` and files in `game_assets/` ([ADR-0005](decisions/0005-asset-catalog-roots.md)); visual generate is Recraft-only. Inside the client, four layers — Presentation, Session, Domain, Edge — keep moves on-device and seams at the edge ([ADR-0006](decisions/0006-layered-client-architecture.md)). The browser export is written to uncommitted `build/web/` ([ADR-0007](decisions/0007-web-export-output.md)). GitHub Pages serves that release export at `https://waigore.github.io/simplechessv2/` ([ADR-0009](decisions/0009-github-pages-client-host.md)). The puzzle catalog is a host-side snapshot of the Lichess export, not bytes in the client ([ADR-0008](decisions/0008-puzzle-catalog-storage.md)).

## Stack

| Area | Choice | ADR |
|------|--------|-----|
| Engine | Godot 4.7.2, GDScript, Web export | [ADR-0001](decisions/0001-godot-engine.md) |
| Frameworks | N/A — Godot is the runtime; no separate web framework | — |
| Libraries | N/A — turn-based 2D board play needs no runtime library beyond the engine | — |
| Data storage | Origin `localStorage` JSON document | [ADR-0003](decisions/0003-localstorage-persistence.md) |
| Data storage | Host-side puzzle catalog snapshot | [ADR-0008](decisions/0008-puzzle-catalog-storage.md) |
| Integrations | Advice backend ↔ Stockfish; dual playtest environments; asset catalog/roots; uncommitted Web export `build/web/` | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0005](decisions/0005-asset-catalog-roots.md), [ADR-0007](decisions/0007-web-export-output.md) |
| Integrations | Advice backend: no host vendor and no deploy plan | [ADR-0010](decisions/0010-no-advice-backend-host-deploy.md) |
| Integrations | GitHub Pages for the public client | [ADR-0009](decisions/0009-github-pages-client-host.md) |
| Game architecture | Layered client (Presentation / Session / Domain / Edge), contract-bound | [ADR-0006](decisions/0006-layered-client-architecture.md) |

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`traceability.md`](traceability.md). Superseded and deprecated decisions: [`archive/`](archive/README.md).

- **Decisions**: [ADR-0001: Godot 4.7.2 engine](decisions/0001-godot-engine.md) — Accepted; [ADR-0002: Stockfish advice via backend](decisions/0002-stockfish-advice-backend.md) — Accepted; [ADR-0003: localStorage persistence](decisions/0003-localstorage-persistence.md) — Accepted; [ADR-0004: Dual playtest environments](decisions/0004-dual-playtest-environments.md) — Accepted; [ADR-0005: Asset catalog and asset roots](decisions/0005-asset-catalog-roots.md) — Accepted; [ADR-0006: Layered client game architecture](decisions/0006-layered-client-architecture.md) — Accepted; [ADR-0007: Web export output directory](decisions/0007-web-export-output.md) — Accepted; [ADR-0008: Host-side Lichess puzzle catalog](decisions/0008-puzzle-catalog-storage.md) — Accepted; [ADR-0009: GitHub Pages client host](decisions/0009-github-pages-client-host.md) — Accepted; [ADR-0010: No advice-backend host or deploy plan](decisions/0010-no-advice-backend-host-deploy.md) — Accepted
