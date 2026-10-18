# Asset Pipeline

Authoring rules: [`.agents/specs/rules/assets/assets.md`](../../.agents/specs/rules/assets/assets.md).

## Purpose

Produces vector piece and board art, quiet UI chrome, icons, locale-capable fonts, short SFX, and cafe ambient music for Shared game and Puzzle stream. Does not cover 3D, voice, or competitive chrome.

## Asset kinds

| Kind | Applicability | Grounds | Kind specs |
|------|---------------|---------|------------|
| Sprites | Applies | Vector 2D pieces; [FRM](../aesthetics/form.md); [E-pieces](../design/entities/pieces.md) | [`piece-sprites`](kinds/piece-sprites.md) |
| Tilesets | N/A — squares live in board art / engine grid | Vector board plane | — |
| Backgrounds | Applies | Mahogany board / cafe table ([P3](../aesthetics/aesthetics.md), [SRF.M1](../aesthetics/surface.md)) | [`board-backgrounds`](kinds/board-backgrounds.md) |
| 3D models | N/A — Vector 2D medium | [aesthetics.md](../aesthetics/aesthetics.md) | — |
| Textures and materials | N/A — no 3D materials | Vector 2D | — |
| Animation clips | N/A — move motion is engine tween ([PHY.M1](../view/physics.md)) | View physics | — |
| Visual effects | N/A — overlays are flat view/UI marks ([FRM.D2](../aesthetics/form.md)) | Perception marks | — |
| Interface art | Applies | Panels / buttons ([ui-style.md](../aesthetics/ui-style.md)) | [`interface-art`](kinds/interface-art.md) |
| Icons | Applies | Mode and control icons ([UI.I1](../aesthetics/ui-style.md)) | [`icons`](kinds/icons.md) |
| Fonts | Applies | T1–T3; `en` / `zh-Hant` / `ja` | [`fonts`](kinds/fonts.md) |
| Sound effects | Applies | [SND.X1–X5](../aesthetics/sound.md) | [`sound-effects`](kinds/sound-effects.md) |
| Music | Applies | [SND.M1](../aesthetics/sound.md) | [`music`](kinds/music.md) |
| Voice | N/A — [SND.V1](../aesthetics/sound.md) | No spoken characters | — |

## Sources

| Source type | Applicability | Grounds |
|-------------|---------------|---------|
| AI generation | Applies | Recraft visual; ElevenLabs SFX/music |
| Procedural generation | N/A — no procedural asset recipes | Authored/generated art only |
| Third-party | Applies | Fonts (licensed for Web) |
| Human-made | Applies | `APR.register` path |

## Catalog

- **Catalog root**: `asset_catalog/` ([ADR-0005](../adr/decisions/0005-asset-catalog-roots.md))
- **Asset root**: `game_assets/` ([ADR-0005](../adr/decisions/0005-asset-catalog-roots.md))

Asset IDs, format, and integrity: [`catalog.md`](catalog.md). Fields: [`catalog/fields.md`](catalog/fields.md).

## Lifecycle

| State | Meaning |
|-------|---------|
| draft | Made and cataloged; not yet approved |
| approved | Passed review per **Approval**, or review-exempt; main code may use it |
| deprecated | Retired; main code must not use it |

- **Approval**: `review-asset` Pass alone.
- **Review exemption**: Only a person may exempt an asset, of any source type, from review, recorded in `CAT.F17`. An exempt asset is approved when its entry merges.
- **Use**: Main code uses only approved assets. A gameplay demo uses only cataloged assets with a `review-asset` Pass or a review exemption.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`tools.md`](tools.md), [`procedures.md`](procedures.md), [`catalog.md`](catalog.md), [`access.md`](access.md).

- **Procedures (split)**: [`procedures/generate.md`](procedures/generate.md), [`procedures/update.md`](procedures/update.md), [`procedures/touch-up.md`](procedures/touch-up.md), [`procedures/establish-style.md`](procedures/establish-style.md).
- **Kinds**: [`piece-sprites`](kinds/piece-sprites.md), [`board-backgrounds`](kinds/board-backgrounds.md), [`interface-art`](kinds/interface-art.md), [`icons`](kinds/icons.md), [`fonts`](kinds/fonts.md), [`sound-effects`](kinds/sound-effects.md), [`music`](kinds/music.md)
