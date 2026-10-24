# Navigation

Authoring rules: [`.agents/specs/rules/ux/navigation.md`](../../.agents/specs/rules/ux/navigation.md).

- **Serves**: Instant play, Cafe calm; Shared game, Puzzle stream, new run (definition); [mode-pick](../design/flows/mode-pick.md), [two-player-game](../design/loops/two-player-game.md), [puzzle-stream](../design/loops/puzzle-stream.md).

## Screens

| Screen | Job | Actors | Spec | Mockup |
|--------|-----|--------|------|--------|
| `mode-pick` | Choose Shared game, Puzzle stream, or quit | Bottom player, Top player | [`screens/mode-pick.md`](screens/mode-pick.md) | [`mockups/screens/mode-pick.html`](mockups/screens/mode-pick.html) |
| `shared-setup` | Set White seat, Clock, Increment, Advice; start | Bottom player, Top player | [`screens/shared-setup.md`](screens/shared-setup.md) | [`mockups/screens/shared-setup.html`](mockups/screens/shared-setup.html) |
| `shared-play` | Play the Shared game on one device | Bottom player, Top player | [`screens/shared-play.md`](screens/shared-play.md) | [`mockups/screens/shared-play.html`](mockups/screens/shared-play.html) |
| `shared-result` | Show result; play again or stop | Bottom player, Top player | [`screens/shared-result.md`](screens/shared-result.md) | [`mockups/screens/shared-result.html`](mockups/screens/shared-result.html) |
| `puzzle-play` | Play the Puzzle stream | Bottom player, Top player | [`screens/puzzle-play.md`](screens/puzzle-play.md) | [`mockups/screens/puzzle-play.html`](mockups/screens/puzzle-play.html) |

## Transitions

Top player and Bottom player are game seats. Every transition is operable by whoever touches the screen. The interface does not gate a transition by seat.

| ID | From | Via | To | Conditions | Actors |
|----|------|-----|----|------------|--------|
| T1 | `mode-pick` | `UI-mode-pick.C1` | `shared-setup` | None | Bottom player, Top player |
| T2 | `mode-pick` | `UI-mode-pick.C2` | `puzzle-play` | None | Bottom player, Top player |
| T3 | `mode-pick` | `UI-mode-pick.C3` then `EX.confirm` Confirm | (session end) | Confirm quit | Bottom player, Top player |
| T4 | `shared-setup` | `UI-shared-setup.C5` | `shared-play` | None | Bottom player, Top player |
| T5 | `shared-setup` | `UI-shared-setup.C6` | `mode-pick` | None | Bottom player, Top player |
| T6 | `shared-play` | resign confirmed (`UI-shared-play.C4` + `EX.confirm`) or game end | `shared-result` | `GS.gameEnded` true | Bottom player, Top player (resign: side to move) |
| T7 | `shared-result` | `UI-shared-result.C1` | `shared-setup` | None | Bottom player, Top player |
| T8 | `shared-result` | `UI-shared-result.C2` | `mode-pick` | None | Bottom player, Top player |
| T9 | `puzzle-play` | `UI-puzzle-play.C5` then `EX.confirm` Confirm | `mode-pick` | Leave stream | Bottom player, Top player |

## Entry and resume

- **N1**: A new session opens on `mode-pick`. Whoever touches operates it ([mode-pick N1](../design/flows/mode-pick.md)).
- **N2**: Interrupt during Shared or Puzzle play resumes on `mode-pick` ([mode-pick U1](../design/flows/mode-pick.md); `EX.interrupt`).
