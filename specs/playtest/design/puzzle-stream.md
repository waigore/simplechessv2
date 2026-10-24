# Protocol: Puzzle stream

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-puzzle-stream`
- **Environment**: `ENV.1` Headless only
- **Cites**: `L-puzzle-stream` (K1–K4, E1), `END.L4`, `END.L5`, `DIF.Y1`, `F-puzzle-catalog` (R1–R5, I1–I3, X1–X2, D1), `SC-puzzle-stream-visit` (W1.1–W1.4, W2.1–W2.4)
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | Open the game, confirm mode pick defaults to Shared game, choose Puzzle stream, and compare the dealt position with the record (first move applied, `puzzleElo` its `Rating`, no band id, no client snapshot) (K1, R1–R3, W1.1, W1.2). |
| S2 | Play the sequence with no wrong move; confirm replies play, `sequenceIndex` steps by 2, `END.W1` and the Elo rise follow, and one next deal (R4, I2, K3, W1.3, W1.4). |
| S3 | On a `mateIn1` record, play a different legal checkmating move; confirm the solve and an unchanged `requiredSequence` (R5). |
| S4 | Solve a puzzle, then deal while its id is inside `CFG.ELO_RECENT_WINDOW` of `GS.recentSolved`; confirm it is not dealt (I1). |
| S5 | Deal with no candidate inside ±`CFG.ELO_MATCH_RANGE`; confirm the widen by `CFG.ELO_BAND_WIDEN` and no Elo band (I1, D1). |
| S6 | Deal a slice with one `Moves` entry, then deal against an unreadable route; confirm nothing dealt and `GS.playerElo` kept (X1, X2). |
| S7 | Play a wrong move on the next puzzle; confirm the same `puzzleId` returns to its start with no next deal, and a second wrong move is retryable (K2, W2.1). |
| S8 | Reveal the solution; confirm failure then a deal (K2, W2.2). Abandon the new puzzle; confirm S = 0 and one deal (W2.3). |
| S9 | Leave confirmed; return to mode-pick, `GS.playerElo` kept, open puzzle unscored (K4/E1, W2.4). |
| S10 | After a wrong move, complete the sequence; confirm `END.L4`, Elo dropping as `DIF.Y1` scores S = 0, and one deal (K3, W1.4). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Deal yields a puzzle matching the served record; solve advances with `END.W1` and the Elo path (R1–R3, W1.1–W1.4). |
| P2 | A wrong move resets the open puzzle and deals nothing; never a solve. Reveal and abandon fail it and deal once. Leave exits unscored (K2–K4, END.L4–L6, W2.1–W2.4). |
| P3 | Selection honours the window, skips recent ids, widens numerically, and refuses an empty solution or unreadable catalog (I1–I3, D1, X1, X2). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A wrong move deals the next puzzle, counts as a solve, or cannot be retried | yes |
| F2 | Leave penalises Elo for the open puzzle | yes |
| F3 | Dealt record does not match the snapshot, or a band id replaces the Rating window | yes |
| F4 | An empty solution or unreadable catalog deals a puzzle or changes `GS.playerElo` | yes |

## Evidence

Default evidence rules ([`evidence.md`](../evidence.md)). The protocol states no extras and waives no screenshot.
