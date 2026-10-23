# Contract: Local move

Authoring rules: [`.agents/specs/rules/technical/contracts.md`](../../../.agents/specs/rules/technical/contracts.md).

- **Kind**: API — apply or reject a player move on-device
- **Provider**: [`CMP-chess-rules`](../components/chess-rules.md)
- **Consumers**: [`CMP-shared-game-session`](../components/shared-game-session.md), [`CMP-puzzle-session`](../components/puzzle-session.md)
- **Serves**: Instant play; Shared game; Puzzle stream
- **Informed by**: pieces entities; end-conditions; Instant play under [`CMP-advice-client`](../components/advice-client.md) R5
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md)

## Operations

| ID | Name | Input | Output / effect | When |
|----|------|-------|-----------------|------|
| O1 | try_move | from/to (and promotion if needed) | Applied position + flags, or reject | Player commits a move |
| O2 | legal_targets | from square | Set of legal destinations | Selection / hint |
| O3 | end_signals | — | Check / mate / draw signals per design | After successful apply |
| O4 | possible_checkmate | mating side | bool: that side can checkmate via some legal-move series (FIDE possible checkmate; D5 is the negation) | Clock hits zero (`END.L3` / `END.D5`) |

## Events

| ID | Name | Payload | When emitted | Who may subscribe |
|----|------|---------|--------------|-------------------|
| E1 | move_applied | move + new side to move | After O1 success | L2 sessions: [`CMP-shared-game-session`](../components/shared-game-session.md); [`CMP-puzzle-session`](../components/puzzle-session.md) |
| E2 | move_rejected | reason | After O1 reject | L2 sessions: [`CMP-shared-game-session`](../components/shared-game-session.md); [`CMP-puzzle-session`](../components/puzzle-session.md) |

## Guarantees

| ID | Guarantee |
|----|-----------|
| G1 | O1 completes on-device with no await on advice or network |
| G2 | Position has a single writer ([`CON.O1`](../concurrency.md)) |

## Errors

| Condition | Result |
|-----------|--------|
| Illegal move | E2; state unchanged |
| Game already ended | Reject; no mutate |

## Diagram

None — two events, four operations.
