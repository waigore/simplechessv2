# Navigation

Authoring rules: [`.agents/specs/rules/ux/navigation.md`](../../.agents/specs/rules/ux/navigation.md).

## Screens

| Screen | Job | Actors | Spec | Mockup |
|--------|-----|--------|------|--------|
| `mode-pick` | Choose Shared game, Puzzle stream, or quit | Bottom player | [`screens/mode-pick.md`](screens/mode-pick.md) | [`mockups/screens/mode-pick.html`](mockups/screens/mode-pick.html) |
| `shared-setup` | Set White seat, Clock, Increment, Advice; start | Bottom player | [`screens/shared-setup.md`](screens/shared-setup.md) | [`mockups/screens/shared-setup.html`](mockups/screens/shared-setup.html) |
| `shared-play` | Play the Shared game on one device | Bottom player, Top player | [`screens/shared-play.md`](screens/shared-play.md) | [`mockups/screens/shared-play.html`](mockups/screens/shared-play.html) |
| `shared-result` | Show result; play again or stop | Bottom player | [`screens/shared-result.md`](screens/shared-result.md) | [`mockups/screens/shared-result.html`](mockups/screens/shared-result.html) |
| `puzzle-play` | Play the Puzzle stream | Bottom player | [`screens/puzzle-play.md`](screens/puzzle-play.md) | [`mockups/screens/puzzle-play.html`](mockups/screens/puzzle-play.html) |

## Transitions

| ID | From | Via | To | Conditions | Actors |
|----|------|-----|----|------------|--------|
| T1 | `mode-pick` | `UI-mode-pick.C1` | `shared-setup` | None | Bottom player |
| T2 | `mode-pick` | `UI-mode-pick.C2` | `puzzle-play` | None | Bottom player |
| T3 | `mode-pick` | `UI-mode-pick.C3` then `EX.confirm` Confirm | (session end) | Confirm quit | Bottom player |
| T4 | `shared-setup` | `UI-shared-setup.C5` | `shared-play` | Options set | Bottom player |
| T5 | `shared-setup` | `UI-shared-setup.C6` | `mode-pick` | None | Bottom player |
| T6 | `shared-play` | resign confirmed (`UI-shared-play.C4` + `EX.confirm`) or game end | `shared-result` | `GS.gameEnded` true | Bottom or Top (resign: side to move) |
| T7 | `shared-result` | `UI-shared-result.C1` | `shared-setup` | None | Bottom player |
| T8 | `shared-result` | `UI-shared-result.C2` | `mode-pick` | None | Bottom player |
| T9 | `puzzle-play` | `UI-puzzle-play.C5` then `EX.confirm` Confirm | `mode-pick` | Leave stream | Bottom player |

## Entry and resume

- **N1**: A new sitting opens on `mode-pick` for Bottom player ([mode-pick N1](../design/flows/mode-pick.md)).
- **N2**: Interrupt during Shared or Puzzle play resumes on `mode-pick` ([mode-pick U1](../design/flows/mode-pick.md); `EX.interrupt`).
