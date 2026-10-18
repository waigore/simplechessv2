# View Glossary

Authoring rules: [`.agents/specs/rules/view/glossary.md`](../../.agents/specs/rules/view/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Board camera | The fixed play camera framing the 8×8 board | [`cameras/board.md`](cameras/board.md) |
| Camera | One way the view is positioned and moved through the world. | [`cameras/`](cameras/) |
| Camera action | A named command the player uses to move the camera, such as orbit. | [`camera-controls.md`](camera-controls.md) |
| Dead zone | The part of the frame the target can move within without the camera moving. | the camera spec |
| Diagram | A to-scale HTML drawing of the projection or of one camera. | [`diagrams/`](diagrams/) |
| Frame | The rectangle of the world shown on the player's display at one moment. | [`projection.md`](projection.md) |
| Listener | The point in the world from which the player hears positional sound. | [`audio.md`](audio.md) |
| Projection | The rule that turns world space into the image on the display. | [`projection.md`](projection.md) |
| Safe area | The inner 90% of the frame that selection, legal-move and Advice marks, and piece identities stay inside. | [`projection.md`](projection.md) |
| Seat flip | 180° board framing so White’s near edge faces the White-seat player | [`cameras/board.md`](cameras/board.md) |
| Visible area | The extent of the world, in world units, inside the frame. | [`projection.md`](projection.md) |
| World unit | The unit of distance in the game world; here one square edge. | [`spatial-model.md`](spatial-model.md) |
