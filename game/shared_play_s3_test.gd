class_name SharedPlayS3Test
extends SceneTree
## UI-shared-play S3 `EX.error` — the board stays playable as S1 (#753). The
## advice failure is raised on the session itself (no advice client, so no
## endpoint is hit), so the gate reads the S3 derivation rather than a fixture
## left at S1 — the shape that let the defect and its old assertion coexist.

var _presentation: Presentation
var _router: SessionRouter
var _error := ""


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_router.locale = "en"
	_router.last_mode = "none"
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_presentation.set_deferred("size", Vector2(720, 1280))
	await process_frame
	await process_frame
	_error = await _enter_s3()
	if _error.is_empty():
		_error = await _tap_and_drag_still_move()
	if _error.is_empty():
		_error = await _dismiss_returns_to_s1()
	if _error.is_empty():
		quit(0)
		return
	push_error(_error)
	quit(1)


## S3 over an S1 session on a board where both sides have a move to make.
func _enter_s3() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	var session := _router.shared_session
	if _router.stage != "shared-play" or session == null:
		return "S3 needs a Shared game"
	var pieces: Array = [
		{"square": "a1", "color": "white", "kind": "king"},
		{"square": "h8", "color": "black", "kind": "king"},
		{"square": "d2", "color": "white", "kind": "pawn"},
		{"square": "g8", "color": "black", "kind": "knight"},
	]
	session.rules.load_position(pieces, "white")
	session._sync_active_to_side_to_move()
	session.selected_piece = ""
	session.play_ui_state = SharedGameSession.UI_S1
	session.advice_error = true
	_router._emit_play_screen()
	await process_frame
	return _first_fail(
		[
			[
				_router.play_ui_state == SharedGameSession.UI_S3,
				"EX.error must show S3 (got %s)" % _router.play_ui_state,
			],
			[_router.play_gestures_available(), "C1-C5 stay available as S1 in S3"],
			[bool(_state().get("c1_available", false)), "C1 available in S3"],
			[bool(_state().get("c2_available", false)), "C2 available in S3"],
			[bool(_state().get("c4_available", false)), "C4 available in S3"],
			[not bool(_state().get("board_unavailable", true)), "board available in S3"],
			[_board().visible, "the board stays drawn in S3"],
		]
	)


func _tap_and_drag_still_move() -> String:
	var session := _router.shared_session
	# C1 select, C2 place by tap (d2 → d4).
	var problem := _first_fail(
		[
			[_router.handle_input_commit("d2", ""), "C1 select must land in S3"],
			[_router.selected_piece == "d2", "C1 selects d2 in S3"],
		]
	)
	if not problem.is_empty():
		return problem
	await _tap_square("d4")
	problem = _first_fail(
		[
			[_router.selected_piece == "", "C2 place clears selection in S3"],
			[_placed("d4") and not _placed("d2"), "C2 moved the pawn d2→d4 in S3"],
			[_router.side_to_move() == "black", "C2 place switches the side to move"],
			[
				session.advice_error and _router.play_ui_state == SharedGameSession.UI_S3,
				"the played move keeps EX.error up in S3",
			],
		]
	)
	if not problem.is_empty():
		return problem
	# C1 + C2 in one gesture: black g8 → f6 by drag, through real pointer events.
	await _drag_square("g8", "f6")
	return _first_fail(
		[
			[_placed("f6") and not _placed("g8"), "B10 pick-and-drag moves in S3"],
			[_router.side_to_move() == "white", "drag place switches the side to move"],
			[session.advice_error, "drag keeps EX.error up"],
		]
	)


## S3 Dismiss → S1; FAIL.T1 leaves the service offline, so no advice returns.
func _dismiss_returns_to_s1() -> String:
	var session := _router.shared_session
	var play := _presentation.get_node("ScreenHost/SharedPlay") as SharedPlayPanel
	var dismiss := play.find_child("AdviceErrorDismiss", true, false) as Button
	if dismiss == null:
		return "S3 Dismiss button missing"
	dismiss.pressed.emit()
	await process_frame
	var problem := _first_fail(
		[
			[_router.play_ui_state == SharedGameSession.UI_S1, "Dismiss must return S1"],
			[_router.play_gestures_available(), "C1-C5 still live after Dismiss"],
		]
	)
	if not problem.is_empty():
		return problem
	return _first_fail(
		[[_router.handle_input_commit("d4", "d5"), "a move lands after Dismiss as S1"]]
	)


func _tap_square(square: String) -> void:
	var at := _screen_for(square)
	var down := InputEventScreenTouch.new()
	down.pressed = true
	down.index = 0
	down.position = at
	_presentation.handle_gui_input(down)
	var up := InputEventScreenTouch.new()
	up.pressed = false
	up.index = 0
	up.position = at
	_presentation.handle_gui_input(up)
	await process_frame


func _drag_square(from_sq: String, to_sq: String) -> void:
	var from := _screen_for(from_sq)
	var to := _screen_for(to_sq)
	var down := InputEventScreenTouch.new()
	down.pressed = true
	down.index = 0
	down.position = from
	_presentation.handle_gui_input(down)
	var mid := from.lerp(to, 0.5)
	# Exceed DRAG_THRESHOLD_PX.
	if mid.distance_to(from) < Presentation.DRAG_THRESHOLD_PX:
		mid = from + Vector2(Presentation.DRAG_THRESHOLD_PX + 4.0, 0)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = mid
	_presentation.handle_gui_input(drag)
	var up := InputEventScreenTouch.new()
	up.pressed = false
	up.index = 0
	up.position = to
	_presentation.handle_gui_input(up)
	await process_frame


func _placed(square: String) -> bool:
	var occ: Dictionary = _router.shared_session.rules.position_field()["occupancy"]
	return occ.has(square)


func _screen_for(square: String) -> Vector2:
	return _board().world_to_screen(_board().framed_center(square))


func _board() -> BoardPresentation:
	return _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation


func _state() -> Dictionary:
	return _router._shared_play_state()


func _first_fail(checks: Array) -> String:
	for item in checks:
		if not bool(item[0]):
			return str(item[1])
	return ""
