class_name SharedPlayTest
extends SceneTree
## Headless coverage for UI-shared-play (#58/#94): gestures, choices, clocks, resign.

const _FOCUS_S1 := [
	"SelectFocus", "ClearFocus", "PlaceFocus", "AdviceToggle", "Resign", "OfferDraw"
]
const _FOCUS_S4 := [
	"AdviceToggle",
	"Resign",
	"OfferDraw",
	"PromoteQueen",
	"PromoteRook",
	"PromoteBishop",
	"PromoteKnight",
]
const _FOCUS_S6 := [
	"SelectFocus",
	"ClearFocus",
	"PlaceFocus",
	"AdviceToggle",
	"AcceptDraw",
	"DeclineDraw",
	"WithdrawDraw",
]

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
		_error = _deselect_empty_non_destination()
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
		_error = _promotion_choice_s4()
	if _error.is_empty():
		_error = _promotion_overlay_at_destination()
	if _error.is_empty():
		_error = _draw_offer_flow()
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
		_error = _focus_order_states()
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
	for locale in StringTable.LOCALES:
		for key in StringTable.shared_play_keys():
			var text := StringTable.shared_play(key, locale)
			if text.is_empty() or text == key:
				return "missing copy %s in %s" % [key, locale]
	if StringTable.shared_result("result_white", "en") != "White wins":
		return "shared-result copy"
	if StringTable.shared_play("resign", "zh-Hant") == StringTable.shared_play("resign", "en"):
		return "shared-play resign still English in zh-Hant"
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
	# Occupied non-legal target → EX.rejected / S5 (not empty-square deselect).
	_router.handle_input_commit("e7", "e4")
	var after: Dictionary = _router.shared_session.rules.position_field()
	var fail := _first_fail(
		[
			[_router.selected_piece == "e7", "illegal keeps selection"],
			[_router.play_ui_state == "S5", "illegal enters S5"],
			[str(_router.shared_session.reject_square) == "e4", "PER.R8 reject square"],
			[str(after["side_to_move"]) == "black", "illegal keeps side to move"],
			[not (after["occupancy"] as Dictionary).has("e3"), "illegal changed position"],
			[before_occ.has("e7"), "illegal cleared origin"],
		]
	)
	if not fail.is_empty():
		return fail
	_router.finish_reject_flash()
	if _router.play_ui_state != "S1":
		return "S5 flash ends → S1"
	return ""


func _deselect_empty_non_destination() -> String:
	## PTU-controls.S2 / B9 — unmarked empty clears selection, no flash.
	_router.handle_input_commit("e7", "")
	if _router.selected_piece != "e7":
		return "deselect setup select"
	_router.handle_input_commit("e7", "e3")
	if _router.selected_piece != "":
		return "B9 empty non-destination clears selection"
	if _router.play_ui_state == "S5":
		return "B9 must not flash S5"
	return ""


func _gesture_b2_changes_selection() -> String:
	# Select e7 then tap g8 (own knight) must select via B2, not attempt B3 place.
	_router.handle_input_commit("e7", "")
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
	# PTU-controls.S5 / B11 — bad drop clears selection.
	if _router.selected_piece != "":
		return "B11 bad drop clears selection"
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


func _promotion_choice_s4() -> String:
	## EX.promote / S4 — last-rank place waits on C6; no auto-queen.
	var session := _router.shared_session
	var pieces: Array = [
		{"square": "e7", "color": "white", "kind": "pawn"},
		{"square": "a1", "color": "white", "kind": "king"},
		{"square": "h8", "color": "black", "kind": "king"},
	]
	session.rules.load_position(pieces, "white")
	session._sync_active_to_side_to_move()
	session.selected_piece = "e7"
	session.play_ui_state = SharedGameSession.UI_S1
	var result := session.place("e7", "e8", "")
	var place_fail := _first_fail(
		[
			[
				bool(result.get("promote", false)) and session.play_ui_state == "S4",
				"last-rank place enters S4",
			],
			[session.pending_promote_to == "e8", "pending promote square"],
		]
	)
	if not place_fail.is_empty():
		return place_fail
	var cancel := session.clear_selection()
	var cancel_fail := _first_fail(
		[
			[
				bool(cancel.get("ok", false)) and session.play_ui_state == "S1",
				"S4 deselect drops choice",
			],
			[session.selected_piece == "e7", "S4 deselect leaves pawn selected"],
		]
	)
	if not cancel_fail.is_empty():
		return cancel_fail
	session.place("e7", "e8", "")
	var commit := session.commit_promotion("queen")
	var occ: Dictionary = session.rules.position_field()["occupancy"]
	var on_e8: Dictionary = occ.get("e8", {})
	return _first_fail(
		[
			[bool(commit.get("ok", false)), "C6 commit promotion"],
			[str(on_e8.get("kind", "")) == "queen", "promoted unit on board"],
			[session.play_ui_state == "S1", "commit returns S1"],
		]
	)


func _promotion_overlay_at_destination() -> String:
	## EX.promote sprites sit on the destination square (2×2), not off last-rank.
	var board := _board()
	board.show_promotion_choice("e8", "white", SharedGameSession.PROMOTE_ORDER)
	var dest := BoardGeometry.square_center("e8")
	var seen: Dictionary = {}
	for child in board.get_node("World/Seat/Content/Overlays/PromoteChoice").get_children():
		var node := child as Node2D
		if node == null:
			continue
		var kind := str(node.get_meta("promote_kind", ""))
		seen[kind] = true
		if node.position.distance_to(dest) > 0.55:
			board.clear_promotion_choice()
			return (
				"promote sprite %s off destination (d=%s)" % [kind, node.position.distance_to(dest)]
			)
		# Last-rank must stay inside the board plane (0..8).
		if node.position.y < 0.0 or node.position.y > 8.0:
			board.clear_promotion_choice()
			return "promote sprite %s leaves board (y=%s)" % [kind, node.position.y]
	board.clear_promotion_choice()
	for kind in SharedGameSession.PROMOTE_ORDER:
		if not seen.has(kind):
			return "missing promote kind %s" % kind
	return ""


func _draw_offer_flow() -> String:
	## C5 → S2 offer confirm → S6; Accept → END.D2 → shared-result.
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	var err := _draw_offer_open_decline()
	if not err.is_empty():
		return err
	err = _draw_offer_withdraw_lapse_accept()
	if not err.is_empty():
		return err
	_router.handle_control("shared-result", "C2")
	return ""


func _draw_offer_open_decline() -> String:
	_router.handle_control("shared-play", "C5")
	var play := _play_panel()
	var err := _first_fail(
		[
			[
				(
					_router.play_ui_state == "S2"
					and play.confirm_kind == SharedGameSession.CONFIRM_OFFER
				),
				"C5 opens offer confirm S2",
			]
		]
	)
	if not err.is_empty():
		return err
	_router.handle_control("shared-play", "confirm")
	err = _first_fail(
		[
			[_router.play_ui_state == "S6", "confirm offer → S6"],
			[bool(_shared_play_state().get("c7_available", false)), "S6 Accept available"],
			[_router.play_gestures_available(), "S6 board stay playable"],
		]
	)
	if not err.is_empty():
		return err
	_router.handle_control("shared-play", "C8")
	return _first_fail(
		[
			[_router.play_ui_state == "S1", "Decline → S1"],
			[str(_router.shared_session.draw_offer).is_empty(), "Decline clears offer"],
		]
	)


func _draw_offer_withdraw_lapse_accept() -> String:
	_router.handle_control("shared-play", "C5")
	_router.handle_control("shared-play", "confirm")
	_router.handle_control("shared-play", "C9")
	if _router.play_ui_state != "S1":
		return "Withdraw → S1"
	_router.handle_control("shared-play", "C5")
	_router.handle_control("shared-play", "confirm")
	# Legal place lapses offer.
	_router.handle_input_commit("e2", "")
	_router.handle_input_commit("e2", "e4")
	var err := _first_fail(
		[
			[_router.play_ui_state == "S1", "place lapses S6 → S1"],
			[str(_router.shared_session.draw_offer).is_empty(), "place lapses draw offer"],
		]
	)
	if not err.is_empty():
		return err
	_router.handle_control("shared-play", "C5")
	_router.handle_control("shared-play", "confirm")
	_router.handle_control("shared-play", "C7")
	var result := _result_panel()
	var end_ok := (
		_router.stage == "shared-result"
		and result != null
		and result.visible
		and result.result_key == "result_draw"
	)
	if not end_ok:
		return "Accept → shared-result END.D2"
	return ""


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
	await process_frame
	var board := _board()
	var err := ""
	if board.offset_top < Presentation.PLAY_CHROME_TOP_PX - 0.5:
		err = "16:9 board must sit below chrome"
	if err.is_empty():
		err = _assert_board_fully_visible(board)
	if err.is_empty():
		err = _assert_coords_on_board(board)
	if err.is_empty():
		err = await _assert_chrome_in_reserve_states("16:9")
	if not err.is_empty():
		return err
	_presentation.size = Vector2(720, 1280)
	await process_frame
	await process_frame
	err = _assert_board_fully_visible(board)
	if not err.is_empty():
		return "9:16 %s" % err
	err = _assert_coords_on_board(board)
	if not err.is_empty():
		return err
	return await _assert_chrome_in_reserve_states("9:16")


func _assert_chrome_in_reserve_states(aspect: String) -> String:
	## PRJ.D1 / A1 — every visible PlayChrome child stays above the board top.
	var play := _play_panel()
	if _router.stage != "shared-play":
		_router.handle_control("mode-pick", "C1")
		_router.handle_control("shared-setup", "C5")
	_router.shared_session.play_ui_state = SharedGameSession.UI_S1
	_router.shared_session.confirm_kind = ""
	_router.shared_session.draw_offer = ""
	_router._emit_play_screen()
	await process_frame
	var err := _assert_chrome_children_in_reserve(play, "%s S1 untimed" % aspect)
	if not err.is_empty():
		return err
	_setup_s4_for_focus()
	_router._emit_play_screen()
	await process_frame
	err = _assert_chrome_children_in_reserve(play, "%s S4 untimed" % aspect)
	if not err.is_empty():
		return err
	_router.handle_control("shared-play", "C6:queen")
	# Timed Blitz S4 — clocks row must still fit the reserved strip.
	if _router.stage == "shared-play":
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		_router.handle_control("shared-result", "C2")
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C2")  # blitz
	_router.handle_control("shared-setup", "C5")
	_setup_s4_for_focus()
	_router._emit_play_screen()
	await process_frame
	err = _assert_chrome_children_in_reserve(play, "%s S4 blitz" % aspect)
	if not err.is_empty():
		return err
	# Fresh opening for S6 so a post-promote check cue is not in chrome.
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	_router.handle_control("shared-result", "C2")
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C2")
	_router.handle_control("shared-setup", "C5")
	_router.handle_control("shared-play", "C5")
	_router.handle_control("shared-play", "confirm")
	if _router.play_ui_state != "S6":
		return "%s S6 setup" % aspect
	await process_frame
	err = _assert_chrome_children_in_reserve(play, "%s S6" % aspect)
	if not err.is_empty():
		return err
	_router.handle_control("shared-play", "C8")
	return ""


func _assert_chrome_children_in_reserve(play: SharedPlayPanel, label: String) -> String:
	var chrome := play.find_child("PlayChrome", true, false) as Control
	if chrome == null:
		return "%s PlayChrome missing" % label
	var limit_y := play.get_global_rect().position.y + Presentation.PLAY_CHROME_TOP_PX
	for child in chrome.get_children():
		var node := child as Control
		if node == null or not node.visible:
			continue
		var bottom := node.get_global_rect().end.y
		if bottom > limit_y + 0.5:
			return (
				"%s chrome child %s bottom %.1f past reserve %.1f"
				% [label, node.name, bottom, limit_y]
			)
	return ""


func _assert_board_fully_visible(board: BoardPresentation) -> String:
	## PRJ.A1 / D1 — every corner square centre stays inside the board rect.
	var rect := board.get_global_rect()
	for square in ["a1", "h1", "a8", "h8", "e4"]:
		var screen := board.world_to_screen(board.framed_center(square))
		if not rect.has_point(screen):
			return "square %s cropped at %s in %s" % [square, screen, rect]
	return ""


func _assert_coords_on_board(board: BoardPresentation) -> String:
	## R1 edge coordinates track the board after chrome offset.
	var rect := board.get_global_rect().grow(8.0)
	var coords := board.get_node("Coordinates") as Control
	if coords == null:
		return "coordinates root missing"
	for child in coords.get_children():
		var chip := child as Control
		if chip == null:
			continue
		var center := chip.get_global_rect().get_center()
		if not rect.has_point(center):
			return "coord chip %s at %s outside board" % [chip.name, center]
	return ""


func _focus_order_states() -> String:
	## controls.md F1 — table order on S1/S4/S5/S6 including C10 and C6.
	var play := _play_panel()
	_router._emit_play_screen()
	var err := _assert_focus_names(play, "S1", _FOCUS_S1)
	if err.is_empty():
		err = _focus_order_s5(play)
	if err.is_empty():
		err = _focus_order_s4(play)
	if err.is_empty():
		err = _focus_order_s6(play)
	if err.is_empty():
		err = _focus_order_c10_activate()
	return err


func _focus_order_s5(play: SharedPlayPanel) -> String:
	_router.shared_session.play_ui_state = SharedGameSession.UI_S5
	_router.shared_session.reject_square = "e4"
	_router._emit_play_screen()
	var err := _assert_focus_names(play, "S5", _FOCUS_S1)
	_router.shared_session.finish_reject_flash()
	return err


func _focus_order_s4(play: SharedPlayPanel) -> String:
	_setup_s4_for_focus()
	_router._emit_play_screen()
	var err := _assert_focus_names(play, "S4", _FOCUS_S4)
	if not err.is_empty():
		return err
	_router.handle_control("shared-play", "C6:queen")
	if _router.play_ui_state != SharedGameSession.UI_S1:
		return "C6 focus commit did not leave S4"
	return ""


func _focus_order_s6(play: SharedPlayPanel) -> String:
	_router.handle_control("shared-play", "C5")
	_router.handle_control("shared-play", "confirm")
	if _router.play_ui_state != "S6":
		return "focus S6 setup confirm offer"
	return _assert_focus_names(play, "S6", _FOCUS_S6)


func _focus_order_c10_activate() -> String:
	_router.handle_control("shared-play", "C8")
	var session := _router.shared_session
	session.rules.reset_opening()
	session._sync_active_to_side_to_move()
	session.play_ui_state = SharedGameSession.UI_S1
	session.draw_offer = ""
	var selected := session.select_own("e2")
	if not bool(selected.get("ok", false)):
		return "C10 setup select e2"
	_router._emit_play_screen()
	_router.handle_control("shared-play", "C10")
	if not str(session.selected_piece).is_empty():
		return "C10 focus did not clear selection"
	return ""


func _setup_s4_for_focus() -> void:
	## Minimal white-to-move position with a last-rank pawn choice pending.
	var session := _router.shared_session
	var pieces: Array = [
		{"square": "e7", "color": "white", "kind": "pawn"},
		{"square": "a1", "color": "white", "kind": "king"},
		{"square": "h8", "color": "black", "kind": "king"},
	]
	session.rules.load_position(pieces, "white")
	session._sync_active_to_side_to_move()
	session.selected_piece = "e7"
	session.pending_promote_from = "e7"
	session.pending_promote_to = "e8"
	session.play_ui_state = SharedGameSession.UI_S4
	session.confirm_kind = ""
	session.draw_offer = ""


func _assert_focus_names(play: SharedPlayPanel, state_id: String, expected: Array) -> String:
	if play.ui_state != state_id:
		return "focus order expects %s got %s" % [state_id, play.ui_state]
	var controls := play.focusable_controls()
	var names: PackedStringArray = PackedStringArray()
	for c in controls:
		names.append(c.name)
	if names.size() != expected.size():
		return (
			"focus %s count %d want %d (%s)"
			% [state_id, names.size(), expected.size(), ",".join(names)]
		)
	for i in range(expected.size()):
		if names[i] != str(expected[i]):
			return "focus %s order %s" % [state_id, ",".join(names)]
	play.focus_first()
	if play.get_viewport().gui_get_focus_owner() != controls[0]:
		return "focus_first %s did not land on %s" % [state_id, expected[0]]
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


func _first_fail(checks: Array) -> String:
	for item in checks:
		if not bool(item[0]):
			return str(item[1])
	return ""


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
