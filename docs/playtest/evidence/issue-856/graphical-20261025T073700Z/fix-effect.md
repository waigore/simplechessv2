# The fix's own effect, measured on equal transfers

Published (with the Pages transfer) and the two localhost exports are not directly
comparable, so the fix is read as base-export ↔ fix-export — same commit's bytes, same
localhost server, same host, minutes apart:

| Arm (`69a03d4` code) | cold mode pick | warm |
|---|---|---|
| base (no #877) | 1442 / 1225 / 1257 / 1222 ms | 901 ms |
| fix (`79d5780`, #877) | 844 / 883 / 1032 / 1053 ms | 653 ms |

0.17–0.60 s earlier on every pair, with the two arms differing only in
`_start_music_after_paint`.

The published page still serves `69a03d4`, because `Web release` has not republished since
#877 merged; the next release run publishes the ordering that measures 0.2–0.6 s earlier.
This folder measures the ordering on the fix export, not on the published page.

## Screenshots

`pub-*` and `fix-*` are the same five states from each build: loading at 600 ms, mode pick,
warm mode pick, Shared game setup after the mode tap, and the puzzle board after the warm
mode tap. Both builds are the same scene; the pages differ only by #877 and by how they are
served.
