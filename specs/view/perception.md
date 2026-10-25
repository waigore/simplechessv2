# Perception and Comfort

Authoring rules: [`.agents/specs/rules/view/perception.md`](../../.agents/specs/rules/view/perception.md).

- **Serves**: Clear board; [experience.md](../design/experience.md) clarity and feedback; [F-move-advice](../design/features/move-advice.md).

## Readability

| ID | Subject | Guarantee | Cameras |
|----|---------|-----------|---------|
| R1 | Each piece type | Named from a solid-black silhouette at its [FRM.P2](../aesthetics/form.md) height. The King is 0.85 units under [PRJ.V1](projection.md) — ≥ about 1/21 of frame height at 9:16 and ≥ about 1/12 at 16:9 ([FRM.L1](../aesthetics/form.md)); identities stay inside [PRJ.A2](projection.md); overlays cover ≤ 10% of the body | all |
| R2 | Light vs dark squares ([E-pieces.I35](../design/entities/pieces/common.md)) | Alternation distinguishable with hue removed — luminance contrast ≥ 0.25 per [PAL.K1](../aesthetics/palette.md) — including after [CAM-board.M2](cameras/board.md) flip | all |
| R7 | Board coordinates (files a–h, ranks 1–8) | Letters and numbers on the outer 1-unit margin only, in ≥ [UIS.T2](../aesthetics/ui-style.md) at ≥ 4.5:1 against the background; correct after [CAM-board.M2](cameras/board.md); never inside squares | all |

Selection, destinations, Advice, turn and check, refused place, and last move (`R3`–`R6`, `R8`, `R9`) are in [`perception-marks.md`](perception-marks.md).

## Depth cues

| ID | Cue | Applies when | Tells the player |
|----|-----|--------------|------------------|
| D1 | N/A — flat board | No depth bands | — |

## Sense of scale

The board reads as a tabletop set: one square is the reference; pieces fill most of [SPC.E1](spatial-model.md) without crowding neighbors.

## Comfort options

| ID | Option | Changes | Choices or range | Default | Platforms |
|----|--------|---------|------------------|---------|-----------|
| M1 | N/A — no camera motion over time; reorients only by [CAM-board.M2](cameras/board.md) Cut 0 s at deal or seat change | No shake or bob ([CAM-board](cameras/board.md)); [CAM-board.T1](cameras/board.md) is also Cut 0 s | — | — | — |

## Experience intent

A glanceable board: selection, legal moves, last move clear; Advice never covers identity.
