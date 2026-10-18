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

## Communication

| ID | Peer | Direction | Via contract | Notes |
|----|------|-----------|--------------|-------|
| C1 | [`CMP-session-router`](session-router.md) | both | internal | Screens |
| C2 | [`CMP-shared-game-session`](shared-game-session.md) | both | internal | Shared play |
| C3 | [`CMP-puzzle-session`](puzzle-session.md) | both | internal | Puzzle play |
| C4 | [`CMP-asset-resolver`](asset-resolver.md) | calls | [`CTR-asset-resolve`](../contracts/asset-resolve.md) | Textures/audio/fonts |

## Owns / mutates

| Schema or state | Access |
|-----------------|--------|
| Visual selection / animation only | write |
| Play state | read |

## Diagram

```mermaid
flowchart LR
  V[CMP-presentation]
  A[CMP-asset-resolver]
  S[sessions]
  V --> A
  S --> V
```

## Failure / concurrency / persistence

[`concurrency.md`](../concurrency.md) U1; [`failures.md`](../failures.md) T4; [`asset-access.md`](../asset-access.md).
