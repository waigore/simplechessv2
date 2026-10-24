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


## `S13` frame limbs (I6). A drive op can always say whether a display exists;
## a real frame height is the seam's own, which it has only once it entered the
## tree. Reporting a frame the seam cannot see is what `S13` forbids.
static func has_display() -> bool:
	return not DisplayServer.get_name() == "headless"


## Whether the seam has entered a tree yet; before that it holds no frame size.
static func in_frame(seam: Node) -> bool:
	return seam.is_inside_tree() and seam.get_tree() != null


## The height the layout renders into: the running window, so `S13` reports the
## frame the shipped layout actually reflowed to. A headless runner keeps the
## engine placeholder size, so it names none rather than a frame nothing renders.
static func frame_height(seam: Node) -> float:
	if not in_frame(seam) or not has_display():
		return 0.0
	return float(seam.get_tree().root.size.y)
