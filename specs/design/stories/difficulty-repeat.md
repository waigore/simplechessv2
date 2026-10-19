# Stories: Difficulty — recently solved deal

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`difficulty.md`](../difficulty.md)
- **Spec key**: `DIF`
- **Glossary terms**: [Player Elo](../glossary.md), [Puzzle Elo](../glossary.md), [Puzzle](../glossary.md)

Split from [`difficulty.md`](difficulty.md) by logical unit; that file proves the Elo update and the default deal.

## Coverage

| Element | Scenarios |
|---------|-----------|
| Y1 | PS1.1 |

## PS1: Repeat when nothing unsolved fits

As a casual player, I still get a puzzle when I have solved the whole catalog recently so that the stream never stalls.

### PS1.1: Recently solved allowed

- **Proves**: Y1

```gherkin
Given GS.playerElo is 1000 And the only catalog puzzle is P at Puzzle Elo 1000 And GS.recentSolved holds P
When the next puzzle is dealt
Then P is dealt And the stream continues
```
