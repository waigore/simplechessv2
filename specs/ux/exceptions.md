# Exception States

Authoring rules: [`.agents/specs/rules/ux/exceptions.md`](../../.agents/specs/rules/ux/exceptions.md).

## Exceptions

| ID | When it appears | Actor sees | Actor can | Blocks the screen | Recovery |
|----|-----------------|------------|-----------|-------------------|----------|
| `EX.loading` | Cold open until the board is playable ([quality.md](../definition/quality.md) load time) | Loading message; no mode controls yet | Wait | yes | Ends on `mode-pick` default when ready |
| `EX.confirm` | Destructive choice: quit sitting, resign, abandon puzzle, leave stream, reveal solution | Confirm and Cancel; names the action | Confirm or Cancel | yes | Confirm runs the action; Cancel returns to the prior screen state |
| `EX.interrupt` | Close, refresh, or reopen during Shared play or Puzzle play ([mode-pick U1](../design/flows/mode-pick.md)) | Next open is mode pick (no mid-game resume) | Use mode pick | n/a (new open) | Arrives at `mode-pick` |
| `EX.save-failure` | Failed commit of Player Elo or Last mode ([quality.md](../definition/quality.md) save durability) | Save failed; prior values kept | Dismiss; continue | no | Dismiss; previous commit intact |
| `EX.error` | Recoverable failure (e.g. Advice fetch while On) | What failed; play may continue | Dismiss | no | Dismiss; local moves never wait |
| `EX.empty` | N/A — every open always has a mode pick or a position | — | — | — | — |
| `EX.unsupported-input` | Non-touch primary input on Web | Input not supported for play | Use touch | no | Switch to touch; control unchanged |

## Experience intent

Errors name the failure and the next step. Confirms slow down resign and leave. Loading is brief; Instant play is never gated by Advice errors.
