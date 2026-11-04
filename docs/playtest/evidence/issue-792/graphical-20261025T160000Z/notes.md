# Notes — #792 mark-form capture

## What this frame is

One composed position so all eight mark forms appear at once, at the narrowest viewport
`PRJ.P1` names (360 × 640, 36 px a square):

- White: pawn e2 (selected), rook a1 (moved to b3), queen f7 (giving check)
- Black: king e8 (checked), knight c6 (capture destination)
- Legal destinations `e3`, `e4` empty, `c6` capture; refused place `d2`
- Advice best move `d5`–`e4`; last move `a1`–`b3`

The board is `BoardPresentation` with the real `play` asset group bound, so the pieces,
the frame art, and the coordinate chips are the shipping art. The window runs with
`content_scale_mode` disabled: with the project's canvas stretch the canvas is 1280 wide
and the capture would be a downscale of it, not a 36 px-square frame.

## What the frame shows that a pixel measure does not

- **Capture brackets at 0.56 read close to a frame.** Eight strokes of 0.06 with 0.56
  arms on a 0.94 edge overlap along each edge, so the four corner pairs nearly close.
  The geometry is the task body's stated size (conflict 1 records that `rules-k9.md`
  states a `1/4` bound with no size for this form); the corner pairs stay four distinct
  strokes in the tree, and the selection ring is still the only closed `Line2D`.
- **The check L-frames are small.** At 36 px a square the 0.20 / 0.10 arms are 7.2 and
  3.6 px, so each cream plate with its `C9` keyline is the readable part at phone width —
  which is what `PAL.K9`'s *Layer split* asks the foreground to do.
- **The from-square band is quiet.** Three `PAL.C7` layers at 16 / 30 / 52% over the
  outer 0.09 of the edge; at this size it reads as a field, not a stroke, per `PER.R9`.
- **The cream foreground separates by keyline, not fill.** C10 on the light square is
  1.28:1; the `C9` keyline at 1.5 px is what draws every cream mark's edge.
