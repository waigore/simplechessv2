# Feature: Move advice

Authoring rules: [`.agents/specs/rules/design/features.md`](../../../.agents/specs/rules/design/features.md).

- **Kind**: system
- **Serves**: Instant play. Scope: optional Stockfish suggestions in a Shared game when online.
- **Depends on**: None
- **Glossary terms**: [Advice](../glossary.md), [Shared game](../glossary.md), [Side to move](../glossary.md), [Puzzle stream](../glossary.md)

## Purpose

When Advice is On and the browser is online, show the engine’s best move for the side to move on the board, without delaying a local move.

## Rules

- **R1**: [Advice](../glossary.md) applies only in a [Shared game](../glossary.md). It never applies in [Puzzle stream](../glossary.md) ([CFG.K3](../configuration.md)).
- **R2**: Advice runs only when the Advice option is On and the browser is online. Otherwise there is no evaluation and no advice display.
- **R3**: Advice is automatic. There is no ask action. While R2 holds, the engine evaluates the current position.
- **R4**: When a best move is ready, the game shows it as piece highlights and an arrow, plus an eval score in centipawns from White's view (`GS.adviceEval`). No longer principal line.
- **R5**: The best move and eval are always for the [Side to move](../glossary.md) only.
- **R6**: A local move never waits on the engine. Piece motion and turn change complete on the device ([L-two-player-game.K2](../loops/two-player-game.md)).
- **R7**: Search is time-capped by `CFG.ADVICE_TIME_MS`. Streaming updates may deepen until the cap.
- **R8**: When a move is completed, or the game ends, clear advice immediately. If the game continues and R2 still holds, start evaluating the new position.
- **R9**: Turning Advice Off, going offline, or leaving the Shared game clears advice and stops evaluation.

## Parameters

- `CFG.ADVICE_TIME_MS` — maximum engine think time per position (see [configuration.md](../configuration.md)).

## State

| Field | Read / write | When |
|-------|--------------|------|
| `GS.advice` | read | Whether Advice may run (R2) |
| `GS.online` | read | Whether Advice may run (R2) |
| `GS.sideToMove` | read | Whose best move and eval (R5) |
| `GS.position` | read | Position to evaluate (R3) |
| `GS.gameEnded` | read | Clear advice on end (R8) |
| `GS.adviceBestMove` | write | Set when ready; clear per R8/R9 |
| `GS.adviceEval` | write | Centipawns from White's view with best move; clear with it |

## Interactions with other features

- **I1**: Never delays [L-two-player-game.K2](../loops/two-player-game.md). Instant play wins over waiting for advice.

## Edge cases

| ID | Situation | Outcome |
|----|-----------|---------|
| X1 | Player moves while evaluation is in flight | Clear advice; start evaluating the new position if R2 holds (R8) |
| X2 | Advice toggled Off mid-game | Clear advice; stop evaluation (R9) |
| X3 | Connection lost mid-evaluation | Clear advice; stop evaluation (R9) |
| X4 | Game ends while advice is showing | Clear advice (R8) |

## Difficulty and configuration effects

- **D1**: Advice Off → R2 and R9; no display. Puzzle stream → R1; no advice.

## Experience intent

Help appears calmly on the board when enabled. Moves stay snappy. Advice never feels like a computer opponent.
