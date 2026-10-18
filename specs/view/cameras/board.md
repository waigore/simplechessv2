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
| F2 | Rest | Board fills the frame per [PRJ.V1](../projection.md); center at frame center |
| F3 | Offset | None — looking straight at the board plane |
| F4 | Dead zone | None — camera does not follow motion |
| F5 | Lookahead | None |

## Motion

| ID | Behavior | Value |
|----|----------|-------|
| M1 | Follow | None — camera stays fixed while pieces move |
| M2 | Seat flip | When [White seat](../../design/glossary.md) is Top player, rotate the framed board 180° about F1 so White’s near edge faces Top; when Bottom, no rotation |

## Limits

| ID | Limit | Value |
|----|-------|-------|
| L1 | Bounds | Stay on [SPC.B1](../spatial-model.md); no pan past the board |
| L2 | Zoom | Fixed to [PRJ.P1](../projection.md) visible height |

## Occlusion

| ID | When blocked | Response | Recovery |
|----|--------------|----------|----------|
| O1 | N/A — open table | No scenery between camera and board | — |

## Transitions

| ID | To or from | Trigger | Cut or blend (s) | Carries over |
|----|------------|---------|------------------|--------------|
| T1 | Enter / leave play | Mode pick ↔ play ([FL-mode-pick](../../design/flows/mode-pick.md)) | Cut 0 | None |

## Effects

| ID | Effect | Trigger | Magnitude and duration | Comfort option |
|----|--------|---------|------------------------|----------------|
| E1 | None | — | No shake or zoom punch | N/A — no comfort option needed |

## Player control

| ID | Camera action | Effect in this camera |
|----|---------------|-----------------------|
| P1 | None | Player cannot move this camera ([camera-controls.md](../camera-controls.md)) |

## Experience intent

A quiet fixed table view. Orientation always favors the White-seat player without asking anyone to walk around the device.
