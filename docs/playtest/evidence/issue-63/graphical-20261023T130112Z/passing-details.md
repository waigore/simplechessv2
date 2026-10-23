# Passing details — issue #63 acceptance run (graphical)

Measurements from the same run as [notes.md](notes.md) that do not bear on the
`PER.R7` failure.

- `AES.P2` rendered bodies, read from the exercise screenshot (`measure_pieces.py` from the
  earlier `graphical-20261023T113000Z` folder): every body inside `SPC.E1`, King 0.85,
  each type within one raster pixel of `FRM.P2`.
- `AES.P3`: board fills are `PAL.C2` 47% / `PAL.C1` 45.5% of the 8×8; the bottom lip is
  `PAL.C5`; no neutral-grey or blue chrome above 0.2% of the board; rose `PAL.C8` appears
  only in the mate frame (check/end).
- #456 end-panel regression: panel `x 41–678` inside the 720 px frame, `z 10`, margins
  230/160.
- Headless exit logs `ObjectDB instances leaked at exit` — engine shutdown noise.
- The `AES.P1` "0–4 ms" line in the README and logs times the tween start, not the 150 ms
  travel; the constant `TRAVEL_S = 0.15` is what meets `MOT.T1`.
