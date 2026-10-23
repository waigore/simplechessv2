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
| P1 | Piece body | The opaque body, not the transparent canvas, is drawn inside the [SPC.E1](../view/spatial-model.md) box (0.85 × 0.85) centered on the square. One uniform scale for every type, set so the King's opaque height is 0.85 of the square. No stretch and no per-type rescale. Every body stands on the bottom edge of that box. A body may be narrower than 0.85 and must not be wider, taller, or spilling into a neighbor |
| P2 | Piece height order | Opaque height as a fraction of one square ([SPC.U1](../view/spatial-model.md)), ±0.01: King 0.85, Queen 0.79, Bishop 0.76, Knight 0.75, Rook 0.68, Pawn 0.62. That order is tallest to shortest. [PER.R1](../view/perception.md) is measured at the King's 0.85 |

## Silhouette

| ID | Must be told apart | Smallest on-screen size | Test |
|----|--------------------|------------------------|------|
| L1 | King, Queen, Bishop, Knight, Rook, Pawn | King at [SPC.E1](../view/spatial-model.md) (0.85 units) under [PRJ.V1](../view/projection.md): ≥ about 1/21 of frame height at 9:16 and ≥ about 1/12 at 16:9 (Web touch; [view.md](../view/view.md) platform; [PRJ.P1](../view/projection.md)). Other types at their P2 heights in that same lineup | Each type named from a solid-black silhouette ([PER.R1](../view/perception.md)) |

## Detail

| ID | Size class or distance | Detail allowed |
|----|------------------------|----------------|
| D1 | Board play size | Clean vector contours; few interior lines; at most three distinct fill regions per piece (body, accent, outline) |
| D2 | Overlay marks | Flat shapes; no texture that hides piece silhouette ([PER.R1](../view/perception.md), [PER.R5](../view/perception.md)) |
