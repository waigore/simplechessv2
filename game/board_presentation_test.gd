class_name BoardPresentationTest
extends SceneTree
## Headless checks for #56: geometry, seat flip, timing budgets.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := _check_geometry()
	if err.is_empty():
		var board := BoardPresentation.new()
		board.size = Vector2(720, 1280)
		root.add_child(board)
		await process_frame
		err = _check_seat(board)
		if err.is_empty():
			err = await _check_viewport(board)
		if err.is_empty():
			err = await _check_motion(board)
	if not err.is_empty():
		_fail(err)
		return
	quit(0)


func _check_geometry() -> String:
	var checks: Array = [
		[BoardGeometry.square_center("a1") == Vector2(0.5, 0.5), "SPC a1 center"],
		[BoardGeometry.square_center("e2") == Vector2(4.5, 1.5), "SPC e2 center (PHY.M5 stories)"],
		[BoardGeometry.square_center("h8") == Vector2(7.5, 7.5), "SPC h8 center"],
		[BoardGeometry.PIECE_EXTENT == 0.85, "SPC.E1 piece extent"],
		[
			(
				is_equal_approx(BoardGeometry.visible_size(16.0 / 9.0).y, 10.0)
				and BoardGeometry.visible_size(16.0 / 9.0).x > 10.0
			),
			"PRJ 16:9 visible height",
		],
		[
			(
				is_equal_approx(BoardGeometry.visible_size(9.0 / 16.0).x, 10.0)
				and BoardGeometry.visible_size(9.0 / 16.0).y > 10.0
			),
			"PRJ 9:16 visible width",
		],
		[
			is_equal_approx(BoardGeometry.clamp_aspect(0.1), BoardGeometry.ASPECT_MIN),
			"PRJ letterbox clamp",
		],
		[
			(
				BoardGeometry.apply_seat(Vector2(0.5, 0.5), BoardGeometry.SEAT_TOP)
				== Vector2(7.5, 7.5)
			),
			"CAM-board.M2 a1 maps to h8 frame",
		],
		[
			(
				BoardGeometry.apply_seat(Vector2(4.5, 1.5), BoardGeometry.SEAT_BOTTOM)
				== Vector2(4.5, 1.5)
			),
			"CAM-board.M2 bottom is identity",
		],
		[BoardGeometry.safe_rect(1.0).has_point(Vector2(4.5, 4.5)), "PRJ.A2 safe area"],
		[
			BoardGeometry.is_light_square("a2") and not BoardGeometry.is_light_square("a1"),
			"PER.R2 square parity",
		],
	]
	return _first_fail(checks)


func _check_seat(board: BoardPresentation) -> String:
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	var checks: Array = [
		[board.white_seat == BoardGeometry.SEAT_BOTTOM, "white seat bottom"],
		[board.framed_center("a1") == Vector2(0.5, 0.5), "framed a1 bottom"],
	]
	var err := _first_fail(checks)
	if not err.is_empty():
		return err
	board.set_white_seat(BoardGeometry.SEAT_TOP)
	checks = [
		[board.framed_center("a1") == Vector2(7.5, 7.5), "framed a1 top"],
		[is_equal_approx(board.get_node("World/Seat").rotation, PI), "seat node rotation"],
	]
	err = _first_fail(checks)
	if not err.is_empty():
		return err
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	checks = [
		[is_equal_approx(board.get_node("World/Seat").rotation, 0.0), "seat rotation cleared"],
		[board.camera_offset == Vector2.ZERO, "camera must stay fixed (no offset)"],
	]
	return _first_fail(checks)


func _check_viewport(board: BoardPresentation) -> String:
	board.size = Vector2(720, 1280)
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	await process_frame
	var tall := board.visible_world_size()
	if not is_equal_approx(tall.x, 10.0):
		return "9:16 visible width stays 10"
	board.size = Vector2(1280, 720)
	await process_frame
	var wide := board.visible_world_size()
	if not is_equal_approx(wide.y, 10.0):
		return "16:9 visible height stays 10"
	if BoardGeometry.board_bounds().size != Vector2(8, 8):
		return "SPC.B1 bounds"
	return ""


func _check_motion(board: BoardPresentation) -> String:
	var rules := ChessRules.new()
	rules.reset_opening()
	board.render_position(rules.position_field())
	await process_frame
	var err := await _motion_drag(board, rules)
	if not err.is_empty():
		return err
	err = await _motion_capture_castle(board)
	if not err.is_empty():
		return err
	return await _motion_marks(board, rules)


func _motion_drag(board: BoardPresentation, rules: ChessRules) -> String:
	var checks: Array = [
		[board.piece_world_center("e2") == Vector2(4.5, 1.5), "opening e2 placement"],
	]
	var err := _first_fail(checks)
	if not err.is_empty():
		return err
	board.begin_drag("e2", Vector2(5.2, 2.0))
	checks = [
		[board.piece_world_center("e2") == Vector2(5.2, 2.0), "PHY.M5 follow"],
		[
			(rules.position_field()["occupancy"] as Dictionary).has("e2"),
			"drag must not mutate position"
		],
	]
	err = _first_fail(checks)
	if not err.is_empty():
		return err
	await board.end_drag_illegal()
	checks = [
		[board.last_return_s <= BoardGeometry.TRAVEL_S + 0.0001, "bad drop return over budget"],
		[board.piece_world_center("e2") == Vector2(4.5, 1.5), "bad drop return home"],
	]
	err = _first_fail(checks)
	if not err.is_empty():
		return err
	board.begin_drag("e2", Vector2(4.5, 1.5))
	await board.end_drag_legal("e4")
	checks = [
		[board.last_travel_s <= BoardGeometry.TRAVEL_S + 0.0001, "M1 travel over budget"],
		[board.last_settle_s <= BoardGeometry.SETTLE_S + 0.0001, "settle over budget"],
		[board.piece_world_center("e4") == Vector2(4.5, 3.5), "legal drop lands on e4"],
		[board.camera_offset == Vector2.ZERO, "camera moved during travel"],
	]
	return _first_fail(checks)


func _motion_capture_castle(board: BoardPresentation) -> String:
	(
		board
		. render_position(
			{
				"occupancy":
				{
					"e4": {"color": "white", "kind": "pawn", "square": "e4"},
					"d5": {"color": "black", "kind": "pawn", "square": "d5"},
				},
				"side_to_move": "white",
			}
		)
	)
	await process_frame
	await board.play_move("e4", "d5", "d5")
	var checks: Array = [
		[board.last_travel_s <= BoardGeometry.TRAVEL_S + 0.0001, "capture travel over budget"],
		[
			board.get_node_or_null("World/Seat/Content/Pieces/piece_d5") != null,
			"capture destination piece missing",
		],
		[
			board.get_node_or_null("World/Seat/Content/Pieces/piece_e4") == null,
			"captured origin still keyed",
		],
	]
	var err := _first_fail(checks)
	if not err.is_empty():
		return err
	(
		board
		. render_position(
			{
				"occupancy":
				{
					"e1": {"color": "white", "kind": "king", "square": "e1"},
					"h1": {"color": "white", "kind": "rook", "square": "h1"},
				},
				"side_to_move": "white",
			}
		)
	)
	await process_frame
	await board.play_move("e1", "g1", "", "", "h1", "f1")
	checks = [
		[board.piece_world_center("g1") == Vector2(6.5, 0.5), "castle king end"],
		[board.piece_world_center("f1") == Vector2(5.5, 0.5), "castle rook end"],
	]
	err = _first_fail(checks)
	if not err.is_empty():
		return err
	(
		board
		. render_position(
			{
				"occupancy": {"e8": {"color": "white", "kind": "pawn", "square": "e8"}},
				"side_to_move": "white",
			}
		)
	)
	await process_frame
	await board.play_move("e8", "e8", "", "queen")
	if board.last_travel_s > BoardGeometry.TRAVEL_S + 0.0001:
		return "promotion morph over budget"
	return ""


func _motion_marks(board: BoardPresentation, rules: ChessRules) -> String:
	board.render_position(
		rules.position_field(),
		"e2",
		PackedStringArray(["e3", "e4"]),
		{"white_seat": "bottom", "capture_marks": []}
	)
	await process_frame
	var select := board.get_node_or_null("World/Seat/Content/Overlays/Selection") as Polygon2D
	if select == null or not select.visible:
		return "PER.R3 selection mark missing"
	var legal_root := board.get_node_or_null("World/Seat/Content/Overlays/LegalMarks")
	if legal_root == null or legal_root.get_child_count() < 2:
		return "PER.R4 legal marks missing"
	return ""


func _first_fail(checks: Array) -> String:
	for item in checks:
		if not bool(item[0]):
			return str(item[1])
	return ""


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
