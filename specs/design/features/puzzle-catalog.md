# Feature: Puzzle catalog

Authoring rules: [`.agents/specs/rules/design/features.md`](../../../.agents/specs/rules/design/features.md).

- **Kind**: system
- **Serves**: Cafe calm (vision); Puzzle stream and Elo matching (definition).
- **Depends on**: None
- **Glossary terms**: [Puzzle catalog](../glossary.md), [Puzzle](../glossary.md), [Puzzle Elo](../glossary.md), [Required sequence](../glossary.md), [Wrong move](../glossary.md), [Solving side](../glossary.md), [Player Elo](../glossary.md)

## Purpose

Deal each [Puzzle](../glossary.md) from one host-held catalog at the player's level.

## Rules

- **R1**: The [Puzzle catalog](../glossary.md) is the public export named in [ADR-0008](../../adr/decisions/0008-puzzle-catalog-storage.md), under CC0. CC0 allows use in this no-install browser game. The catalog stays on the host and is not shipped in the client.
- **R2**: The served snapshot was last updated 2026-10-05 and holds 6,157,341 rated, tagged puzzles. [Puzzle Elo](../glossary.md) is each record's Rating. There are no Elo bands and no per-band counts. A sitting stays about 15–40 minutes ([vision](../../vision.md), [experience](../experience.md)) and does not size the catalog.
- **R3**: A record stores PuzzleId, FEN, Moves, Rating, RatingDeviation, Popularity, NbPlays, Themes, GameUrl, OpeningTags, and DailyDate. FEN is the position before the opponent moves. Moves are ordered UCI. On deal, apply the first move, then present that position. `GS.puzzleId` is PuzzleId. `GS.puzzleElo` is Rating. `GS.requiredSequence` is the later moves, length ≥ 1. Odd steps are [Solving side](../glossary.md) moves; even steps are required replies.
- **R4**: When the mate-in-one mark is false, the next Solving side step matches only the recorded move.
- **R5**: The mark is true exactly when Themes includes `mateIn1`. The list then has exactly one Solving side move. That step matches the recorded move or any other legal checkmating move. Any other move does not match. `GS.requiredSequence` stays the recorded list.

## Parameters

- `CFG.ELO_MATCH_RANGE`, `CFG.ELO_RECENT_WINDOW`, and `CFG.ELO_BAND_WIDEN` — windows [DIF.Y1](../difficulty.md) already owns ([configuration.md](../configuration.md)). This feature adds none.

## State

| Field | Read / write | When |
|-------|--------------|------|
| `GS.puzzleId` | write | Deal (R3) |
| `GS.puzzleElo` | write | Deal (R3) |
| `GS.requiredSequence` | write | Deal (R3, R5) |
| `GS.playerElo` | read | Select (I1) |
| `GS.recentSolved` | read / write | Read on select (I1); append PuzzleId (I3) |

## Interactions with other features

- **I1**: [DIF.Y1](../difficulty.md) selects from this catalog by Rating and PuzzleId: inside ±`CFG.ELO_MATCH_RANGE` of `GS.playerElo`, preferring ids outside the last `CFG.ELO_RECENT_WINDOW` of `GS.recentSolved`, then widening and/or allowing a recent id until one is found. The Elo formula stays as specified there.
- **I2**: [L-puzzle-stream](../loops/puzzle-stream.md) K2 plays even steps as required replies.
- **I3**: After [END.W1](../end-conditions/conditions.md), `GS.recentSolved` appends that PuzzleId. Ids name snapshot 2026-10-05 only.

## Edge cases

| ID | Situation | Outcome |
|----|-----------|---------|
| X1 | Moves after the first would be empty | Not dealt. `GS.puzzleId` stays none |
| X2 | The host catalog cannot be read | No puzzle is dealt. `GS.playerElo` is unchanged |

## Difficulty and configuration effects

- **D1**: [DIF.Y1](../difficulty.md) widens the numeric ± window by `CFG.ELO_BAND_WIDEN` against Rating. That widen is not a named band.

## Experience intent

One puzzle at the player's level, from a set they do not browse. The sitting stays about 15–40 minutes.
