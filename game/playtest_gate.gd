class_name PlaytestGate
extends RefCounted
## CTR-playtest-drive.G2 — whether this process is a playtest build.
## Both playtest nodes ask this before doing anything, so a release export
## never reaches the seam scripts: `main.tscn` carries the nodes,
## `main_release.tscn` does not. The `release` feature reaches Web export
## templates; `playtest_override` is ignored there. Headless, editor, and the
## `Web Playtest` build run seams.


static func is_playtest(override: int = -1) -> bool:
	if OS.has_feature("playtest"):
		return true
	if OS.has_feature("release"):
		return false
	if override >= 0:
		return override == 1
	return true
