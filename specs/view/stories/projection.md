# Stories: Projection

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`projection.md`](../projection.md)
- **Spec key**: `PRJ`
- **Glossary terms**: [Projection](../glossary.md), [Frame](../glossary.md), [Visible area](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| P1 | VS1.1 | V1 | VS1.2 VS1.3 VS1.4 |
| A1 | VS1.2 VS1.3 VS1.4 | A2 | VS1.5 |
| X1 | VS1.6 | D1 | VS1.7 VS1.8 |

## VS1: Full board in frame

As a casual player, I always see the whole board in the browser so that no square is cropped on touch.

### VS1.1: Orthographic height

- **Proves**: P1

```gherkin
Given CAM-board Web 9:16, a 1×1 square at board center
When framed
Then visible height is 10 units (8 board + 1 margin each side) And the square occupies 1/10 of it
```

### VS1.2: Narrow end, 9:16

- **Proves**: V1, A1

```gherkin
Given CAM-board Web 9:16
When play opens
Then visible area is 10×10 containing the full board And letterbox or pillarbox may appear outside
```

### VS1.3: Wide end, 16:9

- **Proves**: V1, A1

```gherkin
Given CAM-board Web 16:9
When play opens
Then visible area is 10×10 containing the full board And letterbox or pillarbox may appear outside
```

### VS1.4: Outside the range

- **Proves**: V1, A1

```gherkin
Given CAM-board Web, aspect outside 9:16–16:9
When play opens
Then bars appear And no board square is cropped
```

### VS1.5: Safe area

- **Proves**: A2

```gherkin
Given CAM-board Web 9:16, selected piece legal-move and Advice marks on the board
When framed
Then each stays inside the inner 90% And piece silhouettes remain inside that safe area
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
