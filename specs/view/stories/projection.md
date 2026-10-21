# Stories: Projection

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`projection.md`](../projection.md)
- **Spec key**: `PRJ`
- **Glossary terms**: [Projection](../glossary.md), [Frame](../glossary.md), [Visible area](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| P1 | VS1.1 | V1 | VS1.1 VS1.2 VS1.3 VS1.4 VS1.9 |
| A1 | VS1.2 VS1.3 VS1.4 VS1.9 | A2 | VS1.3 VS1.4 VS1.5 VS1.9 |
| X1 | VS1.6 | D1 | VS1.7 VS1.8 |

## VS1: Full board in frame

As a casual player, I always see the whole board in the browser so that no square is cropped.

### VS1.1: Orthographic 1:1

- **Proves**: P1, V1

```gherkin
Given CAM-board Web 1:1, a 1×1 square at board center
When framed
Then visible area is 10×10 units (±0.1) And the square occupies 1/10 (±0.005) of visible height
```

### VS1.2: Narrow end, 9:16

- **Proves**: V1, A1

```gherkin
Given CAM-board Web 9:16
When play opens
Then visible area is 10 (±0.1) × 17.8 (±0.1) units And the full 8×8 board is centered And the extra height is cafe background
```

### VS1.3: Wide end, 16:9

- **Proves**: V1, A1, A2

```gherkin
Given CAM-board Web 16:9, selection mark at (4.5, 3.5)
When play opens
Then visible area is 17.8 (±0.1) × 10 (±0.1) units And the full 8×8 board is centered And the extra width is cafe background And the mark stays inside the inner 90% (±1%)
```

### VS1.4: Outside the range

- **Proves**: V1, A1, A2

```gherkin
Given CAM-board Web aspect 9:20, selection mark at (4.5, 3.5)
When play opens
Then letterbox bars appear above and below And the board keeps 10-unit (±0.1) width And no board square is cropped And the mark stays inside the inner 90% (±1%) of the letterboxed frame
```

### VS1.5: Safe area, 9:16

- **Proves**: A2

```gherkin
Given CAM-board Web 9:16, selection mark at (4.5, 3.5), legal-move mark at (4.5, 4.5), Advice mark at (5.5, 3.5), piece body at (4.5, 3.5)
When framed
Then each mark and silhouette stays inside the inner 90% (±1%) of the frame
```

### VS1.6: Vector scale

- **Proves**: X1

```gherkin
Given CAM-board Web 9:16, vector board and pieces
When any resolution is used
Then X1 stays N/A (not pixel art) And scale follows P1 V1
```

### VS1.7: Board fully visible

- **Proves**: D1

```gherkin
Given CAM-board Web 9:16, every occupied square on the 8×8
When framed
Then each square and piece is inside the frame
```

### VS1.8: No hide distance

- **Proves**: D1

```gherkin
Given CAM-board Web 9:16, no off-board hide distance
When D1 applied
Then D1 limit is none And no on-board piece is hidden by distance
```

### VS1.9: Wider than the range

- **Proves**: V1, A1, A2

```gherkin
Given CAM-board Web aspect 21:9, selection mark at (4.5, 3.5)
When play opens
Then pillarbox bars appear left and right And the board keeps 10-unit (±0.1) height And no board square is cropped And the mark stays inside the inner 90% (±1%) of the pillarboxed frame
```
