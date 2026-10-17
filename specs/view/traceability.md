# View Traceability

Authoring rules: [`.agents/specs/rules/view/traceability.md`](../../.agents/specs/rules/view/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play | vision | [`physics.md`](physics.md), [`view.md`](view.md) |
| Clear board | vision | [`perception.md`](perception.md), [`spatial-model.md`](spatial-model.md), [`cameras/board.md`](cameras/board.md) |
| Cafe calm | vision | [`cameras/board.md`](cameras/board.md), [`camera-controls.md`](camera-controls.md) |
| Web / touch primary | definition | [`view.md`](view.md), [`projection.md`](projection.md) |
| Pieces / board ([E-pieces](../design/entities/pieces.md)) | design | [`spatial-model.md`](spatial-model.md), [`physics.md`](physics.md), [`perception.md`](perception.md) |
| Move advice ([F-move-advice](../design/features/move-advice.md)) | design | [`perception.md`](perception.md) |
| Experience clarity / feedback | design | [`perception.md`](perception.md), [`physics.md`](physics.md) |
| Accessibility (shape, not color alone) | quality | [`perception.md`](perception.md) R1–R2 |
| Board edge coordinates (UX play screens) | design / UX | [`perception.md`](perception.md) R7 |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Dimensionality and embodiment | [`view.md`](view.md) | Applies |
| Spatial model and positioning | [`spatial-model.md`](spatial-model.md) | Applies |
| Projection and visible area | [`projection.md`](projection.md) | Applies |
| Cameras | [`cameras/`](cameras/) | Applies |
| Camera controls and settings | [`camera-controls.md`](camera-controls.md) | Applies — None (fixed board) |
| Physics feel | [`physics.md`](physics.md) | Applies |
| Readability and depth | [`perception.md`](perception.md) | Applies — depth N/A |
| Motion comfort | [`perception.md`](perception.md) | N/A — fixed camera; no autonomous camera motion |
| Spatial audio | [`audio.md`](audio.md) | N/A — non-positional event cues only |
| Haptics | [`haptics.md`](haptics.md) | N/A — Web primary; no haptic platforms |
| Diagrams | [`diagrams/`](diagrams/) | TBD — deferred to a follow-up capture |
