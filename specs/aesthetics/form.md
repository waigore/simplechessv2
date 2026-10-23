# Form

Authoring rules: [`.agents/specs/rules/aesthetics/form.md`](../../.agents/specs/rules/aesthetics/form.md).

- **Reference sheet**: [`sheets/lineup.html`](sheets/lineup.html)
- **Serves**: P2; Clear board; [PER.R1](../view/perception.md); [E-pieces](../design/entities/pieces.md); [SPC.E1](../view/spatial-model.md)

## Shape language

| ID | Shape family | Signals | Used by |
|----|--------------|---------|---------|
| S1 | Staunton-inspired vector | Classic chess piece identity; calm table set | All six [Piece](../design/glossary.md) types ([E-pieces](../design/entities/pieces.md)) |
| S2 | Rectangular grid | Stable board plane | Light and dark squares ([E-pieces.I35](../design/entities/pieces/common.md)) |

## Proportions

| ID | Subject | Rule |
|----|---------|------|
| P1 | Piece body | Every type's body is centered on the square and drawn within [SPC.E1](../view/spatial-model.md) (0.85 × 0.85): it may be narrower or shorter than the extent but never wider, taller, or spilling into neighbors. The King reaches the full 0.85 height; each shorter type keeps its narrower base inside the same 0.85 width, centered on the same ground line |
| P2 | Piece height order | King tallest, then Queen, then Rook / Bishop / Knight band, Pawn shortest — crown and height cues reinforce type. All heights stay within the [SPC.E1](../view/spatial-model.md) extent per P1, so [PER.R1](../view/perception.md) readability is measured at the tallest (King) height of 0.85 |

## Silhouette

| ID | Must be told apart | Smallest on-screen size | Test |
|----|--------------------|------------------------|------|
| L1 | King, Queen, Rook, Bishop, Knight, Pawn | Drawn height of [SPC.E1](../view/spatial-model.md) (0.85 units) under [PRJ.V1](../view/projection.md): ≥ about 1/21 of frame height at 9:16 and ≥ about 1/12 at 16:9 (Web touch; [view.md](../view/view.md) platform; [PRJ.P1](../view/projection.md)) | Each type named from a solid-black silhouette at that size ([PER.R1](../view/perception.md)) |

## Detail

| ID | Size class or distance | Detail allowed |
|----|------------------------|----------------|
| D1 | Board play size | Clean vector contours; few interior lines; at most three distinct fill regions per piece (body, accent, outline) |
| D2 | Overlay marks | Flat shapes; no texture that hides piece silhouette ([PER.R1](../view/perception.md), [PER.R5](../view/perception.md)) |
