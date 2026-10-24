extends Node
## Can any argument to `measure()` reach a window that closed by itself?

var _router: Node
var _seams: Node

func _ready() -> void:
	await get_tree().process_frame
	_seams = get_node_or_null("../Presentation/PlaytestSeams")
	_router = get_node_or_null("../Presentation/SessionRouter")
	for _i in 90:
		await get_tree().process_frame
	for kind in ["frame_times", "", "loading_ready", "bogus"]:
		_router.handle_control("mode-pick", "C1")
		for _i in 6:
			await get_tree().process_frame
		_router.handle_control("shared-setup", "C5")
		for _i in 6:
			await get_tree().process_frame
		var armed: Dictionary = _seams.start_measurement("frame_times")
		if str(armed.get("status", "")) != "ok":
			print("ZZ kind=%s arm_refused=%s" % [kind, str(armed.get("detail", ""))])
			continue
		var move := _first_legal("white")
		_router.handle_input_commit(move.substr(0, 2), move.substr(2, 2))
		for _i in 12:
			await get_tree().process_frame
		var got: Dictionary = _seams.measure(kind)
		print("ZZ kind=%s -> status=%s detail=%s samples=%d last_status=%s last_samples=%d" % [kind, str(got.get("status","")), str(got.get("detail","")), int(got.get("sample_count",0)), str(_seams.measurement.last().get("status","")), int(_seams.measurement.last().get("sample_count",0))])
		_router.jump("mode-pick") if false else null
		_seams.measure("")
		_router._go_mode_pick()
	get_tree().quit(0)

func _first_legal(side: String) -> String:
	var snap: Dictionary = _router.play_snapshot()
	var pos: Variant = snap.get("position")
	if not (pos is Dictionary):
		return ""
	var occ: Dictionary = pos["occupancy"]
	var files := ["a", "b", "c", "d", "e", "f", "g", "h"]
	for f in 8:
		for r in 8:
			var sq := "%s%d" % [files[f], r + 1]
			var piece: Variant = occ.get(sq, "")
			if not (piece is Dictionary) or str(piece.get("color", "")) != side:
				continue
			for t in _router.legal_targets_for(sq):
				if _router.can_place(sq, t):
					return "%s%s" % [sq, t]
	return ""
