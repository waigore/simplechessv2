class_name BoardPresentationTest
extends SceneTree
## Headless checks for #56: geometry, seat flip, timing budgets.

## FRM.P1 body box half-width: the widest silhouette / tallest body margin.
const FRM_P1_BODY_HALF := 0.425


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
			err = _check_accessible_name_meta(board)
		if err.is_empty():
			err = await _check_art_orientation(board)
		if err.is_empty():
			err = await _check_viewport(board)
		if err.is_empty():
			err = await _check_tap_round_trip(board)
		if err.is_empty():
			err = await _check_orientation(board)
		if err.is_empty():
			err = await _check_motion(board)
		if err.is_empty():
			err = await _check_check_mark(board)
		if err.is_empty():
			err = await _check_mark_forms(board)
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


## #617: _world mirrors board space (board y up, screen y down); every raster
## sprite must cancel that locally so art reads as authored under CAM-board.M2.
func _check_art_orientation(board: BoardPresentation) -> String:
	var assets := _synthetic_assets()
	var rules := ChessRules.new()
	rules.reset_opening()
	board.provide_assets(assets)
	for seat in [BoardGeometry.SEAT_BOTTOM, BoardGeometry.SEAT_TOP]:
		board.render_position(rules.position_field(), "", PackedStringArray(), {"white_seat": seat})
		board.show_promotion_choice("e8", "white")
		await process_frame
		var err := _orientation_checks(board, seat)
		board.clear_promotion_choice()
		if not err.is_empty():
			return err
		# Re-entry: provide_assets() re-enters _apply_kind_texture(); the sign must persist.
		board.provide_assets(assets)
		await process_frame
		err = _orientation_scale_checks(board, seat, false)
		if not err.is_empty():
			return err
	board.clear_promotion_choice()
	await process_frame
	return await _settle_restores_scale(board)


## A white field with a dark top-left pixel: any mirror or 180° move is detectable.
func _synthetic_assets() -> Dictionary:
	var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	image.set_pixel(0, 0, Color("202020"))
	var texture := ImageTexture.create_from_image(image)
	var assets := {BoardPresentation.BOARD_BG_ID: texture}
	for key in BoardPresentation.PIECE_IDS.keys():
		assets[str(BoardPresentation.PIECE_IDS[key])] = texture
	return assets


func _orientation_checks(board: BoardPresentation, seat: String) -> String:
	var err := _orientation_scale_checks(board, seat, true)
	if not err.is_empty():
		return err
	var piece := _sprite_at(board, "World/Seat/Content/Pieces/piece_e1")
	if piece == null:
		return "orientation setup missing e1"
	var transform := piece.get_global_transform_with_canvas()
	var det := transform.x.cross(transform.y)
	if det <= 0.0:
		return "piece art mirrored at seat %s (global determinant %.2f)" % [seat, det]
	var want_rotation := 0.0 if seat == BoardGeometry.SEAT_BOTTOM else PI
	if absf(angle_difference(transform.get_rotation(), want_rotation)) > 0.001:
		return (
			"piece rotation at seat %s is %.3f, want %.3f"
			% [seat, transform.get_rotation(), want_rotation]
		)
	return _marked_corner_error(piece, seat)


func _orientation_scale_checks(
	board: BoardPresentation, seat: String, with_chooser: bool
) -> String:
	var specs: Array = [
		["piece", _sprite_at(board, "World/Seat/Content/Pieces/piece_e1")],
		["board backdrop", _sprite_at(board, "World/Seat/Content/Board/BoardBackdrop")],
	]
	if with_chooser:
		specs.insert(1, ["promotion chooser", _promote_sprite(board, "knight")])
	for spec in specs:
		var err := _art_scale_error(spec[1] as Sprite2D, str(spec[0]), seat)
		if not err.is_empty():
			return err
	return ""


func _art_scale_error(sprite: Sprite2D, label: String, seat: String) -> String:
	if sprite == null:
		return "%s sprite missing at seat %s" % [label, seat]
	# No texture means _apply_kind_texture never scaled, so the sign check would pass
	# vacuously (#617 step 1).
	if sprite.texture == null:
		return "%s sprite has no texture at seat %s" % [label, seat]
	if sprite.scale.x <= 0.0 or sprite.scale.y >= 0.0:
		return (
			"%s art must cancel the world Y mirror at seat %s (scale %s)"
			% [label, seat, sprite.scale]
		)
	return ""


func _marked_corner_error(sprite: Sprite2D, seat: String) -> String:
	var tex := sprite.texture
	var corner := -Vector2(float(tex.get_width()), float(tex.get_height())) * 0.5
	var transform := sprite.get_global_transform_with_canvas()
	var offset := transform * corner - transform * Vector2.ZERO
	if seat == BoardGeometry.SEAT_BOTTOM:
		if offset.x >= 0.0 or offset.y >= 0.0:
			return "art marker at %s at seat %s, want the sprite's screen top-left" % [offset, seat]
	elif offset.x <= 0.0 or offset.y <= 0.0:
		return "art marker at %s at seat %s, want the sprite's screen bottom-right" % [offset, seat]
	return ""


## #617: parents queue_free their children, so a rebuilt chooser is renamed
## @Node2D@…; look sprites up by their promote_kind meta, never by node name.
func _promote_sprite(board: BoardPresentation, kind: String) -> Sprite2D:
	var root := board.get_node_or_null("World/Seat/Content/Overlays/PromoteChoice")
	if root == null:
		return null
	for child in root.get_children():
		var node := child as Node2D
		if node == null or str(node.get_meta("promote_kind", "")) != kind:
			continue
		return node.get_node_or_null("Sprite") as Sprite2D
	return null


func _sprite_at(board: BoardPresentation, path: String) -> Sprite2D:
	var node := board.get_node_or_null(path)
	if node == null:
		return null
	if node is Sprite2D:
		return node as Sprite2D
	return node.get_node_or_null("Sprite") as Sprite2D


## #617 step 7: _settle squashes toward base * (1, 0.92) and restores base.
func _settle_restores_scale(board: BoardPresentation) -> String:
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
	var err := _art_scale_error(
		_sprite_at(board, "World/Seat/Content/Pieces/piece_e2"), "settle pawn", "bottom"
	)
	if not err.is_empty():
		return err
	var base := (_sprite_at(board, "World/Seat/Content/Pieces/piece_e2") as Sprite2D).scale
	board.update_drag("begin", {"square": "e2", "world": Vector2(4.5, 1.5)})
	await board.end_drag_legal("e4")
	var settled := _sprite_at(board, "World/Seat/Content/Pieces/piece_e4")
	if settled == null:
		return "settle landed piece missing on e4"
	if not settled.scale.is_equal_approx(base):
		return "settle did not restore the art scale (%s → %s)" % [base, settled.scale]
	return ""


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
	# Wider than 16:9 (chrome-reserved strip): pillarbox inside rect, never crop.
	board.size = Vector2(800, 282)
	await process_frame
	var rect := board.get_global_rect()
	for square in ["a1", "h1", "a8", "h8"]:
		var screen := board.world_to_screen(board.framed_center(square))
		if not rect.has_point(screen):
			return "ultra-wide crops %s at %s" % [square, screen]
	var clamped := board.visible_world_size()
	if not is_equal_approx(clamped.y, 10.0):
		return "pillarbox visible height stays 10"
	return ""


## #845 — a tap on a *painted* square must select that square. The exported
## build plays the project's 1280×720 base through `canvas_items`/`expand`, so
## the frame is a non-identity stretch of the canvas; the inverse half of the
## check therefore goes through that stretch, exactly as a pointer does. A test
## under the identity transform a bare runner starts with would pass either way
## and prove nothing.
func _check_tap_round_trip(board: BoardPresentation) -> String:
	_apply_release_stretch()
	var squares := ["a1", "e1", "h1", "a2", "e2", "e4", "d4", "e5", "a8", "h8"]
	var stretched := false
	for frame in [Vector2i(720, 1280), Vector2i(1280, 720), Vector2i(800, 282), Vector2i(390, 844)]:
		root.size = frame
		await process_frame
		board.size = root.get_visible_rect().size
		await process_frame
		var stretch := root.get_final_transform()
		# 1280×720 *is* the base, so its stretch is legitimately identity; every
		# other frame must arrive through a real transform or the check is hollow.
		if frame == Vector2i(1280, 720):
			if stretch != Transform2D.IDENTITY:
				return "#845 the base frame must play at 1:1"
		elif stretch == Transform2D.IDENTITY:
			return "#845 identity stretch at %s — the check would prove nothing" % frame
		else:
			stretched = true
		var problem := _check_painted_squares(board, stretch, frame, squares)
		if not problem.is_empty():
			return problem
	_reset_release_stretch(board)
	if not stretched:
		return "#845 no frame exercised a canvas stretch"
	return ""


func _check_painted_squares(
	board: BoardPresentation, stretch: Transform2D, frame: Vector2i, squares: Array
) -> String:
	# The frame in the stretch's own pixels: the control fills the frame, so its
	# stretched size is the frame the build plays into.
	var frame_rect := Rect2(Vector2.ZERO, stretch * board.size)
	for square in squares:
		var painted: Vector2 = stretch * board.world_to_screen(board.framed_center(square))
		if not frame_rect.has_point(painted):
			return "#845 %s paints outside %s at %s" % [square, frame, painted]
		# The pointer path receives canvas coordinates; the painted point only
		# becomes one after the frame's own stretch is removed (#845).
		var delivered := stretch.affine_inverse() * painted
		var hit := BoardGeometry.square_at(board.screen_to_world(delivered))
		if hit != square:
			return "#845 tap on painted %s hit %s at %s" % [square, hit, frame]
	return _check_painted_frame(board, stretch, frame)


## Half two: the paint itself must sit where the frame's geometry puts it, not
## merely invert against itself. PRJ.A1 centres the eye on the board and never
## crops, so its world centre lands on the control's centre and, on a portrait
## frame, the 10-unit visible width is the frame's full width.
func _check_painted_frame(
	board: BoardPresentation, stretch: Transform2D, frame: Vector2i
) -> String:
	var painted_centre := stretch * board.world_to_screen(BoardGeometry.BOARD_CENTER)
	var control_centre := stretch * (board.get_global_transform_with_canvas() * (board.size * 0.5))
	if painted_centre.distance_to(control_centre) > 1.0:
		return (
			"#845 board centre paints at %s, not the control centre %s"
			% [painted_centre, control_centre]
		)
	var control_px: Vector2 = stretch * board.size
	if frame.y > frame.x:
		var span := stretch * board.world_to_screen(Vector2(BoardGeometry.BOARD_SIZE, 0.0))
		var origin := stretch * board.world_to_screen(Vector2.ZERO)
		var expected := control_px.x * BoardGeometry.BOARD_SIZE / BoardGeometry.SHORT_AXIS
		if absf(span.x - origin.x - expected) > 1.0:
			return "#845 the 8-wide board spans %s of %s px" % [span.x - origin.x, expected]
	return ""


func _apply_release_stretch() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND


func _reset_release_stretch(board: BoardPresentation) -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i(0, 0)
	root.size = Vector2i(720, 1280)
	board.size = Vector2(720, 1280)


func _check_orientation(board: BoardPresentation) -> String:
	## #617 — raster art must not be mirrored by the world Y flip (SPC.E1).
	## Synthetic asymmetric texture: black top-left pixel, everything else white.
	var texture := _asymmetric_texture()
	var assets: Dictionary = {BoardPresentation.BOARD_BG_ID: texture}
	for key in BoardPresentation.PIECE_IDS.keys():
		assets[str(BoardPresentation.PIECE_IDS[key])] = texture
	board.provide_assets(assets)
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	(
		board
		. render_position(
			{
				"occupancy": {"e2": {"color": "white", "kind": "knight", "square": "e2"}},
				"side_to_move": "white",
			}
		)
	)
	board.show_promotion_choice("e8", "white")
	await process_frame
	for pass_index in range(2):
		for seat in [BoardGeometry.SEAT_BOTTOM, BoardGeometry.SEAT_TOP]:
			# Re-entry: a second provide_assets() re-runs _apply_kind_texture.
			if pass_index == 1:
				board.provide_assets(assets)
			board.set_white_seat(seat)
			var err := _assert_orientation(board, seat)
			if not err.is_empty():
				return err
	board.clear_promotion_choice()
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	(
		board
		. render_position(
			{
				"occupancy": {"e2": {"color": "white", "kind": "knight", "square": "e2"}},
				"side_to_move": "white",
			}
		)
	)
	await process_frame
	# Settle: the 0.92 squash restores the pre-settle (art) scale.
	var sprite := _piece_sprite(board, "e2")
	if sprite == null:
		return "#617 piece sprite missing before settle"
	var before := sprite.scale
	board.update_drag("begin", {"square": "e2", "world": BoardGeometry.square_center("e2")})
	await board.end_drag_legal("e4")
	sprite = _piece_sprite(board, "e4")
	if sprite == null:
		return "#617 piece sprite missing after drop"
	if not sprite.scale.is_equal_approx(before):
		return "#617 settle did not restore scale %s vs %s" % [sprite.scale, before]
	# And the settled sprite still satisfies art space after the squash.
	if not (sprite.scale.x > 0.0 and sprite.scale.y < 0.0):
		return "#617 settled scale %s not (+,−)" % sprite.scale
	return ""


func _asymmetric_texture() -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	img.set_pixel(0, 0, Color.BLACK)
	return ImageTexture.create_from_image(img)


func _piece_sprite(board: BoardPresentation, square: String) -> Sprite2D:
	var node := board.get_node_or_null("World/Seat/Content/Pieces/piece_%s" % square)
	if node == null:
		return null
	return node.get_node_or_null("Sprite") as Sprite2D


func _chooser_sprite(board: BoardPresentation) -> Sprite2D:
	## Lookup by `promote_kind` meta: a rebuild may rename nodes (@Node2D@…).
	var root := board.get_node_or_null("World/Seat/Content/Overlays/PromoteChoice")
	if root == null:
		return null
	for child in root.get_children():
		if str(child.get_meta("promote_kind", "")).is_empty():
			continue
		return child.get_node_or_null("Sprite") as Sprite2D
	return null


func _assert_orientation(board: BoardPresentation, seat: String) -> String:
	var piece := _piece_sprite(board, "e2")
	var chooser := _chooser_sprite(board)
	var backdrop := board.get_node_or_null("World/Seat/Content/Board/BoardBackdrop") as Sprite2D
	for pair in [["piece", piece], ["chooser", chooser], ["backdrop", backdrop]]:
		var err := _assert_art_space(str(pair[0]), pair[1] as Sprite2D, seat)
		if not err.is_empty():
			return err
	# Seat space: no mirror on screen; CAM-board.M2 rotation only.
	var global_basis := piece.get_global_transform()
	if global_basis.determinant() <= 0.0:
		return (
			"#617 piece global determinant %s mirrored at seat %s"
			% [global_basis.determinant(), seat]
		)
	var expected := PI if seat == BoardGeometry.SEAT_TOP else 0.0
	var got := wrapf(global_basis.get_rotation(), -PI, PI)
	if not is_equal_approx(absf(got), expected):
		return "#617 piece global rotation %s at seat %s (want %s)" % [got, seat, expected]
	return _assert_marker(piece, seat)


## Art space: a present texture and a (+,−) local scale, i.e. no mirror and the
## texture's top edge facing screen up regardless of seat.
func _assert_art_space(label: String, sprite: Sprite2D, seat: String) -> String:
	if sprite == null:
		return "#617 %s sprite missing (seat %s)" % [label, seat]
	if sprite.texture == null:
		return "#617 %s has no texture — orientation would be vacuous" % label
	var local := sprite.scale
	if not (local.x > 0.0 and local.y < 0.0):
		return "#617 %s local scale %s not (+,−) at seat %s" % [label, local, seat]
	return ""


## Marker: the texture's top-left texel must land on the sprite's top-left
## corner (Bottom) or bottom-right corner (Top) — proof of facing, not parity.
func _assert_marker(piece: Sprite2D, seat: String) -> String:
	var tex := piece.texture
	var half := Vector2(tex.get_width(), tex.get_height()) * 0.5
	var tol := (Vector2(tex.get_width() - 1.0, tex.get_height() - 1.0) * 0.5).length()
	var corners: Array = []
	for sx in [1.0, -1.0]:
		for sy in [1.0, -1.0]:
			corners.append(piece.get_global_transform() * Vector2(half.x * sx, half.y * sy))
	var want := (
		_screen_top_left(corners)
		if seat == BoardGeometry.SEAT_BOTTOM
		else _screen_bottom_right(corners)
	)
	var marked := piece.get_global_transform() * (-half)
	if marked.distance_to(want) > tol:
		return "#617 marker lands %s, want %s at seat %s" % [marked, want, seat]
	return ""


func _screen_top_left(points: Array) -> Vector2:
	var best := points[0] as Vector2
	for p in points:
		var v := p as Vector2
		if v.x < best.x:
			best.x = v.x
		if v.y < best.y:
			best.y = v.y
	return best


func _screen_bottom_right(points: Array) -> Vector2:
	var best := points[0] as Vector2
	for p in points:
		var v := p as Vector2
		if v.x > best.x:
			best.x = v.x
		if v.y > best.y:
			best.y = v.y
	return best


## CMP-presentation.R8: a rendered piece node exposes its kind's name as metadata
## (never a drawn label).
func _check_accessible_name_meta(board: BoardPresentation) -> String:
	var rules := ChessRules.new()
	rules.reset_opening()
	board.render_position(rules.position_field())
	var seen := 0
	for child in board.find_child("Pieces", true, false).get_children():
		var node := child as Node2D
		if node == null or not node.has_meta("piece_kind"):
			continue
		seen += 1
		var kind := str(node.get_meta("piece_kind"))
		var want := BoardPresentation.accessible_name(kind, "shared-play", "en")
		if want.is_empty() or str(node.get_meta("accessible_name", "")) != want:
			return "R8 %s has no accessible name metadata" % node.name
	if seen != 32:
		return "R8 saw %d piece nodes, want 32" % seen
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
	err = await _motion_marks(board, rules)
	if not err.is_empty():
		return err
	return await _check_check_mark(board)


func _motion_drag(board: BoardPresentation, rules: ChessRules) -> String:
	var checks: Array = [
		[board.piece_world_center("e2") == Vector2(4.5, 1.5), "opening e2 placement"],
	]
	var err := _first_fail(checks)
	if not err.is_empty():
		return err
	board.update_drag("begin", {"square": "e2", "world": Vector2(5.2, 2.0)})
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
	var t0 := Time.get_ticks_msec()
	await board.end_drag_illegal()
	var return_elapsed := (Time.get_ticks_msec() - t0) / 1000.0
	checks = [
		[return_elapsed <= BoardGeometry.TRAVEL_S + 0.08, "bad drop return wall-clock over budget"],
		[board.piece_world_center("e2") == Vector2(4.5, 1.5), "bad drop return home"],
	]
	err = _first_fail(checks)
	if not err.is_empty():
		return err
	board.update_drag("begin", {"square": "e2", "world": Vector2(4.5, 1.5)})
	t0 = Time.get_ticks_msec()
	await board.end_drag_legal("e4")
	var travel_elapsed := (Time.get_ticks_msec() - t0) / 1000.0
	checks = [
		[
			travel_elapsed <= BoardGeometry.TRAVEL_S + BoardGeometry.SETTLE_S + 0.08,
			"M1+settle wall-clock over budget"
		],
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
	var t0 := Time.get_ticks_msec()
	await board.play_move("e4", "d5", "d5")
	var capture_elapsed := (Time.get_ticks_msec() - t0) / 1000.0
	var checks: Array = [
		[
			capture_elapsed <= BoardGeometry.TRAVEL_S + BoardGeometry.SETTLE_S + 0.08,
			"capture wall-clock over budget"
		],
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
	t0 = Time.get_ticks_msec()
	await board.play_move("e8", "e8", "", "queen")
	var promote_elapsed := (Time.get_ticks_msec() - t0) / 1000.0
	if promote_elapsed > BoardGeometry.TRAVEL_S + BoardGeometry.SETTLE_S + 0.08:
		return "promotion morph wall-clock over budget"
	err = await _motion_o2_animate(board)
	if not err.is_empty():
		return err
	return ""


func _motion_o2_animate(board: BoardPresentation) -> String:
	## CTR-presentation.O2 post-apply + move must still animate from the origin.
	(
		board
		. render_position(
			{
				"occupancy":
				{
					"e2": {"color": "white", "kind": "pawn", "square": "e2"},
				},
				"side_to_move": "white",
			}
		)
	)
	await process_frame
	if board.get_node_or_null("World/Seat/Content/Pieces/piece_e2") == null:
		return "O2 setup missing e2"
	(
		board
		. render_position(
			{
				"occupancy":
				{
					"e4": {"color": "white", "kind": "pawn", "square": "e4"},
				},
				"side_to_move": "black",
			},
			"",
			PackedStringArray(),
			{"move": {"from": "e2", "to": "e4"}}
		)
	)
	await board.travel_finished
	if board.get_node_or_null("World/Seat/Content/Pieces/piece_e4") == null:
		return "O2 move did not land on e4"
	if board.get_node_or_null("World/Seat/Content/Pieces/piece_e2") != null:
		return "O2 move left origin keyed"
	if board.piece_world_center("e4") != Vector2(4.5, 3.5):
		return "O2 move wrong landing"
	return ""


func _motion_marks(board: BoardPresentation, rules: ChessRules) -> String:
	board.render_position(
		rules.position_field(),
		"e2",
		PackedStringArray(["e3", "e4"]),
		{"white_seat": "bottom", "capture_marks": []}
	)
	await process_frame
	var select := board.get_node_or_null("World/Seat/Content/Overlays/Selection") as Line2D
	if select == null or not select.visible:
		return "PER.R3 selection mark missing"
	if select.default_color != BoardPresentation.COLOR_SELECT:
		return "PER.R3 selection must use full-opacity PAL.C6"
	var legal_root := board.get_node_or_null("World/Seat/Content/Overlays/LegalMarks")
	if legal_root == null or legal_root.get_child_count() < 2:
		return "PER.R4 legal marks missing"
	return _first_fail(_empty_disk_checks(legal_root.get_child(0)))


## PER.R6 / CMP-presentation.R7 — the checked King carries a PAL.C8 L-frame.
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
	var fg := board.mark_foreground()
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
				line.default_color != BoardPresentation.COLOR_SELECT,
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
				is_equal_approx(BoardPresentation.SELECT_STROKE * board.world_px(), 2.16),
				"UIS.I1 the 0.06 selection ring must measure 2.16 px"
			],
			[
				is_equal_approx(BoardPresentation.LEGAL_BRACKET_W * board.world_px(), 2.16),
				"UIS.I1 the 0.06 capture bracket must measure 2.16 px"
			],
			[
				is_equal_approx(BoardPresentation.TICK_W * board.world_px(), 1.44),
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
	board.render_position(
		{
			"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
			"side_to_move": "white",
		},
		"e2",
		PackedStringArray(["e3", "e4"]),
		{"capture_marks": []}
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
	if disk == null or disk.color != BoardPresentation.COLOR_LEGAL:
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
		if not is_equal_approx((point as Vector2).distance_to(centre), BoardPresentation.LEGAL_EMPTY_R):
			checks.append([false, "PER.R4 disk vertex off the 0.36 radius"])
			break
	# The drawn disk is a 32-gon, 0.6% under its circle: πr² = 0.407, not the old
	# diamond's 2r² = 0.259.
	var circle := PI * pow(BoardPresentation.LEGAL_EMPTY_R, 2.0)
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
	board.render_position(
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
				is_equal_approx(stroke.width, BoardPresentation.LEGAL_BRACKET_W),
				"PER.R4 capture bracket stroke %s, want 0.06" % stroke.width
			]
		)
		checks.append(
			[stroke.default_color == BoardPresentation.COLOR_LEGAL, "PER.R4 capture must use PAL.C11"]
		)
		var length := stroke.get_point_position(0).distance_to(stroke.get_point_position(1))
		arms_ok = arms_ok and is_equal_approx(length, BoardPresentation.LEGAL_BRACKET_ARM)
		for i in stroke.get_point_count():
			var point := stroke.get_point_position(i)
			checks.append(
				[
					absf(point.x - centre.x) <= 0.5 and absf(point.y - centre.y) <= 0.5,
					"PER.R4 capture bracket left the square"
				]
			)
		ink += stroke.width * length
	checks.append([arms_ok, "PER.R4 capture bracket arm %s, want 0.56" % BoardPresentation.LEGAL_BRACKET_ARM])
	checks.append([ink >= 0.25 - 0.0001, "PER.R4 capture brackets cover %.3f, under 1/4" % ink])
	for child in legal_root.get_children():
		if child is Line2D and (child as Line2D).closed:
			checks.append([false, "PAL.K9 selection must stay the only closed ring"])
	return _first_fail(checks)


## UIS.C6 — legal destinations draw on the square, so they must never raise a
## cream foreground: a board of eight destinations does not turn cream.
func _check_no_cream_from_legal_marks(board: BoardPresentation) -> String:
	board.render_position(
		{
			"occupancy": {"d4": {"color": "white", "kind": "queen", "square": "d4"}},
			"side_to_move": "white",
		},
		"d4",
		PackedStringArray(["a4", "b4", "c4", "e4", "f4", "g4", "h4", "d5"]),
		{"capture_marks": []}
	)
	await process_frame
	var fg := board.mark_foreground()
	return _first_fail(
		[
			[fg.marked_squares().is_empty(), "UIS.C6 legal marks must not raise a cream foreground"],
			[_cream_nodes(fg).is_empty(), "UIS.C6 no cream node may exist without a cream mark"],
		]
	)


## PER.R8 — the refused place hatches the square's own fill in PAL.C8 under the
## 0.3 s flash: no cream foreground, no keyline, and selection and legal marks
## return when it fades. A clock-tick refresh never restarts the tween.
func _check_refused_hatch(board: BoardPresentation) -> String:
	board.render_position(
		{
			"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
			"side_to_move": "white",
		},
		"e2",
		PackedStringArray(["e3", "e4"]),
		{"reject_square": "d2", "ui_state": "S5", "capture_marks": []}
	)
	await process_frame
	var hatch := board.reject_hatch()
	var tween: Tween = board._reject_tween
	var select := board.get_node_or_null("World/Seat/Content/Overlays/Selection") as Line2D
	var legal_root := board.get_node_or_null("World/Seat/Content/Overlays/LegalMarks")
	var checks: Array = [
		[hatch != null and hatch.visible, "PER.R8 refused place must hatch the square"],
		[hatch != null and hatch.get_child_count() >= 4, "PER.R8 hatching must cross the square"],
		[
			board.mark_foreground().marked_squares().is_empty(),
			"PER.R8 the hatch needs no cream foreground (rules.md Layer split)"
		],
		[_keylines(hatch).is_empty(), "PER.R8 the hatch must carry no keyline"],
		[select != null and select.visible, "PER.R3 selection must stay drawn under the flash"],
		[legal_root != null and legal_root.get_child_count() == 2, "PER.R4 legal marks must stay drawn"],
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
	board.render_position(
		{
			"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
			"side_to_move": "white",
		},
		"e2",
		PackedStringArray(["e3", "e4"]),
		{"reject_square": "d2", "ui_state": "S5", "capture_marks": []}
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
	board.render_position(
		{
			"occupancy": {"e2": {"color": "white", "kind": "pawn", "square": "e2"}},
			"side_to_move": "white",
		}
	)
	await process_frame
	await board.play_move("e2", "e4")
	await process_frame
	var moved := board.last_move()
	var err := _first_fail([[moved[0] == "e2" and moved[1] == "e4", "PER.R9 last move must follow the move"]])
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
			[_band_on_away_edge(board, "e2", "e4"), "PER.R9 band must stay away from the move after a flip"],
			[_ticks_face_from(board, "e4", "e2"), "PER.R9 ticks must face the from-square after a flip"],
		]
	)
	board.set_white_seat(BoardGeometry.SEAT_BOTTOM)
	await process_frame
	return err


## Soft, open, PAL.C7, on the from-square's edge facing away from the to-square.
func _band_checks(board: BoardPresentation, from_square: String, to_square: String) -> String:
	var band := board.last_move_band()
	var checks: Array = [
		[band != null, "PER.R9 from-square band missing"],
		[band != null and band.get_child_count() >= 2, "PER.R9 the band must be soft, not one stroke"],
		[_keylines(band).is_empty(), "PER.R9 the band must carry no keyline (rules.md)"],
		[_band_on_away_edge(board, from_square, to_square), "PER.R9 band must sit away from the move"],
		[_band_body_coverage() <= 0.10, "PER.R9 band covers too much of the King body"],
		[
			float(BoardPresentation.BAND_LAYERS[2][0]) * board.world_px() >= 1.5 - 0.001,
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
	var widest := float(BoardPresentation.BAND_LAYERS[0][0])
	var inner := 0.5 - widest
	var overlap := maxf(0.0, FRM_P1_BODY_HALF - inner) * BoardPresentation.BAND_LENGTH
	return overlap / KING_BODY_AREA


## The band's midpoint is on the from-square's rim, on the side away from the move.
func _band_on_away_edge(board: BoardPresentation, from_square: String, to_square: String) -> bool:
	var band := board.last_move_band()
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
	var fg := board.mark_foreground()
	var marks := fg.marks_on(to_square)
	var checks: Array = [
		[fg.marked_squares().has(to_square), "PER.R9 the to-square must carry a cream foreground"],
		[marks.size() == 4, "PER.R9 the to-square must carry four corner ticks"],
		[_ticks_face_from(board, to_square, from_square), "PER.R9 tick arms must miss the tick geometry"],
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
			[is_equal_approx(float(mark.get("width", 0.0)), BoardPresentation.TICK_W), "PER.R9 tick 0.04 wide"]
		)
		if points.size() != 3:
			continue
		var elbow := points[1]
		var long_arm := points[0].distance_to(elbow)
		var short_arm := elbow.distance_to(points[2])
		checks.append([is_equal_approx(long_arm, BoardPresentation.TICK_LONG), "PER.R9 tick 0.60 long"])
		checks.append([is_equal_approx(short_arm, BoardPresentation.TICK_ARM), "PER.R9 tick L arm 0.10"])
		var centre := BoardGeometry.square_center(to_square)
		var offset := maxf(absf(elbow.x - centre.x), absf(elbow.y - centre.y))
		checks.append(
			[offset <= 0.5 and offset >= 0.5 - BoardPresentation.TICK_BAND, "PER.R9 tick must sit outside 0.10"]
		)
	return _first_fail(checks)


## The long arm runs parallel to the from-facing edge, which is a property of the
## move and survives CAM-board.M2.
func _ticks_face_from(board: BoardPresentation, to_square: String, from_square: String) -> bool:
	var fg := board.mark_foreground()
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
		var points: PackedVector2Array = (mark_var as Dictionary).get("points", PackedVector2Array())
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
	var fg := board.mark_foreground()
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
				[float(mark.get("width", 0.0)) == AdviceMarks.ADVICE_STROKE, "PER.R5 bracket stroke"]
			)
	checks.append([found_brackets, "PER.R5 Advice brackets must draw on the foreground"])
	board.render_advice(null)
	await process_frame
	checks.append(
		[fg.node_for("e4") != null and fg.marks_on("e4").size() == 4, "Advice Off must leave only the ticks"]
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
			[style.border_color == BoardPresentation.COLOR_INK, "PAL.K8 the chip keyline must be PAL.C9"],
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
