# Protocol: Difficulty

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-difficulty`
- **Environment**: `ENV.1` Headless only
- **Cites**: `DIF`
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | Note Player Elo; solve a puzzle; confirm next deal Elo direction per DIF after solve. |
| S2 | Fail a puzzle (wrong or reveal); confirm next deal Elo direction per DIF after fail. |
| S3 | Confirm Shared game results do not change Player Elo. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Puzzle result adjusts selection difficulty per DIF. |
| P2 | Shared endings leave Player Elo unchanged. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Elo/selection moves opposite DIF rules or Shared mutates Elo | yes |

## Evidence

Default evidence rules ([`evidence.md`](../evidence.md)). The protocol states no extras and waives no screenshot.
