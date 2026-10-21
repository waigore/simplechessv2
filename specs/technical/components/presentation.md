# Component: Presentation

Authoring rules: [`.agents/specs/rules/technical/components.md`](../../../.agents/specs/rules/technical/components.md).

- **Layer**: L1 Presentation
- **Module**: M1 `client`
- **Serves**: Clear board; Cafe calm; touch input; view/UX screens
- **Informed by**: view board camera; UX screens; aesthetics motion/sound
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md), [ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md)

## Responsibilities

| ID | Responsibility |
|----|----------------|
| R1 | Render board, pieces, UI from resolved assets |
| R2 | Capture touch select/move gestures for the active session |
| R3 | Play move/check/mate/resign SFX and cafe ambient when specified |
| R4 | Show Advice highlights/arrow/eval when session supplies them |
| R5 | Never await network before completing piece motion |
| R6 | Select player-facing copy from the string table for the current `GS.locale` |

## Communication

| ID | Peer | Direction | Via contract | Notes |
|----|------|-----------|--------------|-------|
| C1 | [`CMP-session-router`](session-router.md) | both | [`CTR-presentation`](../contracts/presentation.md) | Screens, cues/ambient, assets: E1/E3/E5 down; O2/O3 up. Reads the locale string table ([`configuration.md`](../configuration.md) B4) |
| C2 | [`CMP-shared-game-session`](shared-game-session.md) | both | [`CTR-presentation`](../contracts/presentation.md) | Shared play: O1 up; E2–E4 down |
| C3 | [`CMP-puzzle-session`](puzzle-session.md) | both | [`CTR-presentation`](../contracts/presentation.md) | Puzzle play: O1 up; E2–E3 down |

## Owns / mutates

| Schema or state | Access |
|-----------------|--------|
| Visual selection / animation only | write |
| Play state | read |

## Diagram

```mermaid
flowchart LR
  R[CMP-session-router]
  S[CMP-shared-game-session]
  Q[CMP-puzzle-session]
  V[CMP-presentation]
  R -.->|CTR-presentation E1/E3/E5| V
  S -.->|CTR-presentation E2-E4| V
  Q -.->|CTR-presentation E2-E3| V
  V -->|O2/O3| R
  V -->|O1| S
  V -->|O1| Q
```

## Failure / concurrency / persistence

[`concurrency.md`](../concurrency.md) U1; [`failures.md`](../failures.md) T4; [`asset-access.md`](../asset-access.md).
