# Journey: Shared session

Authoring rules: [`.agents/specs/rules/ux/journeys.md`](../../../.agents/specs/rules/ux/journeys.md).

- **Actor**: [`bottom-player.md`](../actors/bottom-player.md) (Top joins on `shared-play`)
- **Goal**: Finish a Shared game and optionally start another
- **Serves**: Instant play, Cafe calm; [mode-pick](../../design/flows/mode-pick.md); [two-player-game](../../design/loops/two-player-game.md)
- **Mockup**: [`../mockups/journeys/shared-session.html`](../mockups/journeys/shared-session.html)
- **Glossary terms**: [Journey](../glossary.md)

## Entry and exit

- **N1**: Starts on `mode-pick` when Bottom opens a sitting
- **N2**: Ends on `mode-pick` after Stop, or on `shared-setup` after Play again (new session continues)

## Steps

| ID | Screen | Control | Arrives at |
|----|--------|---------|------------|
| S1 | `mode-pick` | `UI-mode-pick.C1` | `shared-setup` |
| S2 | `shared-setup` | `UI-shared-setup.C5` | `shared-play` |
| S3 | `shared-play` | `UI-shared-play.C4` then `EX.confirm` Confirm | `shared-result` |
| S4 | `shared-result` | `UI-shared-result.C2` | `mode-pick` |

## Branches

| ID | At step | When | Destination |
|----|---------|------|-------------|
| B1 | S4 | Play again (`UI-shared-result.C1`) | `shared-setup` S1 of a new game |
| B2 | S2 | Back (`UI-shared-setup.C6`) | `mode-pick` S1 |

## Experience intent

Straight path into a friend game; Play again restarts setup without leaving the site.
