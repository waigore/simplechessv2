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
	var release_verdict := seams.assert_telemetry(
		[{"event": "pause", "outcome": "pass", "story_id": "EX.loading"}]
	)
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
	elif (
		release_verdict["verdict"] != "fail"
		or not (release_verdict["matched"] as Array).is_empty()
		or not (release_verdict["missing"] as Array).is_empty()
		or int(release_verdict["event_count"]) != 0
	):
		problem = "release S12 assert_telemetry"
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
	if not _check_telemetry(seams):
		return false
	if not _check_debug(seams, stage):
		return false
	return _check_viewport(seams)


func _check_viewport(seams: PlaytestSeams) -> bool:
	## S13 / SIT.6 — O12 applies a viewport on ENV.2 only, and the reported sizes
	## are the ones that frame renders, never the caller's arguments (D1/D2).
	var reports: Array = []
	seams.viewport_changed.connect(_remember_viewport.bind(reports))
	seams.bind_text_report(Presentation.body_text_screen_px_for_frame_height)
	var wanted := Vector2i(PlaytestSeams.VIEWPORT_PHONE_WIDTH, PlaytestSeams.VIEWPORT_PHONE_HEIGHT)
	var phone := seams.set_viewport(wanted.x, wanted.y, 1.0)
	var shown := seams.last_viewport_report()
	# The unit-test binary runs this seam outside the tree, so it holds no frame
	# yet: the report keeps its shape but no limb may claim the requested one.
	var framed := PlaytestGate.in_frame(seams)
	var frame := int(phone.get("frame_height_px", 0))
	var empty := seams.set_viewport(0, 844, 1.0)
	# UIS.T2 is a ratio to the reference height, so a taller phone frame sits above
	# BODY_PX; a hardcoded or clamped size at BODY_PX fails `scales_with_frame`.
	var phone_expected := Presentation.scaled_body_px(_frame_ratio(wanted.y))
	var scales_with_frame := (
		phone_expected > UiChrome.BODY_PX
		and phone_expected > Presentation.scaled_body_px(_frame_ratio(640))
	)
	var panel_button := seams.get_node("PlaytestDebug/DebugPanel/SetViewport") as Button
	var problem := ""
	if reports.size() != 1 or phone.is_empty() or shown != phone:
		problem = "S13 viewport report"
	elif int(phone["width"]) != wanted.x or int(phone["height"]) != wanted.y:
		problem = "S13 requested size"
	elif not _application_matches(phone, framed, wanted.y):
		problem = "S13 report must match the viewport the runner really applied"
	elif not is_equal_approx(float(phone["text_scale"]), 1.0):
		problem = "S13 applied text scale"
	elif frame <= 0 and int(phone["body_text_px"]) != 0:
		problem = "S13 no frame, no body-text claim"
	elif (
		frame > 0
		and (
			int(phone["body_text_px"])
			!= Presentation.scaled_body_px(Presentation.text_scale_for_frame_height(frame))
		)
	):
		problem = "S13 body text must come from the presentation ratio"
	elif not scales_with_frame:
		problem = "S13 clamped text size (body text must scale with frame height)"
	elif not _bound_report_matches(seams, framed):
		problem = "S13 seam must report the bound presentation size, not its own"
	elif not _ignores_argument_scale(seams):
		problem = "S13 seam must not report the argument it was handed"
	elif not _hook_tracks_the_frame():
		problem = "S13 hook must follow the rendered frame, not a constant"
	elif not _phone_ratio():
		problem = "S13 phone frame must reflow the shipped layout"
	elif not _ignores_argument_scale(seams):
		problem = "S13 seam must not report the argument it was handed"
	elif not empty.is_empty():
		problem = "S13 invalid input must not return a report"
	elif panel_button == null:
		problem = "S13 debug panel control"
	elif not _hook_tracks_the_frame():
		problem = "S13 hook must follow the rendered frame, not a constant"
	elif not _phone_ratio():
		problem = "S13 phone frame must reflow the shipped layout"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _application_matches(report: Dictionary, framed: bool, wanted_px: int) -> bool:
	## `applied` names ENV.2, and only a seam inside a frame may name its height.
	if bool(report.get("applied", false)) != PlaytestGate.has_display():
		return false
	if not framed or not PlaytestGate.has_display():
		## No frame to read: the report keeps its shape but names no height.
		return int(report.get("frame_height_px", 0)) == 0
	return int(round(float(report.get("frame_height_px", 0)))) == wanted_px


func _bound_report_matches(seams: PlaytestSeams, framed: bool) -> bool:
	## The seam must echo the bound presentation hook, never compute a size of its own.
	var sentinel := 1234.0
	seams.bind_text_report(func(_frame_height_px: float) -> float: return sentinel)
	var bound := seams.set_viewport(390, 844, 1.0)
	seams.bind_text_report(Presentation.body_text_screen_px_for_frame_height)
	## The seam only reports the hook's answer for the frame it renders (D2); with
	## no frame on screen the report names none and carries no body-text claim.
	if int(bound.get("frame_height_px", 0)) <= 0:
		return int(bound.get("body_text_px", 0)) == 0
	if not is_equal_approx(float(bound.get("body_text_px", 0.0)), sentinel):
		return false
	if not framed:
		return true
	var named := int(bound.get("frame_height_px", 0))
	return named == int(round(Presentation.frame_height_for_body_px(sentinel)))


func _ignores_argument_scale(seams: PlaytestSeams) -> bool:
	## F2 — the caller's scale argument cannot move what the seam reports.
	var coarse := seams.set_viewport(390, 844, 0.25)
	var fine := seams.set_viewport(390, 844, 4.0)
	return (
		is_equal_approx(float(coarse["body_text_px"]), float(fine["body_text_px"]))
		and is_equal_approx(
			float(coarse["rendered_text_scale"]), float(fine["rendered_text_scale"])
		)
	)


func _hook_tracks_the_frame() -> bool:
	## F1 — the shipped hook reads a frame height and yields UIS.T2 for it: the
	## reference height gives BODY_PX, 844 gives BODY_PX * 844 / 640. A clamped or
	## hardcoded size fails the second check, and the leftover comparison proves
	## that check can fail in this run rather than pass by construction.
	var reference := Presentation.body_text_screen_px_for_frame_height(
		UiChrome.REFERENCE_FRAME_HEIGHT_PX
	)
	var phone := Presentation.body_text_screen_px_for_frame_height(
		PlaytestSeams.VIEWPORT_PHONE_HEIGHT
	)
	var expected := (
		float(UiChrome.BODY_PX)
		* float(PlaytestSeams.VIEWPORT_PHONE_HEIGHT)
		/ UiChrome.REFERENCE_FRAME_HEIGHT_PX
	)
	var clamped_would_differ := not is_equal_approx(phone, reference)
	return (
		int(reference) == UiChrome.BODY_PX
		and int(round(phone)) == int(round(expected))
		and clamped_would_differ
	)


func _phone_ratio() -> bool:
	## F1 — the panels reflow through the shipped hook from the frame they render
	## in. Desktop only: a phone-sized desktop window truncates below the panels'
	## minimum size, which no shipped desktop build shows; the phone-width
	## judgement itself is `PTU-mode-pick` S6 on the Web build.
	if DisplayServer.get_name() == "headless":
		return true
	var presented := Presentation.new()
	root.add_child(presented)
	presented.size = Vector2(390.0, 844.0)
	presented.show_screen(Presentation.MODE_PICK, {"ui_state": "S1"})
	var mode_pick := presented.get_node("ScreenHost/ModePick") as ModePickPanel
	var puzzle := mode_pick.find_child("PuzzleStream", true, false) as Control
	var frame := UiChrome.frame_height_of(mode_pick)
	var expected := UiChrome.text_scale_for_frame_height(frame)
	var applied := mode_pick._text_scale
	var ok := applied > 1.0 and is_equal_approx(applied, expected) and puzzle != null
	if ok:
		var puzzle_px := puzzle.get_theme_font_size("font_size")
		ok = puzzle_px >= UiChrome.scaled_px(UiChrome.BODY_PX, applied)
	presented.queue_free()
	return ok


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
	seams.emit_tel("play_move", "pass", "EX.loading")
	seams.emit_tel("play_move", "pass", "SIT.2")
	var assert_button := seams.get_node(panel + "AssertTelemetry") as Button
	assert_button.pressed.emit()
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


func _check_telemetry(seams: PlaytestSeams) -> bool:
	var wanted := [
		{"event": "jump", "outcome": "pass", "story_id": "mode-pick"},
		{"event": "note", "outcome": "pass", "story_id": ""},
		{"event": "smoke_inspect", "outcome": "pass", "story_id": "EX.loading"},
		{"event": "jump", "outcome": "fail", "story_id": ""},
	]
	var pass_verdict := seams.assert_telemetry(wanted)
	var matched: Array = pass_verdict["matched"]
	var fail_verdict := (
		seams
		. assert_telemetry(
			[
				{"event": "jump", "outcome": "pass", "story_id": "mode-pick"},
				{"event": "play_move", "outcome": "pass", "story_id": "UI-shared-play.US1"},
			]
		)
	)
	var missing: Array = fail_verdict["missing"]
	var problem := ""
	if pass_verdict["verdict"] != "pass" or matched.size() != 4:
		problem = "S12 pass verdict"
	elif pass_verdict["session_id"] != seams.session_id or int(pass_verdict["event_count"]) < 4:
		problem = "S12 log window"
	elif fail_verdict["verdict"] != "fail" or missing.size() != 1:
		problem = "S12 fail verdict"
	elif str(missing[0]["story_id"]) != "UI-shared-play.US1":
		problem = "S12 missing story"
	elif not (fail_verdict["matched"] as Array).has(matched[0]):
		problem = "S12 matched events"
	elif seams.assert_telemetry([])["verdict"] != "pass":
		problem = "S12 empty expectation"
	if not problem.is_empty():
		return _fail(problem)
	return true


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
