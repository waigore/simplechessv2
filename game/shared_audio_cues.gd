class_name SharedAudioCues
extends RefCounted
## L2 holder for Shared-game cue / bed asset IDs (#60).
## Passed through CTR-presentation.O3; L1 must not be the source of these IDs.

## SND.X1–X4 (Play group).
const CUE_SELECT := "01a151f8-b7d8-7ae6-84af-767ba53d09f6"
const CUE_MOVE := "01a151f8-b7d8-710a-b767-92c9137bfd63"
const CUE_CHECK := "01a151f8-b7d8-7e05-9921-e892e9a2e064"
const CUE_END := "01a151f8-b7d8-7fe3-b94f-e3a562395d96"
## SND.X5 — the wrong-puzzle-move tap (#333; Puzzle group). Never plays in shared play.
const CUE_X5 := "01a151f8-b7d8-759c-89c5-e1be5eecb2b2"
## SND.M1 starts the Ambient playlist (M1 → M2 → M1) via O3.
const BED_M1 := "01a15200-69b2-7d13-a30d-696fa4ff390b"
const BED_M2 := "01a15200-69b2-7964-a602-ad5b19583125"
