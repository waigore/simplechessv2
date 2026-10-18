# Surface and Light

Authoring rules: [`.agents/specs/rules/aesthetics/surface.md`](../../.agents/specs/rules/aesthetics/surface.md).

- **Serves**: P2, P3; Cafe calm; [PER.R1](../view/perception.md)–[PER.R2](../view/perception.md); Instant play ([PHY.M2](../view/physics.md))

## Shading

| ID | Shading model | Light direction | Shadow and highlight color |
|----|---------------|-----------------|----------------------------|
| S1 | Soft cel, two tones | From top-left | Shadow: deepen fill toward [PAL.C5](palette.md); highlight: lighten toward [PAL.C3](palette.md) / [PAL.C1](palette.md) |

## Outline

| ID | Who | Width | Color rule |
|----|-----|-------|------------|
| O1 | Every piece | About 2% of piece height | Darker than the piece fill; White pieces use near-[PAL.C4](palette.md); Black pieces use a soft light edge (near [PAL.C3](palette.md)) so the silhouette stays clear on dark squares |

## Materials

| ID | Material family | How it is rendered |
|----|-----------------|--------------------|
| M1 | Wood (board / table) | Warm mahogany fills ([PAL.C1](palette.md), [PAL.C2](palette.md), [PAL.C5](palette.md)); optional soft grain that never breaks square readability ([PER.R2](../view/perception.md)) |
| M2 | Lacquered piece | Flat vector fill with one soft highlight band; no photo-metal shine |

## Light

| ID | Context | Mood and color temperature | Lit vs shadow contrast | Emissive and glow |
|----|---------|----------------------------|------------------------|-------------------|
| L1 | All play | Warm cafe, soft daylight | Low–medium; lit and shadow stay in the same warm family | No glow on pieces; selection uses [PAL.C6](palette.md) mark, not bloom |

## Effects

| ID | Effect class | Shape and color | Largest share of frame |
|----|--------------|-----------------|------------------------|
| E1 | Capture break | Abstract shards in the captured piece’s fill colors; fade within [PHY.M2](../view/physics.md) | ≤ one square (1 × 1 unit); must not hide other piece silhouettes ([PER.R1](../view/perception.md)) |
| E2 | Promotion morph | Continuous reshape of contours into the chosen type within [PHY.M3](../view/physics.md) | ≤ one square |
