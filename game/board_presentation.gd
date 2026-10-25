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

## Empty legal destination: a solid PAL.C11 disk at the square centre, radius 0.36,
## so its area πr² = 0.407 square clears PER.R4's 1/4 (rules-k9.md *Mark table*).
const LEGAL_EMPTY_R := 0.36
const LEGAL_DISK_SEGMENTS := 32
## Capture destination: PAL.C11 corner brackets — two strokes per corner, inside
## the square, never a ring (rules-k9.md *Mark table*). rules-k9.md states the
## 1/4 area bound but no size for this form (conflict 1, #792), so the size is this
## body's choice: at stroke 0.06 unit — the ring's own width, so a bracket reads as
## a bracket and not a hairline — an arm of 0.52 reaches 8 × 0.06 × 0.52 = 0.25
## exactly; arm 0.56 clears it with margin (8 × 0.06 × 0.56 = 0.2688). The arm is
## longer than the PER.R9 tick's 0.10 and changes neither the two-strokes-per-corner
## form nor the corner placement, and it stays inside the square's 1.0.
const LEGAL_BRACKET_W := 0.06
const LEGAL_BRACKET_ARM := 0.56
## Selection frame stroke in world units (≪ 10% of piece body — PER.R1 / R3).
const SELECT_STROKE := 0.06
## Reject frame stroke — rim only so piece silhouette stays readable (PER.R1 / R8).
const REJECT_STROKE := 0.10
## PER.R8 refused place: PAL.C8 hatching over the square's own fill, inside the
## ring (rules.md *Layer split*). No foreground, no keyline — the hatch is a fill.
const HATCH_STROKE := 0.06
const HATCH_GAP := 0.16
const HATCH_INSET := 0.10
## PER.R9 last move, from-square: a soft PAL.C7 band on the square edge opposite
## the move — blurred, no hard stroke, no keyline, never enclosing (rules-k9.md).
## Layers of (world width, alpha): a wide faint field, a mid haze, a soft core. The
## widest is 0.09 on the outer edge 0.41–0.50, so the band keeps 2.16 px of light
## and its body overlap is (0.425 − 0.41) × 0.60 = 0.009 of the King's 0.1274 body,
## 7.1% — inside PER.R9's 10% (SPC.E1). Every layer clears the UIS.I1 1.5 px floor.
const BAND_LAYERS := [[0.09, 0.16], [0.0625, 0.30], [0.0417, 0.52]]
const BAND_LENGTH := 0.60
## PER.R9 last move, to-square: PAL.C10 corner ticks in the outer 0.10 of the
## square — 0.04 wide, 0.60 long on the from-facing edge, each L arm 0.10
## (rules-k9.md *Per-rule*).
const TICK_W := 0.04
const TICK_LONG := 0.60
const TICK_ARM := 0.10
const TICK_BAND := 0.10
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
## PER.R6 check L-frame on the checked King's square (E2 `in_check`).
var _check_marks: CheckMarks
var _reject_flash: Line2D
## PER.R8 PAL.C8 hatching on the refused square, riding the same 0.3 s flash.
var _reject_hatch: Node2D
## PER.R5 advice marks (E4 `show_advice`), over the pieces.
var _advice_marks: AdviceMarks
## PAL.K9 *Layer split* / UIS.C6 — one PAL.C10 foreground per marked square.
var _mark_foreground: MarkForeground
## PER.R9 last move: the from-square's soft PAL.C7 band.
var _last_move_band: Node2D
var _last_from := ""
var _last_to := ""
## The square carrying the PER.R6 cream L-frame, empty when nobody is in check.
var _checked_square := ""
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
	# The refused-place hatch sits over the square's own fill and over selection and
	# legal marks; both return as it fades (PER.R8).
	_reject_hatch = Node2D.new()
	_reject_hatch.name = "RejectHatch"
	_reject_hatch.visible = false
	_overlay_root.add_child(_reject_hatch)
	# PER.R9 band draws on the square, under the cream foreground.
	_last_move_band = Node2D.new()
	_last_move_band.name = "LastMoveBand"
	_overlay_root.add_child(_last_move_band)
	# The one PAL.C10 foreground per marked square (UIS.C6): above the marks the
	# square carries, below the accents that draw on it.
	_mark_foreground = MarkForeground.new()
	_overlay_root.add_child(_mark_foreground)
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
		_refresh_mark_foreground()
		return
	var move: Dictionary = advice_best_move
	var from_square := str(move.get("from", ""))
	var to_square := str(move.get("to", ""))
	if from_square.is_empty() or to_square.is_empty():
		_advice_marks.clear()
		_refresh_mark_foreground()
		return
	_advice_marks.show_best_move(from_square, to_square)
	_refresh_mark_foreground()


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
	# PER.R9 — the pair is replaced by the move that settles, never by a refused one.
	_set_last_move(from_square, to_square)
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
	# The foreground keyline is a screen-px width (UIS.C6 / UIS.I1), so every
	# frame that changes the world scale re-derives it.
	if _mark_foreground != null:
		_mark_foreground.pixels_per_unit = world_px()
		_sync_last_move_band()
		_refresh_mark_foreground()


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
	# R8: the name rides the same node metadata; promotion re-applies it here.
	node.set_meta("accessible_name", accessible_name(kind, "shared-play", "en"))
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
			_legal_root.add_child(capture_brackets(sq))
		else:
			_legal_root.add_child(empty_disk(sq))
	_refresh_mark_foreground()


## PER.R4 / rules-k9.md — the empty destination's solid PAL.C11 disk at the square
## centre: area πr² = 0.407 square at the kept 0.36 radius (≥ 1/4).
static func empty_disk(square: String) -> Polygon2D:
	var c := BoardGeometry.square_center(square)
	var mark := Polygon2D.new()
	mark.name = "EmptyDisk_%s" % square
	mark.color = COLOR_LEGAL
	var points := PackedVector2Array()
	for i in range(LEGAL_DISK_SEGMENTS):
		var ang := TAU * float(i) / float(LEGAL_DISK_SEGMENTS)
		points.append(c + Vector2(cos(ang), sin(ang)) * LEGAL_EMPTY_R)
	mark.polygon = points
	return mark


## PER.R4 / rules-k9.md — the capture destination's PAL.C11 corner brackets: two
## strokes per corner, inside the square, no ring. The strokes are drawn
## separately so the four corners stay visibly apart from the selection ring.
static func capture_brackets(square: String) -> Node2D:
	var c := BoardGeometry.square_center(square)
	var root := Node2D.new()
	root.name = "CaptureBracket_%s" % square
	var inset := 0.5 - LEGAL_BRACKET_W * 0.5
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			var sx_f := float(sx)
			var sy_f := float(sy)
			var corner := c + Vector2(sx_f * inset, sy_f * inset)
			root.add_child(_legal_stroke(corner, corner + Vector2(-sx_f * LEGAL_BRACKET_ARM, 0.0)))
			root.add_child(_legal_stroke(corner, corner + Vector2(0.0, -sy_f * LEGAL_BRACKET_ARM)))
	return root


static func _legal_stroke(from_point: Vector2, to_point: Vector2) -> Line2D:
	var line := Line2D.new()
	line.name = "Bracket"
	line.width = LEGAL_BRACKET_W
	line.default_color = COLOR_LEGAL
	line.antialiased = true
	line.add_point(from_point)
	line.add_point(to_point)
	return line


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


## PER.R6 / R7 — mark the checked King while the side to move is in check. The
## session's `in_check` carries the rules outcome; this only locates the King it
## already renders, so no rules decision is made in L1 (CTR-presentation G2).
func _sync_check_marks(options: Dictionary) -> void:
	if _check_marks == null:
		return
	if not bool(options.get("in_check", false)):
		_check_marks.clear()
		_checked_square = ""
		_refresh_mark_foreground()
		return
	_checked_square = _king_square(str(options.get("side_to_move", "white")))
	_check_marks.show_square(_checked_square)
	_refresh_mark_foreground()


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
func _set_last_move(from_square: String, to_square: String) -> void:
	_last_from = from_square if BoardGeometry.is_square(from_square) else ""
	_last_to = to_square if BoardGeometry.is_square(to_square) else ""
	_sync_last_move_band()
	_refresh_mark_foreground()


func last_move() -> PackedStringArray:
	return PackedStringArray([_last_from, _last_to])


## PER.R9 — leaving the board (a new game, or a screen it does not belong to)
## drops the last-move pair; on the board it is replaced only by the next move.
func clear_last_move() -> void:
	_last_from = ""
	_last_to = ""
	_sync_last_move_band()
	_refresh_mark_foreground()


## The one PAL.C10 foreground layer (UIS.C6), for the layer and form checks.
func mark_foreground() -> MarkForeground:
	return _mark_foreground


## The PER.R9 from-square soft band node.
func last_move_band() -> Node2D:
	return _last_move_band


## The PER.R8 refused-place hatching node.
func reject_hatch() -> Node2D:
	return _reject_hatch


## The from-square's band, rebuilt from the current seat because it is placed by
## the move's direction, not by the square alone.
func _sync_last_move_band() -> void:
	if _last_move_band == null:
		return
	for child in _last_move_band.get_children():
		_last_move_band.remove_child(child)
		child.queue_free()
	if _last_from.is_empty() or _last_to.is_empty():
		return
	var points := from_band_points(_last_from, _last_to)
	if points.size() < 2:
		return
	# Soft: three translucent PAL.C7 layers of falling width. No hard stroke, no
	# keyline, open at both ends — the ring stays the only closed, crisp form.
	for layer in BAND_LAYERS:
		var line := Line2D.new()
		line.name = "SoftBand"
		line.width = float(layer[0])
		line.default_color = Color(AdviceMarks.COLOR_ADVICE, float(layer[1]))
		line.antialiased = true
		for point in points:
			line.add_point(point)
		_last_move_band.add_child(line)


## The PER.R9 from-square band in world coordinates: a 0.60-long open segment on
## the square's outer edge, on the side facing away from the to-square, beyond
## every body half-width (PER.R1 / SPC.E1) so it covers no body.
static func from_band_points(from_square: String, to_square: String) -> PackedVector2Array:
	var from_center := BoardGeometry.square_center(from_square)
	var to_center := BoardGeometry.square_center(to_square)
	var away := (from_center - to_center)
	if away.length() < 0.0001:
		return PackedVector2Array()
	# One edge, chosen along the move's dominant axis, so the pair reads as a
	# direction even with hue removed.
	var normal := (
		Vector2(signf(away.x), 0.0) if absf(away.x) >= absf(away.y) else Vector2(0.0, signf(away.y))
	)
	var half_band := float(BAND_LAYERS[0][0]) * 0.5
	var mid := from_center + normal * (0.5 - half_band)
	var along := Vector2(-normal.y, normal.x)
	return PackedVector2Array([mid - along * BAND_LENGTH * 0.5, mid + along * BAND_LENGTH * 0.5])


## The PER.R9 to-square ticks in world coordinates: an L in each corner, in the
## outer 0.10 of the square. The long arm (0.60) runs along the edge that faces
## the from-square; the short arm (0.10) turns inward at the same corner, so the
## four ticks read as one direction with the band opposite them.
static func tick_polylines(to_square: String, from_square: String) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	if not BoardGeometry.is_square(to_square) or not BoardGeometry.is_square(from_square):
		return out
	var to_center := BoardGeometry.square_center(to_square)
	var facing := BoardGeometry.square_center(from_square) - to_center
	if facing.length() < 0.0001:
		return out
	var axis := (
		Vector2(signf(facing.x), 0.0) if absf(facing.x) >= absf(facing.y) else Vector2(0.0, signf(facing.y))
	)
	var cross := Vector2(-axis.y, axis.x)
	var offset := 0.5 - TICK_BAND * 0.5
	for sa in [-1.0, 1.0]:
		for sc in [-1.0, 1.0]:
			var sa_f := float(sa)
			var sc_f := float(sc)
			var elbow := to_center + axis * (sa_f * offset) + cross * (sc_f * offset)
			var long_end := elbow - cross * (sc_f * TICK_LONG)
			var short_end := elbow - axis * (sa_f * TICK_ARM)
			out.append(PackedVector2Array([long_end, elbow, short_end]))
	return out


## One foreground layer per marked square, built from whichever marks want cream
## this frame (UIS.C6, rules.md *One layer*).
func _refresh_mark_foreground() -> void:
	if _mark_foreground == null:
		return
	_mark_foreground.pixels_per_unit = world_px()
	_mark_foreground.clear()
	if not _checked_square.is_empty():
		# PER.R6 — the cream L-frame on the two corners the C8 cue already uses.
		_mark_foreground.set_mark(_checked_square, "check", _foreground_marks(
			CheckMarks.l_frame_polylines(_checked_square), Color.TRANSPARENT, CheckMarks.CHECK_STROKE
		))
	if _advice_marks != null:
		for square in [_advice_marks.last_from, _advice_marks.last_to]:
			_mark_foreground.set_mark(str(square), "advice", _foreground_marks(
				AdviceMarks.edge_brackets(str(square)),
				AdviceMarks.COLOR_ADVICE,
				AdviceMarks.ADVICE_STROKE
			))
	if not _last_to.is_empty() and not _last_from.is_empty():
		_mark_foreground.set_mark(_last_to, "ticks", _foreground_marks(
			tick_polylines(_last_to, _last_from), Color.TRANSPARENT, TICK_W
		))


static func _foreground_marks(
	polylines: Array[PackedVector2Array], accent: Color, width: float
) -> Array:
	var marks: Array = []
	for points in polylines:
		marks.append({"points": points, "accent": accent, "width": width})
	return marks


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
	_build_reject_hatch(c)
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
	_reject_hatch.modulate.a = 1.0
	_reject_tween.tween_property(_reject_hatch, "modulate:a", 0.0, SharedGameSession.REJECT_FLASH_S)
	_reject_tween.chain().tween_callback(_on_reject_flash_tween_done)


## PER.R8 — PAL.C8 hatching across the refused square's own fill, inset inside the
## selection ring and clear of the rim the flash keeps.
func _build_reject_hatch(center: Vector2) -> void:
	for child in _reject_hatch.get_children():
		_reject_hatch.remove_child(child)
		child.queue_free()
	var reach := 0.5 - HATCH_INSET
	var step := HATCH_GAP / sqrt(2.0)
	var offset := -2.0 * reach
	while offset <= 2.0 * reach:
		var span := hatch_span(offset, reach)
		if not span.is_empty():
			var line := Line2D.new()
			line.name = "HatchStroke"
			line.width = HATCH_STROKE
			line.default_color = COLOR_DANGER
			line.antialiased = true
			line.add_point(center + (span[0] as Vector2))
			line.add_point(center + (span[1] as Vector2))
			_reject_hatch.add_child(line)
		offset += step
	_reject_hatch.visible = true


## One 45° hatch stroke, given its constant x − y and the inset square's reach.
## Returned as the two ends clipped to the square, or empty when it misses it.
static func hatch_span(offset: float, reach: float) -> Array:
	var start := maxf(-reach, offset - reach)
	var end := minf(reach, offset + reach)
	if start >= end:
		return []
	return [Vector2(start, start - offset), Vector2(end, end - offset)]


func _on_reject_flash_tween_done() -> void:
	clear_reject_flash()
	reject_flash_finished.emit()


func clear_reject_flash() -> void:
	if _reject_tween != null:
		_reject_tween.kill()
		_reject_tween = null
	_reject_flash.visible = false
	_reject_square = ""
	if _reject_hatch != null:
		_reject_hatch.visible = false
		_reject_hatch.modulate.a = 1.0


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
