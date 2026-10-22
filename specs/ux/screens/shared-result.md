# Screen: Shared result

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Show the Shared-game result and choose play again or stop
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md)
- **Serves**: Cafe calm, Accessibility; [two-player-game K3](../../design/loops/two-player-game.md)
- **Mockup**: [`../mockups/screens/shared-result.html`](../mockups/screens/shared-result.html)
- **Glossary terms**: [Shared game](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | Result (win / draw / loss per end conditions) | `GS.gameEnded` true |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Result | Outcome | Who won or draw |
| R2 | Next | Continue or leave | Play again, Stop |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Play again | `IN.activate` | always | → `shared-setup` (NAV.T7) — new session |
| C2 | Stop | `IN.activate` | always | → `mode-pick` (NAV.T8) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | After game end | R1–R2 | C1–C2 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| title | Game over | header |
| shared_game | Shared game | R1 |
| result_white | White wins | R1 |
| result_black | Black wins | R1 |
| result_draw | Draw | R1 |
| play_again | Play again | C1 |
| stop | Stop | C2 |

Varying by locale: title, shared_game, result_white, result_black, result_draw, play_again, stop.

## Experience intent

Clear outcome, then either a new session or back to modes — no friction. Meets Accessibility: the result is stated in text, not color alone; controls are 44px-class touch targets.
