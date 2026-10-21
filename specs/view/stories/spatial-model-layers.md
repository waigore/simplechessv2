# Stories: Spatial model layers and bounds

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`spatial-model.md`](../spatial-model.md)
- **Spec key**: `SPC`
- **Glossary terms**: [World unit](../glossary.md)

Split from [`spatial-model.md`](spatial-model.md) by logical unit; that file proves axes, units, placement, and extents.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| L1 L2 | VS2.1 VS2.2 | L3 | VS2.3 |
| L4 | VS2.4 | B1 | VS2.5 VS2.6 VS2.7 VS2.8 |

## VS2: Layers and board bounds

As a casual player, I see depth and a hard board edge so that the table plane stays readable.

### VS2.1: Backdrop under board

- **Proves**: L1, L2

```gherkin
Given CAM-board Web 9:16, cafe L1 under board L2 at center (4.0, 4.0)
When both drawn
Then L2 draws over L1
```

### VS2.2: Parallax by camera motion

- **Proves**: L1, L2

```gherkin
Given CAM-board Web 9:16, L1 cafe and L2 board at (4.0, 4.0), camera translation Δ=(1.0, 0) units
When sampled
Then L1 screen shift is 0×Δ (±0.01) And L2 screen shift is 1×Δ (±0.01)
```

### VS2.3: Pieces by depth

- **Proves**: L3

```gherkin
Given CAM-board Web 9:16, piece at e4 (4.5, 3.5) and piece at e5 (4.5, 4.5) overlapping in frame
When drawn
Then L3 nearer by rank-then-file draws over the farther And on camera Δ=(1.0, 0) L3 shifts 1×Δ (±0.01)
```

### VS2.4: Overlays above pieces

- **Proves**: L4

```gherkin
Given CAM-board Web 9:16, selection overlay on piece at e4 (4.5, 3.5)
When drawn
Then L4 draws over L3 And on camera Δ=(1.0, 0) L4 shifts 1×Δ (±0.01)
```

### VS2.5: Bound at zero

- **Proves**: B1

```gherkin
Given CAM-board Web 9:16, play board, point (0.0, 0.0)
When extent checked
Then (0.0, 0.0) is inside B1 (x and y in 0–8 inclusive)
```

### VS2.6: Bound at eight

- **Proves**: B1

```gherkin
Given CAM-board Web 9:16, play board, point (8.0, 8.0)
When extent checked
Then (8.0, 8.0) is inside B1 (x and y in 0–8 inclusive)
```

### VS2.7: Outside below zero

- **Proves**: B1

```gherkin
Given CAM-board Web 9:16, proposed rest center (−0.1, 4.0) (E-pieces.I1)
When presentation runs
Then no piece center rests at (−0.1, 4.0) (±0.01); drawn rest stays in 0–8
```

### VS2.8: Outside above eight

- **Proves**: B1

```gherkin
Given CAM-board Web 9:16, proposed rest center (8.1, 4.0) (E-pieces.I1)
When presentation runs
Then no piece center rests at (8.1, 4.0) (±0.01); drawn rest stays in 0–8
```
