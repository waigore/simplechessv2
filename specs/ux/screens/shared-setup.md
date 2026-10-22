# Screen: Shared setup

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Set Shared-game options and start
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md), [`top-player.md`](../actors/top-player.md)
- **Serves**: Instant play, Accessibility; [two-player-game K1](../../design/loops/two-player-game.md); [configuration.md](../../design/configuration.md)
- **Mockup**: [`../mockups/screens/shared-setup.html`](../mockups/screens/shared-setup.html)
- **Glossary terms**: [White seat](../../design/glossary.md), [Clock](../../design/glossary.md), [Advice](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | `GS.whiteSeat` | always |
| R1 | `GS.clock` | always |
| R1 | `GS.increment` | Clock is Blitz or Rapid |
| R1 | `GS.advice` | always |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Options | Configure the next game | White seat, Clock, Increment, Advice |
| R2 | Actions | Start or go back | Start, Back |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | White seat | `IN.activate` | always | Cycles Top / Bottom → updates `GS.whiteSeat` |
| C2 | Clock | `IN.activate` | always | Cycles Untimed / Blitz / Rapid → `GS.clock` |
| C3 | Increment | `IN.activate` | Clock is Blitz or Rapid | Cycles 3 s / 5 s → `GS.increment` |
| C4 | Advice | `IN.activate` | always | Toggles On / Off → `GS.advice` |
| C5 | Start | `IN.activate` | always | → `shared-play` (NAV.T4); locks options |
| C6 | Back | `IN.back` | always | → `mode-pick` (NAV.T5) |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | Screen opens | R1–R2; C3 unavailable if Untimed | C1–C6 as availability allows |

## Copy

All keys below vary by locale (`en`, `zh-Hant`, `ja`).

| Key | String | Used in |
|-----|--------|---------|
| title | Shared game setup | header |
| white_seat | White seat | C1 |
| seat_top | Top | C1 |
| seat_bottom | Bottom | C1 |
| clock | Clock | C2 |
| clock_untimed | Untimed | C2 |
| clock_blitz | Blitz | C2 |
| clock_rapid | Rapid | C2 |
| increment | Increment | C3 |
| increment_3s | 3 s | C3 |
| increment_5s | 5 s | C3 |
| advice | Advice | C4 |
| advice_on | On | C4 |
| advice_off | Off | C4 |
| start | Start | C5 |
| back | Back | C6 |

## Experience intent

Quick options, then Start — no tournament chrome. Meets Accessibility: option values read as text, not color alone; controls are 44px-class touch targets.
