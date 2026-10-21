class_name SharedPlayTest
extends SceneTree
## Headless coverage for UI-shared-play (#58): gestures, clocks, resign, NAV.T6.

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
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
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
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
	_error = _geometry_hit()
	if _error.is_empty():
		_error = _string_keys()
	if _error.is_empty():
		_error = _enter_play()
	if _error.is_empty():
		_error = _select_and_place()
	if _error.is_empty():
		_error = _illegal_keeps_selection()
	if _error.is_empty():
		_error = await _gesture_b2_changes_selection()
	if _error.is_empty():
		_error = await _gesture_b3_place()
	if _error.is_empty():
		_error = await _gesture_b10_pick_and_drag()
	if _error.is_empty():
		_error = await _gesture_bad_drop_returns()
	if _error.is_empty():
		_error = _promotion_refused_no_auto_queen()
	if _error.is_empty():
		_error = _resign_flow()
	if _error.is_empty():
		_error = _s2_board_unavailable_and_clock()
	if _error.is_empty():
		_error = _pause_halts_clock_and_input()
	if _error.is_empty():
		_error = _advice_stub()
	if _error.is_empty():
		_error = _clocks_visible_when_timed()
	if _error.is_empty():
		_error = await _layout_reserves_chrome()
	if _error.is_empty():
		quit(0)
		return
	_fail(_error)


func _geometry_hit() -> String:
	if BoardGeometry.square_at(Vector2(0.5, 0.5)) != "a1":
		return "square_at a1"
	if BoardGeometry.square_at(Vector2(4.2, 3.8)) != "e4":
		return "square_at e4"
	if BoardGeometry.square_at(Vector2(-0.1, 0.5)) != "":
		return "square_at off-board"
	return ""


func _string_keys() -> String:
	for key in [
		"resign",
		"resign_confirm",
		"confirm",
		"cancel",
		"white_to_move",
		"black_to_move",
		"check",
		"advice_on",
		"advice_off",
	]:
		var text := StringTable.shared_play(key, "en")
		if text.is_empty() or text == key:
			return "missing copy %s" % key
	if StringTable.shared_result("result_white", "en") != "White wins":
		return "shared-result copy"
	return ""


func _enter_play() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	var play := _play_panel()
	var board := _board()
	var ok := (
		_router.stage == "shared-play"
		and _router.shared_session != null
		and play != null
		and play.visible
		and play.ui_state == "S1"
		and _router.selected_piece == ""
		and board != null
		and board.visible
		and board.offset_top >= Presentation.PLAY_CHROME_TOP_PX - 0.5
	)
	return "" if ok else "Start → shared-play shell"


func _select_and_place() -> String:
	_router.handle_input_commit("e2", "")
	if _router.selected_piece != "e2":
		return "C1 select e2"
	var legal := _router.legal_targets_for("e2")
	if not legal.has("e4"):
		return "legal marks include e4"
	_router.handle_input_commit("e2", "e4")
	if _router.selected_piece != "":
		return "selection clears after place"
	var occ: Dictionary = _router.shared_session.rules.position_field()["occupancy"]
	if not occ.has("e4") or occ.has("e2"):
		return "e2→e4 applied"
	if _router.side_to_move() != "black":
		return "side to move after white place"
	return ""


func _illegal_keeps_selection() -> String:
	_router.handle_input_commit("e7", "")
	if _router.selected_piece != "e7":
		return "select e7"
	var before_occ: Dictionary = (
		(_router.shared_session.rules.position_field()["occupancy"] as Dictionary).duplicate(true)
	)
	_router.handle_input_commit("e7", "e3")
	if _router.selected_piece != "e7":
		return "illegal keeps selection"
	var after: Dictionary = _router.shared_session.rules.position_field()
	if str(after["side_to_move"]) != "black":
		return "illegal keeps side to move"
	if (after["occupancy"] as Dictionary).has("e3"):
		return "illegal changed position"
	if not before_occ.has("e7"):
		return "illegal cleared origin"
	return ""


func _gesture_b2_changes_selection() -> String:
	# Black selected e7; tap g8 (own knight) must select via B2, not attempt B3 place.
	await _tap_square("g8")
	if _router.selected_piece != "g8":
		return "B2 tap own piece changes selection (got %s)" % _router.selected_piece
	return ""


func _gesture_b3_place() -> String:
	# g8 selected; tap f6 empty destination.
	await _tap_square("f6")
	if _router.selected_piece != "":
		return "B3 clears selection"
	var occ: Dictionary = _router.shared_session.rules.position_field()["occupancy"]
	if not occ.has("f6"):
		return "B3 place g8→f6"
	return ""


func _gesture_b10_pick_and_drag() -> String:
	# White to move after black's knight move; drag unselected d2→d4 (e2 already moved).
	if _router.side_to_move() != "white":
		return "B10 expects white to move"
	_router.selected_piece = ""
	await _drag_square("d2", "d4")
	if _router.selected_piece != "":
		return "B10 clears selection (got %s)" % _router.selected_piece
	var occ: Dictionary = _router.shared_session.rules.position_field()["occupancy"]
	if not occ.has("d4") or occ.has("d2"):
		return "B10 pick-and-drag place"
	return ""


func _gesture_bad_drop_returns() -> String:
	# Wait out prior move tween so begin_drag is accepted, then drag far off-board.
	await create_timer(BoardGeometry.TRAVEL_S + BoardGeometry.SETTLE_S + 0.05).timeout
	_router.handle_input_commit("e7", "")
	var board := _board()
	var origin := _screen_for("e7")
	var far := origin + Vector2(120, 120)
	await _drag_to_screen("e7", far)
	await create_timer(BoardGeometry.TRAVEL_S + 0.05).timeout
	if not is_equal_approx(board.last_return_s, BoardGeometry.TRAVEL_S):
		return "bad drop should run PHY.M5 return (last_return_s=%s)" % board.last_return_s
	return ""


func _promotion_refused_no_auto_queen() -> String:
	var session := SharedGameSession.new()
	session.start_shared("untimed", 3)
	var pieces: Array = [
		{"square": "e7", "color": "white", "kind": "pawn"},
		{"square": "a1", "color": "white", "kind": "king"},
		{"square": "h8", "color": "black", "kind": "king"},
	]
	session.rules.load_position(pieces, "white")
	session._sync_active_to_side_to_move()
	var ok := session.try_move("e7", "e8", "")
	var occ: Dictionary = session.rules.position_field()["occupancy"]
	var piece: Dictionary = occ.get("e7", {})
	var passed := (
		not ok and occ.has("e7") and not occ.has("e8") and str(piece.get("kind", "")) == "pawn"
	)
	return "" if passed else "last-rank place must refuse without auto-queen"


func _resign_flow() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	_router.handle_control("shared-play", "C4")
	var play := _play_panel()
	_router.handle_input_commit("e2", "")
	var s2_ok := (
		_router.stage == "shared-play"
		and _router.play_ui_state == "S2"
		and play.ui_state == "S2"
		and _router.selected_piece == ""
		and bool(_shared_play_state().get("board_unavailable", false))
	)
	if not s2_ok:
		return "resign confirm S2 / C1 unavailable"
	_router.handle_control("shared-play", "cancel")
	if _router.play_ui_state != "S1":
		return "cancel → S1"
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	var result := _result_panel()
	var end_ok := (
		_router.stage == "shared-result"
		and result != null
		and result.visible
		and result.result_key == "result_black"
	)
	if not end_ok:
		return "confirm resign → shared-result NAV.T6"
	_router.handle_control("shared-result", "C2")
	return "" if _router.stage == "mode-pick" else "Stop → mode-pick"


func _s2_board_unavailable_and_clock() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C2")  # blitz
	_router.handle_control("shared-setup", "C5")
	if _router.shared_session == null or _router.shared_session.white_clock_ms == null:
		return "S2 clock setup"
	_router.handle_control("shared-play", "C4")
	var before := int(_router.shared_session.white_clock_ms)
	_router.shared_session.tick(250)
	var after := int(_router.shared_session.white_clock_ms)
	if after >= before:
		return "S2 must keep side-to-move clock running"
	if not bool(_shared_play_state().get("board_unavailable", false)):
		return "S2 board_unavailable"
	if _router.play_gestures_available():
		return "S2 gestures blocked"
	_router.handle_control("shared-play", "cancel")
	return ""


func _pause_halts_clock_and_input() -> String:
	if _router.shared_session == null or _router.shared_session.white_clock_ms == null:
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		_router.handle_control("shared-result", "C2")
		_router.handle_control("mode-pick", "C1")
		_router.handle_control("shared-setup", "C2")
		_router.handle_control("shared-setup", "C5")
	_seams.pause()
	var before := int(_router.shared_session.white_clock_ms)
	# Simulate a process tick path: router must not advance while paused.
	_router._process(0.5)
	var after := int(_router.shared_session.white_clock_ms)
	if after != before:
		_seams.resume()
		return "pause must halt clock tick"
	_router.handle_control("shared-play", "C4")
	if _router.play_ui_state == "S2":
		_seams.resume()
		return "pause must block resign control"
	var count_before := _presentation.pointer_count
	var down := InputEventScreenTouch.new()
	down.pressed = true
	down.index = 0
	down.position = _screen_for("e2")
	_presentation.handle_gui_input(down)
	if _presentation.pointer_count != count_before:
		_seams.resume()
		return "pause must ignore pointers"
	_seams.resume()
	return ""


func _advice_stub() -> String:
	if _router.stage != "shared-play":
		_router.handle_control("mode-pick", "C1")
		_router.handle_control("shared-setup", "C5")
	var before := _router.advice_on
	_router.handle_control("shared-play", "C3")
	if _router.advice_on == before:
		return "advice toggle"
	var snap := _router.play_snapshot()
	if snap.get("advice_best_move") != null or snap.get("advice_eval") != null:
		return "F-move-advice.R2 must not show eval"
	return ""


func _clocks_visible_when_timed() -> String:
	if _router.stage == "shared-play":
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		_router.handle_control("shared-result", "C2")
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C2")  # blitz
	_router.handle_control("shared-setup", "C5")
	if _router.stage != "shared-play":
		return "blitz play stage"
	if _router.shared_session == null or _router.shared_session.white_clock_ms == null:
		return "blitz clocks armed"
	var play := _play_panel()
	var clocks := play.find_child("Clocks", true, false) as Label
	if clocks == null or not clocks.visible:
		return "clocks show for Blitz"
	if not clocks.text.contains(":"):
		return "tabular clock text"
	return ""


func _layout_reserves_chrome() -> String:
	_presentation.size = Vector2(800, 450)
	await process_frame
	var board := _board()
	if board.offset_top < Presentation.PLAY_CHROME_TOP_PX - 0.5:
		return "16:9 board must sit below chrome"
	_presentation.size = Vector2(720, 1280)
	await process_frame
	return ""


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
	await _drag_to_screen(from_sq, _screen_for(to_sq))


func _drag_to_screen(from_sq: String, to_screen: Vector2) -> void:
	var from := _screen_for(from_sq)
	var down := InputEventScreenTouch.new()
	down.pressed = true
	down.index = 0
	down.position = from
	_presentation.handle_gui_input(down)
	var mid := from.lerp(to_screen, 0.5)
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
	up.position = to_screen
	_presentation.handle_gui_input(up)
	await process_frame


func _screen_for(square: String) -> Vector2:
	var board := _board()
	return board.world_to_screen(board.framed_center(square))


func _shared_play_state() -> Dictionary:
	return _router._shared_play_state()


func _play_panel() -> SharedPlayPanel:
	return _presentation.get_node("ScreenHost/SharedPlay") as SharedPlayPanel


func _result_panel() -> SharedResultPanel:
	return _presentation.get_node("ScreenHost/SharedResult") as SharedResultPanel


func _board() -> BoardPresentation:
	return _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
