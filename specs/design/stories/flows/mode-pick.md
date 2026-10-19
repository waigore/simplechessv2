# Stories: Mode pick

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`flows/mode-pick.md`](../../flows/mode-pick.md)
- **Spec key**: `FL-mode-pick`
- **Glossary terms**: [Session](../../glossary.md), [Shared game](../../glossary.md), [Puzzle stream](../../glossary.md), [Last mode](../../glossary.md)

Unavailable verbs and interruptions: [`mode-pick-unavailable.md`](mode-pick-unavailable.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Mode pick verbs | PS1.1 |
| P2 | Shared game phase | PS1.2 |
| P3 | Puzzle stream phase | PS1.3 |
| T1 | Choose Shared game | PS1.2 |
| T2 | Choose Puzzle stream | PS1.3 |
| T3 | Stop after result | PS1.4 |
| T4 | Leave stream | PS1.5 |
| T5 | Quit session | PS1.6 |
| N1 | Open at P1 | PS1.1 PS1.7 |
| N2 | End only via T5 | PS1.6 |

## PS1: Choose how to play

As a casual player, I pick a mode so that a session starts or ends cleanly.

### PS1.1: Open at mode pick

- **Proves**: P1, N1

```gherkin
Given the player opens the game and GS.lastMode is none
When the session begins
Then phase is P1 And Shared game is the default choice And piece moves, Advice, and clocks are unavailable
```

### PS1.2: Choose Shared game

- **Proves**: T1, P2

```gherkin
Given phase is P1
When the player chooses Shared game
Then phase is P2 And L-two-player-game.K1 begins And GS.lastMode is Shared game
```

### PS1.3: Choose Puzzle stream

- **Proves**: T2, P3

```gherkin
Given phase is P1 And GS.playerElo is 1000
When the player chooses Puzzle stream
Then phase is P3 And L-puzzle-stream.K1 begins And GS.lastMode is Puzzle stream And GS.playerElo is 1000
```

### PS1.4: Stop after Shared result

- **Proves**: T3

```gherkin
Given phase is P2 And GS.gameEnded is true
When the player stops
Then phase is P1 And no Shared-game field carries forward
```

### PS1.5: Leave Puzzle stream

- **Proves**: T4

```gherkin
Given phase is P3 And a puzzle is open And GS.playerElo is 1100
When the player leaves the stream
Then phase is P1 And GS.playerElo is 1100 And the open puzzle is not abandon-scored
```

### PS1.6: Quit session

- **Proves**: T5, N2

```gherkin
Given phase is P1 And GS.playerElo is 1050 And GS.lastMode is Puzzle stream
When the player quits the session
Then the session ends And GS.playerElo is 1050 And GS.lastMode is Puzzle stream
```

### PS1.7: Last mode default choice

- **Proves**: N1

```gherkin
Given GS.lastMode is Puzzle stream
When the player opens the game
Then phase is P1 And Puzzle stream is the default choice
```
