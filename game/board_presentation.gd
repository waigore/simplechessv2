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
const COLOR_INK := Color("2C2A28")
const COLOR_CREAM := Color("F7F1E8")
## PAL.C8 check rose — refused-place flash (PER.R8 / PAL.K5 full strength ≥ 2:1).
const COLOR_DANGER := Color("C28A86")

## Reject frame stroke — rim only so piece silhouette stays readable (PER.R1 / R8).
const REJECT_STROKE := 0.10
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
var _captures: PackedStringArray = PackedStringArray()
var _motion_busy := false
var _coord_meta: Dictionary = {}

var _letterbox: ColorRect
var _world: Node2D
var _seat: Node2D
var _content: Node2D
var _cafe: Polygon2D
var _board_root: Node2D
var _squares_root: Node2D
## The pieces: one node a square, its sprite, and the capture fragments.
var _pieces: BoardPieceLayer
var _overlay_root: Node2D
## PER.R3 / R4 — the selection ring and the legal destinations.
var _destinations: BoardDestinationMarks
## PER.R6 check L-frame on the checked King's square (E2 `in_check`).
var _check_marks: CheckMarks
var _reject_flash: Line2D
## PER.R5 advice marks (E4 `show_advice`), over the pieces.
var _advice_marks: AdviceMarks
## PAL.K9 *Layer split* / UIS.C6 / PER.R8–R9 — the square marks: the refused
## hatching, the last move's band and ticks, and their one cream foreground.
var _marks: BoardMarkLayer
## EX.promote — the Q/R/B/N chooser on a promoting destination.
var _promotion: BoardPromotionChoice
## B10 / PER.R8 — the piece follows the pointer; a refused drop returns home.
var _drag: BoardDrag
## The seat flip and CMP-presentation.R2's canvas↔world pair.
var _camera: BoardCamera
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

	_pieces = BoardPieceLayer.new()
	_pieces.assets_needed.connect(func(ids: PackedStringArray) -> void: assets_needed.emit(ids))
	_content.add_child(_pieces)
	_drag = BoardDrag.new()
	_drag.pieces = _pieces
	_drag.motion.connect(_on_drag_motion)
	_content.add_child(_drag)
	_camera = BoardCamera.new()
	_camera.content = _content
	_content.add_child(_camera)

	_destinations = BoardDestinationMarks.new()
	_destinations.z_index = 4
	_overlay_root = _destinations
	_content.add_child(_overlay_root)
	_marks = BoardMarkLayer.new()
	_overlay_root.add_child(_marks)
	_check_marks = CheckMarks.new()
	_overlay_root.add_child(_check_marks)
	_reject_flash = Line2D.new()
	_reject_flash.name = "RejectFlash"
	_reject_flash.width = REJECT_STROKE
	_reject_flash.default_color = COLOR_DANGER
	_reject_flash.closed = true
	_reject_flash.visible = false
	_reject_flash.z_index = 0
	_overlay_root.add_child(_reject_flash)
	_promotion = BoardPromotionChoice.new()
	_overlay_root.add_child(_promotion)

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
	_pieces.refresh_textures(_occupancy, _assets, _piece_asset_id)


func render_position(
	position: Dictionary,
	selection: String = "",
	legal: PackedStringArray = PackedStringArray(),
	options: Dictionary = {}
) -> void:
	if options.has("white_seat"):
		set_white_seat(str(options["white_seat"]))
	if options.has("name_screen") and options.has("name_locale"):
		# R8: the screen and `GS.locale` the piece-node names resolve for, fed by
		# every screen show and locale change so O1 owns resolution (#643).
		_set_name_context(str(options["name_screen"]), str(options["name_locale"]))
	_reflow_coordinates()
	var post_occ: Dictionary = (position.get("occupancy", {}) as Dictionary).duplicate(true)
	_selection = selection
	_legal_marks = legal.duplicate()
	var captures := PackedStringArray()
	for square in _legal_marks:
		var piece: Dictionary = post_occ.get(square, {})
		if not piece.is_empty():
			captures.append(str(square))
	if options.has("capture_marks"):
		captures = PackedStringArray(options["capture_marks"])
	_captures = captures
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
		# In-check is decided by L2 and arrives with the applied move (CTR-presentation G2).
		_sync_check_marks(options)
		_play_move_dict(move)
		return
	_occupancy = post_occ
	if not _motion_busy:
		_sync_pieces()
	_sync_overlays()
	_apply_choice_overlays(options)
	_sync_check_marks(options)


## E4 `show_advice` under CMP-presentation.R4 — best move marks or none. Called
## by the presentation whenever the advice fields change; no CTR operation added.
func render_advice(advice_best_move: Variant) -> void:
	if _advice_marks == null:
		return
	if not (advice_best_move is Dictionary):
		_advice_marks.clear()
		_refresh_marks()
		return
	var move: Dictionary = advice_best_move
	var from_square := str(move.get("from", ""))
	var to_square := str(move.get("to", ""))
	if from_square.is_empty() or to_square.is_empty():
		_advice_marks.clear()
		_refresh_marks()
		return
	_advice_marks.show_best_move(from_square, to_square)
	_refresh_marks()


## CMP-presentation.R8 — the one accessible name a piece node exposes: the Copy key
## `LOC.L9` maps for `kind`, resolved through `CTR-localization` O1 for `GS.locale`.
## `LOC.L8`: the name is the type, so colour is never spoken and `screen` only says
## which owner's string table resolves it. Metadata only — no drawn node, no state.
static func accessible_name(kind: String, screen: String, locale: String) -> String:
	var key := StringTable.piece_name_key(kind)
	if key.is_empty():
		return ""
	match screen:
		"puzzle-play":
			return StringTable.puzzle_play(key, locale)
		"shared-play":
			return StringTable.shared_play(key, locale)
	return ""


## R8 — the screen and `GS.locale` the piece-node names resolve for, fed by the
## screen shows and every locale change so O1 owns resolution (`#643`).
func _set_name_context(screen: String, locale: String) -> void:
	_pieces.set_name_context(screen, locale)


func set_white_seat(seat: String) -> void:
	white_seat = (
		BoardGeometry.SEAT_TOP if seat == BoardGeometry.SEAT_TOP else BoardGeometry.SEAT_BOTTOM
	)
	_camera.white_seat = white_seat
	_layout_camera()


func piece_world_center(square: String) -> Vector2:
	if _drag.square() == square:
		return _drag.world()
	var node: Node2D = _pieces.node_for(square)
	if node != null:
		return node.position
	return BoardGeometry.square_center(square)


## B10 drag follow: `begin` with the square and world point, then `move`.
## B10 drag follow (`begin`/`move`), and the drop: `end_drag_legal` hands a
## legal drop to the move, `end_drag_illegal` returns the piece home, and
## `cancel_drag` drops the follow so O2 can own the place animation.
func update_drag(cmd: Variant, payload: Variant = null) -> void:
	_drag.update_drag(cmd, payload)


func end_drag_legal(to_square: String) -> void:
	await _drag.end_legal(to_square, play_move)


func end_drag_illegal() -> void:
	await _drag.end_illegal()


## Drop drag follow without tween so O2 can own the place animation.
func cancel_drag() -> void:
	_drag.cancel()


## The drag reports its own busy hand-off (B10 return) so a sync leaves the
## piece where the animation put it.
func _on_drag_motion(active: bool) -> void:
	_motion_busy = active
	if active:
		last_return_s = _drag.last_return_s


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
	var mover: Node2D = _pieces.node_for(from_square)
	if mover == null:
		_motion_busy = false
		return
	var dest := BoardGeometry.square_center(to_square)
	last_travel_s = BoardGeometry.TRAVEL_S
	var duration := last_travel_s
	var color := _piece_color(from_square, mover)
	var fragments: Array[Node2D] = []
	if not capture_square.is_empty() and _pieces.node_for(capture_square) != null:
		fragments = _pieces.spawn_capture_break(capture_square, COLOR_INK)
		_pieces.remove(capture_square)
	var rook: Node2D = null
	var rook_dest := Vector2.ZERO
	if not castle_rook_from.is_empty() and _pieces.node_for(castle_rook_from) != null:
		rook = _pieces.node_for(castle_rook_from)
		rook_dest = BoardGeometry.square_center(castle_rook_to)
	# PHY.M3: promotion morph runs inside the same ≤0.15 s budget as M1.
	if not promote_kind.is_empty():
		_pieces.apply_kind_texture(mover, color, promote_kind, _assets, _piece_asset_id)
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
	_pieces.rekey(from_square, to_square, mover)
	if rook != null:
		_pieces.rekey(castle_rook_from, castle_rook_to, rook)
	await _settle(mover)
	# PER.R9 — the pair is replaced by the move that settles, never by a refused one.
	_marks.set_last_move(from_square, to_square)
	camera_offset = Vector2.ZERO
	_motion_busy = false
	travel_finished.emit(to_square)


## CMP-presentation.R2 — the board's screen↔world pair, in *canvas* space: the
## same space `get_global_transform_with_canvas()` and `_refresh_coordinates`
## work in, and the space a pointer event reaches the presentation in once that
## control's own transform is removed (`Presentation._board_world_at`, #845).
## `to_global`/`to_local` walk every ancestor transform, so a seat flip, camera
## zoom, or stretch is included and the pair inverts exactly. Do not apply a
## canvas transform again here: callers already hold canvas coordinates.
## The board's camera: the seat flip and CMP-presentation.R2's canvas↔world pair.
## It owns no board face, so the board reads it directly.
func camera() -> BoardCamera:
	return _camera


## Lookup from a `"color|kind"` slot to the piece sprite's catalog id.
func _piece_asset_id(slot: String) -> String:
	return str(PIECE_IDS.get(slot, ""))


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
	# The foreground keyline is a screen-px width (UIS.C6 / UIS.I1), so every
	# frame that changes the world scale re-derives it.
	if _marks != null:
		_marks.pixels_per_unit = world_px()
		_marks.refresh(_advice_squares())


## Screen px per world unit at the current frame — 36 at 360 × 640 (PRJ.P1).
func world_px() -> float:
	if _world == null:
		return 36.0
	return absf(_world.scale.x)


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
	## PAL.K8 draws C9 ink on the C10 chip, so the chip carries the 1.5 px C9 keyline
	## (UIS.I1): the int border field is set to the ceiling of the floor.
	var chip := Panel.new()
	chip.name = "%s_chip" % key
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.border_color = COLOR_INK
	style.set_border_width_all(_chip_keyline_px())
	style.anti_aliasing = true
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


## UIS.I1's 1.5 screen px floor in the integer border field of StyleBoxFlat.
static func _chip_keyline_px() -> int:
	return int(ceil(UiChrome.KEYLINE_PX))


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
		var screen: Vector2 = _camera.world_to_screen(world)
		var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * screen
		if chip != null:
			chip.position = local - Vector2(half, half)
			chip.size = _coord_chip_size()
		else:
			label.position = local - Vector2(half, half)


func _sync_pieces() -> void:
	_pieces.sync(_occupancy, _assets, _motion_busy, _drag.square(), _piece_asset_id)


func _sync_overlays() -> void:
	_destinations.set_selection(_selection)
	_destinations.show_destinations(_legal_marks, _captures)
	_refresh_marks()


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
		_promotion.clear_choice()


## PER.R6 / R7 — mark the checked King while the side to move is in check. The
## session's `in_check` carries the rules outcome; this only locates the King it
## already renders, so no rules decision is made in L1 (CTR-presentation G2).
func _sync_check_marks(options: Dictionary) -> void:
	if _check_marks == null:
		return
	if not bool(options.get("in_check", false)):
		_check_marks.clear()
		_marks.set_checked_square("")
		_refresh_marks()
		return
	var checked := _king_square(str(options.get("side_to_move", "white")))
	_check_marks.show_square(checked)
	_marks.set_checked_square(checked)
	_refresh_marks()


func _king_square(color: String) -> String:
	for square in _occupancy.keys():
		var piece: Dictionary = _occupancy[square]
		if str(piece.get("color", "")) != color:
			continue
		if str(piece.get("kind", "")) == "king":
			return str(square)
	return ""


## PER.R9 — the last move as one state on two squares: a soft PAL.C7 band on the
## from-square and PAL.C10 corner ticks on the to-square, told apart by form and
## placement, never hue. Held until the next move settles; drawn in board space so
## CAM-board.M2's 180° flip carries both without re-deriving (rules-k9.md).
## The marks themselves (band, ticks, hatching, the one foreground) live in
## `mark_layer()`.
func last_move() -> PackedStringArray:
	if _marks == null:
		return PackedStringArray()
	return _marks.last_move()


## PER.R9 — leaving the board (a new game, or a screen it does not belong to)
## drops the last-move pair; on the board it is replaced only by the next move.
func clear_last_move() -> void:
	if _marks != null:
		_marks.clear_last_move()


## The square marks this board draws: the last move's band and ticks, the refused
## hatching, and the one cream foreground (UIS.C6).
func mark_layer() -> BoardMarkLayer:
	return _marks


## Re-derive the square marks from the current state and the advice accents.
func _refresh_marks() -> void:
	if _marks == null:
		return
	_marks.refresh(_advice_squares())


## The two squares the advice accents mark, empty when advice is off.
func _advice_squares() -> Array:
	if _advice_marks == null:
		return []
	return [_advice_marks.last_from, _advice_marks.last_to]


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
	_reject_tween.set_parallel(true)
	_reject_tween.tween_property(
		_reject_flash, "default_color", Color(COLOR_DANGER, 0.0), SharedGameSession.REJECT_FLASH_S
	)
	# The hatching rides the same flash and needs no cream foreground and no keyline:
	# it is PAL.C8 over the square's own fill, inside the ring (rules.md *Layer split*).
	_marks.start_hatch(square, _reject_tween)
	_reject_tween.chain().tween_callback(_on_reject_flash_tween_done)


func _on_reject_flash_tween_done() -> void:
	clear_reject_flash()
	reject_flash_finished.emit()


func clear_reject_flash() -> void:
	if _reject_tween != null:
		_reject_tween.kill()
		_reject_tween = null
	_reject_flash.visible = false
	_reject_square = ""
	if _marks != null:
		_marks.clear_hatch()


## EX.promote — Q/R/B/N upright sprites in a 2×2 on a promoting destination,
## rebuilt only when the square or colour changes (E-pieces.I33 / I34).
func show_promotion_choice(square: String, color: String, kinds_var: Variant = null) -> void:
	_promotion.show_choice(
		square,
		color,
		kinds_var,
		func(node: Node2D, choice_color: String, kind: String) -> void:
			_pieces.apply_kind_texture(node, choice_color, kind, _assets, _piece_asset_id)
	)


## The chooser itself (`clear_choice`, `show_choice`, `kind_at`), for the checks.
func promotion_choice() -> BoardPromotionChoice:
	return _promotion


## Hit-test C6 promotion sprites in world space; returns kind or "".
func promotion_kind_at(world: Vector2) -> String:
	return _promotion.kind_at(world)


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
