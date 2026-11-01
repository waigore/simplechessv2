class_name BoardMarkFormsTest
extends SceneTree
## Headless checks for PAL.K8 / PAL.K9: the marks the board draws on its squares
## and the one cream foreground they share, on a real BoardPresentation.

## FRM.P1 body box half-width: the widest silhouette / tallest body margin.
const FRM_P1_BODY_HALF := 0.425


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var board := BoardPresentation.new()
	board.size = Vector2(720, 1280)
	root.add_child(board)
	await process_frame
	var err := await _check_check_mark(board)
	if err.is_empty():
		err = await _check_mark_forms(board)
	if not err.is_empty():
		_fail(err)
		return
	quit(0)


func _check_check_mark(board: BoardPresentation) -> String:
	var checked_position := {
		"occupancy":
		{
			"e8": {"color": "black", "kind": "king", "square": "e8"},
			"f7": {"color": "white", "kind": "queen", "square": "f7"},
		},
		"side_to_move": "black",
	}
	var quiet_options := {"side_to_move": "black"}
	board.render_position(checked_position, "", PackedStringArray(), quiet_options)
	await process_frame
	var marks := board.get_node_or_null("World/Seat/Content/Overlays/CheckMarks") as Node2D
	var quiet := _first_fail(
		[
			[marks != null, "PER.R6 check mark node missing"],
			[marks != null and marks.get_child_count() == 0, "PER.R6 mark shown out of check"],
		]
	)
	if not quiet.is_empty() or marks == null:
		return quiet
	board.render_position(
		checked_position, "", PackedStringArray(), {"in_check": true, "side_to_move": "black"}
	)
	await process_frame
	var count_ok := [[marks.get_child_count() == 2, "PER.R6 check cue must be two L-frames"]]
	var shown := _first_fail(
		count_ok + _l_frame_checks(marks.get_children(), BoardGeometry.square_center("e8"))
	)
	if not shown.is_empty():
		return shown
	# PER.R6 / rules.md *Layer split* — the C8 cue rides a PAL.C10 L-frame on the
	# square's one cream foreground.
	var fg := board.mark_layer().mark_foreground()
	shown = _first_fail(
		[
			[fg.marked_squares().has("e8"), "PER.R6 check must raise the C10 foreground"],
			[fg.marks_on("e8").size() == 2, "PER.R6 check draws two cream L-frames"],
			[
				not _keylines(fg.node_for("e8")).is_empty(),
				"UIS.C6 the check foreground must carry a C9 keyline"
			],
		]
	)
	if not shown.is_empty():
		return shown
	# In check with no rendered King of that side must not throw a mark.
	board.render_position(
		checked_position, "", PackedStringArray(), {"in_check": true, "side_to_move": "white"}
	)
	await process_frame
	return _first_fail(
		[
			[marks.get_child_count() == 0, "PER.R6 in check without a rendered King threw a mark"],
			[
				not fg.marked_squares().has("e8"),
				"PER.R6 the cream foreground must clear with the cue"
			],
		]
	)


## PAL.K9 form: two asymmetric L-frames, C8, inside the square and off the body.
func _l_frame_checks(children: Array, center: Vector2) -> Array:
	var checks: Array = []
	for child in children:
		var line := child as Line2D
		checks.append([line != null, "PER.R6 check cue must be a stroke"])
		if line == null:
			continue
		checks.append(
			[line.default_color == CheckMarks.COLOR_CHECK, "PER.R6 check cue must be PAL.C8"]
		)
		checks.append(
			[
				line.default_color != BoardDestinationMarks.COLOR_SELECT,
				"PAL.K9 check cue must differ from the selection ring"
			]
		)
		checks.append([line.get_point_count() == 3, "PAL.K9 check cue must be an L-frame"])
		if line.get_point_count() != 3:
			continue
		checks.append([_arms_unequal(line), "PAL.K9 check L arms must be unequal, not a bracket"])
		for i in line.get_point_count():
			var point := line.get_point_position(i)
			var dx := absf(point.x - center.x)
			var dy := absf(point.y - center.y)
			checks.append([dx <= 0.5 and dy <= 0.5, "PER.R6 check cue left the King square"])
			checks.append([maxf(dx, dy) >= FRM_P1_BODY_HALF, "PER.R1 check cue covers the body"])
	return checks


func _arms_unequal(line: Line2D) -> bool:
	var first := line.get_point_position(0).distance_to(line.get_point_position(1))
	var second := line.get_point_position(1).distance_to(line.get_point_position(2))
	return not is_equal_approx(first, second)


## #792 — every form the landed PAL.K8 / PAL.K9 rows require, measured from the
## nodes the board actually drew.
func _check_mark_forms(board: BoardPresentation) -> String:
	# Earlier motion checks left a last-move pair behind; these forms start clean.
	board.clear_last_move()
	await process_frame
	# The narrowest viewport PRJ.P1 names: 36 px a square, so a 1.5 px floor is
	# 0.04167 world units and the 0.04 tick really is 1.44 px.
	root.size = Vector2i(360, 640)
	board.size = Vector2(360, 640)
	await process_frame
	var narrow := _first_fail(
		[
			[is_equal_approx(board.world_px(), 36.0), "PRJ.P1 px a square at 360 × 640"],
			[
				is_equal_approx(BoardDestinationMarks.SELECT_STROKE * board.world_px(), 2.16),
				"UIS.I1 the 0.06 selection ring must measure 2.16 px"
			],
			[
				is_equal_approx(BoardDestinationMarks.LEGAL_BRACKET_W * board.world_px(), 2.16),
				"UIS.I1 the 0.06 capture bracket must measure 2.16 px"
			],
			[
				is_equal_approx(BoardMarkLayer.TICK_W * board.world_px(), 1.44),
				"PAL.K9 the 0.04 tick fill must measure 1.44 px"
			],
		]
	)
	if not narrow.is_empty():
		return narrow
	var err := await _check_empty_disk(board)
	if err.is_empty():
		err = await _check_capture_brackets(board)
	if err.is_empty():
		err = await _check_no_cream_from_legal_marks(board)
	if err.is_empty():
		err = await _check_refused_hatch(board)
	if err.is_empty():
		err = await _check_last_move(board)
	if err.is_empty():
		err = await _check_advice_shares_foreground(board)
	if err.is_empty():
		err = _check_coord_chip(board)
	root.size = Vector2i(720, 1280)
	board.size = Vector2(720, 1280)
	await process_frame
	return err


## PER.R4 / rules-k9.md — an empty destination is a solid PAL.C11 disk at the
## square centre, area πr² ≥ 1/4, never the old diamond.
func _check_empty_disk(board: BoardPresentation) -> String:
	(
		board
		. render_position(
			{
				"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
				"side_to_move": "white",
			},
			"e2",
			PackedStringArray(["e3", "e4"]),
			{"capture_marks": []}
		)
	)
	await process_frame
	var legal_root := board.get_node_or_null("World/Seat/Content/Overlays/LegalMarks")
	if legal_root == null or legal_root.get_child_count() != 2:
		return "PER.R4 two empty destinations must draw two marks"
	for child in legal_root.get_children():
		var err := _first_fail(_empty_disk_checks(child))
		if not err.is_empty():
			return err
	return ""


## A disk: many vertices, all at the kept radius from the square centre. The
## diamond this replaced had four, at 0.36 along the axes.
func _empty_disk_checks(child: Node) -> Array:
	var disk := child as Polygon2D
	if disk == null or disk.color != BoardDestinationMarks.COLOR_LEGAL:
		return [[false, "PER.R4 empty mark must be a full-opacity PAL.C11 disk"]]
	var centre := BoardGeometry.square_center("e3")
	if disk.name.begins_with("EmptyDisk_"):
		var square := disk.name.trim_prefix("EmptyDisk_")
		centre = BoardGeometry.square_center(square)
	var points := disk.polygon
	var area := _polygon_area(points)
	var checks: Array = [
		[points.size() >= 16, "PER.R4 empty mark must be a disk, not a diamond"],
		[area >= 0.25 - 0.0001, "PER.R4 disk area %.3f under 1/4 square" % area],
	]
	for point in points:
		if not is_equal_approx(
			(point as Vector2).distance_to(centre), BoardDestinationMarks.LEGAL_EMPTY_R
		):
			checks.append([false, "PER.R4 disk vertex off the 0.36 radius"])
			break
	# The drawn disk is a 32-gon, 0.6% under its circle: πr² = 0.407, not the old
	# diamond's 2r² = 0.259.
	var circle := PI * pow(BoardDestinationMarks.LEGAL_EMPTY_R, 2.0)
	if absf(area - circle) > circle * 0.01:
		checks.append([false, "PER.R4 disk must be a full circle (πr² = 0.407)"])
	return checks


## Shoelace area of a polygon, in square units.
static func _polygon_area(points: PackedVector2Array) -> float:
	var sum := 0.0
	for i in points.size():
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		sum += a.x * b.y - b.x * a.y
	return absf(sum) * 0.5


## PER.R4 / rules-k9.md — a capture destination is corner brackets: two strokes per
## corner, inside the square, stroke 0.06 / arm 0.56, and no ring at all.
func _check_capture_brackets(board: BoardPresentation) -> String:
	(
		board
		. render_position(
			{
				"occupancy":
				{
					"e2": {"color": "white", "kind": "pawn", "square": "e2"},
					"d3": {"color": "black", "kind": "pawn", "square": "d3"},
				},
				"side_to_move": "white",
			},
			"e2",
			PackedStringArray(["d3"]),
			{"capture_marks": ["d3"]}
		)
	)
	await process_frame
	var legal_root := board.get_node_or_null("World/Seat/Content/Overlays/LegalMarks")
	if legal_root == null or legal_root.get_child_count() != 1:
		return "PER.R4 the capture destination must draw one mark"
	var group := legal_root.get_child(0) as Node2D
	if group == null:
		return "PER.R4 capture mark missing"
	var centre := BoardGeometry.square_center("d3")
	var checks: Array = [[group.get_child_count() == 8, "PER.R4 capture must be 8 bracket strokes"]]
	var ink := 0.0
	var arms_ok := true
	for child in group.get_children():
		var stroke := child as Line2D
		checks.append([stroke != null, "PER.R4 capture brackets must be strokes"])
		if stroke == null:
			continue
		checks.append([not stroke.closed, "PER.R4 capture brackets must not be a ring"])
		checks.append(
			[
				is_equal_approx(stroke.width, BoardDestinationMarks.LEGAL_BRACKET_W),
				"PER.R4 capture bracket stroke %s, want 0.06" % stroke.width
			]
		)
		checks.append(
			[
				stroke.default_color == BoardDestinationMarks.COLOR_LEGAL,
				"PER.R4 capture must use PAL.C11"
			]
		)
		var length := stroke.get_point_position(0).distance_to(stroke.get_point_position(1))
		arms_ok = arms_ok and is_equal_approx(length, BoardDestinationMarks.LEGAL_BRACKET_ARM)
		for i in stroke.get_point_count():
			var point := stroke.get_point_position(i)
			checks.append(
				[
					absf(point.x - centre.x) <= 0.5 and absf(point.y - centre.y) <= 0.5,
					"PER.R4 capture bracket left the square"
				]
			)
		ink += stroke.width * length
	checks.append(
		[
			arms_ok,
			"PER.R4 capture bracket arm %s, want 0.56" % BoardDestinationMarks.LEGAL_BRACKET_ARM
		]
	)
	checks.append([ink >= 0.25 - 0.0001, "PER.R4 capture brackets cover %.3f, under 1/4" % ink])
	for child in legal_root.get_children():
		if child is Line2D and (child as Line2D).closed:
			checks.append([false, "PAL.K9 selection must stay the only closed ring"])
	return _first_fail(checks)


## UIS.C6 — legal destinations draw on the square, so they must never raise a
## cream foreground: a board of eight destinations does not turn cream.
func _check_no_cream_from_legal_marks(board: BoardPresentation) -> String:
	(
		board
		. render_position(
			{
				"occupancy": {"d4": {"color": "white", "kind": "queen", "square": "d4"}},
				"side_to_move": "white",
			},
			"d4",
			PackedStringArray(["a4", "b4", "c4", "e4", "f4", "g4", "h4", "d5"]),
			{"capture_marks": []}
		)
	)
	await process_frame
	var fg := board.mark_layer().mark_foreground()
	return _first_fail(
		[
			[
				fg.marked_squares().is_empty(),
				"UIS.C6 legal marks must not raise a cream foreground"
			],
			[_cream_nodes(fg).is_empty(), "UIS.C6 no cream node may exist without a cream mark"],
		]
	)


## PER.R8 — the refused place hatches the square's own fill in PAL.C8 under the
## 0.3 s flash: no cream foreground, no keyline, and selection and legal marks
## return when it fades. A clock-tick refresh never restarts the tween.
func _check_refused_hatch(board: BoardPresentation) -> String:
	(
		board
		. render_position(
			{
				"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
				"side_to_move": "white",
			},
			"e2",
			PackedStringArray(["e3", "e4"]),
			{"reject_square": "d2", "ui_state": "S5", "capture_marks": []}
		)
	)
	await process_frame
	var hatch := board.mark_layer().reject_hatch()
	var tween: Tween = board._reject_tween
	var select := board.get_node_or_null("World/Seat/Content/Overlays/Selection") as Line2D
	var legal_root := board.get_node_or_null("World/Seat/Content/Overlays/LegalMarks")
	var checks: Array = [
		[hatch != null and hatch.visible, "PER.R8 refused place must hatch the square"],
		[hatch != null and hatch.get_child_count() >= 4, "PER.R8 hatching must cross the square"],
		[
			board.mark_layer().mark_foreground().marked_squares().is_empty(),
			"PER.R8 the hatch needs no cream foreground (rules.md Layer split)"
		],
		[_keylines(hatch).is_empty(), "PER.R8 the hatch must carry no keyline"],
		[select != null and select.visible, "PER.R3 selection must stay drawn under the flash"],
		[
			legal_root != null and legal_root.get_child_count() == 2,
			"PER.R4 legal marks must stay drawn"
		],
	]
	if hatch != null:
		for child in hatch.get_children():
			var stroke := child as Line2D
			if stroke == null or stroke.default_color != BoardPresentation.COLOR_DANGER:
				checks.append([false, "PER.R8 hatching must be PAL.C8"])
				break
	var err := _first_fail(checks)
	if not err.is_empty():
		return err
	# A clock-tick refresh of the same refused square must not restart the flash.
	(
		board
		. render_position(
			{
				"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
				"side_to_move": "white",
			},
			"e2",
			PackedStringArray(["e3", "e4"]),
			{"reject_square": "d2", "ui_state": "S5", "capture_marks": []}
		)
	)
	await process_frame
	if board._reject_tween != tween:
		return "PER.R8 a clock-tick refresh restarted the 0.3 s flash"
	await create_timer(SharedGameSession.REJECT_FLASH_S + 0.15).timeout
	return _first_fail(
		[
			[not hatch.visible, "PER.R8 the hatch must fade with the flash"],
			[select != null and select.visible, "PER.R8 selection must return after the flash"],
			[
				legal_root != null and legal_root.get_child_count() == 2,
				"PER.R8 legal marks must return after the flash"
			],
		]
	)


## PER.R9 — the last move on two squares: a soft PAL.C7 band on the from-square's
## edge away from the move, and four PAL.C10 corner ticks on the to-square's one
## cream foreground. Both survive a CAM-board.M2 180° flip unchanged.
func _check_last_move(board: BoardPresentation) -> String:
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	(
		board
		. render_position(
			{
				"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
				"side_to_move": "white",
			}
		)
	)
	await process_frame
	await board.play_move("e2", "e4")
	await process_frame
	var moved := board.last_move()
	var err := _first_fail(
		[[moved[0] == "e2" and moved[1] == "e4", "PER.R9 last move must follow the move"]]
	)
	if not err.is_empty():
		return err
	err = _band_checks(board, "e2", "e4")
	if not err.is_empty():
		return err
	err = _tick_checks(board, "e4", "e2")
	if not err.is_empty():
		return err
	board.set_white_seat(BoardGeometry.SEAT_TOP)
	await process_frame
	err = _first_fail(
		[
			[
				_band_on_away_edge(board, "e2", "e4"),
				"PER.R9 band must stay away from the move after a flip"
			],
			[
				_ticks_face_from(board, "e4", "e2"),
				"PER.R9 ticks must face the from-square after a flip"
			],
		]
	)
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	await process_frame
	return err


## Soft, open, PAL.C7, on the from-square's edge facing away from the to-square.
func _band_checks(board: BoardPresentation, from_square: String, to_square: String) -> String:
	var band := board.mark_layer().last_move_band()
	var checks: Array = [
		[band != null, "PER.R9 from-square band missing"],
		[
			band != null and band.get_child_count() >= 2,
			"PER.R9 the band must be soft, not one stroke"
		],
		[_keylines(band).is_empty(), "PER.R9 the band must carry no keyline (rules.md)"],
		[
			_band_on_away_edge(board, from_square, to_square),
			"PER.R9 band must sit away from the move"
		],
		[_band_body_coverage() <= 0.10, "PER.R9 band covers too much of the King body"],
		[
			float(BoardMarkLayer.BAND_LAYERS[2][0]) * board.world_px() >= 1.5 - 0.001,
			"UIS.I1 every band layer must clear 1.5 screen px"
		],
	]
	if band != null:
		for child in band.get_children():
			var stroke := child as Line2D
			if stroke == null or stroke.closed:
				checks.append([false, "PER.R9 the band must be open and never enclose"])
				continue
			if stroke.default_color.a >= 0.6:
				checks.append([false, "PER.R9 the band must be blurred, not a hard stroke"])
			if stroke.default_color.to_html(false) != AdviceMarks.COLOR_ADVICE.to_html(false):
				checks.append([false, "PER.R9 the band must be PAL.C7"])
	return _first_fail(checks)


## The share of the King's body the widest band layer lies over: the King body's
## half-width (FRM.P1 0.425) against the band's inner edge, times the band length.
static func _band_body_coverage() -> float:
	const KING_BODY_AREA := 0.1274
	var widest := float(BoardMarkLayer.BAND_LAYERS[0][0])
	var inner := 0.5 - widest
	var overlap := maxf(0.0, FRM_P1_BODY_HALF - inner) * BoardMarkLayer.BAND_LENGTH
	return overlap / KING_BODY_AREA


## The band's midpoint is on the from-square's rim, on the side away from the move.
func _band_on_away_edge(board: BoardPresentation, from_square: String, to_square: String) -> bool:
	var band := board.mark_layer().last_move_band()
	if band == null or band.get_child_count() == 0:
		return false
	var stroke := band.get_child(0) as Line2D
	if stroke == null or stroke.get_point_count() < 2:
		return false
	var mid := (stroke.get_point_position(0) + stroke.get_point_position(1)) * 0.5
	var from_center := BoardGeometry.square_center(from_square)
	var to_center := BoardGeometry.square_center(to_square)
	var away := from_center - to_center
	if (mid - from_center).dot(away) <= 0.0:
		return false
	# On the rim, and beyond every body half-width so it covers no body (SPC.E1).
	var edge := maxf(absf(mid.x - from_center.x), absf(mid.y - from_center.y))
	return edge > FRM_P1_BODY_HALF and edge <= 0.5


## Four corner Ls in the to-square's outer 0.10, 0.04 wide, 0.60 long on the edge
## parallel to the from-facing one, each L arm 0.10, on that square's foreground.
func _tick_checks(board: BoardPresentation, to_square: String, from_square: String) -> String:
	var fg := board.mark_layer().mark_foreground()
	var marks := fg.marks_on(to_square)
	var checks: Array = [
		[fg.marked_squares().has(to_square), "PER.R9 the to-square must carry a cream foreground"],
		[marks.size() == 4, "PER.R9 the to-square must carry four corner ticks"],
		[
			_ticks_face_from(board, to_square, from_square),
			"PER.R9 tick arms must miss the tick geometry"
		],
		[_cream_layers(fg, to_square) == 1, "UIS.C6 a square draws one cream foreground"],
	]
	var node := fg.node_for(to_square)
	if node != null:
		var keylines := _keylines(node)
		checks.append([not keylines.is_empty(), "UIS.C6 the foreground must carry a C9 keyline"])
		for line in keylines:
			var keyline := line as Line2D
			checks.append(
				[
					keyline.width * board.world_px() >= MarkForeground.KEYLINE_PX - 0.001,
					"UIS.I1 the foreground keyline is %.2f px" % (keyline.width * board.world_px())
				]
			)
			checks.append(
				[
					keyline.default_color == MarkForeground.COLOR_INK,
					"UIS.C6 the keyline must be PAL.C9"
				]
			)
	for mark_var in marks:
		var mark: Dictionary = mark_var
		var points: PackedVector2Array = mark.get("points", PackedVector2Array())
		checks.append([points.size() == 3, "PER.R9 a tick is an L"])
		checks.append(
			[
				is_equal_approx(float(mark.get("width", 0.0)), BoardMarkLayer.TICK_W),
				"PER.R9 tick 0.04 wide"
			]
		)
		if points.size() != 3:
			continue
		var elbow := points[1]
		var long_arm := points[0].distance_to(elbow)
		var short_arm := elbow.distance_to(points[2])
		checks.append(
			[is_equal_approx(long_arm, BoardMarkLayer.TICK_LONG), "PER.R9 tick 0.60 long"]
		)
		checks.append(
			[is_equal_approx(short_arm, BoardMarkLayer.TICK_ARM), "PER.R9 tick L arm 0.10"]
		)
		var centre := BoardGeometry.square_center(to_square)
		var offset := maxf(absf(elbow.x - centre.x), absf(elbow.y - centre.y))
		checks.append(
			[
				offset <= 0.5 and offset >= 0.5 - BoardMarkLayer.TICK_BAND,
				"PER.R9 tick must sit outside 0.10"
			]
		)
	return _first_fail(checks)


## The long arm runs parallel to the from-facing edge, which is a property of the
## move and survives CAM-board.M2.
func _ticks_face_from(board: BoardPresentation, to_square: String, from_square: String) -> bool:
	var fg := board.mark_layer().mark_foreground()
	var marks := fg.marks_on(to_square)
	if marks.size() != 4:
		return false
	var facing := BoardGeometry.square_center(from_square) - BoardGeometry.square_center(to_square)
	var axis := (
		Vector2(signf(facing.x), 0.0)
		if absf(facing.x) >= absf(facing.y)
		else Vector2(0.0, signf(facing.y))
	)
	for mark_var in marks:
		var points: PackedVector2Array = (mark_var as Dictionary).get(
			"points", PackedVector2Array()
		)
		if points.size() != 3:
			return false
		if absf((points[0] - points[1]).normalized().dot(axis)) > 0.001:
			return false
	return true


## UIS.C6 / rules.md *One layer* — Advice's brackets draw on the one cream
## foreground of a square that already carries the ticks, never a second one.
func _check_advice_shares_foreground(board: BoardPresentation) -> String:
	board.render_advice({"from": "d3", "to": "e4"})
	await process_frame
	var fg := board.mark_layer().mark_foreground()
	var marks := fg.marks_on("e4")
	var checks: Array = [
		[fg.marked_squares().has("e4"), "UIS.C6 the ticked square must keep its foreground"],
		[marks.size() == 8, "UIS.C6 Advice must share the ticked square's one foreground"],
		[_cream_layers(fg, "e4") == 1, "rules.md One layer: a square draws one cream foreground"],
		[_cream_layers(fg, "d3") == 1, "UIS.C6 the Advice from-square draws one foreground"],
		[
			_foreground_nodes(fg).size() == fg.marked_squares().size(),
			"UIS.C6 one foreground node per marked square"
		],
	]
	var found_brackets := false
	for mark_var in marks:
		var mark: Dictionary = mark_var
		if str(mark.get("source", "")) == "advice":
			found_brackets = true
			checks.append(
				[
					float(mark.get("width", 0.0)) == AdviceMarks.ADVICE_STROKE,
					"PER.R5 bracket stroke"
				]
			)
	checks.append([found_brackets, "PER.R5 Advice brackets must draw on the foreground"])
	board.render_advice(null)
	await process_frame
	checks.append(
		[
			fg.node_for("e4") != null and fg.marks_on("e4").size() == 4,
			"Advice Off must leave only the ticks"
		]
	)
	return _first_fail(checks)


## PAL.K8 / UIS.I1 — the coordinate chip draws C9 ink on a C10 chip with the
## 1.5 px C9 keyline, so the pair PAL.K8 tests is the pair drawn.
func _check_coord_chip(board: BoardPresentation) -> String:
	var chip := board.get_node_or_null("Coordinates/file_a_chip") as Panel
	if chip == null:
		return "PAL.K8 coordinate chip missing"
	var style := chip.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return "PAL.K8 coordinate chip has no style"
	return _first_fail(
		[
			[style.bg_color == BoardPresentation.COLOR_CREAM, "PAL.K8 the chip must be PAL.C10"],
			[
				style.border_color == BoardPresentation.COLOR_INK,
				"PAL.K8 the chip keyline must be PAL.C9"
			],
			[
				float(style.border_width_left) >= MarkForeground.KEYLINE_PX,
				"UIS.I1 the chip keyline %d px, under 1.5" % style.border_width_left
			],
		]
	)


func _keylines(root: Node) -> Array:
	var out: Array = []
	if root == null:
		return out
	for child in root.find_children("Keyline", "Line2D", true, false):
		out.append(child)
	return out


func _foreground_nodes(fg: MarkForeground) -> Array:
	var out: Array = []
	for child in fg.get_children():
		if str((child as Node).name).begins_with("Mark_"):
			out.append(child)
	return out


func _cream_nodes(fg: MarkForeground) -> Array:
	var out: Array = []
	for child in fg.find_children("Plate", "Polygon2D", true, false):
		out.append(child)
	return out


## Cream layers on one square: its single foreground node, whatever it carries.
func _cream_layers(fg: MarkForeground, square: String) -> int:
	var count := 0
	for child in _foreground_nodes(fg):
		if str((child as Node).get_meta("mark_square", "")) == square:
			count += 1
	return count


func _first_fail(checks: Array) -> String:
	for item in checks:
		if not bool(item[0]):
			return str(item[1])
	return ""


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
