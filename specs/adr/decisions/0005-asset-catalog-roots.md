# ADR-0005: Asset catalog and asset roots

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Asset pipeline Catalog; Load time; Instant play; ADR-0001; Recraft/ElevenLabs ADR-free

## Context

Art and sound need catalog records and importable files without treating entry JSON as Godot resources.

## Purpose

Where do catalog entries and asset files live, and how is the asset manifest produced?

In scope: roots, default entry format, manifest boundary, file kinds, Godot project root for the manifest. Out of scope: recipes.

## Decision

- **Catalog root**: `asset_catalog/` — entry JSON only; never Godot-imported.
- **Asset root**: `game_assets/` — cataloged files + `.import`/`.uid` sidecars; entry paths relative here.
- **Godot project root**: `game/` (repo root sibling of the catalog and asset roots).
- **Formats**: SVG preferred / PNG alpha; audio OGG; fonts TTF/OTF/WOFF2 (Web-embed license).
- **Manifest**: generated from catalog, approved-only, at `game/asset_manifest.json`; committed; regenerate on catalog change (including CI).
- Visual generate: **Recraft only** (no fal). Audio: **ElevenLabs**.

## Reasoning

1. Split JSON catalog from importable files.
2. Repo-root folders work before Godot scaffold.
3. Default one-JSON-per-asset keeps PRs safe.
4. Recraft-only matches style lock; drops fal.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Catalog under `res://` | Entry JSON would import |
| fal batch images | Recraft only |
| Custom catalog DB | Default JSON enough |

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | Load path technical |
| Load time / latency | Affects | Boot/play groups fit 3 s open |
| Reliability | Affects | Approved-only manifest; ACC.A3 |
| Observability | No effect | — |
| Save durability | No effect | — |
| Accessibility | Affects | Pieces/fonts meet shape/text |
| Localization | Affects | Fonts for `en`/`zh-Hant`/`ja` |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Tool quotas outside repo; fonts licensed |
| Maintainability | Flat roots; `asset_catalog.py` |
| Testability | Catalog CI |
| Portability | Web primary |
| Security and privacy | No credentials in repo |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| `specs/assets/assets.md` Catalog | Roots as Decision |
| `specs/assets/access.md` | Uses these roots |
| `specs/technical/asset-access.md` | Manifest outside roots |

## Validation

| Check | Method | When |
|-------|--------|------|
| Catalog integrity | `asset_catalog.py` | PRs with catalog |
| Roots not mixed | Review | Every release |
