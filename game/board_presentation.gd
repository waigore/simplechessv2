class_name BoardPresentation
extends Control
## Board camera, pieces, and SPC.L4 marks for CTR-presentation.O2 / O5 (#56).

signal travel_finished(square: String)
signal assets_needed(asset_ids: PackedStringArray)

const COLOR_LIGHT := Color("E8D5B5")
const COLOR_DARK := Color("8B5A3C")
const COLOR_TABLE := Color("5C3A2A")
const COLOR_SELECT := Color("B8940C")
const COLOR_LEGAL := Color("6EA746")
const COLOR_INK := Color("2C2A28")
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
var _select_poly: Polygon2D
var _legal_root: Node2D
var _board_sprite: Sprite2D
var _coords_root: Control


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
	_select_poly = Polygon2D.new()
	_select_poly.name = "Selection"
	_select_poly.color = Color(COLOR_SELECT, 0.45)
	_select_poly.visible = false
	_overlay_root.add_child(_select_poly)
	_legal_root = Node2D.new()
	_legal_root.name = "LegalMarks"
	_overlay_root.add_child(_legal_root)

	_coords_root = Control.new()
	_coords_root.name = "Coordinates"
	_coords_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_coords_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_coords_root)
	_build_coordinates()

	resized.connect(_layout_camera)
	_layout_camera()


func provide_assets(resources_by_id: Dictionary) -> void:
	_assets = resources_by_id.duplicate()
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
	_occupancy = (position.get("occupancy", {}) as Dictionary).duplicate(true)
	_selection = selection
	_legal_marks = legal.duplicate()
	_capture_marks = PackedStringArray()
	for square in _legal_marks:
		var piece: Dictionary = _occupancy.get(square, {})
		if not piece.is_empty():
			_capture_marks.append(str(square))
	if options.has("capture_marks"):
		_capture_marks = PackedStringArray(options["capture_marks"])
	_sync_pieces()
	_sync_overlays()
	if options.has("move"):
		_play_move_dict(options["move"] as Dictionary)


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


func begin_drag(square: String, world: Vector2) -> void:
	if not _piece_nodes.has(square) or _motion_busy:
		return
	_drag_square = square
	_drag_world = world
	var node: Node2D = _piece_nodes[square] as Node2D
	node.z_index = 10
	node.position = world


func update_drag(world: Vector2) -> void:
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
	var color := _piece_color(from_square)
	var fragments: Array[Node2D] = []
	if not capture_square.is_empty() and _piece_nodes.has(capture_square):
		fragments = _spawn_capture_break(capture_square)
		_remove_piece_node(capture_square)
	var rook: Node2D = null
	var rook_dest := Vector2.ZERO
	if not castle_rook_from.is_empty() and _piece_nodes.has(castle_rook_from):
		rook = _piece_nodes[castle_rook_from] as Node2D
		rook_dest = BoardGeometry.square_center(castle_rook_to)
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
		tw.tween_property(mover, "modulate:a", 0.35, duration * 0.5)
	await tw.finished
	for frag in fragments:
		frag.queue_free()
	if not promote_kind.is_empty():
		_apply_kind_texture(mover, color, promote_kind)
		var morph := create_tween()
		morph.set_ease(Tween.EASE_OUT)
		morph.set_trans(Tween.TRANS_QUAD)
		mover.modulate.a = 0.35
		morph.tween_property(mover, "modulate:a", 1.0, duration * 0.5)
		await morph.finished
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


func _piece_color(square: String) -> String:
	var piece: Dictionary = _occupancy.get(square, {})
	return str(piece.get("color", "white"))


func _play_move_dict(move: Dictionary) -> void:
	play_move(
		str(move.get("from", "")),
		str(move.get("to", "")),
		str(move.get("capture", "")),
		str(move.get("promote", "")),
		str(move.get("rook_from", "")),
		str(move.get("rook_to", ""))
	)


func _layout_camera() -> void:
	if _world == null or _seat == null:
		return
	camera_offset = Vector2.ZERO
	camera_zoom = 1.0
	var view := size
	if view.x <= 1.0 or view.y <= 1.0:
		view = Vector2(1280, 720)
	var raw_aspect := view.x / view.y
	var clamped := BoardGeometry.clamp_aspect(raw_aspect)
	var vis := BoardGeometry.visible_size(clamped)
	var content := view
	if raw_aspect < BoardGeometry.ASPECT_MIN:
		content.x = view.y * BoardGeometry.ASPECT_MIN
	elif raw_aspect > BoardGeometry.ASPECT_MAX:
		content.y = view.x / BoardGeometry.ASPECT_MAX
	var ppu: float
	if content.x / content.y >= 1.0:
		ppu = content.y / vis.y
	else:
		ppu = content.x / vis.x
	_world.position = view * 0.5
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
	var label := Label.new()
	label.name = key
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", COLOR_INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.custom_minimum_size = Vector2(18, 18)
	_coords_root.add_child(label)
	return label


func _refresh_coordinates() -> void:
	if _content == null:
		return
	for key in _coord_meta.keys():
		var entry: Dictionary = _coord_meta[key]
		var label := entry["label"] as Label
		var world: Vector2 = entry["world"]
		# Content rotates with CAM-board.M2; labels stay upright in screen space.
		var screen := world_to_screen(world)
		label.position = screen - Vector2(9, 9)


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
	sprite.scale = Vector2.ONE * (BoardGeometry.PIECE_EXTENT / px)


func _sync_overlays() -> void:
	for child in _legal_root.get_children():
		child.queue_free()
	if _selection.is_empty() or not BoardGeometry.is_square(_selection):
		_select_poly.visible = false
	else:
		var c := BoardGeometry.square_center(_selection)
		_select_poly.polygon = PackedVector2Array(
			[
				c + Vector2(-0.5, -0.5),
				c + Vector2(0.5, -0.5),
				c + Vector2(0.5, 0.5),
				c + Vector2(-0.5, 0.5),
			]
		)
		_select_poly.visible = true
	for square in _legal_marks:
		var sq := str(square)
		if not BoardGeometry.is_square(sq):
			continue
		var mark := Polygon2D.new()
		var c := BoardGeometry.square_center(sq)
		var is_capture := false
		for cap in _capture_marks:
			if str(cap) == sq:
				is_capture = true
				break
		if is_capture:
			# Hollow ring (≥1/4 square) so capture targets read without hiding the piece.
			var ring := Line2D.new()
			ring.width = 0.08
			ring.default_color = Color(COLOR_LEGAL, 0.9)
			ring.closed = true
			var rad := 0.38
			for i in range(16):
				var ang := TAU * float(i) / 16.0
				ring.add_point(c + Vector2(cos(ang), sin(ang)) * rad)
			_legal_root.add_child(ring)
		else:
			mark.color = Color(COLOR_LEGAL, 0.75)
			var r := 0.28
			mark.polygon = PackedVector2Array(
				[
					c + Vector2(-r, 0),
					c + Vector2(0, -r),
					c + Vector2(r, 0),
					c + Vector2(0, r),
				]
			)
			_legal_root.add_child(mark)


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
	_board_sprite.scale = Vector2(10.0 / w, 10.0 / h)


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
