# View

Authoring rules: [`.agents/specs/rules/view/view.md`](../../.agents/specs/rules/view/view.md).

## Dimensionality

- **Gameplay space**: 2D board plane. Axes: file (x) and rank (y). Positions resolve on the 8×8 grid ([E-pieces.I1](../design/entities/pieces/common.md)).
- **Rendered space**: 2D. Matches gameplay space; no depth mismatch for the player.

## Embodiment

- **Viewpoint**: Fixed board. White’s near rank edge faces the [White seat](../design/glossary.md) player. When Top is White, the board is rotated 180° so White stays toward that seat (Bottom may be Black).
- **Player presence**: No avatar. Attention anchors on the selected piece and the [Side to move](../design/glossary.md).

## Platform implications

- Web touch → the full 8×8 board plus margin stays inside the frame; the board dominates the play area on phone-width and wider viewports.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`stories.md`](stories.md), [`story-coverage.md`](story-coverage.md), [`spatial-model.md`](spatial-model.md), [`projection.md`](projection.md), [`camera-controls.md`](camera-controls.md), [`physics.md`](physics.md), [`perception.md`](perception.md), [`audio.md`](audio.md), [`haptics.md`](haptics.md). Diagrams: [`diagrams/`](diagrams/).

- **Cameras**: [`board.md`](cameras/board.md)
