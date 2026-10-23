# Surface and Light

Authoring rules: [`.agents/specs/rules/aesthetics/surface.md`](../../.agents/specs/rules/aesthetics/surface.md).

- **Serves**: P2, P3; Cafe calm; [PER.R1](../view/perception.md)–[PER.R2](../view/perception.md); Instant play ([PHY.M2](../view/physics.md))

Values are measured in sRGB so two reviewers judge the same asset by the same numbers. A shadow tone is the fill blended 30% toward [PAL.C5](palette.md), drawn as the flat hex it makes: C1 `#E8D5B5` gives `#BEA68B`. A contrast ratio is the WCAG relative-luminance ratio of the two hex values as drawn. Outline width 0.017 units is 2% of the King's 0.85 height ([FRM.P1](form.md)): at the smallest on-screen size ([FRM.L1](form.md), 1/21 of a 1280-px short axis) it reads 2.3 screen pixels, and it scales with screen size.

## Shading

| ID | Shading model | Light direction | Shadow and highlight color |
|----|---------------|-----------------|----------------------------|
| S1 | Soft cel, two tones | From top-left | Shadow: the shadow tone, 30% toward [PAL.C5](palette.md); highlight: lighten the fill by 25% toward white, one band at most |

## Outline

| ID | Who | Width | Color rule |
|----|-----|-------|------------|
| O1 | Every piece | 2% of that piece's own height, held on every type; the King's 0.85 body ([FRM.P1](form.md)) gives 0.017 units | White pieces: [PAL.C4](palette.md) `#2C2A28` on the whole contour (≥ 9.9:1 against [PAL.C1](palette.md)); Black pieces: [PAL.C3](palette.md) `#F5F0E6` on the whole contour (5.1:1 against [PAL.C2](palette.md)) so the silhouette stays clear on dark squares ([PAL.K2](palette.md)) |

## Materials

| ID | Material family | How it is rendered |
|----|-----------------|--------------------|
| M1 | Wood (board / table) | Warm mahogany fills ([PAL.C1](palette.md), [PAL.C2](palette.md), [PAL.C5](palette.md)); optional soft grain that never breaks square readability ([PER.R2](../view/perception.md)) |
| M2 | Lacquered piece | Flat vector fill with one soft highlight band; no photo-metal shine |

## Light

| ID | Context | Mood and color temperature | Lit vs shadow contrast | Emissive and glow |
|----|---------|----------------------------|------------------------|-------------------|
| L1 | All play | Warm cafe, soft daylight | At least 1.6:1 between a lit fill and its shadow tone (Shading S1); lit and shadow stay in the same warm family and shadow never hides a contour ([PER.R1](../view/perception.md)). Measured: [PAL.C1](palette.md) 1.6:1, [PAL.C2](palette.md) 1.2:1, [PAL.C3](palette.md) 1.7:1, [PAL.C4](palette.md) 1.1:1 | No glow on pieces; selection uses [PAL.C6](palette.md) mark, not bloom |

## Effects

| ID | Effect class | Shape and color | Largest share of frame |
|----|--------------|-----------------|------------------------|
| E1 | Capture break | Abstract shards in the captured piece’s fill colors; fade within [PHY.M2](../view/physics.md) | ≤ one square (1 × 1 unit); must not hide other piece silhouettes ([PER.R1](../view/perception.md)) |
| E2 | Promotion morph | Continuous reshape of contours into the chosen type within [PHY.M3](../view/physics.md) | ≤ one square |
