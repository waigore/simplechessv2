# `PER.R1` — the shape claim (#640)

Parent: [`../notes.md`](notes.md) · sheet: [`../screenshots/silhouette-naming.md`](screenshots/silhouette-naming.md) · key: [`../logs/key.md`](logs/key.md)

## Clause ownership

`PER.R1` states four things; only the first two are judged by #640, so a `pass` here is
never a `pass` on the whole rule.

| `PER.R1` clause | Owner |
|---|---|
| Each type named from a solid-black silhouette at its `FRM.P2` height | **#640** — six of six named correctly |
| The King is 0.85 units under `PRJ.V1` (≥ about 1/21 of frame height at 9:16) | **#640** — 102 px = `1/20.94` of a 9:16 frame |
| Identities stay inside `PRJ.A2` (inner 90% of the frame) | **not judged** — a safe-area bound is not a shape test; #641 owns the simulated board |
| Overlays cover ≤ 10% of the body | **not judged** — overlay coverage is #641's mark leg |

## The shape claim — `pass`

- **Viewport ratio 9:16** (`PRJ.V1`: 10 units short axis, 17.8 long axis), the binding
  case (`1/21` of frame height). **DPR 1**: a still render of shipped art at a 120 px
  unit, so the notional frame is 1 200 × 2 136 px; the sheet shows the lineup band
  (600 × 328 px), not the whole frame.
- **Rendered opaque heights:** King **102 px**, Pawn **74 px**; Queen 95, Bishop 91,
  Knight 89, Rook 82. King / frame `= 102/2136 = 1/20.94` meets `FRM.L1`; Pawn / King
  `= 0.725` against `FRM.P2`'s `0.62/0.85 = 0.729`, inside the `±0.01` allowance once
  integer rounding is allowed for.
- **Solid black over the whole opaque body**, including the band `SRF.O1` would outline
  (alpha is the only mask), so no contour or highlight leaks side.
- **One uniform scale for every type** (`FRM.P1`), each sprite at its own `FRM.P2`
  height — not a per-sprite box fit.
- **Shipped art only:** the twelve `piece-sprites/*` entries under `asset_catalog/` and
  `game_assets/` (ADR-0005), traced twice in the naming record; nothing from `demos/`.
- **Blind read:** one reader named all six types from the sheet alone, **six of six**
  correct, key stated after the verdicts ([`../logs/reader-transcript.md`](logs/reader-transcript.md)).

No `PER.R1` naming row failed, so nothing is filed under this element.
