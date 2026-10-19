# Stories: Progression — mode and solved list commits

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`progression.md`](../progression.md)
- **Spec key**: `PRG`
- **Glossary terms**: [Last mode](../glossary.md), [Puzzle](../glossary.md), [Session](../glossary.md)

Split from [`progression.md`](progression.md) by logical unit; that file proves the Elo axis and the remaining persistence.

## Coverage

| Element | Scenarios |
|---------|-----------|
| P2 | PS2.1 PS2.3 |
| P3 | PS2.2 PS2.3 |
| M1 | PS2.1 PS2.2 |

## PS2: Commit mode and the solved list

As a casual player, I resume in the mode I chose with a bounded solved list so that the next session starts clean.

### PS2.1: Puzzle mode commits

- **Proves**: P2, M1

```gherkin
Given mode pick
When the player chooses Puzzle stream (FL-mode-pick.T2)
Then GS.lastMode is Puzzle stream And it is committed
```

### PS2.2: Solved list stays at the window

- **Proves**: P3, M1

```gherkin
Given CFG.ELO_RECENT_WINDOW is 20 And GS.recentSolved holds 20 IDs with p1 oldest
When END.W1 appends p21
Then GS.recentSolved holds 20 IDs, p1 dropped and p21 newest last And the list is committed
```

### PS2.3: Cleared data resets mode and solved list

- **Proves**: P2, P3

```gherkin
Given GS.lastMode is Puzzle stream And GS.recentSolved holds p1
When this game's saved data is cleared
Then GS.lastMode is none And GS.recentSolved is empty
```
