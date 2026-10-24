extends SceneTree
## #617 acceptance — graphical drive of the shipped shared-play screen.
##
## Runs the real `main.tscn` in a rendered (non-headless) Godot session at 720x1280,
## clicks real panel controls (resolved by their bound control_id), taps board
## squares through the production pointer path, and captures the actual rendered
## framebuffer in-process (`root.get_texture().get_image()`).
##
## Out-of-process `screencapture` is not used: this host denies Screen Recording to
## the automation process, while the in-process grab is the same rendered frame.

const WIDTH := 720
const HEIGHT := 1280
const OUT_DIR := "res://../docs/playtest/evidence/issue-617/graphical-20261024T000000Z/screenshots"

var pres: Control
var router: Node
var board: Control
var shots: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()
	_watchdog()


func _watchdog() -> void:
	await create_timer(240.0).timeout
	print("STEP WATCHDOG_TIMEOUT")
	quit(3)


func log_line(s: String) -> void:
	print("STEP %s" % s)


func _settle(frames: int = 20) -> void:
	for i in frames:
		await process_frame


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(WIDTH, HEIGHT))
	var packed: PackedScene = load("res://main.tscn")
	pres = packed.instantiate()
	root.add_child(pres)
	await _settle(90)
	router = pres.get_node("SessionRouter")
	board = pres.get("_board")
	log_line("booted window=%s frame=%s godot=%s seams=%s" % [
		str(DisplayServer.window_get_size()),
		str(root.get_visible_rect().size),
		str(Engine.get_version_info().string),
		str(pres.has_node("PlaytestSeams")),
	])

	# Hide the playtest debug overlay so the capture shows the shipped screen.
	var seams: Node = pres.get_node("PlaytestSeams")
	seams.call("set_overlay", false, PackedStringArray())
	await _settle(10)

	# ---- mode pick -> shared setup -> shared play (seat Bottom is the default)
	_click("mode_pick", "C1")
	await _settle(40)
	log_line("stage_after_mode_pick=%s" % router.stage)
	_click("shared_setup", "C5")
	await _settle(90)
	log_line("seat_bottom_ready stage=%s white_seat=%s" % [router.stage, router.white_seat])
	await _shot("01-seat-bottom-start")

	# ---- S1: Bottom (White) moves via real board taps
	var e4: Dictionary = router.occupancy_at("e4")
	await _tap_move("e2", "e4")
	log_line("S1 bottom_move e2e4 done side_to_move=%s" % str(router.side_to_move()))
	await _settle(30)
	log_line("S1 after occupancy_e4=%s side_to_move=%s" % [
		str(router.occupancy_at("e4")), str(router.side_to_move())
	])
	await _shot("02-seat-bottom-after-bottom-move")

	# ---- S2: Top-side player (Black) moves at the rotated seat
	await _tap_move("e7", "e5")
	await _settle(30)
	log_line("S2 top_move e7e5 occupancy_e5=%s side_to_move=%s" % [
		str(router.occupancy_at("e5")), str(router.side_to_move())
	])
	await _shot("03-seat-bottom-after-both-moves")

	# ---- S3: resign opens a confirm; cancel returns to play
	_click("shared_play", "C4")
	await _settle(40)
	log_line("S3 resign_ui_state=%s" % router.play_ui_state)
	await _shot("04-resign-confirm")
	_click("shared_play", "cancel")
	await _settle(30)
	log_line("S3 resign_cancel_ui_state=%s" % router.play_ui_state)

	# ---- S4: promotion chooser sprites (the second sprite set in the defect)
	_open_promotion()
	await _settle(60)
	log_line("S4 chooser_ui_state=%s" % router.play_ui_state)
	await _shot("05-promotion-chooser-bottom")
	_click("shared_play", "cancel")
	await _settle(30)
	log_line("S4 after_cancel_ui_state=%s" % router.play_ui_state)

	# ---- SIT.4: frame timing across one full local move
	await _timed_move("c2", "c4")
	await _settle(30)
	log_line("SIT.4 c2c4 occupancy_c4=%s" % str(router.occupancy_at("c4")))

	# ---- White seat Top: finish the game, return to setup, toggle the seat.
	_click("shared_play", "C4")
	await _settle(30)
	_click("shared_play", "confirm")
	await _settle(60)
	log_line("resign_accepted stage=%s" % router.stage)
	await _shot("06-resign-result")
	_click("shared_result", "C1")
	await _settle(60)
	log_line("after_play_again stage=%s" % router.stage)
	_click("shared_setup", "C1")
	await _settle(40)
	log_line("white_seat_toggled=%s" % router.white_seat)
	await _shot("07-seat-top-setup")
	_click("shared_setup", "C5")
	await _settle(90)
	log_line("seat_top_ready stage=%s white_seat=%s" % [router.stage, router.white_seat])
	await _shot("08-seat-top-start")

	await _tap_move("d2", "d4")
	await _settle(40)
	log_line("S1b seat_top_move d2d4 occupancy_d4=%s side_to_move=%s" % [
		str(router.occupancy_at("d4")), str(router.side_to_move())
	])
	await _tap_move("d7", "d5")
	await _settle(40)
	log_line("S2b seat_top_black d7d5 occupancy_d5=%s side_to_move=%s" % [
		str(router.occupancy_at("d5")), str(router.side_to_move())
	])
	await _shot("09-seat-top-after-moves")

	# ---- S6 / SIT.5: TEL correlation for the judged stories
	var verdict: Dictionary = seams.call("assert_telemetry", [
		{"event": "shared.start", "outcome": "ok", "story_id": "UI-shared-play.US1"},
		{"event": "shared.move", "outcome": "ok", "story_id": "UI-shared-play.US1.3"},
		{"event": "shared.resign", "outcome": "confirm", "story_id": "UI-shared-play.US1.1"},
	])
	log_line("S6 TEL_VERDICT=%s" % str(verdict.get("verdict", "")))
	for m in verdict.get("matched", []):
		log_line("S6 TEL %s" % JSON.stringify(m))
	for miss in verdict.get("missing", []):
		log_line("S6 TEL_MISSING %s" % JSON.stringify(miss))

	log_line("SHOTS %s" % JSON.stringify(shots))
	log_line("DONE")
	quit(0)

func _open_promotion() -> void:
	var sess: RefCounted = router.shared_session
	if sess == null:
		log_line("promotion_error no session")
		return
	var rules: Object = sess.get("rules")
	if rules == null:
		log_line("promotion_error no rules")
		return
	rules.call("_load_fen", "4k3/1P6/8/8/8/8/8/4K3 w - - 0 1")
	router.call("_emit_play_screen")
	await _settle(40)
	log_line("promotion_fen_loaded occupancy_b7=%s side_to_move=%s" % [
		str(router.occupancy_at("b7")), str(router.side_to_move())
	])
	await _tap_move("b7", "b8")
	log_line("promotion_move b7b8 done")


func _timed_move(from_sq: String, to_sq: String) -> void:
	var a := _screen_of(from_sq)
	var b := _screen_of(to_sq)
	var deltas: Array = []
	_press(a)
	var prev := Time.get_ticks_usec()
	for i in 16:
		await process_frame
		var now := Time.get_ticks_usec()
		deltas.append(snappedf(float(now - prev) / 1000.0, 0.01))
		prev = now
		_motion(a.lerp(b, float(i + 1) / 16.0))
	_motion(b)
	_press_release(b)
	for i in 16:
		await process_frame
		var now := Time.get_ticks_usec()
		deltas.append(snappedf(float(now - prev) / 1000.0, 0.01))
		prev = now
	var worst := 0.0
	for d in deltas:
		worst = maxf(worst, float(d))
	log_line("SIT.4 frame_samples_ms=%s worst_frame_ms=%.2f budget_ms=16.67" % [
		JSON.stringify(deltas), worst
	])


func _screen_of(square: String) -> Vector2:
	# Board space -> global (content) coordinates, exactly what pointer input uses.
	return board.call("world_to_screen", board.call("framed_center", square))


func _tap_move(from_sq: String, to_sq: String) -> void:
	# Tap-select then tap-destination, one frame between events (the production tap
	# path resolves on pointer-up, so each down/up pair needs its own frame).
	_press(_screen_of(from_sq))
	await process_frame
	_press_release(_screen_of(from_sq))
	await process_frame
	await process_frame
	_press(_screen_of(to_sq))
	await process_frame
	_press_release(_screen_of(to_sq))
	await process_frame


func _press(at: Vector2) -> void:
	pres.call("_on_pointer_down", at, 0)


func _press_release(at: Vector2) -> void:
	pres.call("_on_pointer_up", at, 0)


func _motion(at: Vector2) -> void:
	pres.call("_on_pointer_move", at)


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
	log_line("click %s/%s at %s" % [screen, control_id, str(content_center)])


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
	await _settle(8)
	var img := root.get_texture().get_image()
	if img == null:
		log_line("shot_failed %s no image" % name)
		return
	var path := "%s/%s.png" % [OUT_DIR, name]
	var err := img.save_png(path)
	shots.append(name)
	log_line("shot %s size=%s err=%d" % [name, str(img.get_size()), err])
