# Stories: Puzzle play

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle-play.md`](../../screens/puzzle-play.md)
- **Spec key**: `UI-puzzle-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| R1 | Board, coordinates, selection, legal marks | US2.1 US2.2 US2.3 US2.9 |
| R2 | Elo and result cues | US2.4 US2.5 US2.7 US2.8 |
| R3 | Stream actions | US2.6 |
| C1 | Select | US1.1 US5.4 |
| C2 | Place | US1.2 US1.10 |
| C3 | Reveal confirm | US1.3 US3.5 US3.10 US5.5 |
| C4 | Abandon confirm | US1.4 US3.6 US3.11 US5.6 |
| C5 | Leave confirm | US5.1 US3.7 US3.12 |
| C3 unavailable | Not on S4 | US3.5 |
| C4 unavailable | Not on S4 | US3.6 |
| C5 unavailable | Not on S4 | US3.7 |
| S1 | Default | US2.1 |
| S2 | EX.confirm | US5.1 US5.2 US5.3 US5.4 US5.5 US5.6 |
| S3 | EX.save-failure | US1.8 |
| C6 | Promotion piece | US3.1 US3.2 US3.8 US3.9 |
| S4 | EX.promote | US3.1 US3.4 |
| S5 | EX.rejected | US3.3 |

US2 region scenarios live in [`puzzle-play-regions.md`](puzzle-play-regions.md). US3 choice scenarios live in [`puzzle-play-choices.md`](puzzle-play-choices.md). US5 confirm scenarios live in [`puzzle-play-confirm.md`](puzzle-play-confirm.md).

## US1: Puzzle stream controls

As Bottom player, I solve or leave puzzles so that Elo tracks my session.

### US1.1: Select

- **Proves**: C1

```gherkin
Given puzzle-play S1 with an open puzzle
When Bottom activates C1 on a movable piece
Then GS.selectedPiece is that piece
```

### US1.2: Place

- **Proves**: C2

```gherkin
Given a piece is selected on puzzle-play S1
When Bottom activates C2 on a square
Then the interface asks the puzzle loop to handle that move
```

### US1.3: Reveal

- **Proves**: C3

```gherkin
Given puzzle-play S1
When Bottom activates C3
Then EX.confirm shows Reveal the solution?
```

### US1.4: Abandon

- **Proves**: C4

```gherkin
Given puzzle-play S1
When Bottom activates C4
Then EX.confirm shows Abandon this puzzle?
```

### US1.8: Save failure

- **Proves**: S3

```gherkin
Given puzzle-play S3 after Elo write failed
When Bottom dismisses
Then prior GS.playerElo remains and the screen is puzzle-play S1
```

### US1.10: Place unavailable without selection

- **Proves**: C2

```gherkin
Given puzzle-play S1 and no piece is selected
When Bottom activates C2 on a square
Then the position is unchanged and nothing is asked
```
