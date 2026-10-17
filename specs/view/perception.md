# Perception and Comfort

Authoring rules: [`.agents/specs/rules/view/perception.md`](../../.agents/specs/rules/view/perception.md).

- **Serves**: Clear board; [experience.md](../design/experience.md) clarity and feedback; [F-move-advice](../design/features/move-advice.md).

## Readability

| ID | Subject | Guarantee | Cameras |
|----|---------|-----------|---------|
| R1 | Each piece type | Recognizable by shape alone inside [PRJ.A2](projection.md); overlays never hide silhouette identity | all |
| R2 | Light vs dark squares ([E-pieces.I35](../design/entities/pieces/common.md)) | Alternation readable after [CAM-board.M2](cameras/board.md) flip; not by hue alone when accessibility Applies | all |
| R3 | Selected piece | Occupied square and piece both highlighted while selected | all |
| R4 | Legal destinations | Empty and capture targets for the selection are marked on those squares while selected | all |
| R5 | Advice ([F-move-advice](../design/features/move-advice.md)) | Best-move from/to highlights, arrow, and eval visible when set; never obscure R1 | all |
| R6 | Side to move / check | Whose turn and check stay obvious without relying on sound | all |

## Depth cues

| ID | Cue | Applies when | Tells the player |
|----|-----|--------------|------------------|
| D1 | N/A — flat board | No depth bands | — |

## Sense of scale

The board reads as a tabletop set: one square is the reference; pieces fill most of their square ([SPC.E1](spatial-model.md)) without crowding neighbors.

## Comfort options

| ID | Option | Changes | Choices or range | Default | Platforms |
|----|--------|---------|------------------|---------|-----------|
| M1 | N/A — fixed camera | No shake or bob ([CAM-board](cameras/board.md)) | — | — | — |

## Experience intent

A glanceable board: selection and legal moves are clear; Advice helps without covering identity.
