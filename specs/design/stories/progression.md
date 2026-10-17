# Stories: Progression

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`progression.md`](../progression.md)
- **Spec key**: `PRG`
- **Glossary terms**: [Player Elo](../glossary.md), [Last mode](../glossary.md), [Sitting](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| A1 | Player Elo axis | PS1.1 |
| P1 | Elo persists | PS1.2 PS1.3 |
| P2 | Last mode persists | PS1.4 |
| M1 | Commit timing | PS1.1 PS1.4 PS1.5 |
| F1 | Failure continues stream | PS1.6 |
| Z1 | No completion | PS1.7 |
| Z2 | Ends | PS1.7 |
| Z3 | Same as finishing | PS1.7 |

## PS1: Keep Elo across sittings

As a casual player, I keep my Elo and last mode so that the next sitting continues calmly.

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
Given GS.playerElo is 1120 And the sitting ends
When the player opens again
Then GS.playerElo is 1120
```

### PS1.3: Elo lost only when storage cleared

- **Proves**: P1

```gherkin
Given GS.playerElo is 1120
When the browser clears this game's storage
Then GS.playerElo resets to CFG.ELO_START on next use
```

### PS1.4: Last mode commits on choose

- **Proves**: P2, M1

```gherkin
Given mode pick
When the player chooses Shared game (FL-mode-pick.T1)
Then GS.lastMode is Shared game And it is committed
```

### PS1.5: After interrupt, mode pick then Elo deal

- **Proves**: M1

```gherkin
Given Puzzle stream interrupted And GS.playerElo is 1080
When the player reopens and chooses Puzzle stream
Then first screen is mode pick And the deal uses GS.playerElo 1080
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
Given Puzzle stream
When the player leaves the stream
Then there is no completion requirement And the sitting may end
```
