class_name PlaytestSeamsTest
extends SceneTree


func _initialize() -> void:
	if not _check_release():
		return
	if not _check_playtest():
		return
	quit(0)


func _check_release() -> bool:
	var seams := PlaytestSeams.new()
	seams.playtest_override = 0
	root.add_child(seams)
	seams.configure()
	seams.pause()
	seams.resume()
	var jump_error := seams.jump("loading")
	var viewport_report := seams.set_viewport(390, 844, 1.0)
	seams.set_overlay(true, PackedStringArray(["EX.loading"]))
	seams.set_seed(3)
	seams.record_input(true)
	seams.note_pointer({"kind": "touch"})
	seams.replay_input([{"kind": "touch"}])
	seams.emit_tel("pause", "pass", "EX.loading")
	var problem := ""
	if seams.playtest_build:
		problem = "release build kept seams"
	elif seams.session_id.is_empty():
		problem = "missing session id"
	elif seams.is_paused():
		problem = "release pause"
	elif not seams.inspect(PackedStringArray(["stage"])).is_empty():
		problem = "release inspect"
	elif jump_error != ERR_UNAVAILABLE:
		problem = "release jump"
	elif not seams.dump_state().is_empty():
		problem = "release dump"
	elif not viewport_report.is_empty():
		problem = "S13 release viewport"
	elif not seams.last_viewport_report().is_empty():
		problem = "S13 release viewport report"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _check_playtest() -> bool:
	var seams := PlaytestSeams.new()
	seams.playtest_override = 1
	var stage := {"id": "loading"}
	var tel_events: Array = []
	root.add_child(seams)
	seams.configure()
	var problem := ""
	if not seams.playtest_build:
		problem = "playtest build off"
	elif seams.inspect(PackedStringArray(["stage"])).has("stage"):
		problem = "inspect before bind"
	if not problem.is_empty():
		return _fail(problem)
	seams.bind_state(_provider.bind(stage))
	seams.jump_requested.connect(_remember_stage.bind(stage))
	seams.tel_event.connect(_remember_tel.bind(tel_events))
	seams.register_stages(PackedStringArray(["loading", "mode-pick"]))
	if not _check_drive(seams, stage, tel_events):
		return false
	seams.record_input(true)
	seams.note_pointer(_sample_pointer())
	var recorded := _log_size(seams)
	seams.record_input(false)
	seams.note_pointer(_sample_pointer())
	var while_off := _log_size(seams)
	seams.record_input(true)
	seams.pause()
	seams.note_pointer(_sample_pointer())
	var while_paused := _log_size(seams)
	var replayed: Array = []
	seams.input_replayed.connect(_remember_replay.bind(replayed))
	seams.replay_input(seams.dump_state()["input_log"])
	var paused_replays := replayed.size()
	seams.resume()
	seams.replay_input(seams.dump_state()["input_log"])
	var after_replay := _log_size(seams)
	seams.set_seed(9)
	problem = ""
	if recorded != 1 or while_off != 1 or while_paused != 1:
		problem = "record"
	elif paused_replays != 0 or replayed.size() != 1 or after_replay != 1:
		problem = "replay"
	elif seams.seed_value != 9 or _log_size(seams) != 0:
		problem = "seed reset"
	elif not seams.dump_state().has("session_id"):
		problem = "dump beyond inspect"
	if not problem.is_empty():
		return _fail(problem)
	if not _check_debug(seams, stage):
		return false
	return _check_viewport(seams)


func _check_viewport(seams: PlaytestSeams) -> bool:
	## S13 / SIT.6 — O12 applies a viewport on ENV.2 only; the report never lies.
	var reports: Array = []
	seams.viewport_changed.connect(_remember_viewport.bind(reports))
	var phone := seams.set_viewport(
		PlaytestSeams.VIEWPORT_PHONE_WIDTH,
		PlaytestSeams.VIEWPORT_PHONE_HEIGHT,
		_frame_ratio(PlaytestSeams.VIEWPORT_PHONE_HEIGHT)
	)
	var shown := seams.last_viewport_report()
	var graphical := DisplayServer.get_name() != "headless"
	var empty := seams.set_viewport(0, 844, 1.0)
	var reference := UiChrome.scaled_px(UiChrome.BODY_PX, _frame_ratio(640))
	var phone_expected := UiChrome.scaled_px(
		UiChrome.BODY_PX, _frame_ratio(PlaytestSeams.VIEWPORT_PHONE_HEIGHT)
	)
	# UIS.T2 is a ratio to the reference height, so a taller phone frame sits above
	# BODY_PX; a hardcoded or clamped size at BODY_PX fails `scales_with_frame`.
	var scales_with_frame := phone_expected > UiChrome.BODY_PX and phone_expected > reference
	var panel_button := seams.get_node("PlaytestDebug/DebugPanel/SetViewport") as Button
	var problem := ""
	if reports.size() != 1 or phone.is_empty() or shown != phone:
		problem = "S13 viewport report"
	elif bool(phone.get("applied", false)) != graphical:
		problem = "S13 ENV.2 boundary"
	elif graphical and (int(phone["width"]) != 390 or int(phone["height"]) != 844):
		problem = "S13 applied size"
	elif not is_equal_approx(float(phone["text_scale"]), _frame_ratio(844)):
		problem = "S13 applied text scale"
	elif int(phone["body_text_px"]) != phone_expected:
		problem = "S13 body text must come from the presentation ratio"
	elif not scales_with_frame:
		problem = "S13 clamped text size (body text must scale with frame height)"
	elif not _bound_report_matches(seams):
		problem = "S13 seam must report the bound presentation size, not its own"
	elif not empty.is_empty():
		problem = "S13 invalid input must not return a report"
	elif panel_button == null:
		problem = "S13 debug panel control"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _bound_report_matches(seams: PlaytestSeams) -> bool:
	## The seam must echo the presentation hook, never compute a size of its own.
	var sentinel := 1234.0
	seams.bind_text_report(func() -> float: return sentinel)
	var bound := seams.set_viewport(390, 844, 1.0)
	seams.bind_text_report(Callable())
	return is_equal_approx(float(bound.get("body_text_px", 0.0)), sentinel)


func _frame_ratio(height_px: int) -> float:
	return Presentation.text_scale_for_frame_height(float(height_px))


func _remember_viewport(report: Dictionary, reports: Array) -> void:
	reports.append(report)


func _check_drive(seams: PlaytestSeams, stage: Dictionary, tel_events: Array) -> bool:
	var unknown := seams.jump("missing")
	var stage_after_unknown := str(stage["id"])
	var known := seams.jump("mode-pick")
	var inspected := seams.inspect(PackedStringArray(["stage", "absent"]))
	seams.emit_tel("smoke_inspect", "pass", "EX.loading")
	seams.emit_tel("note", "pass", "")
	var problem := ""
	if unknown != ERR_INVALID_PARAMETER or stage_after_unknown != "loading":
		problem = "unknown jump"
	elif known != OK or str(stage["id"]) != "mode-pick":
		problem = "known jump"
	elif str(inspected.get("stage", "")) != "mode-pick" or inspected.has("absent"):
		problem = "inspect"
	elif tel_events.size() < 2 or not _tel_complete(tel_events[-2], true):
		problem = "telemetry fields"
	elif not _tel_complete(tel_events[-1], false):
		problem = "story id should be omitted"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _check_debug(seams: PlaytestSeams, stage: Dictionary) -> bool:
	seams.set_overlay(true, PackedStringArray(["EX.loading", "SIT.2"]))
	var overlay := seams.get_node("PlaytestDebug/StoryOverlay") as Label
	var overlay_text := overlay.text
	var overlay_on := overlay.visible
	var panel := "PlaytestDebug/DebugPanel/"
	var jump_id := seams.get_node(panel + "JumpId") as LineEdit
	jump_id.text = "loading"
	var jump_button := seams.get_node(panel + "Jump") as Button
	jump_button.pressed.emit()
	var overlay_button := seams.get_node(panel + "Overlay") as Button
	overlay_button.pressed.emit()
	overlay_button.pressed.emit()
	var debug_overlay := overlay.visible
	var pause_button := seams.get_node(panel + "Pause") as Button
	pause_button.pressed.emit()
	var paused := seams.is_paused()
	var resume_button := seams.get_node(panel + "Resume") as Button
	resume_button.pressed.emit()
	var inspect_button := seams.get_node(panel + "Inspect") as Button
	inspect_button.pressed.emit()
	var plain := PlaytestSeams.new()
	root.add_child(plain)
	plain.configure()
	var problem := ""
	if not overlay_on or overlay_text != "EX.loading SIT.2":
		problem = "overlay"
	elif str(stage["id"]) != "loading":
		problem = "debug jump"
	elif not debug_overlay:
		problem = "debug overlay"
	elif not paused:
		problem = "debug pause"
	elif not plain.playtest_build:
		problem = "default headless run is playtest"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _log_size(seams: PlaytestSeams) -> int:
	return (seams.dump_state()["input_log"] as Array).size()


func _provider(stage: Dictionary) -> Dictionary:
	return {
		"stage": stage["id"],
		"mode": "",
		"game_ended": {"ended": false, "reason": ""},
		"seed": 0,
	}


func _remember_stage(stage_id: String, stage: Dictionary) -> void:
	stage["id"] = stage_id


func _remember_tel(payload: Dictionary, tel_events: Array) -> void:
	tel_events.append(payload)


func _remember_replay(record: Dictionary, replayed: Array) -> void:
	replayed.append(record)


func _sample_pointer() -> Dictionary:
	return {"kind": "touch", "pressed": true, "index": 0, "x": 1.0, "y": 2.0}


func _tel_complete(payload: Dictionary, with_story: bool) -> bool:
	if str(payload.get("TEL.1", "")).is_empty():
		return false
	if typeof(payload.get("TEL.2", "")) != TYPE_INT:
		return false
	if str(payload.get("TEL.3", "")).is_empty():
		return false
	if str(payload.get("TEL.5", "")).is_empty():
		return false
	return payload.has("TEL.4") == with_story


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
