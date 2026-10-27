# Protocol view

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../.agents/specs/rules/playtest/traceability.md).

One row per protocol, per the [map index](../story-protocol.md), split by level: [design protocols](protocols-design.md) and [UX protocols](protocols-ux.md). **Judged rows** are the story rows that protocol's **Cites** covers; the wave sweeps copy this list instead of retyping a story set. **`none`** names rows in that protocol's namespace it does not judge.

Level and **Cites** are quoted from each protocol file, which remains the authority — this view edits no protocol.

## Tally

| Level | Protocols | Rows judged | Notes |
|-------|-----------|-------------|-------|
| Design | 12 | 41 of 41 story rows | — |
| UX | 11 | 33 of 34 story rows | 1 `none`, out of playtest scope ([#788](https://github.com/waigore/simplechessv2/issues/788)); the seven actor `US2`–`US5` splits cite no protocol |

## How to read a row

- A protocol may judge a row it is not named after: `PTD-mode-and-config`'s bare `CFG` cite covers every `CFG.*` element, so it judges `loops/two-player-tunables.md#PS1` and `features/move-advice-tunables.md#PS1` without citing their own keys.
- `PTD-puzzle-stream` names `END.L4`, `END.L5`, and `DIF.Y1`, which are already covered by their own protocols; that cite binds the flow, it judges no additional row.
- A UX protocol's story-ID cite reaches every file carrying that heading, so `UI-mode-pick.US1` judges both `screens/mode-pick.md#US1` and `screens/mode-pick-unavailable.md#US1` for each of its two citing protocols.
