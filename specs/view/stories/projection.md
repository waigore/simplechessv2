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

### VS1.1–VS1.4: Ortho and aspect

- **Proves**: P1, V1, A1

```gherkin
Given CAM-board And a 1×1 square at board center When framed Then visible height is 10 units (8 board + 1 unit margin each side) And the square occupies 1/10 of that height
Given Web aspect about 9:16 When play opens Then visible area is 10×10 containing the full board And letterbox or pillarbox may appear outside
Given Web aspect about 16:9 When play opens Then visible area is 10×10 containing the full board And letterbox or pillarbox may appear outside
Given Web aspect outside about 9:16–16:9 When play opens Then bars appear And no board square is cropped
```

### VS1.5–VS1.8: Safe area, scale, visibility

- **Proves**: A2, X1, D1

```gherkin
Given a selected piece legal-move marks and Advice marks on the board When framed Then each stays inside the inner 90% of the frame And piece silhouettes remain inside that safe area
Given vector board and pieces When any resolution is used Then X1 stays N/A (not pixel art) And scale follows P1 V1
Given every occupied square on the 8×8 When framed Then each square and piece is inside the frame
Given no off-board hide distance When D1 applied Then D1 limit is none And no on-board piece is hidden by distance
```
