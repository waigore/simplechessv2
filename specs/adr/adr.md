# Architecture

Authoring rules: [`.agents/specs/rules/adr/adr.md`](../../.agents/specs/rules/adr/adr.md).

## Overview

The game is a Godot Web client ([ADR-0001](decisions/0001-godot-engine.md)) that runs Shared game and Puzzle stream on-device. Optional Advice goes to a separate Python advice backend at a client-configured endpoint, authenticated with a shared API key; that server invokes Stockfish locally and streams results ([ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0010](decisions/0010-advice-backend-stack.md), [ADR-0011](decisions/0011-local-stockfish-invocation.md)); the project conveys no Stockfish binary, so the GPL duty falls on the operator ([ADR-0012](decisions/0012-advice-backend-gpl-compliance.md)). Player Elo, Last mode, and recent solves persist in origin `localStorage` ([ADR-0003](decisions/0003-localstorage-persistence.md)). Agent playtesting uses Godot `--headless` and Graphical Web sessions with Must debug/telemetry seams in playtest builds ([ADR-0004](decisions/0004-dual-playtest-environments.md)). Catalog entries live in `asset_catalog/` and files in `game_assets/` ([ADR-0005](decisions/0005-asset-catalog-roots.md)); visual generate is Recraft-only. Inside the client, four layers — Presentation, Session, Domain, Edge — keep moves on-device and seams at the edge ([ADR-0006](decisions/0006-layered-client-architecture.md)). The browser export is written to uncommitted `build/web/` ([ADR-0007](decisions/0007-web-export-output.md)). GitHub Pages serves that release export at `https://waigore.github.io/simplechessv2/` ([ADR-0009](decisions/0009-github-pages-client-host.md)). The puzzle catalog is a host-side Lichess snapshot, not client bytes ([ADR-0008](decisions/0008-puzzle-catalog-storage.md)); the browser reads one puzzle per deal from a key-checked, rate-limited route on the advice server ([ADR-0013](decisions/0013-puzzle-catalog-api.md)). Advice deployments are operator-run only ([ADR-0015](decisions/0015-advice-backend-operator-deployments.md)).

## Stack

| Area | Choice | ADR |
|------|--------|-----|
| Engine | Godot 4.7.2, GDScript, Web export | [ADR-0001](decisions/0001-godot-engine.md) |
| Frameworks | N/A — Godot is the runtime; no separate web framework | — |
| Libraries | N/A — turn-based 2D board play needs no runtime library beyond the engine | — |
| Data storage | Origin `localStorage` JSON document | [ADR-0003](decisions/0003-localstorage-persistence.md) |
| Data storage | Host-side puzzle catalog snapshot | [ADR-0008](decisions/0008-puzzle-catalog-storage.md) |
| Integrations | Advice backend ↔ Stockfish (separate Python server; configured endpoint; shared API key); dual playtest environments; asset catalog/roots; uncommitted Web export `build/web/` | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0010](decisions/0010-advice-backend-stack.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0005](decisions/0005-asset-catalog-roots.md), [ADR-0007](decisions/0007-web-export-output.md) |
| Integrations | Python advice server invokes Stockfish locally | [ADR-0011](decisions/0011-local-stockfish-invocation.md) |
| Integrations | Operator-installed Stockfish; no bundled Stockfish binary; GPL duties on the operator | [ADR-0012](decisions/0012-advice-backend-gpl-compliance.md) |
| Integrations | GitHub Pages for the public client | [ADR-0009](decisions/0009-github-pages-client-host.md) |
| Integrations | Puzzle catalog read: route on the advice server, shared key, one record per deal, 30 requests per key per minute | [ADR-0013](decisions/0013-puzzle-catalog-api.md) |
| Game architecture | Layered client (Presentation / Session / Domain / Edge), contract-bound | [ADR-0006](decisions/0006-layered-client-architecture.md) |

## Traceability

[`traceability.md`](traceability.md).

## Index

[`index.md`](index.md) lists the global specs and every Proposed and Accepted decision with its status.
