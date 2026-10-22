# Screen: Mode pick

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Choose Shared game, Puzzle stream, or quit the session
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md), [`top-player.md`](../actors/top-player.md)
- **Serves**: Instant play, Cafe calm, Accessibility; [mode-pick.md](../../design/flows/mode-pick.md)
- **Mockup**: [`../mockups/screens/mode-pick.html`](../mockups/screens/mode-pick.html)
- **Glossary terms**: [Screen](../glossary.md); [Last mode](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | `GS.lastMode` highlight | always on this screen |
| R3 | `GS.locale` current locale name | always on this screen |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Mode choices | Pick how to play | Shared game and Puzzle stream controls; Last mode default highlight ([mode-pick N1](../../design/flows/mode-pick.md)) |
| R2 | Quit | End the session | Quit control |
| R3 | Locale | Switch the interface language | Switch locale control showing the current locale's name |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Shared game | `IN.activate` | S1 or S4 | → `shared-setup` (NAV.T1) |
| C2 | Puzzle stream | `IN.activate` | S1 or S4 | → `puzzle-play` (NAV.T2) |
| C3 | Quit | `IN.activate` | S1 or S4 | → `EX.confirm` quit session |
| C4 | Switch locale | `IN.activate` | S1 or S4 | Switch to the next shipped locale (`en` → `zh-Hant` → `ja` → `en`); all copy updates immediately |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Screen opens | R1–R3; Last mode highlighted | C1–C4 |
| S2 | `EX.loading` | Cold open before playable | Loading only | none until ready |
| S3 | `EX.confirm` | C3 activated | Quit confirm | Confirm → session end (NAV.T3); Cancel → S1 |
| S4 | `EX.save-failure` | Persist write failed | Save-failure message | Dismiss → S1; C1–C4 as S1 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| title | Choose how to play | header |
| last | Last | R1 |
| shared | Shared game | C1 |
| puzzle | Puzzle stream | C2 |
| quit | Quit | C3 |
| quit_confirm | End this session? | S3 |
| confirm | Confirm | S3 |
| cancel | Cancel | S3 |
| loading | Loading… | S2 |
| save_failed | Save failed. Prior values kept. | S4 |
| dismiss | Dismiss | S4 |
| locale | English | C4 |

Varying by locale: title, last, shared, puzzle, quit, quit_confirm, confirm, cancel, loading, save_failed, dismiss. locale is the own-name (English, 繁體中文, 日本語), same in every locale.

Copy owner `mode-pick`; keys and `en` source per [localization.md](../localization.md) L1.

## Experience intent

Calm and immediate: two clear modes, Last mode remembered, quit is confirmed. Meets Accessibility: modes and locale read as text, not color alone; controls are 44px-class touch targets.
