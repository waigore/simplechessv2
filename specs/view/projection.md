# Projection

Authoring rules: [`.agents/specs/rules/view/projection.md`](../../.agents/specs/rules/view/projection.md).

- **Serves**: Clear board; Web touch primary. [spatial-model.md](spatial-model.md).
- **Diagram**: [`diagrams/projection.html`](diagrams/projection.html)

## Projections

| ID | Type | Parameters | Used in |
|----|------|------------|---------|
| P1 | Orthographic | Visible height 10 units (8 board + 1 unit margin each side of the square bounds) | [CAM-board](cameras/board.md) |

## Visible area

| ID | Platform | Minimum (units) | Maximum (units) | Reference distance |
|----|----------|-----------------|-----------------|--------------------|
| V1 | Web | 10 × 10 containing the full board | Same; letterbox or pillarbox outside | N/A — orthographic |

## Aspect and safe area

| ID | Rule | Statement |
|----|------|-----------|
| A1 | Aspect | Supported from about 9:16 to 16:9. Outside: bars; board never cropped. |
| A2 | Safe area | Inner 90% of the frame; selection, legal moves, Advice marks, and piece identities stay inside. |

## Pixel scale

| ID | Rule | Statement |
|----|------|-----------|
| X1 | Vector | N/A — pieces and board are vector, not pixel art. |

## Visibility limits

| ID | Limit | Distance (units) | Never hidden |
|----|-------|------------------|--------------|
| D1 | None | N/A — full board always in frame | All squares and pieces on the board |
