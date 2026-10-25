# Render / measurement log — #640 review run

Every number in [`../notes.md`](../notes.md) and [`../manifest.md`](../manifest.md) is
reproducible from this folder. Scripts are dependency-free (Node 22+; no packages).
Readings: [`readings.md`](readings.md). Source: [`source-validation.md`](source-validation.md).

## How to reproduce

```sh
node run.mjs https://waigore.github.io/simplechessv2/ .   # capture the published board
node read.mjs .                                          # geometry, swatches, K1
node piece.mjs ../../../../game_assets .                  # K2 crops, both simulations
node render.mjs ../../../../game_assets screenshots 39    # FRM.L1 sheet body
node label.mjs .                                          # labels A–F
```

`capture.json` holds the capture sequence; `readings.json` every measurement;
`screenshots/sheet.json` the sheet geometry.

## Scripts

| File | Job |
|---|---|
| `cdp.mjs` | dependency-free Chrome DevTools Protocol driver (same shape as the #845 run's) |
| `png.mjs` | PNG decoder (from the #845 run) |
| `measure.mjs` | colour maths, simulations, board finder, silhouette sheet, PNG writer |
| `run.mjs` | drives the browser to the board and captures the control |
| `read.mjs` | board geometry, drawn swatches, K1 in both simulations |
| `piece.mjs` | K2 crops at judged pixel size, both simulations |
| `render.mjs` | the `FRM.L1` silhouette sheet body |
| `label.mjs` | the six anonymous labels A–F |

## Sheet

600 × 328 px; unit 120 px; ground line y 264; opaque heights King 102, Queen 95, Bishop
91, Knight 89, Rook 82, Pawn 74 px. See [`../screenshots/silhouette-naming.md`](../screenshots/silhouette-naming.md).

## Frame stability

`screenshots/board-control.png` and `board-control-b.png` are 1.2 s apart and
**pixel-identical** (empty difference), so the capture is an idle board, not a frame
mid-repaint.

## Console

`capture-console.log` holds the Godot banner and one SwiftShader `GPU stall due to
ReadPixels` performance warning; no preload or asset-open line appears.
