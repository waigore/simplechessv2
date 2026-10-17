# Controls

Authoring rules: [`.agents/specs/rules/ux/controls.md`](../../.agents/specs/rules/ux/controls.md).

## UI actions

| ID | Action | Meaning |
|----|--------|---------|
| `IN.confirm` | Confirm | Accept the focused choice. |
| `IN.cancel` | Cancel | Dismiss without accepting. |
| `IN.back` | Back | Return to the previous screen. |
| `IN.point` | Point | Move the pointer or the focus. |
| `IN.activate` | Activate | Invoke the focused control. |
| `IN.select` | Select | Select a piece or square under the pointer. |
| `IN.move` | Move | Place the selected piece on the pointed square. |

## Bindings

| ID | Platform | Input | Action |
|----|----------|-------|--------|
| B1 | Web | Tap on a control | `IN.activate` |
| B2 | Web | Tap on a piece or occupied square (play) | `IN.select` |
| B3 | Web | Tap on a destination square while a piece is selected | `IN.move` |
| B4 | Web | Tap Confirm in an exception | `IN.confirm` |
| B5 | Web | Tap Cancel / Dismiss in an exception | `IN.cancel` |
| B6 | Web | Tap Back | `IN.back` |

No camera bindings — [camera-controls.md](../view/camera-controls.md) has none.

## Focus

- **F1**: On each screen, focus follows that screen's controls table top to bottom. Pointer activation hits the control under the pointer. An unavailable control shows unavailable and does not activate.
