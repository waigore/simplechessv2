# Headless notes — #331

Judged the merged deal component (PR #514, merge `463e19c`) on a clean checkout of `main` at `b8a1e81`. Verification pass; the implementation summary was posted by a separate session.

## Scope

`CMP-puzzle-session` R1 only: selection, deal writes, first-move presentation, and the two deal failures. Sequence judging, outcomes, Elo, and the commit path are on the session leaf; they are not judged here.

## What was checked

- `DIF.Y1` selection inside `±CFG.ELO_MATCH_RANGE` of `GS.playerElo`, skipping ids in the recent window when alternatives exist.
- The `CFG.ELO_BAND_WIDEN` widen step and the allow-recent relax, each exercised; a record far outside every widened window still deals rather than failing.
- First UCI move applied before presenting; `GS.solvingSide` is the side to move in the presented position; `GS.requiredSequence` holds the later moves; `CFG.ELO_RECENT_WINDOW` trimming on the saved list.
- `F-puzzle-catalog` X1 (one-move record) and X2 (empty catalog) both deal nothing and leave `GS.playerElo` unchanged.
- Mate-in-one marking reads `mateIn1` from the record themes.

## Limits

- The suite is the test file's own assertions; this run did not add probes. The headless smoke confirms the shipped game still boots and reaches mode pick with the new component compiled in.
- No graphical run is in scope: the component is not on any screen yet.
