# Spatial Model

Authoring rules: [`.agents/specs/rules/view/spatial-model.md`](../../.agents/specs/rules/view/spatial-model.md).

- **Serves**: Clear board, Instant play. [E-pieces](../design/entities/pieces.md); [view.md](view.md).

## Coordinate frame

| ID | Convention | Statement |
|----|------------|-----------|
| A1 | Axes | x along files a→h; y along ranks 1→8. Origin at the outer corner of a1. Angles unused (no facing in plane). |
| A2 | Orientation | Axes are White-fixed. Display rotation for White seat and Puzzle Solving side is owned by [CAM-board](cameras/board.md), not by renaming axes. |

## Units and scale

| ID | Measure | Statement |
|----|---------|-----------|
| U1 | World unit | 1 unit = 1 square edge. Board is 8×8 units. |
| U2 | Time | Motion rates use seconds. |

## Placement

| ID | Rule | Statement |
|----|------|-----------|
| P1 | Snap | A piece occupies the center of its square. No continuous slide for legality; travel is presentation only ([physics.md](physics.md)). |
| P2 | Share | At most one piece per square ([E-pieces.I1](../design/entities/pieces/common.md)). |

## Object extents

| ID | Object | Extent (units) | Anchor | Facing |
|----|--------|----------------|--------|--------|
| E1 | Piece body | 0.85 × 0.85 | Square center | None — upright on the plane |
| E2 | Square | 1 × 1 | Square center | None |

## Render layers and depth

Render layers (draw bands), farthest to nearest.

| ID | Render layer | Holds | Depth order | Parallax |
|----|--------------|-------|-------------|----------|
| L1 | Cafe / table | Ambient backdrop | Fixed | 0 |
| L2 | Board | Light and dark squares ([E-pieces.I35](../design/entities/pieces/common.md)) | Fixed | 1 |
| L3 | Pieces | All piece bodies | By rank then file when overlapping draws | 1 |
| L4 | Overlays | Selection, legal-move marks, Advice marks, eval | Fixed above pieces | 1 |

## Bounds

| ID | Stage | Extent (units) | Edge |
|----|-------|----------------|------|
| B1 | Play board | x 0–8, y 0–8 | Hard edge of the 8×8 ([E-pieces.I1](../design/entities/pieces/common.md)) |
