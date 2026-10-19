# Stories: Progression

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`progression.md`](../progression.md)
- **Spec key**: `PRG`
- **Glossary terms**: [Player Elo](../glossary.md), [Last mode](../glossary.md), [Session](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| A1 | Player Elo axis | PS1.1 |
| P1 | Elo persists | PS1.2 PS1.3 PS1.5 |
| P2 | Last mode persists | PS1.4 |
| P3 | Solved IDs persist | PS1.8 PS1.9 |
| M1 | Commit timing | PS1.1 PS1.4 PS1.10 |
| F1 | Failure continues stream | PS1.6 |
| Z1 | No completion | PS1.7 |
| Z2 | Ends | PS1.7 |
| Z3 | Same as finishing | PS1.7 |

## PS1: Keep Elo across sessions

As a casual player, I keep my Elo and last mode so that the next session continues calmly.

### PS1.1: Elo advances on puzzle result

- **Proves**: A1, M1

```gherkin
Given Puzzle stream And END.W1 holds And GS.playerElo is 1000
When the result commits
Then A1 updates per DIF.Y1 And the new Elo is committed
```

### PS1.2: Elo survives reopen

- **Proves**: P1

```gherkin
Given GS.playerElo is 1120 And the session ends
When the player opens again
Then GS.playerElo is 1120
```

### PS1.3: Elo lost only when saved data cleared

- **Proves**: P1

```gherkin
Given GS.playerElo is 1120
When this game's saved data is cleared
Then GS.playerElo resets to CFG.ELO_START on next use
```

### PS1.4: Last mode commits on choose

- **Proves**: P2, M1

```gherkin
Given mode pick
When the player chooses Shared game (FL-mode-pick.T1)
Then GS.lastMode is Shared game And it is committed
```

### PS1.5: After interrupt, reopen returns to mode pick

- **Proves**: P1, FL-mode-pick.U1

```gherkin
Given Puzzle stream interrupted And GS.playerElo is 1080
When the player reopens
Then the phase is FL-mode-pick.P1 And GS.playerElo is 1080
```

### PS1.6: Puzzle failure continues

- **Proves**: F1

```gherkin
Given Puzzle stream And END.L4 holds
When the result applies
Then the stream continues And only A1 updates And Shared game still carries nothing
```

### PS1.7: No completion gate

- **Proves**: Z1, Z2, Z3

```gherkin
Given Puzzle stream And GS.playerElo is 1000
When the player leaves the stream
Then the phase is FL-mode-pick.P1 And no completion condition gates leaving And GS.playerElo is 1000
```

### PS1.8: Solved IDs commit on W1

- **Proves**: P3

```gherkin
Given GS.recentSolved holds p1, newest last
When END.W1 appends p2
Then GS.recentSolved holds p1, p2 And the new list is committed
```

### PS1.9: Solved IDs survive reopen

- **Proves**: P3

```gherkin
Given GS.recentSolved holds p1, p2 And the session ends
When the player reopens
Then GS.recentSolved holds p1, p2
```

### PS1.10: Choosing Puzzle stream deals at committed Elo

- **Proves**: M1

```gherkin
Given the phase is FL-mode-pick.P1 And GS.playerElo is 1080
When the player chooses Puzzle stream
Then the phase is FL-mode-pick.P3 And the deal uses GS.playerElo 1080
```
