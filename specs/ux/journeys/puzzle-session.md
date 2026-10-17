# Journey: Puzzle session

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`bottom-player.md`](../actors/bottom-player.md)
- **Goal**: Practice puzzles then leave the stream
- **Serves**: Cafe calm; [puzzle-stream](../../design/loops/puzzle-stream.md)
- **Mockup**: [`../mockups/journeys/puzzle-session.html`](../mockups/journeys/puzzle-session.html)
- **Glossary terms**: [Journey](../glossary.md)

## Entry and exit

- **N1**: Starts on `mode-pick`
- **N2**: Ends on `mode-pick` after Leave stream confirmed

## Steps

| ID | Screen | Control | Arrives at |
|----|--------|---------|------------|
| S1 | `mode-pick` | `UI-mode-pick.C2` | `puzzle-play` |
| S2 | `puzzle-play` | `UI-puzzle-play.C5` then Confirm | `mode-pick` |

## Branches

| ID | At step | When | Destination |
|----|---------|------|-------------|
| B1 | S2 | Cancel on leave confirm | stays `puzzle-play` S1 |

## Experience intent

Into puzzles in one tap; leave is calm and confirmed without Elo hit on the open puzzle.
