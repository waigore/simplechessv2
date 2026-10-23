class_name DemoBoardView
extends Node2D
## Board, pieces, motion, and overlays for demo #335, in SPC world units.
## The origin sits at the board's top-left on screen; local x runs files a-h
## and local y runs down toward rank 1. CAM-board.M2 (puzzle): the Solving side
## Black rotates the whole view 180° about the board center so that side's near
## edge faces the player; White solves at rotation 0. Cut at deal, no motion.

const COLOR_LIGHT := Color("E8D5B5")   # PAL.C1
const COLOR_DARK := Color("8B5A3C")    # PAL.C2
const COLOR_TABLE := Color("5C3A2A")   # PAL.C5, SPC.L1 cafe backdrop
const COLOR_SELECT := Color("B8940C")  # PAL.C6, PER.R3
const COLOR_LEGAL := Color("6EA746")   # PAL.C11, PER.R4
const COLOR_INK := Color("2C2A28")     # PAL.C9
const COLOR_CREAM := Color("F7F1E8")   # PAL.C10
## PER.R7 coordinate ink: cream PAL.C10 on the wooden coordinate band, 7.38:1
## (defect #427 item 3).
const COORD_COLOR := Color("F7F1E8")   # PAL.C10
const COLOR_ROSE := Color("C28A86")    # PAL.C8: check rim, refusal flash
## Empty-legal diamond half-diagonal r; ink area 2 r^2 >= 1/4 square (PER.R4).
const LEGAL_EMPTY_R := 0.36
## Capture ink ring: ink area 2 pi r w >= 1/4 square (PER.R4).
const LEGAL_CAPTURE_R := 0.40
const LEGAL_CAPTURE_W := 0.10
const SELECT_STROKE := 0.06            # far under 10% of the body (PER.R1/R3)
const REJECT_STROKE := 0.10
const CHECK_STROKE := 0.10
## SPC.E1 piece body extent (FRM.P1): a 0.85 x 0.85 box centered on the square,
## and every body drawn inside it on one ground line. The catalog sprites are
## tall and narrow (body 1.6-2.1 times taller than wide) and float in a
## transparent canvas, so neither the canvas nor one axis alone can be the fit.
## One shared body scale is taken from the tallest body (the King): the King
## reaches the full 0.85 height, each shorter type keeps its artwork proportion
## and the FRM.P2 height order, and no body is ever wider or taller than the
## extent. (Scaling the canvas drew bodies 0.52-0.72 units tall — the miss in
## #427 item 1; scaling the body width instead drew them 1.32-1.81 tall — the
## acceptance miss on #63.)
const PIECE_EXTENT := 0.85
## Solid wooden bevel (defect #427 item 4, SRF.M1 wood, AES.P3 physical set):
## a frame around the 8x8 so the board reads as one carved wooden object on the
## cafe table. It uses the board's own outer band, so it never covers a piece
## square (SPC.E1) and never adds chrome inside the play area.
const RIM_OUTER := 0.10                # wooden lip around the 0..8 square bounds
const BEVEL_FRAME := 0.10              # raised frame outside the lip
const BEVEL_LIP_COLOR := Color("8B5A3C")     # PAL.C2 grain, lit from top-left
const BEVEL_SHADOW_COLOR := Color("43281D")  # C5 deepened, shadowed lip
const BEVEL_FRAME_COLOR := Color("5C3A2A")   # PAL.C5 table wood, the frame
const BEVEL_LINE := Color("2E1B13")    # darker than the bevel fill (SRF.O1)
## The coordinate bands (left for ranks, bottom for files) are PAL.C2 grain
## darkened to give the coordinate ink its field (PER.R7; see _build_bevel).
const BEVEL_LIP_INK_COLOR := Color("6E4430")
const BEVEL_LIP_INK_BAND := 0.16       # depth of each coordinate band, units
## PER.R7: file letters and rank numbers sit on the wooden lip, never inside a
## square, at >= 4.5:1 for every glyph pixel. Ink is cream PAL.C10 on the
## coordinate band: ink PAL.C9 reaches only 1.72:1 there and PAL.C10 7.38:1,
## over R7's 4.5:1 floor (defect #427 item 3).
##
## The label must fit the field it is painted on: the glyph's whole ink box has
## to stay inside the BEVEL_LIP_INK_BAND-wide band, or the part that hangs over
## the light PAL.C1 table margin reads at 1.28:1 (defect #592). The font is
## therefore clamped to the largest em that inks COORD_BAND_SHARE of the band,
## and the labels are centred in the band, not in the lip. UIS.T2's 16 px floor
## is a 640 px-frame figure and cannot also fit a 0.16-unit band; R7's contrast
## floor wins here (defect #592).
const COORD_BAND_SHARE := 0.8          # share of the band the glyph may ink
const COORD_UNIT_PX := 72.0            # PRJ.P1: screen px per board unit here
const COORD_CANVAS_UNITS := 10.0       # canvas spans the 10-unit frame
const COORD_CANVAS_POSITION := Vector2.ZERO
## The canvas is pinned to the 0..8 board bounds, so its origin is the board's
## own (0, 0) in board units (defect #427 item 3: the labels used to shift by
## this inset on top of an inset that was already part of their positions, which
## put the files one rank below and the ranks one file left).
const TRAVEL_S := 0.15                 # PHY.M1 / MOT.T1 budget
const RETURN_S := 0.15                 # PHY.M5 bad-drop return
const SETTLE_S := 0.03                 # PHY.I1 settle window
const PROMOTE_SPRITE_SCALE := 0.75     # chooser cell share of the fitted body scale

const PROMOTE_ORDER := ["q", "r", "b", "n"]  # I33/I34 demo chooser order
## FRM.P2 opaque height per type as a fraction of one square, +-0.01.
const FRM_P2_HEIGHTS := {
	"wK": 0.85, "wQ": 0.79, "wB": 0.76, "wN": 0.75, "wR": 0.68, "wP": 0.62,
}
const FRM_P2_TOLERANCE := 0.01

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

var _loaded_assets: Dictionary = {}
var _fit_scale := 0.0        # board units per canvas px, shared by all piece types
var _tallest_body_px := 0.0  # the King's opaque body height, px
var _pieces: Dictionary = {}   # square index -> Node2D
var _drag_square := -1
var _motion_busy := false
var flipped := false           # CAM-board.M2: Solving side Black turns the view over


func setup(piece_ids: Dictionary, font: Font, board_bg: Texture2D) -> void:
	_piece_ids = piece_ids
	font_resource = font
	_build_backdrop(board_bg)
	_build_bevel()
	_squares_root = Node2D.new()
	_squares_root.name = "Squares"
	add_child(_squares_root)
	_build_squares()
	_build_coords()
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
	# PRJ.P1: the cafe backdrop art spans the 10-unit frame; the board draws above
	# its middle, so only the cafe-table margin around the board shows.
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


## Defect #427 item 4: a solid wooden bevel frames the 8x8 so the board reads as
## one carved wooden object on the cafe table (AES.P3, SRF.M1). A lit/shadowed
## lip sits against the squares and a raised frame outside it, all inside the
## board's outer margin (SPC.P1): no square or piece is ever covered.
func _build_bevel() -> void:
	# Raised frame outside the lip, visible on the shadowed bottom and right
	# edges and turned into the carved corner at the bottom-right.
	var outer := 8.0 + RIM_OUTER + BEVEL_FRAME
	_add_band("BevelFrameBottom", BEVEL_FRAME_COLOR,
		Vector2(-RIM_OUTER, 8.0 + RIM_OUTER), Vector2(8.0 + RIM_OUTER, outer))
	_add_band("BevelFrameRight", BEVEL_FRAME_COLOR,
		Vector2(8.0 + RIM_OUTER, -RIM_OUTER), Vector2(outer, 8.0 + RIM_OUTER))
	# Light falls from the top-left (SRF.S1): top and left lips in PAL.C2 grain,
	# bottom and right lips in the deepened C5, so every square edge meets wood.
	_add_band("BevelLipTop", BEVEL_LIP_COLOR,
		Vector2(-RIM_OUTER, -RIM_OUTER), Vector2(8.0 + RIM_OUTER, RIM_OUTER))
	_add_band("BevelLipLeft", BEVEL_LIP_COLOR,
		Vector2(-RIM_OUTER, RIM_OUTER), Vector2(RIM_OUTER, 8.0 + RIM_OUTER))
	_add_band("BevelLipBottom", BEVEL_SHADOW_COLOR,
		Vector2(-RIM_OUTER, 8.0 - RIM_OUTER), Vector2(8.0 + RIM_OUTER, 8.0 + RIM_OUTER))
	_add_band("BevelLipRight", BEVEL_SHADOW_COLOR,
		Vector2(8.0 - RIM_OUTER, RIM_OUTER), Vector2(8.0 + RIM_OUTER, 8.0 - RIM_OUTER))
	# Coordinate bands (defect #427 item 3, PER.R7): the letters and numbers need
	# a 4.5:1 field. On the lit PAL.C2 lip ink reaches only 2.5:1, so the left and
	# bottom lips — where the ranks and files are — lie in PAL.C2 grain darkened
	# to #6E4430, and the labels are drawn in cream PAL.C10: 7.4:1 on the band
	# (ink PAL.C9 would be 1.7:1). The bands lie on the lip, outside the 8x8, so
	# no piece square is covered.
	_add_band("BevelLipLeftInk", BEVEL_LIP_INK_COLOR,
		Vector2(-RIM_OUTER, -RIM_OUTER),
		Vector2(-RIM_OUTER + BEVEL_LIP_INK_BAND, 8.0 + RIM_OUTER))
	_add_band("BevelLipBottomInk", BEVEL_LIP_INK_COLOR,
		Vector2(-RIM_OUTER, 8.0 + RIM_OUTER - BEVEL_LIP_INK_BAND),
		Vector2(8.0 + RIM_OUTER, 8.0 + RIM_OUTER))
	var outline := Line2D.new()
	outline.name = "BevelOutline"
	outline.width = 0.012
	outline.default_color = BEVEL_LINE
	outline.closed = true
	for corner in [
		Vector2(-RIM_OUTER, -RIM_OUTER), Vector2(outer, -RIM_OUTER),
		Vector2(outer, outer), Vector2(-RIM_OUTER, outer),
	]:
		outline.add_point(corner)
	add_child(outline)


func _signed_area(points: PackedVector2Array) -> float:
	var area := 0.0
	for i in range(points.size()):
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		area += a.x * b.y - b.x * a.y
	return area / 2.0


## One rectangular wooden band (a bevel lip or frame edge), wound for Polygon2D.
func _add_band(band_name: String, color: Color, lo: Vector2, hi: Vector2) -> void:
	var corners := PackedVector2Array([lo, Vector2(lo.x, hi.y), hi, Vector2(hi.x, lo.y)])
	if _signed_area(corners) < 0.0:
		corners.reverse()
	var band := Polygon2D.new()
	band.name = band_name
	band.color = color
	band.polygon = corners
	add_child(band)


func _build_coords() -> void:
	if font_resource == null:
		return
	# PER.R7: the labels are a canvas-sized Control in canvas pixels, scaled by
	# 1 / COORD_UNIT_PX into board units, so the font size stays a real canvas
	# size (a Node2D glyph at a sub-pixel size is dropped). Its z_index sits above
	# the board polygons and below the pieces.
	var coords := CoordLabels.new()
	coords.name = "Coordinates"
	coords.font = font_resource
	coords.font_px = coord_font_px()
	coords.flipped = flipped
	coords.size = Vector2.ONE * COORD_CANVAS_UNITS * COORD_UNIT_PX
	coords.scale = coords.layout_multiplier()
	coords.position = COORD_CANVAS_POSITION
	add_child(coords)


## PER.R7: the label size, clamped so the glyph's ink box (ascent + descent)
## fits inside the coordinate band (defect #592: the fixed 40 px glyph is taller
## than the whole band, so its top and bottom landed on the light margin at
## 1.28:1).
func coord_font_px() -> float:
	if font_resource == null:
		return 0.0
	var target := BEVEL_LIP_INK_BAND * COORD_UNIT_PX * COORD_BAND_SHARE
	var px := 48.0  # start above any size that fits, then shrink to the clamp
	while px > 1.0 and coord_text_height(px) > target:
		px -= 0.5
	return px


## The ink height of the shipped face at `px`: ascent + descent.
func coord_text_height(px: float) -> float:
	if font_resource == null:
		return 0.0
	return float(font_resource.get_ascent(px) + font_resource.get_descent(px))


## PER.R7 geometric check for the autodrive: every label's ink box (the whole
## glyph, x and y) inside the wooden coordinate band it sits on, so none of its
## ink can land on the 1.28:1 table margin or inside the 8x8. Canvas pixels;
## the coordinates node scales them to board units unchanged.
func measure_coord_labels() -> Array:
	var problems: Array = []
	if font_resource == null:
		return ["no font for the coordinate labels"]
	var px := coord_font_px()
	print("[demo] coordinates %.1f px glyph ink %.1f px in a %.1f px band (PER.R7)" % [
		px, coord_text_height(px), BEVEL_LIP_INK_BAND * COORD_UNIT_PX,
	])
	for spot in CoordLabels.spots(flipped):
		var text: String = spot["text"]
		var rect := CoordLabels.text_rect(font_resource, text, spot["at"] as Vector2, px)
		var band := spot["band"] as Rect2
		print("[demo]   %s box x %.1f..%.1f y %.1f..%.1f px; band x %.1f..%.1f y %.1f..%.1f" % [
			text, rect.position.x, rect.end.x, rect.position.y, rect.end.y,
			band.position.x, band.end.x, band.position.y, band.end.y,
		])
		if not band.encloses(rect):
			problems.append("%s label %s leaves its coordinate band %s" % [text, rect, band])
	return problems


## PER.R7: files a-h and ranks 1-8 in cream PAL.C10 on the coordinate bands of
## the wooden bevel (7.4:1 against the band). Drawn in board units by the
## board's own transform, so the glyphs stay vector; the geometry is computed in
## canvas px (PRJ.P1: COORD_UNIT_PX per unit) and scaled back down.
class CoordLabels extends Control:
	var font: Font
	var font_px := 0.0    # the PER.R7 clamped canvas size, set when the labels are built
	var flipped := false  # CAM-board.M2: mirrored board keeps the labels upright

	## The file and rank label spots in canvas px, centred in the band they sit
	## on, with the band they must stay inside. Canvas x runs files (0 at file a)
	## and canvas y runs ranks (0 at rank 8). A flipped board labels the screen
	## column/row with its own board file/rank, so the letters and numbers stay
	## upright while the squares turn over.
	static func spots(flipped: bool) -> Array:
		var left := Rect2(0.0, 0.0,
			BEVEL_LIP_INK_BAND * COORD_UNIT_PX,
			(8.0 + RIM_OUTER) * COORD_UNIT_PX)  # the left band runs the lip's height
		var bottom := Rect2(0.0, (8.0 + RIM_OUTER - BEVEL_LIP_INK_BAND) * COORD_UNIT_PX,
			(8.0 + RIM_OUTER) * COORD_UNIT_PX, BEVEL_LIP_INK_BAND * COORD_UNIT_PX)
		var out: Array = []
		for screen_file in range(8):
			var file_index := 7 - screen_file if flipped else screen_file
			out.append({
				"text": String.chr(97 + file_index),
				"at": Vector2((float(screen_file) + 0.5) * COORD_UNIT_PX, bottom.get_center().y),
				"band": bottom,
			})
		for screen_row in range(8):
			var rank := screen_row + 1 if flipped else 8 - screen_row
			out.append({
				"text": str(rank),
				"at": Vector2(left.get_center().x, (float(screen_row) + 0.5) * COORD_UNIT_PX),
				"band": left,
			})
		return out

	## The ink box of one label centred on `at` (canvas px). draw_string takes the
	## glyph's baseline, not its top, so the top is one ascent above it and the
	## ink height is ascent + descent (defect #592: the old stamp took the
	## baseline for the top and drew every label ~0.43 unit too high).
	static func text_rect(f: Font, text: String, at: Vector2, px: float) -> Rect2:
		var width := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var ascent := float(f.get_ascent(px))
		var descent := float(f.get_descent(px))
		return Rect2(at - Vector2(width / 2.0, (ascent + descent) / 2.0),
			Vector2(width, ascent + descent))

	## PER.R7 placement: every spot is set in canvas px (one unit = COORD_UNIT_PX
	## px). The Control is canvas-sized and sits on the board's top-left corner.
	func layout_multiplier() -> Vector2:
		return Vector2.ONE / COORD_UNIT_PX

	func _draw() -> void:
		# A Control in the 2D tree sorts by z_index as a canvas item: the labels
		# sit above the board's polygons (z 0) and below the pieces (z 3).
		z_index = 2
		if font == null or font_px <= 1.0:
			return
		for spot in spots(flipped):
			var text := str(spot["text"])
			var at: Vector2 = spot["at"]
			var box := text_rect(font, text, at, font_px)
			var baseline := box.end.y - float(font.get_descent(font_px))
			draw_string(font, Vector2(box.position.x, baseline), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, font_px, COORD_COLOR)


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


## CAM-board.M2: the puzzle view rotates 180° about F1 (4, 4) so the Solving
## side's near edge faces the player. Squares and the wooden bevel are symmetric,
## so only the piece/overlay positions and the input mapping turn over.
func place_point(index: int) -> Vector2:
	var c := square_center(index)
	if flipped:
		return Vector2(8.0 - c.x, 8.0 - c.y)
	return c


func set_orientation(flipped_board: bool) -> void:
	flipped = flipped_board
	var coords := get_node_or_null("Coordinates")
	if coords != null:
		coords.set("flipped", flipped)
		coords.queue_redraw()


func index_from_unit(unit_pos: Vector2) -> int:
	## Unit-space point (relative to the board origin) -> square; -1 off board.
	var point := unit_pos
	if flipped:
		point = Vector2(8.0 - unit_pos.x, 8.0 - unit_pos.y)
	var f := int(floorf(point.x))
	var row := int(floorf(point.y))
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
	node.position = place_point(index)
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"  # demos move code finds it by name
	sprite.centered = true
	_apply_piece_texture(sprite, code)
	node.set_meta("code", code)
	node.add_child(sprite)
	_pieces_root.add_child(node)
	_pieces[index] = node


## Draws one piece at the shared body scale inside the SPC.E1 extent (FRM.P1):
## the scale is the same for every type, so the King stands the full 0.85 tall
## and each shorter type keeps its own height and the FRM.P2 order, and every
## body sits on the extent box's ground line, centered on the square. The same
## fit serves placement, promotion, and the promotion chooser.
func _apply_piece_texture(sprite: Sprite2D, code: String) -> void:
	var texture := _texture_for(code)
	if texture == null:
		return
	sprite.texture = texture
	sprite.scale = Vector2.ONE * _piece_fit()
	# The extent box is centered on the square, so its ground line is half an
	# extent below the node origin; shift the canvas until the opaque body's
	# bottom edge meets that line.
	var body := _body_rect(texture)
	sprite.offset = Vector2(0.0,
		float(texture.get_height()) / 2.0 - float(body.end.y) + _tallest_body_px / 2.0)


## The shared body scale in board units per canvas pixel: the tallest body in the
## set maps to PIECE_EXTENT, so every other body stays inside the extent.
func _piece_fit() -> float:
	if _fit_scale <= 0.0:
		var tallest := 1.0
		for asset_id in _piece_ids.values():
			var texture := _loaded_assets.get(str(asset_id), null) as Texture2D
			if texture != null:
				tallest = maxf(tallest, float(maxi(_body_rect(texture).size.y, 1)))
		_tallest_body_px = tallest
		_fit_scale = PIECE_EXTENT / tallest
	return _fit_scale


## FRM.P1/P2 evidence: each type's drawn body in board units against the extent
## and its FRM.P2 height (+-0.01). The autodrive logs the lines and fails on any
## problem.
func measure_piece_bodies() -> Array:
	var problems: Array = []
	for code in FRM_P2_HEIGHTS:
		var texture := _texture_for(code)
		if texture == null:
			problems.append("no piece texture for %s" % code)
			continue
		var body := _body_rect(texture)
		var size := Vector2(float(body.size.x), float(body.size.y)) * _piece_fit()
		var expected := float(FRM_P2_HEIGHTS[code])
		print("[demo] %s body %.2f x %.2f units (SPC.E1 %.2f, FRM.P2 %.2f)" % [
			code, size.x, size.y, PIECE_EXTENT, expected,
		])
		if size.x > PIECE_EXTENT + FRM_P2_TOLERANCE or size.y > PIECE_EXTENT + FRM_P2_TOLERANCE:
			problems.append("%s body %.2f x %.2f exceeds the SPC.E1 extent" % [
				code, size.x, size.y,
			])
		if absf(size.y - expected) > FRM_P2_TOLERANCE:
			problems.append("%s body height %.2f is not the FRM.P2 %.2f" % [
				code, size.y, expected,
			])
	return problems


func _body_rect(texture: Texture2D) -> Rect2i:
	var used := texture.get_image().get_used_rect()
	if used.size.x <= 0:
		return Rect2i(0, 0, texture.get_width(), texture.get_height())
	return used


func _texture_for(code: String) -> Texture2D:
	var loader_resource: Resource = _loaded_assets.get(str(_piece_ids.get(code, "")), null)
	return loader_resource as Texture2D


func provide_assets(resources_by_id: Dictionary) -> void:
	_loaded_assets.merge(resources_by_id)
	_fit_scale = 0.0  # the shared body scale is measured over the loaded set
	_tallest_body_px = 0.0


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
	var c := place_point(selected)
	var half := 0.5 - SELECT_STROKE * 0.5
	_select_frame.clear_points()
	_select_frame.add_point(c + Vector2(-half, -half))
	_select_frame.add_point(c + Vector2(half, -half))
	_select_frame.add_point(c + Vector2(half, half))
	_select_frame.add_point(c + Vector2(-half, half))
	_select_frame.visible = true
	for target in legal:
		var mark_c := place_point(int(target))
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
	var c := place_point(index)
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
	tween.tween_property(node, "position", place_point(index), RETURN_S)
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
		var promoted_code := "%s%s" % [str(node.get_meta("code")).substr(0, 1), promo_kind.to_upper()]
		if sprite != null and _texture_for(promoted_code) != null:
			node.set_meta("code", promoted_code)
			_apply_piece_texture(sprite, promoted_code)
			base_scale = sprite.scale
			sprite.modulate.a = 0.35
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "position", place_point(dest), dur)
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
		tween.tween_property(king_node, "position", place_point(king_to), dur)
	if rook_node != null:
		tween.tween_property(rook_node, "position", place_point(rook_to), dur)
	await tween.finished
	_motion_busy = false


func codes_match(index: int) -> bool:
	return _pieces.has(index)


## I33/I34: four upright sprites in a 2x2 on the destination square.
func show_promo_choice(dest_index: int, color: String) -> void:
	hide_promo_choice()
	var c := place_point(dest_index)
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
		if _texture_for("%s%s" % [color, kind]) != null:
			var sprite := Sprite2D.new()
			sprite.centered = true
			# Same body-fitted scale as the board, then shrunk for the chooser cell.
			_apply_piece_texture(sprite, "%s%s" % [color, kind])
			sprite.scale *= PROMOTE_SPRITE_SCALE
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
