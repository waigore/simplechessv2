# Projection

Authoring rules: [`.agents/specs/rules/view/projection.md`](../../.agents/specs/rules/view/projection.md).

- **Serves**: Clear board; Web touch primary. [spatial-model.md](spatial-model.md).
- **Diagram**: [`diagrams/projection.html`](diagrams/projection.html)

## Projections

| ID | Type | Parameters | Used in |
|----|------|------------|---------|
| P1 | Orthographic | Visible short-axis extent 10 units (8 board + 1 unit margin each side of the square bounds); the long axis extends with aspect | [CAM-board](cameras/board.md) |

## Visible area

| ID | Platform | Minimum (units) | Maximum (units) | Reference distance |
|----|----------|-----------------|-----------------|--------------------|
| V1 | Web | 10 × 10 at 1:1, containing the full 8×8 board plus a 1-unit margin each side | 10 units on the short axis and 17.8 on the long axis at 9:16 or 16:9; never crops | N/A — orthographic |

## Aspect and safe area

| ID | Rule | Statement |
|----|------|-----------|
| A1 | Aspect | Supported 9:16 to 16:9. Taller than 1:1: visible width stays 10 units; extra height shows cafe background above and below. Wider than 1:1: visible height stays 10 units; extra width shows cafe background left and right. Outside the range: letterbox when taller, pillarbox when wider, to the nearest supported aspect; the board is never cropped. |
| A2 | Safe area | Inner 90% of the frame; selection, legal moves, Advice marks, and piece identities stay inside. |

## Pixel scale

| ID | Rule | Statement |
|----|------|-----------|
| X1 | Vector | N/A — pieces and board are vector, not pixel art. |

## Visibility limits

| ID | Limit | Distance (units) | Never hidden |
|----|-------|------------------|--------------|
| D1 | None | N/A — full board always in frame | All squares and pieces on the board |
