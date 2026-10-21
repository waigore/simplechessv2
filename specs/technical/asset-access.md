# Asset Access (Technical)

Authoring rules: [`.agents/specs/rules/technical/asset-access.md`](../../.agents/specs/rules/technical/asset-access.md).

- **Serves**: Load time; Instant play; Reliability; [`ACC`](../assets/access.md) G1 G2 G3
- **Informed by**: [`specs/assets/access.md`](../assets/access.md); [ADR-0005](../adr/decisions/0005-asset-catalog-roots.md); [ADR-0001](../adr/decisions/0001-godot-engine.md)
- **ADRs**: [ADR-0005](../adr/decisions/0005-asset-catalog-roots.md), [ADR-0001](../adr/decisions/0001-godot-engine.md)

## Resolution

| ID | Aspect | Realizes | Rule |
|----|--------|----------|------|
| R1 | Asset manifest | `ACC.A2` | Generated JSON from `asset_catalog/`; path `game/asset_manifest.json` (outside `asset_catalog/` and `game_assets/`); never hand-edited; regenerated when catalog entries change. |
| R2 | Resolver | `ACC.A1` | [`CMP-asset-resolver`](components/asset-resolver.md) reads the manifest by asset ID. Opus audio loads the Vorbis copy in O3. |
| R3 | Unresolved asset ID | `ACC.A3` | Dev/playtest: log + Must overlay. Release: skip draw, keep session, log once. |

## Engine resources

| ID | Resource class | Lives in | Uses | Kept in step by |
|----|----------------|----------|------|-----------------|
| E1 | Board / UI scenes that instance cataloged textures | Outside `game_assets/` (Godot scenes) | Piece, board, UI, icon, font, audio IDs | Manifest-driven load; audio via O3; no hard-coded paths |

## Build outputs

| ID | Output | Generator | Inputs | Location | Committed |
|----|--------|-----------|--------|----------|-----------|
| O1 | Godot `.import` caches | Godot import (ADR-0001) | Files under `game_assets/` | Beside assets or Godot cache | Rebuild; sidecars may commit with assets |
| O2 | Asset manifest | Catalog generator (ADR-0005) | Approved `asset_catalog/` entries | `game/asset_manifest.json` | Committed; regenerate in CI when catalog changes |
| O3 | Playback audio | Catalog generator (ADR-0005, ADR-0001) | Approved music and sound-effects Ogg Opus | `audio_runtime/<asset-id>.ogg` | Committed Vorbis copy. Catalog files stay Opus. Godot 4.7.2 does not decode Opus. Regenerate with the manifest. |

## Load groups

| ID | Realizes | Mechanism | Owner | Sequence |
|----|----------|-----------|-------|----------|
| G1 | `ACC.G1` | Preload Boot group before mode pick ready | [`CMP-asset-resolver`](components/asset-resolver.md) | Cold open → Boot IDs → ready when every ID resolves |
| G2 | `ACC.G2` | Preload Play group on first play screen | [`CMP-asset-resolver`](components/asset-resolver.md) | First play entry → Play IDs → ready when every ID resolves |
| G3 | `ACC.G3` | Load Ambient group when music first starts | [`CMP-asset-resolver`](components/asset-resolver.md) | Board playable, then music start → Ambient IDs → ready when every ID resolves |

## Diagram

None — three sequential groups; no overlap unload.
