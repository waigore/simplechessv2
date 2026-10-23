# Motion Style

Authoring rules: [`.agents/specs/rules/aesthetics/motion.md`](../../.agents/specs/rules/aesthetics/motion.md).

- **Serves**: P1; Instant play; [PHY.M1](../view/physics.md)–[PHY.M4](../view/physics.md); [experience.md](../design/experience.md) rhythm

## Animation principles

| ID | Principle | Strength | Applies to |
|----|-----------|----------|------------|
| A1 | Ease-out | Decelerate into the destination square | Piece travel ([PHY.M1](../view/physics.md)) |
| A2 | Squash and stretch | ≤ 10% of piece height at land | Piece on settle ([PHY.I1](../view/physics.md)); drop if it hurts silhouette ([AES.P2](aesthetics.md)) |
| A3 | No smear / no anticipation hold | Instant commit | Moves must not invent wind-up that delays the outcome |

## Timing

| ID | Action class | Frame rate | Frames or duration | Fits design timing |
|----|--------------|------------|--------------------|--------------------|
| T1 | Piece move | 60 fps display | Duration ≤ 0.15 s | [PHY.M1](../view/physics.md); Shared-game / Puzzle move steps |
| T2 | Capture break | 60 fps | Lifetime ≤ 0.15 s (inside T1) | [PHY.M2](../view/physics.md) |
| T3 | Promotion morph | 60 fps | ≤ 0.15 s | [PHY.M3](../view/physics.md) |
| T4 | Idle / ambient | — | None — pieces stay still between moves | Cafe calm; no fidget |

## Effect motion

| ID | Effect class | Lifetime (s) | Motion rule |
|----|--------------|--------------|-------------|
| E1 | Capture break ([SRF.E1](surface/effects.md)) | ≤ 0.15 | Fragments ease-out and fade; clear when mover lands |
| E2 | Promotion morph ([SRF.E2](surface/effects.md)) | ≤ 0.15 | Continuous contour morph; no pop-cut |
