# Stories: Puzzle play confirm

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle-play.md`](../../screens/puzzle-play.md)
- **Spec key**: `UI-puzzle-play`

## Coverage

Part of [`puzzle-play.md`](puzzle-play.md). The coverage table lives there.

## US5: Puzzle confirm

As Bottom player, I confirm stream-leaving actions so that a stray tap does not end my puzzle.

### US5.1: Leave opens confirm

- **Proves**: C5, S2

```gherkin
Given puzzle-play S1
When Bottom activates C5
Then EX.confirm shows Leave the puzzle stream?
```

### US5.2: Confirm leave

- **Proves**: S2

```gherkin
Given puzzle-play S2 leave confirm
When Bottom activates Confirm
Then the screen is mode-pick
```

### US5.3: Cancel leave

- **Proves**: S2

```gherkin
Given puzzle-play S2 leave confirm
When Bottom activates Cancel
Then the screen is puzzle-play S1
```

### US5.4: Select unavailable in confirm

- **Proves**: C1, S2

```gherkin
Given puzzle-play S2 leave confirm
When Bottom activates C1 on a piece
Then GS.selectedPiece is unchanged
```

### US5.5: Reveal confirm

- **Proves**: S2

```gherkin
Given puzzle-play S1
When Bottom activates C3
Then S2 shows Reveal the solution? with Confirm and Cancel
```

### US5.6: Abandon confirm

- **Proves**: S2

```gherkin
Given puzzle-play S1
When Bottom activates C4
Then S2 shows Abandon this puzzle? with Confirm and Cancel
```
