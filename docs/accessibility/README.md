# Accessibility review runs

Rendered-surface accessibility reviews that are outside playtest protocol scope — no
`SIT.*` row, no `PTU-*` protocol, no playtest folder ([`playtest.md`](../../specs/playtest/playtest.md)
Gate; [`evidence.md`](../../specs/playtest/evidence.md) line 9). The run folder borrows the
`evidence-manifest.md` field names so the consuming gate can read it beside its own folders.

| Issue | Run | What it judged |
|---|---|---|
| #640 | [`issue-640/review-20261025/`](issue-640/review-20261025/manifest.md) | `PER.R1` (shape naming), `PAL.K1` (square lightness), `PAL.K2` (piece side) on the shipped build |
