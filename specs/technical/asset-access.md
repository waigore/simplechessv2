# Asset Access (Technical)

Authoring rules: [`.agents/specs/rules/technical/asset-access.md`](../../.agents/specs/rules/technical/asset-access.md).

- **Serves**: Load time; Instant play; Reliability; [`ACC`](../assets/access.md) G1 G2
- **Informed by**: [`specs/assets/access.md`](../assets/access.md); [ADR-0005](../adr/decisions/0005-asset-catalog-roots.md); [ADR-0001](../adr/decisions/0001-godot-engine.md)
- **ADRs**: [ADR-0005](../adr/decisions/0005-asset-catalog-roots.md), [ADR-0001](../adr/decisions/0001-godot-engine.md)

## Resolution

| ID | Aspect | Realizes | Rule |
|----|--------|----------|------|
| R1 | Asset manifest | `ACC.A2` | Generated JSON from `asset_catalog/`; path `game/asset_manifest.json` (outside `asset_catalog/` and `game_assets/`); never hand-edited; regenerated when catalog entries change. |
| R2 | Resolver | `ACC.A1` | [`CMP-asset-resolver`](components/asset-resolver.md) reads the manifest by asset ID. |
| R3 | Unresolved asset ID | `ACC.A3` | Dev/playtest: log + Must overlay. Release: skip draw, keep session, log once. |

## Engine resources

| ID | Resource class | Lives in | Uses | Kept in step by |
|----|----------------|----------|------|-----------------|
| E1 | Board / UI scenes that instance cataloged textures | Outside `game_assets/` (Godot scenes) | Piece, board, UI, icon, font, audio IDs | Manifest-driven load; no hard-coded paths |

## Build outputs

| ID | Output | Generator | Inputs | Location | Committed |
|----|--------|-----------|--------|----------|-----------|
| O1 | Godot `.import` caches | Godot import (ADR-0001) | Files under `game_assets/` | Beside assets or Godot cache | Rebuild; sidecars may commit with assets |
| O2 | Asset manifest | Catalog generator (ADR-0005) | Approved `asset_catalog/` entries | `game/asset_manifest.json` | Committed; regenerate in CI when catalog changes |

## Load groups

| ID | Realizes | Mechanism | Owner | Sequence |
|----|----------|-----------|-------|----------|
| G1 | `ACC.G1` | Preload Boot set before mode pick ready | [`CMP-asset-resolver`](components/asset-resolver.md) | Cold open → manifest Boot IDs → mark ready |
| G2 | `ACC.G2` | Preload Play set on first play screen | [`CMP-asset-resolver`](components/asset-resolver.md) | Enter Shared/Puzzle play → Play IDs |

## Diagram

None — two sequential groups; no overlap unload.
