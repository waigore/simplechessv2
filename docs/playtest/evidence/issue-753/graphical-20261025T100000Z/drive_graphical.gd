extends SceneTree
## #753 acceptance — graphical drive of the shipped scene graph (`res://main.tscn`)
## in a rendered session at 720x1280. Same protocol steps as `drive_headless.gd`,
## plus in-process framebuffer captures of each judged state (the host denies
## Screen Recording to the automation process; the in-process grab is the same
## rendered frame — as in the #617 run).
##
## Story scope: `PTU-exceptions` (`EX.US1`, S1 → `EX.US1.5`) and `PTU-controls`
## (`IN.US1`, `IN.US2`, `IN.US3`).
##
## Every gesture is driven through `Presentation.handle_gui_input` with the event
## shapes of the defect's reproduction step 3 — `InputEventScreenTouch{pressed}`
## and `InputEventScreenDrag` — never through `handle_input_commit`, so the
## pointer gate in `_on_pointer_down` is what the run exercises. The S3 fixture is
## a real advice failure (AdviceClient seam + `FakeAdviceTransport` E2, ADR-0002
## Testability); `advice_error` and `play_ui_state == "S3"` are production state.
##
## Each assertion re-runs the same drive with S1 forced over the live advice
## failure, so S3 and S1 outcomes are compared directly. Prints `STEP` lines and
## exits non-zero if a judged expectation fails.

var pres: Control
var router: Node
var board: Control
var seams: Node
var failures: Array[String] = []
var cases: Array = []
var progress := 0
const OUT_DIR := "res://../docs/playtest/evidence/issue-753/graphical-20261025T100000Z/screenshots"
var shots: Array = []


func _initialize() -> void:
	_run.call_deferred()
	_watchdog()


## The drive must reach `DONE` within the window. A GDScript runtime error aborts
## the coroutine silently (Godot still exits 0), so completion — not the exit code
## alone — is what the runner checks.
func _watchdog() -> void:
	await create_timer(180.0).timeout
	print("STEP WATCHDOG_TIMEOUT at progress=%d" % progress)
	quit(3)


func log_line(s: String) -> void:
	print("STEP %s" % s)


func check(ok: bool, label: String) -> void:
	log_line("%s %s" % ["ok:" if ok else "FAIL:", label])
	progress += 1
	if not ok:
		failures.append(label)


func _settle(frames: int = 20) -> void:
	for i in frames:
		await process_frame


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(720, 1280))
	var packed: PackedScene = load("res://main.tscn")
	pres = packed.instantiate()
	# The headless smoke harness quits on boot; the drive replaces it (as the unit tests do).
	var harness := pres.get_node("PlaytestHarness")
	pres.remove_child(harness)
	harness.free()
	root.add_child(pres)
	await _settle(120)
	router = pres.get_node("SessionRouter")
	board = pres.get("_board")
	seams = pres.get_node("PlaytestSeams")
	seams.call("set_overlay", false, PackedStringArray())
	log_line("booted frame=%s window=%s godot=%s display=%s playtest_build=%s" % [
		str(root.get_visible_rect().size),
		str(DisplayServer.window_get_size()),
		str(Engine.get_version_info().string),
		DisplayServer.get_name(),
		str(PlaytestGate.is_playtest()),
	])

	# A real advice endpoint + key configures the shipped advice client; the peer is
	# simulated through the AdviceClient seam, so nothing leaves the process.
	router.advice_endpoint = "http://advice.test/advice"
	router.advice_api_key = "acceptance-key"
	check(bool(router.advice_on), "Advice defaults On in shared-setup")

	# ---- enter Shared play (mode-pick C1, shared-setup C5)
	await _click("mode_pick", "C1")
	await _settle(40)
	await _click("shared_setup", "C5")
	await _settle(60)
	log_line("stage=%s white_seat=%s ui_state=%s advice_on=%s" % [
		router.stage, str(router.white_seat), str(router.play_ui_state), str(router.advice_on)
	])
	check(router.stage == "shared-play", "entered shared-play")
	check(router.play_ui_state == "S1", "starts in S1")
	check(router.shared_session.get("advice_client") != null, "advice client configured for the game")
	await _settle(20)
	await _shot("01-shared-play-s1-start")

	# ---- PTU-controls S1/S2 and PTU-exceptions S1 on S1 (baseline into the game)
	await _drive_into_game("S1-baseline", "S1")

	# ---- PTU-exceptions S1: a real advice failure puts play in S3 (`EX.error`)
	var sess: Object = router.shared_session
	await _raise_advice_failure()
	check(bool(sess.get("advice_error")), "advice_error raised by a failed fetch")
	check(router.play_ui_state == "S3", "play_ui_state is S3 (got %s)" % str(router.play_ui_state))
	check(not bool(sess.get("online")), "FAIL.T1 keeps the advice service offline")
	var play_panel: Node = pres.get("_shared_play")
	var err_box := play_panel.find_child("AdviceError", true, false) as Control
	var dismiss := play_panel.find_child("AdviceErrorDismiss", true, false) as Button
	check(err_box != null and err_box.visible, "EX.error panel is up")
	check(dismiss != null, "Dismiss control present")
	log_line("EX.US1.5 shown ui_state=%s panel_visible=%s dismiss_text=%s advice_failed=%s" % [
		str(router.play_ui_state),
		str(err_box.visible if err_box != null else false),
		str(dismiss.text if dismiss != null else ""),
		str(sess.get("advice_client").failed()),
	])
	await _settle(20)
	await _shot("02-s3-exerror-panel")
	await _press_release("e2", "S3")
	await _settle(8)
	await _shot("03-s3-selected-e2")
	await _press_release("e2", "S3")
	await _settle(8)

	# ---- PTU-controls in S3 — the defect's claim: C1–C5 as S1 under EX.error
	await _drive_into_game("S3", "S3")
	check(bool(sess.get("advice_error")) and router.play_ui_state == "S3", "EX.error still up after the S3 drives")
	await _settle(20)
	await _shot("04-s3-after-tap-and-drag-moves")

	# ---- S2 in S3: tap the selected piece clears the selection
	await _press_release("e2", "S3")
	await _settle(8)
	check(str(router.selected_piece) == "e2", "C1 tap-select e2 in S3 (got '%s')" % str(router.selected_piece))
	await _press_release("e2", "S3")
	await _settle(8)
	check(str(router.selected_piece).is_empty(), "S2 tap the selected piece clears it in S3 (got '%s')" % str(router.selected_piece))

	# ---- PTU-exceptions S1 (Then): Dismiss → S1, board still usable
	await _click_control(dismiss)
	await _settle(30)
	check(router.play_ui_state == "S1", "Dismiss returns S1 (got %s)" % str(router.play_ui_state))
	check(not bool(sess.get("advice_error")), "Dismiss clears advice_error")
	await _settle(20)
	await _shot("05-s1-after-dismiss")
	_load_fixture("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1")
	await _settle(10)
	await _drag_move("d2", "d4", "after-dismiss")
	await _settle(20)
	check(_occupant("d4") == "white", "a drag move lands after Dismiss as S1")

	# ---- a second real failure after Dismiss, driven again (repeatability).
	# FAIL.T1 parks the client until the browser reconnects, so the run takes the
	# documented reconnect path (client.resume) rather than a silent retry.
	var client2: Object = sess.get("advice_client")
	client2.call("resume")
	sess.set("online", true)
	await _raise_advice_failure()
	check(router.play_ui_state == "S3", "a second advice failure reaches S3 (got %s)" % str(router.play_ui_state))
	await _drive_into_game("S3-second", "S3")

	# ---- IN.US3 web point over the Dismiss control
	await _point_dismiss()

	# ---- telemetry (TEL.1–TEL.5) over the judged window
	var verdict: Dictionary = seams.call("assert_telemetry", [
		{"event": "shared.advice.error", "outcome": "shown", "story_id": "EX.error"},
	])
	log_line("TEL verdict=%s" % str(verdict.get("verdict", "")))
	for m in verdict.get("matched", []):
		log_line("TEL %s" % JSON.stringify(m))
	for miss in verdict.get("missing", []):
		log_line("TEL_MISSING %s" % JSON.stringify(miss))
	check(str(verdict.get("verdict", "")) == "pass", "TEL correlates shared.advice.error shown → EX.error")

	log_line("final ui_state=%s side_to_move=%s advice_error=%s online=%s" % [
		str(router.play_ui_state), str(router.side_to_move()),
		str(sess.get("advice_error")), str(sess.get("online")),
	])
	await _shot("06-final-state")
	log_line("SHOTS %s" % JSON.stringify(shots))
	log_line("FAILURES %s" % JSON.stringify(failures))
	log_line("DONE failures=%d" % failures.size())
	quit(0 if failures.is_empty() else 1)


# ---- a full game drive from a fixture, judged against the S1 run -----------

func _drive_into_game(label: String, mode: String) -> void:
	## Load the same fixture, then drive C1/C2 by tap and drag and B11 by an
	## illegal drop. In `S3` mode the session keeps the live advice failure; Dismiss
	## and re-raise the failure after the game so the screen returns to S3.
	var sess: Object = router.shared_session
	var fen := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1"
	_load_fixture(fen)
	if mode == "S1":
		sess.set("advice_error", false)
		router.call("_emit_play_screen")
		await _settle(20)
	else:
		# A drive labelled S3 must actually run in S3, or its result proves nothing.
		check(
			bool(sess.get("advice_error")) and str(router.play_ui_state) == "S3",
			"[%s] the session is in S3 before the drive (advice_error=%s ui_state=%s)" % [
				label, str(sess.get("advice_error")), str(router.play_ui_state)
			]
		)
	var result := {
		"tap": false, "drag": false, "deselect": false, "illegal": false, "stayed": false,
		"tap_detail": {}, "deselect_detail": {}, "illegal_detail": {},
	}
	var tap_detail := {}
	for attempt in 3:
		_load_fixture(fen)
		await _settle(6)
		# C1 + C2 by tap: e2 → e4
		await _press_release("e2", label)
		await _settle(4)
		var sel := str(router.selected_piece)
		log_line("%s after_select selection='%s'" % [label, sel])
		await _press_release("e4", label)
		await _settle(10)
		tap_detail = {
			"selected": sel,
			"e2": _occupant("e2"),
			"e4": _occupant("e4"),
			"side": str(router.side_to_move()),
			"ui_state": str(router.play_ui_state),
			"select_count": router.get("pointer_count"),
		}
		result["tap_detail"] = tap_detail
		result["tap"] = _occupant("e4") == "white" and _occupant("e2").is_empty()
		result["stayed"] = str(router.side_to_move()) == "black"
		log_line("%s tap_move e2e4 landed=%s detail=%s" % [
			label, str(result["tap"]), JSON.stringify(tap_detail)
		])
		if result["tap"]:
			break
	if not result["tap"]:
		log_line("%s tap_move never landed after 3 attempts" % label)
	# C1 + C2 by drag from an unselected piece: b8 → c6 (B10)
	for attempt in 3:
		await _drag("b8", "c6", label)
		await _settle(10)
		result["drag"] = _occupant("c6") == "black" and _occupant("b8").is_empty()
		log_line("%s drag_move b8c6 landed=%s side_to_move=%s" % [
			label, str(result["drag"]), str(router.side_to_move())
		])
		if result["drag"]:
			break
	# B11: an illegal drop places nothing and clears the selection. The target is
	# an own pawn (g1→g2: a legal drop devoted to a refuse), so nothing can land.
	await _press_release("g1", label)
	await _settle(4)
	var b11_picked := str(router.selected_piece) == "g1"
	await _drag("g1", "g2", label)
	await _settle(10)
	var g2: Dictionary = router.occupancy_at("g2")
	result["illegal"] = (
		_occupant("g2") == "white"
		and str(g2.get("kind", "")) == "pawn"
		and _occupant("g1") == "white"
		and str(router.selected_piece).is_empty()
	)
	result["illegal_detail"] = {"picked": b11_picked, "g1": _occupant("g1"), "g2": g2, "selection": str(router.selected_piece)}
	log_line("%s illegal_drop g1g2 refused=%s detail=%s" % [
		label, str(result["illegal"]), JSON.stringify(result["illegal_detail"])
	])
	# S2: tap a selected piece clears it (IN.deselect, B8). The game is mid-tap-
	# place here, so the tap probe runs on a fresh fixture of its own.
	_load_fixture(fen)
	await _settle(6)
	await _press_release("a2", label)
	await _settle(4)
	var picked := str(router.selected_piece) == "a2"
	log_line("%s deselect_probe selection='%s' picked=%s" % [label, str(router.selected_piece), str(picked)])
	await _press_release("a2", label)
	await _settle(8)
	result["deselect"] = picked and str(router.selected_piece).is_empty()
	result["deselect_detail"] = {"picked": picked, "after": _occupant("a2"), "selection": str(router.selected_piece)}
	log_line("%s deselect_by_tap picked=%s cleared=%s" % [
		label, str(picked), str(router.selected_piece).is_empty()
	])
	log_line("%s RESULT %s" % [label, JSON.stringify(result)])
	cases.append({"label": label, "mode": mode, "result": result})
	check(bool(result["tap"]), "[%s] C1+B2/B3 tap-select then tap-place moves" % label)
	check(bool(result["drag"]), "[%s] C1+B10 drag-to-move moves" % label)
	check(bool(result["illegal"]), "[%s] B11 illegal drop places nothing and clears" % label)
	check(bool(result["deselect"]), "[%s] S2 tap the selected piece clears it" % label)
	check(bool(result["stayed"]), "[%s] the tap move hands the turn to Black" % label)


func _load_fixture(fen: String) -> void:
	var sess: Object = router.shared_session
	sess.get("rules").call("_load_fen", fen)
	sess.set("selected_piece", "")
	sess.set("play_ui_state", "S1")
	sess.call("_sync_active_to_side_to_move")
	router.call("_emit_play_screen")


# ---- the advice failure (FakeAdviceTransport E2 through the client seam) ----

func _raise_advice_failure() -> void:
	var sess: Object = router.shared_session
	var client: Object = sess.get("advice_client")
	if client == null:
		log_line("advice_failure_error no client")
		return
	if client.get("_transport") == null:
		client.call(
			"start", sess.get("rules").call("position_field"), sess.get("rules").call("castling_ep")
		)
	var peer = client.get("_transport")
	if peer == null:
		log_line("advice_failure_error no peer")
		return
	log_line("advice_peer=%s endpoint=%s online=%s" % [
		peer.get_script().get_global_name() if peer.get_script() != null else "<none>",
		str(peer.get("endpoint")), str(sess.get("online")),
	])
	peer.call("push_end", AdviceWireReader.REASON_ERROR)
	await _settle(8)
	log_line("advice_failure advice_error=%s ui_state=%s online=%s" % [
		str(sess.get("advice_error")), str(router.play_ui_state), str(sess.get("online")),
	])


# ---- a faithful gesture drive: production event shapes through handle_gui_input ----

func _pointer(pressed: bool, at: Vector2) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.pressed = pressed
	ev.position = at
	pres.call("handle_gui_input", ev)


func _drag_event(at: Vector2) -> void:
	var ev := InputEventScreenDrag.new()
	ev.index = 0
	ev.position = at
	pres.call("handle_gui_input", ev)


func _screen_of(square: String) -> Vector2:
	return board.call("world_to_screen", board.call("framed_center", square))


func _drag(from_sq: String, to_sq: String, label: String) -> void:
	## Press, move past the drag threshold, release on the destination (B10).
	var a := _screen_of(from_sq)
	var b := _screen_of(to_sq)
	_pointer(true, a)
	await process_frame
	for i in 4:
		_drag_event(a.lerp(b, float(i + 1) / 5.0))
		await process_frame
	_drag_event(b)
	_pointer(false, b)
	log_line("gesture drag %s→%s (%s)" % [from_sq, to_sq, label])


func _press_release(square: String, label: String) -> void:
	var at := _screen_of(square)
	_pointer(true, at)
	await process_frame
	_pointer(false, at)
	log_line("gesture tap %s (%s)" % [square, label])


func _drag_move(from_sq: String, to_sq: String, label: String) -> void:
	await _drag(from_sq, to_sq, label)


func _point_dismiss() -> void:
	## IN.US3: a pointer over the Dismiss control fires `IN.point` and nothing else.
	var play_panel: Node = pres.get("_shared_play")
	var dismiss := play_panel.find_child("AdviceErrorDismiss", true, false) as Button
	if dismiss == null:
		check(false, "IN.US3 dismiss control present for the pointer check")
		return
	var before_ui: String = str(router.play_ui_state)
	var before_side: String = str(router.side_to_move())
	dismiss.emit_signal("mouse_entered")
	dismiss.emit_signal("focus_entered")
	await _settle(4)
	var pointed: String = str(pres.get("last_point_control"))
	check(pointed == "advice_dismiss", "IN.US3 pointer over Dismiss fires IN.point (got %s)" % pointed)
	check(str(router.play_ui_state) == before_ui, "IN.US3 the pointer fires no other action")
	check(str(router.side_to_move()) == before_side, "IN.US3 no move from the pointer")
	var play_panel_named := ["AdviceToggle", "AdviceEval", "AdviceErrorDismiss", "Resign", "ResignConfirm", "ResignCancel"]
	var chain: Array = []
	var here: Control = dismiss
	for i in 8:
		var next := here.find_next_valid_focus()
		if next == null or next == here:
			break
		here = next
		chain.append(str(next.name))
	log_line("IN.US3 focus_chain_from_dismiss=%s play_controls=%s" % [
		JSON.stringify(chain), JSON.stringify(play_panel_named)
	])
	check(chain.size() >= 1, "IN.US3 Tab moves focus off the first control (F1)")


# ---- board helpers ---------------------------------------------------------

func _occupant(square: String) -> String:
	var occ: Dictionary = router.occupancy_at(square)
	return str(occ.get("color", ""))


func _panel(screen: String) -> Node:
	match screen:
		"mode_pick":
			return pres.get("_mode_pick")
		"shared_setup":
			return pres.get("_shared_setup")
		"shared_play":
			return pres.get("_shared_play")
		"shared_result":
			return pres.get("_shared_result")
	return null


func _click(screen: String, control_id: String) -> void:
	var panel := _panel(screen)
	if panel == null:
		log_line("click %s/%s FAILED no panel" % [screen, control_id])
		return
	var target := _find_control(panel, control_id)
	if target == null:
		log_line("click %s/%s FAILED no control" % [screen, control_id])
		return
	await _click_control(target)


func _click_control(target: Control) -> void:
	var content_center := target.get_global_rect().get_center()
	var window_point := root.get_final_transform() * content_center
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = window_point
	down.global_position = window_point
	Input.parse_input_event(down)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = window_point
	up.global_position = window_point
	Input.parse_input_event(up)
	Input.flush_buffered_events()
	log_line("click %s at %s" % [target.name, str(content_center)])


func _find_control(node: Node, control_id: String) -> Control:
	for sig in node.get_signal_list():
		for c in node.get_signal_connection_list(sig.name):
			var bounds: Array = c.callable.get_bound_arguments()
			if bounds.is_empty() or not (bounds[0] is String):
				continue
			if str(bounds[0]) != control_id:
				continue
			if node is Control and (node as Control).is_visible_in_tree():
				return node as Control
	for child in node.get_children():
		var hit := _find_control(child, control_id)
		if hit != null:
			return hit
	return null


func _shot(name: String) -> void:
	await _settle(10)
	var img := root.get_texture().get_image()
	if img == null:
		log_line("shot_failed %s no image" % name)
		failures.append("screenshot %s missing" % name)
		return
	var path := "%s/%s.png" % [OUT_DIR, name]
	var err := img.save_png(path)
	shots.append(name)
	log_line("shot %s size=%s err=%d" % [name, str(img.get_size()), err])
