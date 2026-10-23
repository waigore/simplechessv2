# Surface Effects

Authoring rules: [`.agents/specs/rules/aesthetics/surface.md`](../../../.agents/specs/rules/aesthetics/surface.md).

Part of [`surface.md`](../surface.md).

Effects are measured against the rest of the surface: WCAG ratios of the hexes as drawn, and fractions of a 1-unit square.

## Effects

| ID | Effect class | Shape and color | Largest share of frame |
|----|--------------|-----------------|------------------------|
| E1 | Capture break | Abstract shards in the captured piece's fill colors; fade within [PHY.M2](../../view/physics.md) | ≤ one square (1 × 1 unit); must not hide other piece silhouettes ([PER.R1](../../view/perception.md)) |
| E2 | Promotion morph | Continuous reshape of contours into the chosen type within [PHY.M3](../../view/physics.md) | ≤ one square |
