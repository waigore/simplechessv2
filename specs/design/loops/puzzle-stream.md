# Loop: Puzzle stream

Authoring rules: [`.agents/specs/rules/design/loops.md`](../../../.agents/specs/rules/design/loops.md).

- **Level**: session
- **Timescale**: One [Puzzle](../glossary.md) per iteration, as many as fit a [Sitting](../glossary.md) of about 15–40 minutes.
- **Serves**: Instant play and Cafe calm. Scope: continuous solo Puzzle stream matched to level.
- **Parent / child loops**: None. Mode pick before entry is a separate flow.

## Steps

| ID | Player does | Game responds | Player gains or learns |
|----|-------------|---------------|------------------------|
| K1 | Enter Puzzle stream after choosing that mode | Deals the next [Puzzle](../glossary.md) per [DIF.Y1](../difficulty.md). Shows [Player Elo](../glossary.md). The player moves the side to move in the dealt position. | The position and their Elo are clear. |
| K2 | Makes a move, reveals the solution, or abandons this puzzle | A move that matches the next step of the [Required sequence](../glossary.md) advances it. A [Wrong move](../glossary.md) returns the puzzle to its start and does not deal the next. [L5](../end-conditions/conditions.md) on reveal. Abandoning the puzzle is an Elo loss (S = 0), then the next puzzle is dealt. No clocks. No [Advice](../glossary.md). | Progress on the puzzle, or a clear fail and a new deal. |
| K3 | After [W1](../end-conditions/conditions.md), [L4](../end-conditions/conditions.md), [L5](../end-conditions/conditions.md), or abandon-puzzle | [Player Elo](../glossary.md) updates per [DIF.Y1](../difficulty.md). The next puzzle is dealt. Returns to K2. | Elo drifts; a new puzzle begins. |
| K4 | Leaves the stream (quits the mode) | The mode ends. [Player Elo](../glossary.md) is kept ([PRG.P1](../progression.md)). An open puzzle is not scored as abandon. | They can stop without Elo change on the open puzzle. |

## Motivation

Quiet practice at their level, for as long as the commute sitting allows.

## Inputs and outputs

[Player Elo](../glossary.md) and the puzzle catalog go in. An updated [Player Elo](../glossary.md) comes out. Nothing else carries forward. Deal rules live in [difficulty.md](../difficulty.md).

## Variation

Each deal can be a different position and [Puzzle Elo](../glossary.md). [Player Elo](../glossary.md) drifts after each result. Prefer in-band puzzles not solved in the last 20 of the stream ([DIF.Y1](../difficulty.md)).

## Exits

- **E1**: Leave the stream (K4). Player choice. Not a puzzle win or loss. See [progression.md](../progression.md) Z1.

W1, L4, L5, and abandon-puzzle continue the stream; they are not loop exits.

## Experience intent

Untimed and calm. Each move resolves on the device. Failure never ends the stream. Leaving the mode is always available.
