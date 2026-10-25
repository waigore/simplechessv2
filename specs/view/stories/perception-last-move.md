# Stories: Perception — last move

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`perception-marks.md`](../perception-marks.md)
- **Spec key**: `PER`
- **Glossary terms**: [Board camera](../glossary.md), [Last-move band](../glossary.md), [Last-move ticks](../glossary.md)

Split from [`perception-marks.md`](perception-marks.md) by logical unit; that file proves selection, destinations, Advice, turn, refused place, and coordinates.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| R9 | VS4.1 VS4.2 | | |

## VS4: Read the last move

As a casual player, I see what the last move was without having watched it, so that I can follow the shared board.

### VS4.1: Last move on both squares

- **Proves**: R9

```gherkin
Given CAM-board Web 9:16, White plays e2–e4, then taps d2 with Advice On
When the move has settled and the next move has not
Then e2 carries the PAL.K9 soft band in PAL.C7 at ≥ 2:1 on C1 and C2 (PAL.K5) And e4 carries the PAL.K9 corner ticks, C10 on the C9 keyline at 9.95:1 on C1 and 2.47:1 on C2 And the two squares differ by form and placement, not hue And with the ring, legal marks, and advice marks they cover ≤ 10% of the body (SPC.E1) And after the next move settles, only its squares carry the marks
```

### VS4.2: Last move above its coverage bound

- **Proves**: R9

```gherkin
Given CAM-board Web 9:16, White plays e2–e4, then taps d2 with Advice On, all overlays at 11% of the King's body
When the move has settled and the next move has not
Then overlay coverage is 11% of the body And that exceeds R9's ≤ 10% limit
```
