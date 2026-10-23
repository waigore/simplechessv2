# Rework for #63 — `PER.R7` coordinates

Environment: **headless**, Godot `4.7.2.stable.official.ed1daf0bf`, macOS arm64.
Build: branch `fix/63-demo-coord-labels` on `origin/main` `16e197b`.

The verification comment on #63 failed the build because the rank numerals were
painted inside the a-file squares (x 74–80 px; squares start at x 72), leaving
the left wooden band empty. Three causes, all in `demos/shared-game/`:

1. `CoordLabels.spots()` put the left band at canvas x `0..0.16` while the drawn
   band is board x `-RIM_OUTER..-RIM_OUTER+0.16` — the reported ~11 px shift.
2. `text_rect()` took `spot["at"]` in canvas **pixels** but computed the box for
   a **unit-scaled** string: the ink landed ~63 px below and ~11 px left of the
   band.
3. The lip (`RIM_OUTER = 0.10`) was shallower than the 0.16-unit band, so the
   band itself overlapped the a-file and rank-1 squares by 0.06 unit.

The fix, the measurements and the guard self-tests: [rework.md](rework.md).
Pipeline findings: [findings.md](findings.md).
