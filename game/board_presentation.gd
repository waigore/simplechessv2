class_name BoardPresentation
extends Control
## Board camera, pieces, and SPC.L4 marks for CTR-presentation.O2 / O5 (#56).

signal travel_finished(square: String)
signal assets_needed(asset_ids: PackedStringArray)
## PER.R8 flash tween ended — session owns S5 → S1; Presentation must not dual-time.
signal reject_flash_finished

const COLOR_LIGHT := Color("E8D5B5")
const COLOR_DARK := Color("8B5A3C")
const COLOR_TABLE := Color("5C3A2A")
const COLOR_SELECT := Color("B8940C")
const COLOR_LEGAL := Color("6EA746")
const COLOR_INK := Color("2C2A28")
const COLOR_CREAM := Color("F7F1E8")
## PAL.C8 check rose — refused-place flash (PER.R8 / PAL.K5 full strength ≥ 2:1).
const COLOR_DANGER := Color("C28A86")

## Empty legal diamond half-diagonal so area 2 r² ≥ 1/4 square (PER.R4).
const LEGAL_EMPTY_R := 0.36
## Capture ring radius / stroke so ink area ≈ 2π r w ≥ 1/4 square.
const LEGAL_CAPTURE_R := 0.40
const LEGAL_CAPTURE_W := 0.10
## Selection frame stroke in world units (≪ 10% of piece body — PER.R1 / R3).
const SELECT_STROKE := 0.06
## Reject frame stroke — rim only so piece silhouette stays readable (PER.R1 / R8).
const REJECT_STROKE := 0.10
## C6 chooser sprites scaled to fit a 2×2 on the destination square.
const PROMOTE_SPRITE_SCALE := 0.42
const BOARD_BG_ID := "01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855"
const PIECE_IDS := {
	"white|pawn": "01a15dab-051c-7db1-8f3e-9cb5e68058d8",
	"white|knight": "01a15dab-051c-7155-b8ec-6de860bae114",
	"white|bishop": "01a15dab-051c-73ff-96fa-a75c6719313a",
	"white|rook": "01a15dab-051c-7c3f-94fc-ce51926b3549",
	"white|queen": "01a15dab-051c-7023-973b-0b37ef3aa1b3",
	"white|king": "01a15dab-051c-75dc-8624-91f1c45f98f7",
	"black|pawn": "01a15dab-051c-73c8-9edc-c4e82957f267",
	"black|knight": "01a15dab-051c-72b6-8859-f3edab33c514",
	"black|bishop": "01a15dab-051c-7061-9aaf-f2ba5a069413",
	"black|rook": "01a15dab-051c-73b7-bad0-e6df05f4d2b6",
	"black|queen": "01a15dab-051c-784b-859a-1d347edf39f0",
	"black|king": "01a15dab-051c-7392-9318-e8b69bf7abf2",
}

var white_seat := BoardGeometry.SEAT_BOTTOM
var last_travel_s := 0.0
var last_return_s := 0.0
var last_settle_s := 0.0
var camera_offset := Vector2.ZERO
var camera_zoom := 1.0

var _assets: Dictionary = {}
var _occupancy: Dictionary = {}
var _selection := ""
var _legal_marks: PackedStringArray = PackedStringArray()
var _capture_marks: PackedStringArray = PackedStringArray()
var _piece_nodes: Dictionary = {}
var _drag_square := ""
var _drag_world := Vector2.ZERO
var _motion_busy := false
var _coord_meta: Dictionary = {}

var _letterbox: ColorRect
var _world: Node2D
var _seat: Node2D
var _content: Node2D
var _cafe: Polygon2D
var _board_root: Node2D
var _squares_root: Node2D
var _pieces_root: Node2D
var _overlay_root: Node2D
var _select_frame: Line2D
var _legal_root: Node2D
var _reject_flash: Line2D
## PER.R6 check mark: the C8 L-frame on the checked king's square (CheckMark).
var _check_mark: CheckMark
## PER.R5 advice marks (E4 `show_advice`), over the pieces.
var _advice_marks: AdviceMarks
var _promote_root: Node2D
var _promote_square := ""
var _promote_color := ""
var _reject_square := ""
var _board_sprite: Sprite2D
var _coords_root: Control
var _coord_font: Font
var _text_scale := 1.0
var _reject_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_letterbox = ColorRect.new()
	_letterbox.name = "Letterbox"
	_letterbox.color = COLOR_TABLE
	_letterbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_letterbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_letterbox)

	_world = Node2D.new()
	_world.name = "World"
	add_child(_world)
	_seat = Node2D.new()
	_seat.name = "Seat"
	_world.add_child(_seat)
	_content = Node2D.new()
	_content.name = "Content"
	_content.position = -BoardGeometry.BOARD_CENTER
	_seat.add_child(_content)

	_cafe = Polygon2D.new()
	_cafe.name = "Cafe"
	_cafe.color = COLOR_TABLE
	_cafe.z_index = 0
	_content.add_child(_cafe)

	_board_root = Node2D.new()
	_board_root.name = "Board"
	_board_root.z_index = 1
	_content.add_child(_board_root)
	_board_sprite = Sprite2D.new()
	_board_sprite.name = "BoardBackdrop"
	_board_sprite.centered = true
	_board_sprite.position = BoardGeometry.BOARD_CENTER
	_board_root.add_child(_board_sprite)
	_squares_root = Node2D.new()
	_squares_root.name = "Squares"
	_board_root.add_child(_squares_root)
	_build_squares()

	_pieces_root = Node2D.new()
	_pieces_root.name = "Pieces"
	_pieces_root.z_index = 3
	_content.add_child(_pieces_root)

	_overlay_root = Node2D.new()
	_overlay_root.name = "Overlays"
	_overlay_root.z_index = 4
	_content.add_child(_overlay_root)
	_select_frame = Line2D.new()
	_select_frame.name = "Selection"
	_select_frame.width = SELECT_STROKE
	_select_frame.default_color = COLOR_SELECT
	_select_frame.closed = true
	_select_frame.visible = false
	_overlay_root.add_child(_select_frame)
	_legal_root = Node2D.new()
	_legal_root.name = "LegalMarks"
	_overlay_root.add_child(_legal_root)
	_reject_flash = Line2D.new()
	_reject_flash.name = "RejectFlash"
	_reject_flash.width = REJECT_STROKE
	_reject_flash.default_color = COLOR_DANGER
	_reject_flash.closed = true
	_reject_flash.visible = false
	_reject_flash.z_index = 0
	_overlay_root.add_child(_reject_flash)
	_check_mark = CheckMark.new()
	_overlay_root.add_child(_check_mark)
	_promote_root = Node2D.new()
	_promote_root.name = "PromoteChoice"
	_promote_root.visible = false
	_promote_root.z_index = 2
	_overlay_root.add_child(_promote_root)

	_advice_marks = AdviceMarks.new()
	_overlay_root.add_child(_advice_marks)

	_coords_root = Control.new()
	_coords_root.name = "Coordinates"
	_coords_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_coords_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_coords_root)
	_build_coordinates()

	resized.connect(_layout_camera)
	_layout_camera()


func provide_assets(resources_by_id: Dictionary) -> void:
	for asset_id in resources_by_id.keys():
		_assets[str(asset_id)] = resources_by_id[asset_id]
	var latin: Variant = resources_by_id.get(UiChrome.FONT_LATIN, null)
	if latin is Font:
		_coord_font = latin as Font
		_refresh_coordinate_fonts()
	_bind_board_backdrop()
	_refresh_piece_textures()


func render_position(
	position: Dictionary,
	selection: String = "",
	legal: PackedStringArray = PackedStringArray(),
	options: Dictionary = {}
) -> void:
	if options.has("white_seat"):
		set_white_seat(str(options["white_seat"]))
	_reflow_coordinates()
	var post_occ: Dictionary = (position.get("occupancy", {}) as Dictionary).duplicate(true)
	_selection = selection
	_legal_marks = legal.duplicate()
	_capture_marks = PackedStringArray()
	for square in _legal_marks:
		var piece: Dictionary = post_occ.get(square, {})
		if not piece.is_empty():
			_capture_marks.append(str(square))
	if options.has("capture_marks"):
		_capture_marks = PackedStringArray(options["capture_marks"])
	var move_opt: Variant = options.get("move", null)
	var has_move := (
		move_opt is Dictionary and not str((move_opt as Dictionary).get("from", "")).is_empty()
	)
	if has_move:
		# O2 is post-apply; rebuild the pre-move board so play_move can animate.
		var move: Dictionary = move_opt as Dictionary
		var prior := _occupancy.duplicate(true)
		if prior.is_empty() or not prior.has(str(move.get("from", ""))):
			prior = _occupancy_before_move(post_occ, move)
		_occupancy = prior
		if not _motion_busy:
			_sync_pieces()
		_sync_overlays()
		_apply_choice_overlays(options)
		_occupancy = post_occ
		_play_move_dict(move)
		return
	_occupancy = post_occ
	if not _motion_busy:
		_sync_pieces()
	_sync_overlays()
	_apply_choice_overlays(options)


## E4 `show_advice` under CMP-presentation.R4 — best move marks or none. Called
## by the presentation whenever the advice fields change; no CTR operation added.
func render_advice(advice_best_move: Variant) -> void:
	if _advice_marks == null:
		return
	if not (advice_best_move is Dictionary):
		_advice_marks.clear()
		return
	var move: Dictionary = advice_best_move
	var from_square := str(move.get("from", ""))
	var to_square := str(move.get("to", ""))
	if from_square.is_empty() or to_square.is_empty():
		_advice_marks.clear()
		return
	_advice_marks.show_best_move(from_square, to_square)


func set_white_seat(seat: String) -> void:
	white_seat = (
		BoardGeometry.SEAT_TOP if seat == BoardGeometry.SEAT_TOP else BoardGeometry.SEAT_BOTTOM
	)
	_layout_camera()


func piece_world_center(square: String) -> Vector2:
	if _drag_square == square:
		return _drag_world
	var node: Node2D = _piece_nodes.get(square) as Node2D
	if node != null:
		return node.position
	return BoardGeometry.square_center(square)


## B10 drag follow: `begin` with the square and world point, then `move`.
func update_drag(cmd: Variant, payload: Variant = null) -> void:
	match str(cmd):
		"begin":
			var start: Dictionary = payload
			_begin_drag(str(start.get("square", "")), start.get("world", Vector2.ZERO))
		"move":
			_move_drag(payload)


func _begin_drag(square: String, world: Vector2) -> void:
	if not _piece_nodes.has(square) or _motion_busy:
		return
	_drag_square = square
	_drag_world = world
	var node: Node2D = _piece_nodes[square] as Node2D
	node.z_index = 10
	node.position = world


func _move_drag(world: Vector2) -> void:
	if _drag_square.is_empty():
		return
	_drag_world = world
	var node: Node2D = _piece_nodes.get(_drag_square) as Node2D
	if node != null:
		node.position = world


func end_drag_legal(to_square: String) -> void:
	if _drag_square.is_empty():
		return
	var from_square := _drag_square
	_drag_square = ""
	await play_move(from_square, to_square)


func end_drag_illegal() -> void:
	if _drag_square.is_empty():
		return
	var square := _drag_square
	_drag_square = ""
	var node: Node2D = _piece_nodes.get(square) as Node2D
	if node == null:
		return
	var origin := BoardGeometry.square_center(square)
	last_return_s = BoardGeometry.TRAVEL_S
	_motion_busy = true
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(node, "position", origin, last_return_s)
	await tw.finished
	node.z_index = 0
	_motion_busy = false


## Drop drag follow without tween so O2 can own the place animation.
func cancel_drag() -> void:
	if _drag_square.is_empty():
		return
	var square := _drag_square
	_drag_square = ""
	var node: Node2D = _piece_nodes.get(square) as Node2D
	if node == null:
		return
	node.position = BoardGeometry.square_center(square)
	node.z_index = 0


func play_move(
	from_square: String,
	to_square: String,
	capture_square: String = "",
	promote_kind: String = "",
	castle_rook_from: String = "",
	castle_rook_to: String = ""
) -> void:
	if _motion_busy:
		return
	_motion_busy = true
	var mover: Node2D = _piece_nodes.get(from_square) as Node2D
	if mover == null:
		_motion_busy = false
		return
	var dest := BoardGeometry.square_center(to_square)
	last_travel_s = BoardGeometry.TRAVEL_S
	var duration := last_travel_s
	var color := _piece_color(from_square, mover)
	var fragments: Array[Node2D] = []
	if not capture_square.is_empty() and _piece_nodes.has(capture_square):
		fragments = _spawn_capture_break(capture_square)
		_remove_piece_node(capture_square)
	var rook: Node2D = null
	var rook_dest := Vector2.ZERO
	if not castle_rook_from.is_empty() and _piece_nodes.has(castle_rook_from):
		rook = _piece_nodes[castle_rook_from] as Node2D
		rook_dest = BoardGeometry.square_center(castle_rook_to)
	# PHY.M3: promotion morph runs inside the same ≤0.15 s budget as M1.
	if not promote_kind.is_empty():
		_apply_kind_texture(mover, color, promote_kind)
		mover.modulate.a = 0.35
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_parallel(true)
	tw.tween_property(mover, "position", dest, duration)
	if rook != null:
		tw.tween_property(rook, "position", rook_dest, duration)
	for frag in fragments:
		tw.tween_property(frag, "modulate:a", 0.0, duration)
	if not promote_kind.is_empty():
		tw.tween_property(mover, "modulate:a", 1.0, duration)
	await tw.finished
	for frag in fragments:
		frag.queue_free()
	if not promote_kind.is_empty():
		mover.modulate = Color.WHITE
	_rekey_piece(from_square, to_square, mover)
	if rook != null:
		_rekey_piece(castle_rook_from, castle_rook_to, rook)
	await _settle(mover)
	camera_offset = Vector2.ZERO
	_motion_busy = false
	travel_finished.emit(to_square)


func screen_to_world(screen: Vector2) -> Vector2:
	if _content == null:
		return Vector2.ZERO
	return _content.to_local(screen)


func world_to_screen(world: Vector2) -> Vector2:
	if _content == null:
		return Vector2.ZERO
	return _content.to_global(world)


func framed_center(square: String) -> Vector2:
	return BoardGeometry.apply_seat(BoardGeometry.square_center(square), white_seat)


func aspect_ratio() -> float:
	if size.y <= 0.0:
		return 1.0
	return size.x / size.y


func visible_world_size() -> Vector2:
	return BoardGeometry.visible_size(aspect_ratio())


func _piece_color(square: String, node: Node2D = null) -> String:
	var piece: Dictionary = _occupancy.get(square, {})
	if not piece.is_empty():
		return str(piece.get("color", "white"))
	if node != null and node.has_meta("piece_color"):
		return str(node.get_meta("piece_color"))
	return "white"


func _play_move_dict(move: Dictionary) -> void:
	play_move(
		str(move.get("from", "")),
		str(move.get("to", "")),
		str(move.get("capture", "")),
		str(move.get("promote", "")),
		str(move.get("rook_from", "")),
		str(move.get("rook_to", ""))
	)


## Invert a post-apply occupancy using the move payload so O2 can animate.
func _occupancy_before_move(post: Dictionary, move: Dictionary) -> Dictionary:
	var pre: Dictionary = post.duplicate(true)
	var from_sq := str(move.get("from", ""))
	var to_sq := str(move.get("to", ""))
	var capture_sq := str(move.get("capture", ""))
	var promote_kind := str(move.get("promote", ""))
	var rook_from := str(move.get("rook_from", ""))
	var rook_to := str(move.get("rook_to", ""))
	if not to_sq.is_empty() and pre.has(to_sq):
		var mover: Dictionary = (pre[to_sq] as Dictionary).duplicate(true)
		if not promote_kind.is_empty():
			mover["kind"] = "pawn"
		mover["square"] = from_sq
		pre[from_sq] = mover
		pre.erase(to_sq)
	if not capture_sq.is_empty() and move.has("captured"):
		pre[capture_sq] = (move["captured"] as Dictionary).duplicate(true)
	elif not capture_sq.is_empty():
		pre[capture_sq] = {
			"color": str(move.get("captured_color", "black")),
			"kind": str(move.get("captured_kind", "pawn")),
			"square": capture_sq,
		}
	if not rook_to.is_empty() and pre.has(rook_to):
		var rook: Dictionary = (pre[rook_to] as Dictionary).duplicate(true)
		rook["square"] = rook_from
		pre[rook_from] = rook
		pre.erase(rook_to)
	return pre


func _layout_camera() -> void:
	if _world == null or _seat == null:
		return
	camera_offset = Vector2.ZERO
	camera_zoom = 1.0
	var view := size
	if view.x <= 1.0 or view.y <= 1.0:
		view = Vector2(1280, 720)
	var raw_aspect := view.x / view.y
	# PRJ.A1: outside 9:16–16:9, letterbox/pillarbox *inside* the rect (never crop).
	var content := view
	var origin := Vector2.ZERO
	if raw_aspect < BoardGeometry.ASPECT_MIN:
		content.y = view.x / BoardGeometry.ASPECT_MIN
		origin.y = (view.y - content.y) * 0.5
	elif raw_aspect > BoardGeometry.ASPECT_MAX:
		content.x = view.y * BoardGeometry.ASPECT_MAX
		origin.x = (view.x - content.x) * 0.5
	var clamped := BoardGeometry.clamp_aspect(content.x / content.y)
	var vis := BoardGeometry.visible_size(clamped)
	var ppu: float
	if content.x / content.y >= 1.0:
		ppu = content.y / vis.y
	else:
		ppu = content.x / vis.x
	_world.position = origin + content * 0.5
	_world.scale = Vector2(ppu, -ppu)
	_seat.rotation = PI if white_seat == BoardGeometry.SEAT_TOP else 0.0
	var pad := vis * 0.5 + Vector2(2, 2)
	_cafe.polygon = PackedVector2Array(
		[
			BoardGeometry.BOARD_CENTER + Vector2(-pad.x, -pad.y),
			BoardGeometry.BOARD_CENTER + Vector2(pad.x, -pad.y),
			BoardGeometry.BOARD_CENTER + Vector2(pad.x, pad.y),
			BoardGeometry.BOARD_CENTER + Vector2(-pad.x, pad.y),
		]
	)
	_fit_board_sprite()
	_refresh_coordinates()


func _build_squares() -> void:
	for file in range(1, 9):
		for rank in range(1, 9):
			var square := "%s%s" % [char(96 + file), rank]
			var poly := Polygon2D.new()
			poly.name = square
			var c := BoardGeometry.square_center(square)
			poly.polygon = PackedVector2Array(
				[
					c + Vector2(-0.5, -0.5),
					c + Vector2(0.5, -0.5),
					c + Vector2(0.5, 0.5),
					c + Vector2(-0.5, 0.5),
				]
			)
			poly.color = COLOR_LIGHT if BoardGeometry.is_light_square(square) else COLOR_DARK
			_squares_root.add_child(poly)


func _build_coordinates() -> void:
	_coord_meta.clear()
	for file in range(1, 9):
		var key := "file_%s" % char(96 + file)
		var label := _make_coord_label(char(96 + file), key)
		_coord_meta[key] = {"label": label, "world": Vector2(float(file) - 0.5, -0.55)}
	for rank in range(1, 9):
		var key := "rank_%d" % rank
		var label := _make_coord_label(str(rank), key)
		_coord_meta[key] = {"label": label, "world": Vector2(-0.55, float(rank) - 0.5)}


func _make_coord_label(text: String, key: String) -> Label:
	## PER.R7: UIS.T2 size, C9 ink on C10 cream chip (≥ 4.5:1), catalog font when bound.
	var chip := Panel.new()
	chip.name = "%s_chip" % key
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.set_corner_radius_all(3)
	style.content_margin_left = 2
	style.content_margin_right = 2
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.name = key
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiChrome.add_body_size(label, _text_scale)
	label.add_theme_color_override("font_color", COLOR_INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.custom_minimum_size = _coord_chip_size()
	if _coord_font != null:
		UiChrome.apply_font(label, _coord_font)
	chip.add_child(label)
	_coords_root.add_child(chip)
	return label


## SIT.6 / S13 — coordinate labels take UIS.T2 from the frame they render in, on
## every render, so a phone-width frame keeps its sizes after any later action
## (AC4). No second sizing path: `UiChrome.add_font_size` is the only write.
func _reflow_coordinates() -> void:
	if _coords_root == null:
		return
	_text_scale = UiChrome.responsive_text_scale(self, _text_scale)
	for key in _coord_meta.keys():
		var label := _coord_meta[key]["label"] as Label
		if label != null:
			UiChrome.add_body_size(label, _text_scale)
			label.custom_minimum_size = _coord_chip_size()


func _coord_chip_size() -> Vector2:
	var side := float(UiChrome.scaled_px(UiChrome.BODY_PX, _text_scale) + 4)
	return Vector2(side, side)


func _refresh_coordinate_fonts() -> void:
	if _coord_font == null:
		return
	for key in _coord_meta.keys():
		var entry: Dictionary = _coord_meta[key]
		var label := entry["label"] as Label
		UiChrome.apply_font(label, _coord_font)


func _refresh_coordinates() -> void:
	if _content == null or _coords_root == null:
		return
	var half := _coord_chip_size().x * 0.5
	for key in _coord_meta.keys():
		var entry: Dictionary = _coord_meta[key]
		var label := entry["label"] as Label
		var chip := label.get_parent() as Control
		var world: Vector2 = entry["world"]
		# Content rotates with CAM-board.M2; labels stay upright in board-local space.
		var screen: Vector2 = world_to_screen(world)
		var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * screen
		if chip != null:
			chip.position = local - Vector2(half, half)
			chip.size = _coord_chip_size()
		else:
			label.position = local - Vector2(half, half)


func _sync_pieces() -> void:
	var keep: Dictionary = {}
	for square in _occupancy.keys():
		var piece: Dictionary = _occupancy[square]
		keep[square] = true
		var node: Node2D = _piece_nodes.get(square) as Node2D
		if node == null:
			node = _make_piece_node(str(square), piece)
			_piece_nodes[square] = node
		else:
			_apply_kind_texture(node, str(piece.get("color", "")), str(piece.get("kind", "")))
			if _drag_square != square and not _motion_busy:
				node.position = BoardGeometry.square_center(str(square))
	var stale: Array = []
	for square in _piece_nodes.keys():
		if not keep.has(square) and square != _drag_square:
			stale.append(square)
	for square in stale:
		_remove_piece_node(str(square))


func _make_piece_node(square: String, piece: Dictionary) -> Node2D:
	var root := Node2D.new()
	root.name = "piece_%s" % square
	root.position = BoardGeometry.square_center(square)
	root.set_meta("piece_color", str(piece.get("color", "white")))
	root.set_meta("piece_kind", str(piece.get("kind", "pawn")))
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = true
	root.add_child(sprite)
	_apply_kind_texture(root, str(piece.get("color", "")), str(piece.get("kind", "")))
	_pieces_root.add_child(root)
	return root


func _apply_kind_texture(node: Node2D, color: String, kind: String) -> void:
	var sprite := node.get_node_or_null("Sprite") as Sprite2D
	if sprite == null:
		return
	node.set_meta("piece_color", color)
	node.set_meta("piece_kind", kind)
	var asset_id := str(PIECE_IDS.get("%s|%s" % [color, kind], ""))
	if asset_id.is_empty():
		return
	var texture: Texture2D = _assets.get(asset_id) as Texture2D
	if texture == null:
		assets_needed.emit(PackedStringArray([asset_id]))
		sprite.texture = null
		return
	sprite.texture = texture
	var px := float(maxi(texture.get_width(), texture.get_height()))
	if px <= 0.0:
		px = 1.0
	# _world mirrors board space (board y up, screen y down). Raster art cancels
	# that locally so pieces read as authored and still rotate with CAM-board.M2 (#617).
	var s := BoardGeometry.PIECE_EXTENT / px
	sprite.scale = Vector2(s, -s)


func _sync_overlays() -> void:
	for child in _legal_root.get_children():
		child.queue_free()
	if _selection.is_empty() or not BoardGeometry.is_square(_selection):
		_select_frame.visible = false
	else:
		var c := BoardGeometry.square_center(_selection)
		var half := 0.5 - SELECT_STROKE * 0.5
		_select_frame.clear_points()
		_select_frame.add_point(c + Vector2(-half, -half))
		_select_frame.add_point(c + Vector2(half, -half))
		_select_frame.add_point(c + Vector2(half, half))
		_select_frame.add_point(c + Vector2(-half, half))
		_select_frame.default_color = COLOR_SELECT
		_select_frame.width = SELECT_STROKE
		_select_frame.visible = true
	for square in _legal_marks:
		var sq := str(square)
		if not BoardGeometry.is_square(sq):
			continue
		var c := BoardGeometry.square_center(sq)
		var is_capture := false
		for cap in _capture_marks:
			if str(cap) == sq:
				is_capture = true
				break
		if is_capture:
			# Hollow ring at full PAL.C11; ink area 2π r w ≥ 1/4 square (PER.R4 / PAL.K6).
			var ring := Line2D.new()
			ring.width = LEGAL_CAPTURE_W
			ring.default_color = COLOR_LEGAL
			ring.closed = true
			for i in range(16):
				var ang := TAU * float(i) / 16.0
				ring.add_point(c + Vector2(cos(ang), sin(ang)) * LEGAL_CAPTURE_R)
			_legal_root.add_child(ring)
		else:
			# Diamond at full PAL.C11; area 2 r² ≥ 1/4 square.
			var mark := Polygon2D.new()
			mark.color = COLOR_LEGAL
			var r := LEGAL_EMPTY_R
			mark.polygon = PackedVector2Array(
				[
					c + Vector2(-r, 0),
					c + Vector2(0, -r),
					c + Vector2(r, 0),
					c + Vector2(0, r),
				]
			)
			_legal_root.add_child(mark)


func _apply_choice_overlays(options: Dictionary) -> void:
	var reject := str(options.get("reject_square", ""))
	if not reject.is_empty() and BoardGeometry.is_square(reject):
		flash_reject(reject)
	elif str(options.get("ui_state", "")) != "S5":
		clear_reject_flash()
	var promote_to := str(options.get("pending_promote_to", ""))
	var promote_color := str(options.get("side_to_move", "white"))
	var kinds_var: Variant = options.get("promote_kinds", SharedGameSession.PROMOTE_ORDER)
	if str(options.get("ui_state", "")) == "S4" and BoardGeometry.is_square(promote_to):
		show_promotion_choice(promote_to, promote_color, kinds_var)
	else:
		clear_promotion_choice()
	if _check_mark != null:
		_check_mark.set_square(str(options.get("check_square", "")))


## PER.R8 — full-strength PAL.C8 rim on the attempted square for 0.3 s (SPC.L4).
func flash_reject(square: String) -> void:
	if not BoardGeometry.is_square(square):
		return
	# Clock-tick chrome refresh must not restart an in-flight flash.
	if (
		_reject_flash.visible
		and _reject_square == square
		and _reject_tween != null
		and _reject_tween.is_running()
	):
		return
	_reject_square = square
	var c := BoardGeometry.square_center(square)
	var half := 0.5 - REJECT_STROKE * 0.5
	_reject_flash.clear_points()
	_reject_flash.add_point(c + Vector2(-half, -half))
	_reject_flash.add_point(c + Vector2(half, -half))
	_reject_flash.add_point(c + Vector2(half, half))
	_reject_flash.add_point(c + Vector2(-half, half))
	_reject_flash.default_color = COLOR_DANGER
	_reject_flash.width = REJECT_STROKE
	_reject_flash.visible = true
	if _reject_tween != null:
		_reject_tween.kill()
	_reject_tween = create_tween()
	_reject_tween.set_ease(Tween.EASE_OUT)
	_reject_tween.tween_property(
		_reject_flash, "default_color", Color(COLOR_DANGER, 0.0), SharedGameSession.REJECT_FLASH_S
	)
	_reject_tween.tween_callback(_on_reject_flash_tween_done)


func _on_reject_flash_tween_done() -> void:
	clear_reject_flash()
	reject_flash_finished.emit()


func clear_reject_flash() -> void:
	if _reject_tween != null:
		_reject_tween.kill()
		_reject_tween = null
	_reject_flash.visible = false
	_reject_square = ""


## EX.promote — Q/R/B/N upright sprites in a 2×2 on the destination square.
func show_promotion_choice(square: String, color: String, kinds_var: Variant = null) -> void:
	var kinds: Array = []
	if kinds_var is Array or kinds_var is PackedStringArray:
		for item in kinds_var:
			kinds.append(str(item))
	else:
		kinds = SharedGameSession.PROMOTE_ORDER.duplicate()
	if kinds.is_empty():
		kinds = SharedGameSession.PROMOTE_ORDER.duplicate()
	# Clock-tick refresh must not rebuild an open chooser.
	if _promote_root.visible and _promote_square == square and _promote_color == color:
		return
	_promote_square = square
	_promote_color = color
	for child in _promote_root.get_children():
		child.queue_free()
	var c := BoardGeometry.square_center(square)
	# 2×2 centered on the destination so last-rank stays on-board (E-pieces.I33/I34).
	var offsets := [
		Vector2(-0.28, -0.28),
		Vector2(0.28, -0.28),
		Vector2(-0.28, 0.28),
		Vector2(0.28, 0.28),
	]
	for i in range(kinds.size()):
		var kind := str(kinds[i])
		var node := Node2D.new()
		node.name = "Promote_%s" % kind
		node.position = c + offsets[mini(i, offsets.size() - 1)]
		node.set_meta("promote_kind", kind)
		var sprite := Sprite2D.new()
		sprite.name = "Sprite"
		sprite.centered = true
		node.add_child(sprite)
		# Sprite orientation follows CAM-board.M2 seat rotation with the board;
		# color/kind art is the side-to-move set (E-pieces.I33 / I34).
		_apply_kind_texture(node, color, kind)
		_scale_promote_sprite(sprite)
		_promote_root.add_child(node)
	_promote_root.visible = true


func _scale_promote_sprite(sprite: Sprite2D) -> void:
	if sprite.texture == null:
		return
	var px := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
	if px <= 0.0:
		px = 1.0
	# Same local Y cancel as _apply_kind_texture: the chooser overrides that scale (#617).
	var s := BoardGeometry.PIECE_EXTENT * PROMOTE_SPRITE_SCALE / px
	sprite.scale = Vector2(s, -s)


func clear_promotion_choice() -> void:
	_promote_square = ""
	_promote_color = ""
	for child in _promote_root.get_children():
		child.queue_free()
	_promote_root.visible = false


## Hit-test C6 promotion sprites in world space; returns kind or "".
func promotion_kind_at(world: Vector2) -> String:
	if not _promote_root.visible:
		return ""
	var best := ""
	var best_d := 0.38
	for child in _promote_root.get_children():
		var node := child as Node2D
		if node == null:
			continue
		var d := node.position.distance_to(world)
		if d < best_d:
			best_d = d
			best = str(node.get_meta("promote_kind", ""))
	return best


func _bind_board_backdrop() -> void:
	var texture: Texture2D = _assets.get(BOARD_BG_ID) as Texture2D
	if texture == null:
		assets_needed.emit(PackedStringArray([BOARD_BG_ID]))
		_board_sprite.texture = null
		return
	_board_sprite.texture = texture
	_fit_board_sprite()


func _fit_board_sprite() -> void:
	if _board_sprite.texture == null:
		return
	var tex := _board_sprite.texture
	var w := float(maxi(tex.get_width(), 1))
	var h := float(maxi(tex.get_height(), 1))
	# Frame art cancels the world Y mirror like the pieces do (#617).
	_board_sprite.scale = Vector2(10.0 / w, -10.0 / h)


func _refresh_piece_textures() -> void:
	for square in _piece_nodes.keys():
		var piece: Dictionary = _occupancy.get(square, {})
		if piece.is_empty():
			continue
		_apply_kind_texture(
			_piece_nodes[square] as Node2D, str(piece.get("color", "")), str(piece.get("kind", ""))
		)


func _spawn_capture_break(square: String) -> Array[Node2D]:
	var out: Array[Node2D] = []
	var origin := BoardGeometry.square_center(square)
	for i in range(4):
		var frag := Polygon2D.new()
		frag.color = Color(COLOR_INK, 0.85)
		var o := Vector2(0.12 if i % 2 == 0 else -0.12, 0.12 if i < 2 else -0.12)
		frag.polygon = PackedVector2Array(
			[origin + o, origin + o + Vector2(0.15, 0), origin + o + Vector2(0.08, 0.15)]
		)
		_pieces_root.add_child(frag)
		out.append(frag)
	return out


func _settle(mover: Node2D) -> void:
	last_settle_s = BoardGeometry.SETTLE_S
	var sprite := mover.get_node_or_null("Sprite") as Sprite2D
	if sprite == null:
		return
	var base := sprite.scale
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(sprite, "scale", base * Vector2(1.0, 0.92), last_settle_s * 0.5)
	tw.tween_property(sprite, "scale", base, last_settle_s * 0.5)
	await tw.finished


func _rekey_piece(from_square: String, to_square: String, node: Node2D) -> void:
	_piece_nodes.erase(from_square)
	_piece_nodes[to_square] = node
	node.name = "piece_%s" % to_square
	node.z_index = 0
	node.position = BoardGeometry.square_center(to_square)


func _remove_piece_node(square: String) -> void:
	var node: Node2D = _piece_nodes.get(square) as Node2D
	_piece_nodes.erase(square)
	if node != null:
		node.queue_free()
