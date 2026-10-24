# Protocol: Progression

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-progression`
- **Environment**: `ENV.1` Headless only
- **Cites**: `PRG` (A1, P1, P2, P3, M1, F1, Z1–Z3)
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Solve a puzzle; quit; reopen; confirm Player Elo, Last mode, and recent solved IDs committed (P1/P2/P3/M1). |
| S2 | Solve puzzles past `CFG.ELO_RECENT_WINDOW`; confirm the solved list keeps the newest `CFG.ELO_RECENT_WINDOW` IDs with the oldest dropped (P3/M1). |
| S3 | Fail a puzzle; confirm stream continues (F1) and Elo commit rules. |
| S4 | Confirm Shared game has no progression axis: its results advance no axis (A1) and carry nothing forward (F1). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Elo, Last mode, and recent solved IDs persist across sittings per PRG. |
| P2 | The solved list stays within `CFG.ELO_RECENT_WINDOW`, newest last (PRG.P3/PRG.M1). |
| P3 | Failure continues the stream; Shared game has no progression axis (PRG.F1) and no completion gate stops leaving the stream (PRG.Z1–Z3). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A persist field (P1/P2/P3) is missing after reopen or the solved list exceeds `CFG.ELO_RECENT_WINDOW` | yes |
| F2 | Shared game advances a progression axis or carries anything forward | yes |

## Evidence

Default evidence rules ([`evidence.md`](../evidence.md)). The protocol states no extras and waives no screenshot.
