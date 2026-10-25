# View Glossary

Authoring rules: [`.agents/specs/rules/view/glossary.md`](../../.agents/specs/rules/view/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Board camera | The fixed play camera framing the 8×8 board | [`cameras/board.md`](cameras/board.md) |
| Board orientation | 0° or 180° board framing so the White seat in a Shared game or the Solving side in a Puzzle faces its player | [`cameras/board.md`](cameras/board.md) |
| Camera | One way the view is positioned and moved through the world. | [`cameras/`](cameras/) |
| Camera action | A named command the player uses to move the camera, such as orbit. | [`camera-controls.md`](camera-controls.md) |
| Dead zone | The part of the frame the target can move within without the camera moving. | [`cameras/board.md`](cameras/board.md) |
| Diagram | A to-scale HTML drawing of the projection or of one camera. | [`diagrams/`](diagrams/) |
| Frame | The rectangle of the world shown on the player's display at one moment. | [`projection.md`](projection.md) |
| Last-move band | The soft C7 band on the from-square of the last move, blurred and without a hard stroke, so it reads as a field rather than a mark. | [`perception-marks.md`](perception-marks.md) |
| Last-move ticks | The two C10 corner Ls on the to-square of the last move, on a C9 keyline, set in the corners facing the from-square. | [`perception-marks.md`](perception-marks.md) |
| Listener | The point in the world from which the player hears positional sound. | [`audio.md`](audio.md) |
| Lookahead | How far ahead of a moving target the camera leads the framing. | [`cameras/board.md`](cameras/board.md) |
| Offset | A shift of the camera’s aim away from the board center to reframe the board. | [`cameras/board.md`](cameras/board.md) |
| Projection | The rule that turns world space into the image on the display. | [`projection.md`](projection.md) |
| Safe area | The inner 90% of the frame that selection, legal-move and Advice marks, and piece identities stay inside. | [`projection.md`](projection.md) |
| Visible area | The extent of the world, in world units, inside the frame. | [`projection.md`](projection.md) |
| World unit | The unit of distance in the game world; here one square edge. | [`spatial-model.md`](spatial-model.md) |
