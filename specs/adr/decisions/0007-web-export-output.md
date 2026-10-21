# ADR-0007: Web export output directory

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-21
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Web platform (definition); no-install browser commute (definition); Web/HTML5 export (ADR-0001); Godot project root `game/` (ADR-0005)

## Context

ADR-0001 ships a Godot 4.7.2 Web/HTML5 client. ADR-0005 places the project at `game/` and the committed manifest at `game/asset_manifest.json`. No spec names the browser export directory or whether that tree is committed. Asset-access O1 already rebuilds import caches and may commit `.import` / `.uid` sidecars beside `game_assets/`.

## Purpose

Where does the Web/HTML5 export land, relative to the repo root, and is that tree committed?

In scope: export directory and commit policy. Out of scope: project root, manifest, import caches, export preset steps.

## Decision

The Web/HTML5 export output directory is `build/web/` relative to the repo root. That tree is not committed. It holds the generated browser build (HTML, WASM, PCK, and the other files of that export). It is not `game/` and not `game/asset_manifest.json`.

## Reasoning

1. The shipped client is the Web build (definition platform; ADR-0001), so export needs one stable repo-root path.
2. HTML, WASM, and PCK change every export. They are rebuildable output. The no-install commute is served from that build, not from git.
3. The directory stays outside `game/` so the project root (ADR-0005) remains source.

Costs accepted: export targets `build/web/`; a fresh clone has no browser build until export.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Commit the export tree | Rebuildable binaries change every export |
| Output under `game/` (for example `game/build/`) | Mixes build products with the project root |

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | Frame budget unchanged |
| Load time / latency | No effect | Cold-open target unchanged |
| Reliability | No effect | Sitting soak unchanged |
| Observability | No effect | Logs are not this tree |
| Save durability | No effect | Persistence is ADR-0003 |
| Accessibility | No effect | Readability checks unchanged |
| Localization | No effect | Locale set unchanged |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Not relevant — no new dependency or fee |
| Maintainability | One repo-root directory; a move is a new ADR |
| Testability | Review `.gitignore` for `build/web/` and `.godot/`; `.import` and `.uid` beside `game_assets/` stay unignored |
| Portability | Web only, matching the supported platform |
| Security and privacy | Not relevant — public client bytes, no new store |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| None | — |

## Validation

| Check | Method | When |
|-------|--------|------|
| Uncommitted `build/web/`; `.godot/` ignored; `game_assets/` `.import` and `.uid` not ignored | Review of this ADR and `.gitignore` | Every release |
