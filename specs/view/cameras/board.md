# Camera: Board

Authoring rules: [`.agents/specs/rules/view/cameras.md`](../../../.agents/specs/rules/view/cameras.md).

- **Kind**: fixed
- **Used in**: [FL-mode-pick.P2](../../design/flows/mode-pick.md), [FL-mode-pick.P3](../../design/flows/mode-pick.md) (Shared game and Puzzle stream play)
- **Projection**: [PRJ.P1](../projection.md)
- **Diagram**: [`../diagrams/cameras/board.html`](../diagrams/cameras/board.html)
- **Serves**: Clear board, Cafe calm. Fixed board embodiment in [view.md](../view.md).
- **Glossary terms**: [Camera](../glossary.md), [Frame](../glossary.md)

## Framing

| ID | Element | Value |
|----|---------|-------|
| F1 | Target | Board center (4, 4) in [SPC](../spatial-model.md) units |
| F2 | Rest | Board centered at frame center; 1-unit margin on the short axis and extra cafe background on the long axis ([PRJ.V1](../projection.md)) |
| F3 | Offset | None — looking straight at the board plane |
| F4 | Dead zone | None — camera does not follow motion |
| F5 | Lookahead | None |

## Motion

| ID | Behavior | Value |
|----|----------|-------|
| M1 | Follow | None — camera stays fixed while pieces move |
| M2 | Orientation | Shared game: [White seat](../../design/glossary.md) Top → rotate 180° about F1 so White’s near edge faces Top; Bottom → 0°. Puzzle: [Solving side](../../design/glossary.md) Black → 180°; White → 0°, so that side’s near edge faces the player |

## Limits

| ID | Limit | Value |
|----|-------|-------|
| L1 | Bounds | Stay on [SPC.B1](../spatial-model.md); no pan past the board |
| L2 | Zoom | Fixed to [PRJ.P1](../projection.md) short-axis extent |

## Occlusion

| ID | When blocked | Response | Recovery |
|----|--------------|----------|----------|
| O1 | N/A — open table | No scenery between camera and board | — |

## Transitions

| ID | To or from | Trigger | Cut or blend (s) | Carries over |
|----|------------|---------|------------------|--------------|
| T1 | None (mode pick) ↔ CAM-board | Enter on [FL-mode-pick.T1](../../design/flows/mode-pick.md) or [T2](../../design/flows/mode-pick.md); leave on [T3](../../design/flows/mode-pick.md) or [T4](../../design/flows/mode-pick.md) | Cut 0 s | None |

## Effects

| ID | Effect | Trigger | Magnitude and duration | Comfort option |
|----|--------|---------|------------------------|----------------|
| E1 | None | — | No shake or zoom punch | N/A — no comfort option needed |

## Player control

| ID | Camera action | Effect in this camera |
|----|---------------|-----------------------|
| P1 | None | Player cannot move this camera ([camera-controls.md](../camera-controls.md)) |

## Experience intent

A quiet fixed table view. Orientation favors the White-seat player in a Shared game and the Solving side in a Puzzle without asking anyone to walk around the device.
