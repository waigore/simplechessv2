# Surface and Light

Authoring rules: [`.agents/specs/rules/aesthetics/surface.md`](../../.agents/specs/rules/aesthetics/surface.md).

- **Serves**: P2, P3; Cafe calm; [PER.R1](../view/perception.md)–[PER.R2](../view/perception.md); Instant play ([PHY.M2](../view/physics.md))

Values are measured in sRGB so two reviewers judge the same asset by the same numbers. A contrast ratio is the WCAG relative-luminance ratio of the two hex values as drawn. The board and table surfaces split only on lightness ([PAL.K1](palette.md)) and carry no shading; every piece fill has a fixed lit and shadow tone.

A shadow tone is the fill blended 40% toward [PAL.C5](palette.md) `#5C3A2A` in sRGB, drawn as the flat hex it makes:

| Fill | Lit hex | Shadow tone | Lit : shadow |
|------|---------|-------------|--------------|
| [PAL.C1](palette.md) | `#E8D5B5` | `#B0977D` | 1.93:1 |
| [PAL.C2](palette.md) | `#8B5A3C` | `#784D35` | 1.25:1 |
| [PAL.C3](palette.md) | `#F5F0E6` | `#B8A79B` | 2.05:1 |
| [PAL.C4](palette.md) | `#2C2A28` | `#3F3029` | 1.13:1 |

Outline width is a fixed 2% of the subject's height, stated per row in Outline O1.

## Shading

| ID | Shading model | Light direction | Shadow and highlight color |
|----|---------------|-----------------|----------------------------|
| S1 | Soft cel, two tones | From top-left | Shadow: the fill's shadow tone from the table above, 40% toward [PAL.C5](palette.md); highlight: lighten the fill 25% toward white, one band at most |

## Outline

| ID | Who | Width | Color rule |
|----|-----|-------|------------|
| O1 | Every piece | 0.017 units: 2% of the King's 0.85 body height ([FRM.P1](form.md)), 2.3 screen pixels at the smallest size ([FRM.L1](form.md)), on every type | White pieces: [PAL.C4](palette.md) `#2C2A28` on the whole contour, 9.95:1 against [PAL.C1](palette.md) and 2.47:1 against [PAL.C2](palette.md); Black pieces: [PAL.C3](palette.md) `#F5F0E6` on the whole contour, 5.10:1 against [PAL.C2](palette.md) and 1.26:1 against [PAL.C1](palette.md), so a silhouette reads as a 2.47:1 field with a 1.26:1 edge on either square ([PAL.K2](palette.md)) |

## Materials

| ID | Material family | How it is rendered |
|----|-----------------|--------------------|
| M1 | Wood (board / table) | Warm mahogany fills ([PAL.C1](palette.md), [PAL.C2](palette.md), [PAL.C5](palette.md)); optional soft grain that never breaks square readability ([PER.R2](../view/perception.md)) |
| M2 | Lacquered piece | Flat vector fill with one soft highlight band; no photo-metal shine |

## Light

| ID | Context | Mood and color temperature | Lit vs shadow contrast | Emissive and glow |
|----|---------|----------------------------|------------------------|-------------------|
| L1 | All play | Warm cafe, soft daylight | Lit : shadow per fill in the header table (S1): [PAL.C1](palette.md) 1.93:1, [PAL.C2](palette.md) 1.25:1, [PAL.C3](palette.md) 2.05:1, [PAL.C4](palette.md) 1.13:1, every pair ≥ 1.13:1 and in the same warm family; shadow never hides a contour ([PER.R1](../view/perception.md)) | No glow on pieces; selection uses [PAL.C6](palette.md) mark, not bloom |

## Effects

[`surface/effects.md`](surface/effects.md): capture shards (E1) and promotion morph (E2), each ≤ one square and never hiding a protected silhouette.
