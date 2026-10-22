# Technical Design

Authoring rules: [`.agents/specs/rules/technical/technical.md`](../../.agents/specs/rules/technical/technical.md).

## Overview

A Godot 4.7.2 Web client ([ADR-0001](../adr/decisions/0001-godot-engine.md)) runs Presentation, Session, Domain, and Edge layers on-device ([ADR-0006](../adr/decisions/0006-layered-client-architecture.md)) so a local move never waits on the network. The Edge talks to origin `localStorage` ([ADR-0003](../adr/decisions/0003-localstorage-persistence.md)), an advice backend that alone peers with Stockfish ([ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md)) and has no host or deploy plan in this project ([ADR-0010](../adr/decisions/0010-no-advice-backend-host-deploy.md)), and a generated asset manifest ([ADR-0005](../adr/decisions/0005-asset-catalog-roots.md)). Playtest builds add Headless and Graphical seams ([ADR-0004](../adr/decisions/0004-dual-playtest-environments.md)). The puzzle catalog is a host snapshot ([ADR-0008](../adr/decisions/0008-puzzle-catalog-storage.md)).

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`layers.md`](layers.md), [`modules.md`](modules.md), [`asset-access.md`](asset-access.md). Diagrams: [`diagrams/`](diagrams/). Optional copy sources: [`_templates/`](_templates/).

- **Failures**: [`failures.md`](failures.md)
- **Concurrency**: [`concurrency.md`](concurrency.md)
- **Persistence**: [`persistence.md`](persistence.md)
- **Configuration**: [`configuration.md`](configuration.md)
- **Verification**: [`verification.md`](verification.md)
- **Components**: [`session-router`](components/session-router.md), [`shared-game-session`](components/shared-game-session.md), [`puzzle-session`](components/puzzle-session.md), [`chess-rules`](components/chess-rules.md), [`presentation`](components/presentation.md), [`advice-client`](components/advice-client.md), [`advice-backend`](components/advice-backend.md), [`persist-store`](components/persist-store.md), [`asset-resolver`](components/asset-resolver.md), [`playtest-seams`](components/playtest-seams.md)
- **Contracts**: [`local-move`](contracts/local-move.md), [`presentation`](contracts/presentation.md), [`advice-stream`](contracts/advice-stream.md), [`persist-document`](contracts/persist-document.md), [`asset-resolve`](contracts/asset-resolve.md), [`playtest-drive`](contracts/playtest-drive.md)
- **Schemata**: [`play-state`](schemata/play-state.md), [`persist-doc`](schemata/persist-doc.md), [`advice-update`](schemata/advice-update.md), [`puzzle-attempt`](schemata/puzzle-attempt.md), [`puzzle-catalog`](schemata/puzzle-catalog.md)
- **Sequences**: [`cold-open`](sequences/cold-open.md), [`apply-local-move`](sequences/apply-local-move.md), [`advice-stream`](sequences/advice-stream.md), [`puzzle-result-commit`](sequences/puzzle-result-commit.md), [`shared-end-new-session`](sequences/shared-end-new-session.md), [`playtest-headless-smoke`](sequences/playtest-headless-smoke.md)
