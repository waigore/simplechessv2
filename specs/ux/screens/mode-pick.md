# Screen: Mode pick

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Choose Shared game, Puzzle stream, or quit the sitting
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md)
- **Serves**: Instant play, Cafe calm; [mode-pick.md](../../design/flows/mode-pick.md)
- **Mockup**: [`../mockups/screens/mode-pick.html`](../mockups/screens/mode-pick.html)
- **Glossary terms**: [Screen](../glossary.md); [Last mode](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | `GS.lastMode` highlight | always on this screen |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Mode choices | Pick how to play | Shared game and Puzzle stream controls; Last mode default highlight ([mode-pick N1](../../design/flows/mode-pick.md)) |
| R2 | Quit | End the sitting | Quit control |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Shared game | `IN.activate` | always | → `shared-setup` (NAV.T1) |
| C2 | Puzzle stream | `IN.activate` | always | → `puzzle-play` (NAV.T2) |
| C3 | Quit | `IN.activate` | always | → `EX.confirm` quit sitting |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Screen opens | R1–R2; Last mode highlighted | C1–C3 |
| S2 | `EX.loading` | Cold open before playable | Loading only | none until ready |
| S3 | `EX.confirm` | C3 activated | Quit confirm | Confirm → session end (NAV.T3); Cancel → S1 |
| S4 | `EX.save-failure` | Persist write failed | Save-failure message | Dismiss → S1 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| title | Choose how to play | header |
| shared | Shared game | C1 |
| puzzle | Puzzle stream | C2 |
| quit | Quit | C3 |
| quit_confirm | End this sitting? | S3 |
| loading | Loading… | S2 |

## Experience intent

Calm and immediate: two clear modes, Last mode remembered, quit is confirmed.
