# Loop: Puzzle stream

Authoring rules: [`.agents/specs/rules/design/loops.md`](../../../.agents/specs/rules/design/loops.md).

- **Level**: session
- **Timescale**: One [Puzzle](../glossary.md) per iteration, as many as fit a [Session](../glossary.md) of about 15–40 minutes.
- **Serves**: Instant play and Cafe calm. Scope: continuous solo Puzzle stream matched to level.
- **Parent / child loops**: None. Entered from [mode-pick](../flows/mode-pick.md) P3; Leave stream returns there.

## Steps

| ID | Player does | Game responds | Player gains or learns |
|----|-------------|---------------|------------------------|
| K1 | Enter Puzzle stream after choosing that mode | Deals the next [Puzzle](../glossary.md) per [DIF.Y1](../difficulty.md). Shows [Player Elo](../glossary.md). The player moves the [Solving side](../glossary.md), the side to move in the dealt position. | The position, their side, and their Elo are clear. |
| K2 | Makes a move of the [Solving side](../glossary.md), reveals the solution, or abandons this puzzle | A move of the Solving side completes at acceptance. A move that matches the next step of the [Required sequence](../glossary.md) advances it. On a mate-in-one puzzle, any checkmating move matches that step ([F-puzzle-catalog](../features/puzzle-catalog.md) R5). When the sequence then has a required reply, the game plays that reply at once for the other side and the player moves again. A [Wrong move](../glossary.md) returns the puzzle to its start and does not deal the next. [END.L5](../end-conditions/conditions.md) on reveal. Abandon reaches [END.L6](../end-conditions/conditions.md). This step does not update Elo and does not deal the next puzzle. No clocks. No [Advice](../glossary.md). | Progress on the puzzle, or a clear fail. |
| K3 | After [END.W1](../end-conditions/conditions.md), [END.L4](../end-conditions/conditions.md), [END.L5](../end-conditions/conditions.md), or [END.L6](../end-conditions/conditions.md) (abandon) | [Player Elo](../glossary.md) updates once per [DIF.Y1](../difficulty.md). The next puzzle is dealt once. Returns to K2. | Elo drifts; a new puzzle begins. |
| K4 | Leaves the stream (quits the mode) | Returns to [mode pick](../flows/mode-pick.md). [Player Elo](../glossary.md) is kept ([PRG.P1](../progression.md)). An open puzzle is not scored as abandon ([END.L6](../end-conditions/conditions.md)). | They can stop without Elo change on the open puzzle. |

## Motivation

Quiet practice at their level, for as long as the commute session allows.

## Inputs and outputs

[Player Elo](../glossary.md) and the [puzzle catalog](../features/puzzle-catalog.md) go in. An updated [Player Elo](../glossary.md) comes out. Nothing else carries forward. Deal rules live in [difficulty.md](../difficulty.md).

## Variation

Each deal can be a different position and [Puzzle Elo](../glossary.md). [Player Elo](../glossary.md) drifts after each result. Prefer in-band puzzles not solved in the last `CFG.ELO_RECENT_WINDOW` of the stream ([DIF.Y1](../difficulty.md)).

## Exits

- **E1**: Leave the stream (K4). Player choice. Not a puzzle win or loss. See [progression.md](../progression.md) Z1.

END.W1, END.L4, END.L5, and END.L6 (abandon-puzzle) continue the stream; they are not loop exits.

## Experience intent

Untimed and calm. Each move resolves on the device. Failure never ends the stream. Leaving the mode is always available.
