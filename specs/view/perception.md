# Perception and Comfort

Authoring rules: [`.agents/specs/rules/view/perception.md`](../../.agents/specs/rules/view/perception.md).

- **Serves**: Clear board; [experience.md](../design/experience.md) clarity and feedback; [F-move-advice](../design/features/move-advice.md).

## Readability

| ID | Subject | Guarantee | Cameras |
|----|---------|-----------|---------|
| R1 | Each piece type | Recognizable by shape alone inside [PRJ.A2](projection.md); overlays never hide silhouette identity | all |
| R2 | Light vs dark squares ([E-pieces.I35](../design/entities/pieces/common.md)) | Alternation distinguishable with hue removed — luminance contrast per [palette K1](../aesthetics/palette.md) — including after [CAM-board.M2](cameras/board.md) flip | all |
| R3 | Selected piece | Occupied square and piece both highlighted while selected | all |
| R4 | Legal destinations | Empty and capture targets for the selection are marked on those squares while selected | all |
| R5 | Advice ([F-move-advice](../design/features/move-advice.md)) | Best-move from/to highlights, arrow, and eval visible when set; never obscure R1 | all |
| R6 | Side to move / check | A non-audio indicator of side to move and of check is inside the frame at all times | all |
| R7 | Board coordinates (files a–h, ranks 1–8) | Letters and numbers along outer edges only; stay correct after [CAM-board.M2](cameras/board.md) White-seat flip; never drawn inside squares | all |
| R8 | Refused place | The attempted square flashes [PAL.C8](../aesthetics/palette.md), then the selection and legal marks show as before | all |

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
