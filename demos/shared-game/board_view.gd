class_name DemoBoardView
extends Node2D
## Board, pieces, motion, and overlays for demo #63, in SPC world units.
## The origin sits at the board's top-left on screen; local x runs files a-h
## and local y runs down toward rank 1, realizing CAM-board.M2 for the White
## seat (White's near edge faces Bottom; rotation 0).

const COLOR_LIGHT := Color("E8D5B5")   # PAL.C1
const COLOR_DARK := Color("8B5A3C")    # PAL.C2
const COLOR_TABLE := Color("5C3A2A")   # PAL.C5, SPC.L1 cafe backdrop
const COLOR_SELECT := Color("B8940C")  # PAL.C6, PER.R3
const COLOR_LEGAL := Color("6EA746")   # PAL.C11, PER.R4
const COLOR_INK := Color("2C2A28")     # PAL.C9
const COLOR_CREAM := Color("F7F1E8")   # PAL.C10
const COLOR_ROSE := Color("C28A86")    # PAL.C8: check rim, refusal flash
## Empty-legal diamond half-diagonal r; ink area 2 r^2 >= 1/4 square (PER.R4).
const LEGAL_EMPTY_R := 0.36
## Capture ink ring: ink area 2 pi r w >= 1/4 square (PER.R4).
const LEGAL_CAPTURE_R := 0.40
const LEGAL_CAPTURE_W := 0.10
const SELECT_STROKE := 0.06            # far under 10% of the body (PER.R1/R3)
const REJECT_STROKE := 0.10
const CHECK_STROKE := 0.10
const PIECE_EXTENT := 0.85             # SPC.E1
const TRAVEL_S := 0.15                 # PHY.M1 / MOT.T1 budget
const RETURN_S := 0.15                 # PHY.M5 bad-drop return
const SETTLE_S := 0.03                 # PHY.I1 settle window
const PROMOTE_SPRITE_SCALE := 0.42

const PROMOTE_ORDER := ["q", "r", "b", "n"]  # I33/I34 demo chooser order

var font_resource: Font

var _piece_ids: Dictionary = {}
var _squares_root: Node2D
var _pieces_root: Node2D
var _fragments_root: Node2D
var _overlay_root: Node2D
var _select_frame: Line2D
var _legal_root: Node2D
var _reject_flash: Line2D
var _check_rim: Line2D
var _promo_root: Node2D

var _pieces: Dictionary = {}   # square index -> Node2D
var _drag_square := -1
var _motion_busy := false


func setup(piece_ids: Dictionary, font: Font, board_bg: Texture2D) -> void:
	_piece_ids = piece_ids
	font_resource = font
	_build_backdrop(board_bg)
	_squares_root = Node2D.new()
	_squares_root.name = "Squares"
	add_child(_squares_root)
	_build_squares()
	_pieces_root = Node2D.new()
	_pieces_root.name = "Pieces"
	_pieces_root.z_index = 3
	add_child(_pieces_root)
	_fragments_root = Node2D.new()
	_fragments_root.name = "Fragments"
	_fragments_root.z_index = 4
	add_child(_fragments_root)
	_overlay_root = Node2D.new()
	_overlay_root.name = "Overlays"
	_overlay_root.z_index = 5
	add_child(_overlay_root)
	_select_frame = _make_rim("SelectFrame", COLOR_SELECT, SELECT_STROKE)
	_legal_root = Node2D.new()
	_legal_root.name = "LegalMarks"
	_overlay_root.add_child(_legal_root)
	_reject_flash = _make_rim("RejectFlash", COLOR_ROSE, REJECT_STROKE)
	_check_rim = _make_rim("CheckRim", COLOR_ROSE, CHECK_STROKE)
	_promo_root = Node2D.new()
	_promo_root.name = "PromoChoice"
	_promo_root.visible = false
	_promo_root.z_index = 8
	add_child(_promo_root)


func _make_rim(rim_name: String, color: Color, stroke: float) -> Line2D:
	var rim := Line2D.new()
	rim.name = rim_name
	rim.width = stroke
	rim.default_color = color
	rim.closed = true
	rim.visible = false
	_overlay_root.add_child(rim)
	return rim


func _build_backdrop(board_bg: Texture2D) -> void:
	# PRJ.P1: the cafe backdrop art spans the 10-unit frame; squares draw above.
	if board_bg == null:
		return
	var backdrop := Sprite2D.new()
	backdrop.name = "Backdrop"
	backdrop.centered = true
	backdrop.position = Vector2(4.0, 4.0)  # CAM-board.F1: board center
	backdrop.texture = board_bg
	var px := float(maxi(board_bg.get_width(), 1))
	backdrop.scale = Vector2(10.0 / px, 10.0 / px)
	add_child(backdrop)


func _build_squares() -> void:
	# E-pieces.I35: a1 is dark; file index + rank even means dark.
	for index in range(64):
		var poly := Polygon2D.new()
		var c := square_center(index)
		poly.polygon = PackedVector2Array([
			c + Vector2(-0.5, -0.5), c + Vector2(0.5, -0.5),
			c + Vector2(0.5, 0.5), c + Vector2(-0.5, 0.5),
		])
		poly.color = COLOR_DARK if (index / 8 + index % 8) % 2 == 0 else COLOR_LIGHT
		_squares_root.add_child(poly)


static func square_center(index: int) -> Vector2:
	# SPC.A1: x along files a-h; SPC.P1/SNC.P2: state sits on square centers.
	return Vector2(float(index % 8) + 0.5, float(7 - index / 8) + 0.5)


static func index_from_unit(unit_pos: Vector2) -> int:
	## Unit-space point (relative to the board origin) -> square; -1 off board.
	var f := int(floorf(unit_pos.x))
	var row := int(floorf(unit_pos.y))
	if f < 0 or f > 7 or row < 0 or row > 7:
		return -1
	return (7 - row) * 8 + f


func unit_at(screen: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * screen


func setup_position(pos: Dictionary) -> void:
	for child in _pieces_root.get_children():
		child.free()
	_pieces.clear()
	_drag_square = -1
	_motion_busy = false
	var board: PackedStringArray = pos["board"]
	for index in range(64):
		if board[index] != "":
			_make_piece(index, board[index])


func _make_piece(index: int, code: String) -> void:
	var node := Node2D.new()
	node.position = square_center(index)
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"  # demos move code finds it by name
	sprite.centered = true
	var texture := _texture_for(code)
	if texture != null:
		sprite.texture = texture
		sprite.scale = Vector2.ONE * (PIECE_EXTENT / maxi(texture.get_width(), 1))
	node.set_meta("code", code)
	node.add_child(sprite)
	_pieces_root.add_child(node)
	_pieces[index] = node


func _texture_for(code: String) -> Texture2D:
	var loader_resource: Resource = _loaded_assets.get(str(_piece_ids.get(code, "")), null)
	return loader_resource as Texture2D


var _loaded_assets: Dictionary = {}


func provide_assets(resources_by_id: Dictionary) -> void:
	_loaded_assets.merge(resources_by_id)


func piece_node(index: int) -> Node2D:
	return _pieces.get(index, null) as Node2D


func is_motion_busy() -> bool:
	return _motion_busy


## PER.R3: C6 frame on the selected square; PER.R4: C11 marks on legal targets.
func set_selection(selected: int, legal: Array, capture_targets: Array) -> void:
	for child in _legal_root.get_children():
		child.free()
	if selected < 0 or not _pieces.has(selected):
		_select_frame.visible = false
		return
	var c := square_center(selected)
	var half := 0.5 - SELECT_STROKE * 0.5
	_select_frame.clear_points()
	_select_frame.add_point(c + Vector2(-half, -half))
	_select_frame.add_point(c + Vector2(half, -half))
	_select_frame.add_point(c + Vector2(half, half))
	_select_frame.add_point(c + Vector2(-half, half))
	_select_frame.visible = true
	for target in legal:
		var mark_c := square_center(int(target))
		if capture_targets.has(int(target)):
			var ring := Line2D.new()
			ring.width = LEGAL_CAPTURE_W
			ring.default_color = COLOR_LEGAL
			ring.closed = true
			for i in range(16):
				var angle := TAU * float(i) / 16.0
				ring.add_point(mark_c + Vector2(cos(angle), sin(angle)) * LEGAL_CAPTURE_R)
			_legal_root.add_child(ring)
		else:
			var diamond := Polygon2D.new()
			diamond.color = COLOR_LEGAL
			diamond.polygon = PackedVector2Array([
				mark_c + Vector2(-LEGAL_EMPTY_R, 0), mark_c + Vector2(0, -LEGAL_EMPTY_R),
				mark_c + Vector2(0, LEGAL_EMPTY_R), mark_c + Vector2(-LEGAL_EMPTY_R, 0),
			])
			_legal_root.add_child(diamond)


func clear_selection() -> void:
	set_selection(-1, [], [])


## PER.R8: the refused square flashes PAL.C8 for 0.3 s, then clears.
func flash_reject(square: int) -> void:
	_rim_square(_reject_flash, square)
	_reject_flash.visible = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_reject_flash, "default_color", Color(COLOR_ROSE, 0.0), 0.3)
	tween.tween_callback(_reject_flash.hide)


## PER.R6: a king in check sits under a persistent PAL.C8 rim.
func set_check_rim(king_index: int) -> void:
	if king_index < 0:
		_check_rim.visible = false
		return
	_rim_square(_check_rim, king_index)
	_check_rim.visible = true


func _rim_square(rim: Line2D, index: int) -> void:
	var c := square_center(index)
	var half := 0.5 - rim.width * 0.5
	rim.clear_points()
	rim.add_point(c + Vector2(-half, -half))
	rim.add_point(c + Vector2(half, -half))
	rim.add_point(c + Vector2(half, half))
	rim.add_point(c + Vector2(-half, half))


## PHY.M5: while held the dragged piece follows the pointer.
func start_drag(index: int) -> void:
	if _pieces.has(index) and not _motion_busy:
		_drag_square = index
		(_pieces[index] as Node2D).z_index = 6


func drag_to(unit_pos: Vector2) -> void:
	if _drag_square < 0:
		return
	var node: Node2D = _pieces.get(_drag_square, null)
	if node != null:
		node.position = unit_pos


func drop() -> int:
	## Ends the drag and returns the square of the dragged piece (-1 none).
	var index := _drag_square
	_drag_square = -1
	return index


## PHY.M5: a bad drop returns the piece to its origin center in <= 0.15 s.
func return_piece(index: int) -> void:
	var node: Node2D = _pieces.get(index, null)
	if node == null:
		return
	_motion_busy = true
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "position", square_center(index), RETURN_S)
	tween.tween_callback(_end_motion)
	node.z_index = 0


func _end_motion() -> void:
	_motion_busy = false


## PHY.M1: piece travels origin-destination in <= TRAVEL_S straight and ease-out.
## PHY.M2/MOT.E1: a captured piece breaks apart and clears during the travel.
## PHY.M3/MOT.E2: promotion crossfades into the chosen type inside the same budget.
func move_piece(mover: int, dest: int, capture_index: int, promo_kind: String, dur: float = TRAVEL_S) -> void:
	if _motion_busy:
		push_warning("move_piece while busy %d->%d" % [mover, dest])
		return
	_motion_busy = true
	var node: Node2D = _pieces.get(mover, null)
	var victim: Node2D = null
	var fragments: Array = []
	if capture_index >= 0 and _pieces.has(capture_index):
		victim = _pieces.get(capture_index) as Node2D
	if victim != null:
		# PHY.M2/MOT.E1: fragments spawn while the mover travels to the square.
		fragments = _spawn_fragments(victim.position)
		_pieces.erase(capture_index)
		victim.free()
	_pieces.erase(mover)
	_pieces[dest] = node
	var sprite := node.get_node_or_null("Sprite2D") as Sprite2D
	var base_scale := Vector2.ONE
	if sprite != null and sprite.texture != null:
		base_scale = sprite.scale
	if promo_kind != "":
		var texture := _texture_for("%s%s" % [str(node.get_meta("code")).substr(0, 1), promo_kind.to_upper()])
		if sprite != null and texture != null:
			node.set_meta("code", str(node.get_meta("code")).substr(0, 1) + promo_kind)
			sprite.texture = texture
			sprite.scale = Vector2.ONE * (PIECE_EXTENT / maxi(texture.get_width(), 1))
			base_scale = sprite.scale
			sprite.modulate.a = 0.35
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "position", square_center(dest), dur)
	for frag in fragments:
		tween.tween_property(frag, "modulate:a", 0.0, dur)
	if promo_kind != "":
		tween.tween_property(sprite, "modulate:a", 1.0, dur)
	tween.chain().tween_callback(func() -> void:
		for frag in fragments:
			frag.free()
	)
	await tween.finished
	_motion_busy = false
	# PHY.I1 / MOT.A2: settle squash <= 0.03 s, <= 10% of piece height.
	if sprite != null and sprite.texture != null:
		var squash := create_tween()
		squash.tween_property(sprite, "scale", base_scale * Vector2(1.0, 0.9), SETTLE_S / 2.0)
		squash.tween_property(sprite, "scale", base_scale, SETTLE_S / 2.0)


## PHY.M4: castling — king and rook each travel to their end square concurrently.
func castle_move(king_from: int, king_to: int, rook_from: int, rook_to: int, dur: float = TRAVEL_S) -> void:
	if _motion_busy:
		return
	_motion_busy = true
	var king_node: Node2D = _pieces.get(king_from, null)
	var rook_node: Node2D = _pieces.get(rook_from, null)
	_pieces.erase(king_from)
	_pieces[king_to] = king_node
	_pieces.erase(rook_from)
	_pieces[rook_to] = rook_node
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	if king_node != null:
		tween.tween_property(king_node, "position", square_center(king_to), dur)
	if rook_node != null:
		tween.tween_property(rook_node, "position", square_center(rook_to), dur)
	await tween.finished
	_motion_busy = false


func codes_match(index: int) -> bool:
	return _pieces.has(index)


## I33/I34: four upright sprites in a 2x2 on the destination square.
func show_promo_choice(dest_index: int, color: String) -> void:
	hide_promo_choice()
	var c := square_center(dest_index)
	var offsets := [Vector2(-0.3, -0.3), Vector2(0.3, -0.3), Vector2(-0.3, 0.3), Vector2(0.3, 0.3)]
	for i in range(PROMOTE_ORDER.size()):
		var kind := str(PROMOTE_ORDER[i])
		var holder := Node2D.new()
		holder.name = "promo_%s" % kind
		holder.position = c + offsets[i]
		holder.set_meta("kind", kind)
		var backing := Polygon2D.new()
		backing.color = COLOR_CREAM
		backing.polygon = PackedVector2Array([
			Vector2(-0.24, -0.24), Vector2(0.24, -0.24), Vector2(0.24, 0.24), Vector2(-0.24, 0.24),
		])
		holder.add_child(backing)
		var texture := _texture_for("%s%s" % [color, kind])
		if texture != null:
			var sprite := Sprite2D.new()
			sprite.centered = true
			sprite.texture = texture
			sprite.scale = Vector2.ONE * (PIECE_EXTENT * PROMOTE_SPRITE_SCALE / maxi(texture.get_width(), 1))
			holder.add_child(sprite)
		_promo_root.add_child(holder)
	_promo_root.visible = true


func hide_promo_choice() -> void:
	for child in _promo_root.get_children():
		child.free()
	_promo_root.visible = false


func promo_kind_at(unit_pos: Vector2) -> String:
	if not _promo_root.visible:
		return ""
	for child in _promo_root.get_children():
		var holder := child as Node2D
		if holder != null and holder.position.distance_to(unit_pos) < 0.42:
			return str(holder.get_meta("kind", ""))
	return ""


func is_promo_open() -> bool:
	return _promo_root.visible


## MOT.E1/SRF.E1: ink fragments ease out and fade inside the M1 budget.
func _spawn_fragments(at: Vector2) -> Array:
	var out: Array = []
	for i in range(4):
		var frag := Polygon2D.new()
		frag.color = Color(COLOR_INK, 0.85)
		var o := Vector2(0.12 if i % 2 == 0 else -0.12, 0.12 if i < 2 else -0.12)
		frag.polygon = PackedVector2Array([
			at + o, at + o + Vector2(0.15, 0), at + o + Vector2(0.08, 0.15),
		])
		_fragments_root.add_child(frag)
		out.append(frag)
	return out
