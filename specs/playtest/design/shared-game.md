# Protocol: Shared game

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-shared-game`
- **Environment**: `ENV.1` Headless only
- **Cites**: `L-two-player-game` (K1–K3, E1–E4)
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | `DBG.3` into Shared setup Untimed; White seat Bottom; start game. |
| S2 | Complete one legal White move and one legal Black move via player controls. |
| S3 | `DBG.3` into Blitz + increment; confirm only side-to-move clock runs after a move. |
| S4 | Drive to a checkmate or resign path; confirm `gameEnded` and clocks stopped. |
| S5 | Begin another session; confirm K1 restarts. Stop to mode-pick. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Untimed start: orthodox opening, sideToMove White, clocks none. |
| P2 | Legal moves update position and sideToMove; illegal attempt leaves state unchanged. |
| P3 | Blitz: only side-to-move clock runs; increment applies after a completed move. |
| P4 | Result sets gameEnded; begin-another runs K1; stop reaches mode-pick. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Move waits on network or clocks both run | yes |
| F2 | Result or restart does not match K3/E* | yes |

## Evidence

Default evidence rules ([`evidence.md`](../evidence.md)). The protocol states no extras and waives no screenshot.
