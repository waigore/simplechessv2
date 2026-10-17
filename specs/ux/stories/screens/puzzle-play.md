# Stories: Puzzle play

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle-play.md`](../../screens/puzzle-play.md)
- **Spec key**: `UI-puzzle-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Board and coordinates | US1.1 |
| R2 | Elo | US1.2 |
| R3 | Stream actions | US1.3 |
| C1 | Select | US1.4 |
| C2 | Place | US1.5 |
| C3 | Reveal confirm | US1.6 |
| C4 | Abandon confirm | US1.7 |
| C5 | Leave confirm | US1.8 |
| C5 unavailable N/A | always | US1.8 |
| S1 | Default | US1.1 |
| S2 | EX.confirm | US1.8 US1.9 |
| S3 | EX.save-failure | US1.10 |

## US1: Puzzle stream UI

As Bottom player, I solve or leave puzzles so that Elo tracks my sitting.

### US1.1: Coordinates

- **Proves**: R1, S1

```gherkin
Given Bottom player is on puzzle-play S1
When the screen is shown
Then R1 shows a–h and 1–8 only on the outer edges
```

### US1.2: Elo visible

- **Proves**: R2

```gherkin
Given GS.playerElo is 1000
When puzzle-play is shown
Then R2 shows Elo 1000
```

### US1.3: Actions visible

- **Proves**: R3

```gherkin
Given puzzle-play S1
When the screen is shown
Then R3 shows Reveal, Abandon, and Leave stream
```

### US1.4: Select

- **Proves**: C1

```gherkin
Given puzzle-play S1 with an open puzzle
When Bottom activates C1 on a movable piece
Then GS.selectedPiece is that piece
```

### US1.5: Place

- **Proves**: C2

```gherkin
Given a piece is selected on puzzle-play S1
When Bottom activates C2 on a square
Then the interface asks the puzzle loop to handle that move
```

### US1.6: Reveal

- **Proves**: C3

```gherkin
Given puzzle-play S1
When Bottom activates C3
Then EX.confirm shows Reveal the solution?
```

### US1.7: Abandon

- **Proves**: C4

```gherkin
Given puzzle-play S1
When Bottom activates C4
Then EX.confirm shows Abandon this puzzle?
```

### US1.8: Leave

- **Proves**: C5, S2

```gherkin
Given puzzle-play S1
When Bottom activates C5 and then Confirm
Then the screen is mode-pick
```

### US1.9: Cancel leave

- **Proves**: S2

```gherkin
Given puzzle-play S2 leave confirm
When Bottom activates Cancel
Then the screen is puzzle-play S1
```

### US1.10: Save failure

- **Proves**: S3

```gherkin
Given puzzle-play S3 after Elo write failed
When Bottom dismisses
Then prior GS.playerElo remains and the screen is puzzle-play S1
```

