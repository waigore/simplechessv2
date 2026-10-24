extends Node
## Acceptance probe for #544 (throwaway, not committed): boots the real
## `main.tscn` playtest build and exercises `S11` / `O10` through the live seam
## wiring — real snapshot provider, real frame source, no fakes.
##
## Navigation is the player's own: `loading_ready` is armed before boot finishes,
## shared play is entered from mode pick `C1` -> `C5`, and every move is committed
## through `handle_input_commit` so the move path is untouched (`G3`).

var _failures: Array[String] = []
var _router: Node
var _seams: Node


func _ready() -> void:
	# Frame 0: arm the loading window while the router is still loading.
	_seams = get_node_or_null("../Presentation/PlaytestSeams")
	_router = get_node_or_null("../Presentation/SessionRouter")
	if _seams == null or _router == null:
		_print_fail("no PlaytestSeams / SessionRouter under Presentation (release build?)")
		get_tree().quit(1)
		return
	print("PROBE stage_at_arm=%s" % str(_router.stage))
	var loading_armed: Dictionary = _seams.start_measurement("loading_ready")
	print("PROBE loading_arm=%s" % _mini(loading_armed))
	if str(loading_armed.get("status", "")) != "ok":
		_print_fail("loading_ready arm at open refused: %s" % str(loading_armed.get("detail", "")))
		loading_armed = {}
	var observed := 0
	while str(_router.stage) == "loading" and observed < 600:
		await get_tree().process_frame
		observed += 1
	print("PROBE loading_frames_observed=%d stage=%s" % [observed, str(_router.stage)])
	if not loading_armed.is_empty():
		var loading_report: Dictionary = _seams.measure("loading_ready")
		print("PROBE loading_report=%s" % JSON.stringify(_short(loading_report)))
		_judge_ok("loading_ready", loading_report)
	await _frame_times_shared()
	if _failures.is_empty():
		print("ACCEPT544_PROBE pass")
		get_tree().quit(0)
	else:
		for failure in _failures:
			print("ACCEPT544_PROBE fail: %s" % failure)
		get_tree().quit(1)


func _frame_times_shared() -> void:
	_router.handle_control("mode-pick", "C1")
	await _frames(10)
	if str(_router.stage) == "shared-setup":
		_router.handle_control("shared-setup", "C5")
		await _frames(10)
	print("PROBE shared_stage=%s" % str(_router.stage))
	if str(_router.stage) != "shared-play":
		_print_fail("could not reach shared-play through the controls (stage=%s)" % str(_router.stage))
		return
	var armed: Dictionary = _seams.start_measurement("frame_times")
	print("PROBE shared_arm=%s" % _mini(armed))
	if str(armed.get("status", "")) != "ok":
		_print_fail("frame_times/shared arm refused: %s" % str(armed.get("detail", "")))
		return
	var open := false
	for step in 6:
		await get_tree().process_frame
		var still: bool = _seams.measurement.is_armed()
		print("PROBE shared_frame%d armed=%s fields=%s" % [step, str(still), JSON.stringify(_play_fields())])
		if not still:
			var early: Dictionary = _seams.measurement.last()
			_print_fail("window closed before the move on frame %d: %s" % [step, JSON.stringify(_short(early))])
			return
		open = true
	if not open:
		return
	var move := _first_legal(str(armed.get("solver", "")))
	if move.is_empty():
		_print_fail("no legal move for %s on the live board" % str(armed.get("solver", "")))
		_seams.measure("")
		return
	print("PROBE shared_move=%s" % move)
	var committed: bool = _router.handle_input_commit(move.substr(0, 2), move.substr(2, 2))
	print("PROBE shared_committed=%s after=%s" % [str(committed), JSON.stringify(_play_fields())])
	await _frames(15)
	var report: Dictionary = _seams.measure("")
	print("PROBE shared_report=%s" % JSON.stringify(_short(report)))
	_judge_ok("frame_times/shared", report)


func _first_legal(side: String) -> String:
	var snap: Dictionary = _router.play_snapshot()
	var pos: Variant = snap.get("position")
	if not (pos is Dictionary):
		return ""
	var occupancy: Dictionary = pos["occupancy"]
	var files := ["a", "b", "c", "d", "e", "f", "g", "h"]
	for file_index in 8:
		for rank in 8:
			var square := "%s%d" % [files[file_index], rank + 1]
			var piece: Variant = occupancy.get(square, "")
			if not (piece is Dictionary):
				continue
			if str(piece.get("color", "")) != side:
				continue
			for target in _router.legal_targets_for(square):
				if _router.can_place(square, target):
					return "%s%s" % [square, target]
	return ""


func _play_fields() -> Dictionary:
	var snap: Dictionary = _router.play_snapshot()
	var out := {
		"stage": snap.get("stage", ""),
		"mode": snap.get("mode", ""),
	}
	var pos: Variant = snap.get("position")
	if pos is Dictionary:
		out["side_to_move"] = pos.get("side_to_move", "")
		out["pieces"] = (pos.get("occupancy", {}) as Dictionary).size()
	return out


func _judge_ok(label: String, report: Dictionary) -> void:
	var status := str(report.get("status", ""))
	if status != "ok":
		_print_fail("%s did not close: status=%s detail=%s" % [label, status, str(report.get("detail", ""))])
		return
	if int(report.get("sample_count", 0)) <= 0:
		_print_fail("%s closed with no samples" % label)
	if float(report.get("max_ms", 0.0)) <= 0.0:
		_print_fail("%s closed with max_ms 0.0" % label)


func _frames(count: int) -> void:
	for _index in count:
		await get_tree().process_frame


func _short(report: Dictionary) -> Dictionary:
	var copy := report.duplicate(true)
	copy.erase("armed")
	var samples: Array = copy.get("samples", [])
	copy["samples_first"] = samples.slice(0, 5)
	copy["samples_total"] = samples.size()
	copy.erase("samples")
	return copy


func _mini(report: Dictionary) -> String:
	return JSON.stringify({
		"kind": report.get("kind", ""),
		"mode": report.get("mode", ""),
		"status": report.get("status", ""),
		"detail": report.get("detail", ""),
		"solver": report.get("solver", ""),
	})


func _print_fail(message: String) -> void:
	_failures.append(message)
