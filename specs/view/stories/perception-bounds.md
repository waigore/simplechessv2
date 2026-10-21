# Stories: Perception — thresholds and T1

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`perception.md`](../perception.md)
- **Spec key**: `PER`
- **Glossary terms**: [Board camera](../glossary.md), [Frame](../glossary.md)

Split from [`perception.md`](perception.md) by logical unit; that file proves identity at both aspects, seat flip, depth, and comfort.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| R1 | VS3.1 VS3.2 VS3.3 VS3.7 | R2 | VS3.4 VS3.5 VS3.6 VS3.8 |

## VS3: Bound and transition readability

As a casual player, I still read the board when overlays and contrast sit at their limits and when CAM-board enters, so that Clear board holds.

### VS3.1: Overlay at bound

- **Proves**: R1

```gherkin
Given CAM-board Web 9:16, each piece type at SPC.E1 under PRJ.V1, overlays at 10% of body
When viewed in PRJ.A2
Then each type is named from a solid-black silhouette And overlays cover ≤ 10% of the body
```

### VS3.2: Overlay below bound

- **Proves**: R1

```gherkin
Given CAM-board Web 9:16, each piece type at SPC.E1 under PRJ.V1, overlays at 5% of body
When viewed in PRJ.A2
Then each type is named from a solid-black silhouette And overlays cover ≤ 10% of the body
```

### VS3.3: Overlay above bound

- **Proves**: R1

```gherkin
Given CAM-board Web 9:16, each piece type at SPC.E1 under PRJ.V1, overlays at 11% of body
When viewed in PRJ.A2
Then overlay coverage is 11% of the body And that exceeds R1's ≤ 10% limit
```

### VS3.4: Squares at luminance bound

- **Proves**: R2

```gherkin
Given CAM-board Web 9:16, White seat Bottom, light and dark squares with luminance Δ 0.25
When compared with hue removed
Then alternation stays distinct (PAL.K1)
```

### VS3.5: Squares above luminance bound

- **Proves**: R2

```gherkin
Given CAM-board Web 9:16, White seat Bottom, light and dark squares with luminance Δ 0.30
When compared with hue removed
Then alternation stays distinct (PAL.K1)
```

### VS3.6: Squares below luminance bound

- **Proves**: R2

```gherkin
Given CAM-board Web 9:16, White seat Bottom, light and dark squares with luminance Δ 0.24
When compared with hue removed
Then alternation is not distinct under PAL.K1
```

### VS3.7: Identity through CAM-board.T1

- **Proves**: R1

```gherkin
Given mode pick Web 9:16, CAM-board as the target camera, each piece type at SPC.E1 under PRJ.V1
When FL-mode-pick.T1 fires
Then CAM-board is in use within cut 0 s And each type is named from a solid-black silhouette And overlays cover ≤ 10% of the body
```

### VS3.8: Squares through CAM-board.T1

- **Proves**: R2

```gherkin
Given mode pick Web 9:16, CAM-board as the target camera, White seat Bottom
When FL-mode-pick.T1 fires
Then CAM-board is in use within cut 0 s And light and dark square alternation stays distinct (PAL.K1: luminance Δ ≥ 0.25)
```
