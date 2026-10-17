# Physics Feel

Authoring rules: [`.agents/specs/rules/view/physics.md`](../../.agents/specs/rules/view/physics.md).

- **Serves**: Instant play. [E-pieces](../design/entities/pieces.md); Shared-game and Puzzle-stream loops.

## Motion

| ID | Realizes | Profile | Must reproduce |
|----|----------|---------|----------------|
| M1 | Legal place ([E-pieces.I10](../design/entities/pieces/common.md); loop move steps) | Piece travels origin→destination in ≤ 0.15 s, ease-out; path is straight on the board plane | Position updates when travel ends; no network wait |
| M2 | Capture ([E-pieces.I3](../design/entities/pieces/common.md)) | Captured piece breaks apart and clears during M1 travel (same ≤ 0.15 s budget) | Captured unit gone when the mover lands |
| M3 | Promotion ([E-pieces.I33](../design/entities/pieces/pawn.md)) | Arriving pawn morphs into the chosen type within the same ≤ 0.15 s budget as M1 | New type visible when the move settles |
| M4 | Castling ([E-pieces.I13](../design/entities/pieces/king.md)) | King and rook each use M1 concurrently to their end squares | Both end on castling squares together |

## Collision

| ID | Colliders | Shape (units) | Response | Passes through |
|----|-----------|---------------|----------|----------------|
| K1 | N/A — grid only | — | No simulated blocking; placement only ([SPC.P1](spatial-model.md)) | — |

## Contact feel

| ID | Event | Feedback | Linked cues |
|----|-------|----------|-------------|
| I1 | Move lands (M1) | Settle ≤ 0.03 s; no camera shake | Selection clears to new occupancy ([perception.md](perception.md)) |
| I2 | Capture break (M2) | Break fragments fade within M1 | — |
| I3 | Promotion morph (M3) | Continuous morph; no pop-cut | — |

## Experience intent

Moves feel snappy and decisive. Captures break; promotions morph. Instant play stays obvious.
