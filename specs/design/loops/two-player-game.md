# Loop: Two-player game

Authoring rules: [`.agents/specs/rules/design/loops.md`](../../../.agents/specs/rules/design/loops.md).

- **Level**: session
- **Timescale**: One game, inside a sitting of about 15–40 minutes. Blitz is shorter than rapid.
- **Serves**: Instant play and Cafe calm. Scope: two people play on one device, untimed and timed play, and a new session after a result.
- **Parent / child loops**: None

## Steps

| ID | Player does | Game responds | Player gains or learns |
|----|-------------|---------------|------------------------|
| K1 | Choose who is White. Choose untimed, blitz, or rapid. When timed, choose 3 or 5 seconds added per move. | The game starts from the orthodox opening. White is to move. Clocks are equal, or there is no clock. In a timed game only White's clock runs. | Both players know the clock and that White moves first. |
| K2 | The side to move makes one legal move, or resigns. | A legal move updates the position. In a timed game, only that side's clock runs. It stops when the move is completed, the chosen seconds are added, and the other clock starts. Seconds are added only for a completed move. A clock that has reached zero does not receive them. An illegal attempt is refused, the same side is still to move, and that clock keeps running. Advice never delays this response. | The position and whose turn it is are clear. |
| K3 | After a result, begin another game or stop. | Another game returns to K1. Stopping ends the sitting. Checkmate, resignation, draw, and clock expiry stop both clocks. | They can play again on the same device. |

A move is legal when it is one orthodox move and the mover's king is not left in check. What each piece may do, including castling, en passant, and promotion, is specified with the pieces.

## Motivation

A quiet game with a friend, with unlimited think time, or a short clocked game when they choose one.

## Inputs and outputs

Two players and a clock choice go in. A result comes out: White wins, Black wins, or the game is drawn. Nothing carries into the next game. Clock lengths live in [`configuration.md`](../configuration.md).

## Variation

The players choose the clock, who is White, and every move. Each game starts from the same opening and diverges from there.

## Exits

- **E1**: Checkmate. The side to move is in check and has no legal move. That side loses. See [`end-conditions.md`](../end-conditions.md).
- **E2**: Resignation. The resigning side loses. See [`end-conditions.md`](../end-conditions.md).
- **E3**: Draw, when [`end-conditions.md`](../end-conditions.md) says the game is drawn.
- **E4**: Clock expiry, in a timed game only. The side whose clock reaches zero loses if the other side can still checkmate. Otherwise the game is drawn. See [`end-conditions.md`](../end-conditions.md).

## Experience intent

Untimed play stays calm. Blitz and rapid stay short. Each accepted move resolves immediately on the device. Only the side to move ever has a clock running down.
