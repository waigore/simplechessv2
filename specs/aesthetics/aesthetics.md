# Aesthetics

Authoring rules: [`.agents/specs/rules/aesthetics/aesthetics.md`](../../.agents/specs/rules/aesthetics/aesthetics.md).

## Medium

- **Medium**: Vector 2D. Matches the flat board plane ([view.md](../view/view.md)); pieces and board are crisp shapes, not pixel art or 3D.
- **Resolution and scale**: Art is resolution-independent with no intrinsic art resolution, so each element is drawn to scale at any screen size ([PRJ.X1](../view/projection.md)). Proportions use world units ([SPC.U1](../view/spatial-model.md)): 1 unit = 1 square, and the reference frame's short axis is 10 world units ([PRJ.P1](../view/projection.md)), with the long axis extending at that constant scale ([PRJ.V1](../view/projection.md)). The King's opaque body is 0.85 of a square inside [SPC.E1](../view/spatial-model.md); other types follow [FRM.P2](form.md).
- **Platform implications**: Web touch → the board dominates the play area; each piece silhouette remains readable at the size in [FRM.L1](form.md) (about 1/21 of frame height at 9:16 and about 1/12 at 16:9).

## Style pillars

| ID | Pillar | Description | Conforms if… | Serves |
|----|--------|-------------|--------------|--------|
| P1 | Snap settle | Move visuals and cues finish without network wait | Piece travel and its SFX end within [PHY.M1](../view/physics.md) (≤ 0.15 s) | Instant play |
| P2 | Distinct vectors | Six piece types read from shape alone | A casual player names each type from a solid-black silhouette at the size in [FRM.L1](form.md) | Clear board; [PER.R1](../view/perception.md) |
| P3 | Quiet mahogany | Warm wood board and soft cafe calm, not tournament chrome | Board reads as mahogany ([PAL.C2](palette.md)); UI fills use only the [PAL.S3](palette.md) swatches (C9, C10, C6); no accent outside [PAL.C6](palette.md)/[PAL.C7](palette.md)/[PAL.C8](palette.md)/[PAL.C11](palette.md); panel fill [PAL.C10](palette.md) differs from light square [PAL.C1](palette.md) by less than the board squares' [PAL.K1](palette.md) 0.25 luminance difference | Cafe calm; [experience.md](../design/experience.md) mood |

When pillars conflict: P1 > P2 > P3 (vision tradeoffs).

## Content limits

- No computer-opponent or AI avatar imagery (vision non-goal).

## Variation

| Axis | What varies | What stays fixed | Realized by |
|------|-------------|------------------|-------------|
| None | — | One style throughout Shared game and Puzzle stream | All palette sets and form |

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`palette.md`](palette.md) with [`palette/swatches.md`](palette/swatches.md) and [`palette/sets.md`](palette/sets.md), [`form.md`](form.md), [`surface.md`](surface.md), [`motion.md`](motion.md), [`ui-style.md`](ui-style.md), [`sound.md`](sound.md), [`references.md`](references.md).

- **Reference sheets**: [`sheets/palette.html`](sheets/palette.html), [`sheets/lineup.html`](sheets/lineup.html)
