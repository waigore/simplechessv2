# Stories: Perception

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`perception.md`](../perception.md)
- **Spec key**: `PER`
- **Glossary terms**: [Board camera](../glossary.md), [Frame](../glossary.md)

Marks and coordinates: [`perception-marks.md`](perception-marks.md). Threshold sides and CAM-board.T1: [`perception-bounds.md`](perception-bounds.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| R1 | VS1.1 VS1.1b | R2 | VS1.2 VS1.3 |
| D1 | VS1.10 | M1 | VS1.11 |

R1/R2 bound and T1 scenarios: [`perception-bounds.md`](perception-bounds.md).

## VS1: Glanceable board

As a casual player, I read piece type and the board at a glance so that Clear board holds on touch.

### VS1.1: Identity

- **Proves**: R1

```gherkin
Given CAM-board Web 9:16, each piece type at its FRM.P2 height (King at SPC.E1, 0.85 units) under PRJ.V1 (~1/21 frame height)
When viewed in PRJ.A2
Then each type is named from a solid-black silhouette And overlays cover ≤ 10% of the body
```

### VS1.1b: Identity at 16:9

- **Proves**: R1

```gherkin
Given CAM-board Web 16:9, each piece type at its FRM.P2 height (King at SPC.E1, 0.85 units) under PRJ.V1 (~1/12 frame height)
When viewed in PRJ.A2
Then each type is named from a solid-black silhouette And overlays cover ≤ 10% of the body
```

### VS1.2: Squares, Bottom seat

- **Proves**: R2

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When light and dark squares are compared with hue removed
Then alternation stays distinct (PAL.K1: luminance Δ ≥ 0.25)
```

### VS1.3: Squares after flip

- **Proves**: R2

```gherkin
Given CAM-board Web 9:16, White seat Top after CAM-board.M2
When light and dark squares are compared with hue removed
Then alternation stays distinct (PAL.K1: luminance Δ ≥ 0.25)
```

### VS1.10: Depth

- **Proves**: D1

```gherkin
Given CAM-board Web 9:16, a flat board
When depth cues checked
Then D1 holds: no depth bands
```

### VS1.11: Comfort

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, no camera motion over time
When comfort options are checked
Then M1 is N/A And no shake or bob toggle is needed
```
