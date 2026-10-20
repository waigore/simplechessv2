# Controls

Authoring rules: [`.agents/specs/rules/ux/controls.md`](../../.agents/specs/rules/ux/controls.md).

- **Serves**: Instant play; Web touch (definition primary input); every screen’s controls; [camera-controls.md](../view/camera-controls.md) (no camera actions).

## UI actions

| ID | Action | Meaning |
|----|--------|---------|
| `IN.confirm` | Confirm | Accept the focused choice. |
| `IN.cancel` | Cancel | Dismiss without accepting. |
| `IN.back` | Back | Return to the previous screen. |
| `IN.point` | Point | Move the pointer or the focus. |
| `IN.activate` | Activate | Invoke the focused control. |
| `IN.select` | Select | Select a piece of the side to move. |
| `IN.move` | Move | Place an own piece of the side to move on a legal destination. Includes pick-and-drag from an unselected piece. |
| `IN.deselect` | Clear selection | Clear `GS.selectedPiece` on shared-play or puzzle-play without asking for a move. In `EX.promote`, dismiss the choice and leave the pawn selected. |

## Bindings

| ID | Platform | Input | Action |
|----|----------|-------|--------|
| B1 | Web | Tap on a control | `IN.activate` |
| B2 | Web | Tap an own piece that is not the selection (play) | `IN.select` |
| B3 | Web | Tap a legal destination while a piece is selected (play) | `IN.move` |
| B4 | Web | Tap Confirm in an exception | `IN.confirm` |
| B5 | Web | Tap Cancel / Dismiss in an exception | `IN.cancel` |
| B6 | Web | Tap Back | `IN.back` |
| B7 | Web | Pointer moved over, or focus moved to, a control | `IN.point` |
| B8 | Web | Tap the selected piece (play) | `IN.deselect` |
| B9 | Web | Tap an empty square that is not a legal destination, while a piece is selected (play) | `IN.deselect` |
| B10 | Web | Drag an own piece onto a legal destination (play); may start unselected | `IN.move` |
| B11 | Web | Release a drag of an own piece on an illegal square, an empty non-destination, or off the board (play) | `IN.deselect` |

No camera bindings — [camera-controls.md](../view/camera-controls.md) has none.

## Focus

- **F1**: On each screen, focus follows that screen's controls table top to bottom. Pointer activation hits the control under the pointer. An unavailable control shows unavailable and does not activate.
