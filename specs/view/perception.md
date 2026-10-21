# Perception and Comfort

Authoring rules: [`.agents/specs/rules/view/perception.md`](../../.agents/specs/rules/view/perception.md).

- **Serves**: Clear board; [experience.md](../design/experience.md) clarity and feedback; [F-move-advice](../design/features/move-advice.md).

## Readability

| ID | Subject | Guarantee | Cameras |
|----|---------|-----------|---------|
| R1 | Each piece type | Named from a solid-black silhouette at the drawn height of [SPC.E1](spatial-model.md) (0.85 units) under [PRJ.V1](projection.md) — ≥ about 1/21 of frame height at 9:16 and ≥ about 1/12 at 16:9 ([FRM.L1](../aesthetics/form.md)); identities stay inside [PRJ.A2](projection.md); overlays cover ≤ 10% of the body | all |
| R2 | Light vs dark squares ([E-pieces.I35](../design/entities/pieces/common.md)) | Alternation distinguishable with hue removed — luminance contrast ≥ 0.25 per [PAL.K1](../aesthetics/palette.md) — including after [CAM-board.M2](cameras/board.md) flip | all |
| R3 | Selected piece | Square and piece highlighted with [PAL.C6](../aesthetics/palette.md) at ≥ 2:1 on both square colors ([PAL.K5](../aesthetics/palette.md)); ≥ 90% of the body stays visible | all |
| R4 | Legal destinations | Empty and capture targets marked with [PAL.C11](../aesthetics/palette.md) at ≥ 2:1 on both square colors ([PAL.K6](../aesthetics/palette.md)); each mark covers ≥ 1/4 square | all |
| R5 | Advice ([F-move-advice](../design/features/move-advice.md)) | From/to marks and arrow use [PAL.C7](../aesthetics/palette.md) at ≥ 2:1 on both squares ([PAL.K5](../aesthetics/palette.md)); eval text is ≥ [UIS.T2](../aesthetics/ui-style.md); together they cover ≤ 10% of any body | all |
| R6 | Side to move / check | A non-audio indicator at ≥ 1/12 frame height inside the frame at all times, with ≥ 4.5:1 contrast ([PAL.K4](../aesthetics/palette.md)); check also uses [PAL.C8](../aesthetics/palette.md) | all |
| R7 | Board coordinates (files a–h, ranks 1–8) | Letters and numbers on the outer 1-unit margin only, in ≥ [UIS.T2](../aesthetics/ui-style.md) at ≥ 4.5:1 against the background; correct after [CAM-board.M2](cameras/board.md); never inside squares | all |
| R8 | Refused place | The square flashes [PAL.C8](../aesthetics/palette.md) for 0.3 s at ≥ 2:1 on both square colors ([PAL.K5](../aesthetics/palette.md)), then selection and legal marks show as before | all |

## Depth cues

| ID | Cue | Applies when | Tells the player |
|----|-----|--------------|------------------|
| D1 | N/A — flat board | No depth bands | — |

## Sense of scale

The board reads as a tabletop set: one square is the reference; pieces fill most of their square ([SPC.E1](spatial-model.md)) without crowding neighbors.

## Comfort options

| ID | Option | Changes | Choices or range | Default | Platforms |
|----|--------|---------|------------------|---------|-----------|
| M1 | N/A — no camera motion over time; reorients only by an instantaneous cut at deal or seat change | No shake or bob ([CAM-board](cameras/board.md)); [CAM-board.T1](cameras/board.md) is Cut 0 | — | — | — |

## Experience intent

A glanceable board: selection and legal moves are clear; Advice helps without covering identity.
