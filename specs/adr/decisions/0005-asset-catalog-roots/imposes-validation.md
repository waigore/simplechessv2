# ADR-0005: Imposes and validation

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0005](../0005-asset-catalog-roots.md) per [`decision.md`](../../../../.agents/specs/rules/adr/decision.md). Roots, formats, and the manifest are in that ADR's Decision.

## Context

N/A — the forces behind these constraints are in the parent ADR.

## Purpose

N/A — this file holds the parent ADR's Imposes and Validation sections only.

## Decision

N/A — see the parent ADR's Decision.

## Reasoning

N/A — see the parent ADR's Reasoning.

## Rejected alternatives

N/A — see the parent ADR's Rejected alternatives.

## Non-functional requirements

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| `specs/assets/assets.md` Catalog | Roots as Decision |
| `specs/assets/catalog.md` Format | Default one-JSON-per-asset entry format, unless an Integration ADR sets another |
| `specs/assets/access.md` P1–P2 | Asset root holds only cataloged files and import sidecars; engine resources and build outputs live outside it |
| `specs/assets/kinds/piece-sprites.md` S2, `kinds/board-backgrounds.md` S3, `kinds/interface-art.md` S2, `kinds/icons.md` S3 | SVG preferred / PNG alpha |
| `specs/assets/kinds/sound-effects.md` S4, `kinds/music.md` S5 | Audio is OGG |
| `specs/assets/kinds/fonts.md` S4 | Fonts are TTF/OTF/WOFF2 |
| `specs/assets/tools.md` Constraints on ADR | fal is not used for visual generation; tool roles stay ADR-free as that spec records |
| `specs/technical/asset-access.md` R1, O2 | Manifest generated from the catalog outside both roots, committed at `game/asset_manifest.json`, never hand-edited |

## Validation

| Check | Method | When |
|-------|--------|------|
| Catalog integrity | `asset_catalog.py` | PRs with catalog |
| Roots not mixed | Review of this ADR, `ACC.P1`–`P2`, and `specs/technical/asset-access.md` | Every release |
| Formats match kind specs | `asset_catalog.py` and review of each approved entry's medium against `AK-piece-sprites.S2`, `AK-board-backgrounds.S3`, `AK-interface-art.S2`, `AK-icons.S3`, `AK-sound-effects.S4`, `AK-music.S5`, `AK-fonts.S4` | PRs with catalog |
| Sitting survives a failed resolve | quality.md sitting soak; unresolved asset ID skipped in a Release build, sitting continues, one log line (`ACC.A3`) | Every release |
| 3 s open with boot/play groups | quality.md timed cold open | Every release |
| Piece/font readability | quality.md readability checks | Every release |
| Locale font coverage | quality.md locale spot-check | Every release |
