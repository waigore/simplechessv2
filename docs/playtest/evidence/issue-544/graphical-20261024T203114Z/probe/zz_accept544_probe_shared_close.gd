extends Node
## How much real frame evidence a closing window keeps (D2 / AC 6).

var _router: Node
var _seams: Node

func _ready() -> void:
	await get_tree().process_frame
	_seams = get_node_or_null("../Presentation/PlaytestSeams")
	_router = get_node_or_null("../Presentation/SessionRouter")
	for _i in 90:
		await get_tree().process_frame
	# loading_ready: arm while loading is still ahead is not possible post-boot,
	# so judge the passing window: jump back to loading through the seam, arm, then
	# return to mode pick.
	_seams.jump("loading")
	await get_tree().process_frame
	_seams.jump("mode-pick")
	for _i in 3:
		await get_tree().process_frame
	print("ZZ live last-report-after-loading=%s" % JSON.stringify(_report(_seams.measurement.last())))
	_router.handle_control("mode-pick", "C1")
	for _i in 8:
		await get_tree().process_frame
	_router.handle_control("shared-setup", "C5")
	for _i in 8:
		await get_tree().process_frame
	var armed: Dictionary = _seams.start_measurement("frame_times")
	print("ZZ armed=%s" % JSON.stringify(_report(armed)))
	for step in 6:
		await get_tree().process_frame
	var move := _first_legal(str(armed.get("solver", "")))
	print("ZZ move=%s" % move)
	_router.handle_input_commit(move.substr(0, 2), move.substr(2, 2))
	var seen := -1
	for step in 20:
		await get_tree().process_frame
		var last: Dictionary = _seams.measurement.last()
		if seen < 0 and str(last.get("status", "")) == "ok" and int(last.get("sample_count", 0)) > 0:
			seen = step
	print("ZZ after-move last=%s armed=%s" % [JSON.stringify(_report(_seams.measurement.last())), str(_seams.measurement.is_armed())])
	get_tree().quit(0)

func _report(report: Dictionary) -> Dictionary:
	return {"kind": report.get("kind", ""), "status": report.get("status", ""), "sample_count": int(report.get("sample_count", 0)), "max_ms": float(report.get("max_ms", 0.0)), "detail": report.get("detail", ""), "armed": report.get("armed", null) != null}

func _first_legal(side: String) -> String:
	var snap: Dictionary = _router.play_snapshot()
	var pos: Variant = snap.get("position")
	if not (pos is Dictionary):
		return ""
	var occupancy: Dictionary = pos["occupancy"]
	var files := ["a", "b", "c", "d", "e", "f", "g", "h"]
	for f in 8:
		for r in 8:
			var square := "%s%d" % [files[f], r + 1]
			var piece: Variant = occupancy.get(square, "")
			if not (piece is Dictionary) or str(piece.get("color", "")) != side:
				continue
			for target in _router.legal_targets_for(square):
				if _router.can_place(square, target):
					return "%s%s" % [square, target]
	return ""
