# Stories: Physics drag

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`physics.md`](../physics.md)
- **Spec key**: `PHY`
- **Glossary terms**: [World unit](../glossary.md)

## Coverage

Part of [`physics.md`](physics.md). The coverage table lives there. This file proves drag motion M5.

## VS1: Drag follow and return

As a casual player, I see a dragged piece follow the pointer and return home so that Instant play stays obvious.

### VS1.8: Follow

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, piece on e2 center (4.5, 1.5), pointer held at (5.2, 2.0)
When sampled during the hold
Then the piece body center is (5.2, 2.0) And the position stays e2
```

### VS1.9: Legal drop

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, drag from e2 (4.5, 1.5) released on e4 (B10)
When the drop completes
Then the place uses M1 And the position updates when that travel ends
```

### VS1.10: Bad drop

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, drag from e2 released off the board at (9.0, 1.5) (B11)
When the drop completes
Then the piece returns to (4.5, 1.5) in ≤ 0.15 s ease-out And no new cue plays
```

### VS1.11: Return ends

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, elapsed 0.15 s after a bad drop from e2
When sampled
Then the piece body center is (4.5, 1.5)
```
