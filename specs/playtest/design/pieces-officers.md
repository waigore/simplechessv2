# Protocol: Officers

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-pieces-officers`
- **Environment**: `ENV.1` Headless only
- **Cites**: `E-pieces` officers (sliding and knight stories)
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | Bishop/rook/queen: slide along empty ray; stop before own piece; capture first enemy. |
| S2 | Blocked ray: cannot jump; confirm illegal beyond blocker. |
| S3 | Knight: L-shape jumps; capture on landing; blocked path irrelevant. |
| S4 | Queen combines rook+bishop rays under same blocking rules. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Sliding and knight movement match officer stories. |
| P2 | Illegal slides/jumps rejected without state change. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Piece jumps illegally or cannot capture legally | yes |

## Evidence

Default evidence rules ([`evidence.md`](../evidence.md)). The protocol states no extras and waives no screenshot.
