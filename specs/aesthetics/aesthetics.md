# Aesthetics

Authoring rules: [`.agents/specs/rules/aesthetics/aesthetics.md`](../../.agents/specs/rules/aesthetics/aesthetics.md).

## Medium

- **Medium**: Vector 2D. Matches the flat board plane ([view.md](../view/view.md)); pieces and board are crisp shapes, not pixel art or 3D.
- **Resolution and scale**: Art is resolution-independent. Proportions use world units ([SPC.U1](../view/spatial-model.md)): 1 unit = 1 square. Piece bodies fill [SPC.E1](../view/spatial-model.md) (0.85 × 0.85).
- **Platform implications**: Web touch → the board dominates the play area; each piece silhouette remains readable at about 1/12 of frame height.

## Style pillars

| ID | Pillar | Description | Conforms if… | Serves |
|----|--------|-------------|--------------|--------|
| P1 | Snap settle | Move visuals and cues finish without network wait | Piece travel and its SFX end within [PHY.M1](../view/physics.md) (≤ 0.15 s) | Instant play |
| P2 | Distinct vectors | Six piece types read from shape alone | A casual player names each type from a solid-black silhouette at the size in [FRM.L1](form.md) | Clear board; [PER.R1](../view/perception.md) |
| P3 | Quiet mahogany | Warm wood board and soft cafe calm, not tournament chrome | Board reads as mahogany ([PAL.C2](palette.md)); UI fills use only the [PAL.S3](palette.md) swatches (C9, C10, C6); no accent outside [PAL.C6](palette.md)/[PAL.C7](palette.md)/[PAL.C8](palette.md)/[PAL.C11](palette.md); panel fill [PAL.C10](palette.md) differs from light square [PAL.C1](palette.md) by less than the board squares' [PAL.K1](palette.md) 0.25 luminance difference | Cafe calm; [experience.md](../design/experience.md) mood |

When pillars conflict: P1 > P2 > P3 (vision tradeoffs).

## Content limits

- No competitive chess-site chrome (loud leaderboards, rank badges, esports framing).
- No computer-opponent or AI avatar imagery (vision non-goal).

## Variation

| Axis | What varies | What stays fixed | Realized by |
|------|-------------|------------------|-------------|
| None | — | One style throughout Shared game and Puzzle stream | All palette sets and form |

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`palette.md`](palette.md), [`form.md`](form.md), [`surface.md`](surface.md), [`motion.md`](motion.md), [`ui-style.md`](ui-style.md), [`sound.md`](sound.md), [`references.md`](references.md).

- **Sheets**: [`sheets/palette.html`](sheets/palette.html), [`sheets/lineup.html`](sheets/lineup.html)
