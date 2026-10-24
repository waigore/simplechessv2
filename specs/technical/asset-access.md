# Asset Access (Technical)

Authoring rules: [`.agents/specs/rules/technical/asset-access.md`](../../.agents/specs/rules/technical/asset-access.md).

- **Serves**: Load time; Instant play; Reliability; [`ACC.G1`–`G3`](../assets/access.md)
- **Informed by**: [`specs/assets/access.md`](../assets/access.md); ADR-0005; ADR-0001
- **ADRs**: ADR-0005, ADR-0001, [ADR-0014](../adr/decisions/0014-web-asset-root-route.md)

## Resolution

| ID | Aspect | Realizes | Rule |
|----|--------|----------|------|
| R1 | Asset manifest | `ACC.A2` | Generated JSON from `asset_catalog/` at `game/asset_manifest.json`, outside both roots; never hand-edited; regenerated when catalog entries change. |
| R2 | Resolver | `ACC.A1` | [`CMP-asset-resolver`](components/asset-resolver.md) reads the manifest by ID; a preload group leaving an approved ID unresolved surfaces as E4 ([`CTR-asset-resolve`](contracts/asset-resolve.md)), never pending. On Web the read path is `res://<asset_root>/…` and the Vorbis copy `res://audio_runtime/<asset ID>.ogg`, both beside `index.html`; elsewhere repo root (ADR-0014). Opus audio loads the Vorbis copy in O3; any other audio stream loads where it lies. |
| R3 | Unresolved asset ID | `ACC.A3` | Dev/playtest: log the unresolved ID and show the debug overlay where the build has one. Release: skip draw, keep session, log once. |

## Engine resources

| ID | Resource class | Lives in | Uses | Kept in step by |
|----|----------------|----------|------|-----------------|
| E1 | Board / UI scenes instancing cataloged textures | Outside `game_assets/` (Godot scenes) | Piece, board, UI, icon, font, audio IDs | Manifest-driven load; audio via O3; no hard-coded paths |

## Build outputs

| ID | Output | Generator | Inputs | Location | Committed |
|----|--------|-----------|--------|----------|-----------|
| O1 | Godot import cache (`.godot/`) | Godot import (ADR-0001) | Files under `game_assets/` | `game/.godot/` — outside the asset root | Rebuilt on import; not committed (`.gitignore`). In-root `.import` / `.uid` sidecars are asset-root content (`ACC.P1`). |
| O2 | Asset manifest | Catalog generator (ADR-0005) | Approved catalog entries | `game/asset_manifest.json` | Committed; CI regenerates on catalog change |
| O3 | Playback audio | Catalog generator (ADR-0005, ADR-0001) | Approved music and sound-effects Ogg Opus | `audio_runtime/<asset-id>.ogg` | Committed Vorbis copy; catalog files stay Opus, which 4.7.2 cannot decode. |
| O4 | Group gate | Export | `ACC.G1`–`G3` | `--check-groups` | Fails a group file with no route R2 reads, loose or packed (#812) |

## Load groups

| ID | Realizes | Mechanism | Owner | Sequence |
|----|----------|-----------|-------|----------|
| G1 | `ACC.G1` | Preload Boot group before mode pick ready | [`CMP-asset-resolver`](components/asset-resolver.md) | Load: cold open → Boot IDs → ready when every ID resolves; an unresolved ID fails the group ([`CTR-asset-resolve`](contracts/asset-resolve.md) E4), never pending. Unload: never in a sitting. |
| G2 | `ACC.G2` | Preload Play group on first play screen | [`CMP-asset-resolver`](components/asset-resolver.md) | Load: first play entry → Play IDs → ready when every ID resolves; an unresolved ID fails the group per R2. Unload: never in a sitting. |
| G3 | `ACC.G3` | Load Ambient group when mode pick becomes ready | [`CMP-asset-resolver`](components/asset-resolver.md) | Load: mode pick ready → Ambient IDs ([`SND.M1`](../aesthetics/sound.md)) → ready when every ID resolves; an unresolved ID fails the group per R2. Unload: never in a sitting. |

## Diagram

None — three sequential groups.
