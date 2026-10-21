# Stories: Physics drag

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`physics.md`](../physics.md)
- **Spec key**: `PHY`
- **Glossary terms**: [World unit](../glossary.md)

Split from [`physics.md`](physics.md) by logical unit; that file proves place, capture, promotion, and castling.

## Coverage

| Element | Scenarios |
|---------|-----------|
| M5 | VS2.1 VS2.2 VS2.3 VS2.4 VS2.5 VS2.6 |

## VS2: Drag follow and return

As a casual player, I see a dragged piece follow the pointer and return home so that Instant play stays obvious.

### VS2.1: Follow

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, piece on e2 center (4.5, 1.5), pointer held at (5.2, 2.0)
When sampled during the hold
Then the piece body center is (5.2, 2.0) And the position stays e2
```

### VS2.2: Legal drop

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, drag from e2 (4.5, 1.5) released on e4 (B10)
When the drop completes
Then the place uses M1 And the committed square is e4 at acceptance while the body may still travel
```

### VS2.3: Bad drop starts return

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, drag from e2 released off the board at (9.0, 1.5) (B11)
When the drop completes
Then the piece returns toward (4.5, 1.5) ease-out And no new cue plays
```

### VS2.4: Return mid

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, bad drop from e2 started return, elapsed 0.07 s
When sampled
Then the piece body center is between (9.0, 1.5) and (4.5, 1.5) And not on (4.5, 1.5)
```

### VS2.5: Return bound

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, bad drop from e2 started return
When sampled at elapsed 0.15 s
Then the piece body center is (4.5, 1.5)
And at elapsed 0.16 s it remains (4.5, 1.5)
```

### VS2.6: Position until legal place

- **Proves**: M5

```gherkin
Given CAM-board Web 9:16, drag from e2 held or bad-dropped
When sampled before a legal place completes
Then the position stays e2
```
