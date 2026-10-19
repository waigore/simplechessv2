# Exception States

Authoring rules: [`.agents/specs/rules/ux/exceptions.md`](../../.agents/specs/rules/ux/exceptions.md).

## Exceptions

| ID | When it appears | Actor sees | Actor can | Blocks the screen | Recovery |
|----|-----------------|------------|-----------|-------------------|----------|
| `EX.loading` | Cold open until the board is playable ([quality.md](../definition/quality.md) load time) | Loading message; no mode controls yet | Wait | yes | Ends on `mode-pick` default when ready |
| `EX.confirm` | Destructive or hard-to-undo choice: quit sitting, resign, offer a draw, abandon puzzle, leave stream, reveal solution | Confirm and Cancel; names the action | Confirm or Cancel | yes | Confirm runs the action; Cancel returns to the prior screen state |
| `EX.promote` | A legal pawn place is on the last rank ([I33](../design/entities/pieces/pawn.md)) | Queen, rook, bishop, then knight sprites of that color at the destination, upright for the side to move | Tap one sprite to commit that type, or `IN.deselect` to drop the choice and leave the pawn selected | no | Commit completes the place; drop returns to the selected pawn. A running shared-game clock keeps running |
| `EX.rejected` | A place the piece rules refuse ([I11](../design/entities/pieces/common.md), [K2](../design/loops/two-player-game.md)) | A short danger flash on the attempted square ([PER.R8](../view/perception.md)). Selection, legal marks, and position stay | Try another square or clear the selection at once | no | The flash ends on the same screen. No Dismiss. The running clock keeps running |
| `EX.draw-offer` | The side to move confirmed a draw offer ([END.D2](../design/end-conditions/conditions.md)) | Draw offered. The other seat sees Accept and Decline. The offering seat sees Withdraw | Accept, Decline, or Withdraw | yes | Accept ends the game as a draw. Decline or Withdraw returns to play, same side to move, that clock still running |
| `EX.interrupt` | Close, refresh, or reopen during Shared play or Puzzle play ([mode-pick U1](../design/flows/mode-pick.md)) | Next open is mode pick (no mid-game resume) | Use mode pick | n/a (new open) | Arrives at `mode-pick` |
| `EX.save-failure` | Failed commit of Player Elo or Last mode ([quality.md](../definition/quality.md) save durability) | Save failed; prior values kept | Dismiss; continue | no | Dismiss; previous commit intact |
| `EX.error` | Recoverable failure (e.g. Advice fetch while On) | What failed; play may continue | Dismiss | no | Dismiss; local moves never wait |
| `EX.unsupported-input` | Non-touch primary input on Web | Input not supported for play | Use touch | no | Switch to touch; control unchanged |

## Experience intent

Errors name the failure and the next step. Confirms slow down resign, draw offers, and leave. A refused place flashes and does not trap the actor. Loading is brief; Instant play is never gated by Advice errors.
