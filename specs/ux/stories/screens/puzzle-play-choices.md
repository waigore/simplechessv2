# Stories: Puzzle play choices

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle-play.md`](../../screens/puzzle-play.md)
- **Spec key**: `UI-puzzle-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`puzzle-play.md`](puzzle-play.md). The coverage table lives there.

## US3: Promotion and refusal

As Bottom player, I choose a promotion or leave an illegal place so that the puzzle does not advance by mistake.

### US3.4: Promotion shown

- **Proves**: S4

```gherkin
Given puzzle-play S1 and a legal pawn place is on the last rank
When Bottom asks that place
Then S4 shows queen, rook, bishop, and knight sprites and C6 is usable
```

### US3.1: Promotion commit

- **Proves**: C6, S4

```gherkin
Given puzzle-play S4 and the pawn is White
When Bottom activates C6 on the queen sprite
Then the puzzle judges that place with a White queen and S4 closes
```

### US3.2: Promotion unavailable

- **Proves**: C6

```gherkin
Given puzzle-play S1 and no pawn is on the last rank
When Bottom activates C6
Then no promotion type is committed
```

### US3.8: Underpromotion to a rook

- **Proves**: C6

```gherkin
Given puzzle-play S4 and the pawn is White
When Bottom activates C6 on the rook sprite
Then the puzzle judges that place with a White rook and S4 closes
```

### US3.9: Underpromotion to a bishop

- **Proves**: C6

```gherkin
Given puzzle-play S4 and the pawn is White
When Bottom activates C6 on the bishop sprite
Then the puzzle judges that place with a White bishop and S4 closes
```

### US3.3: Refused place

- **Proves**: S5

```gherkin
Given puzzle-play S1 with a selection and a place the piece rules refuse
When Bottom asks that place
Then S5 flashes that square, GS.selectedPiece stays set, and C1 stays usable
```

### US3.5: Reveal unavailable during promotion

- **Proves**: C3

```gherkin
Given puzzle-play S4
When Bottom activates C3
Then EX.confirm is not shown and S4 stays
```

### US3.6: Abandon unavailable during promotion

- **Proves**: C4

```gherkin
Given puzzle-play S4
When Bottom activates C4
Then EX.confirm is not shown and S4 stays
```

### US3.7: Leave unavailable during promotion

- **Proves**: C5

```gherkin
Given puzzle-play S4
When Bottom activates C5
Then EX.confirm is not shown and S4 stays
```

### US3.10: Reveal unavailable in confirm

- **Proves**: C3

```gherkin
Given puzzle-play S2 leave confirm
When Bottom activates C3
Then EX.confirm is unchanged and S2 stays
```

### US3.11: Abandon unavailable in confirm

- **Proves**: C4

```gherkin
Given puzzle-play S2 leave confirm
When Bottom activates C4
Then EX.confirm is unchanged and S2 stays
```

### US3.12: Leave unavailable in confirm

- **Proves**: C5

```gherkin
Given puzzle-play S2 leave confirm
When Bottom activates C5
Then EX.confirm is unchanged and S2 stays
```
