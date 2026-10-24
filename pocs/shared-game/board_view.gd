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
## PER.R7 coordinate ink: PAL.C9 ink on the light PAL.C1 coordinate band, 9.95:1
## (defect #427 item 3; the issue and PO direction ask for black/ink coordinates
## on a light-brown margin, which the earlier dark band could not carry at
## 4.5:1 and so had gone cream).
const COORD_COLOR := Color("2C2A28")   # PAL.C9
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
## The lip is 0.65 units deep so the 0.50-unit coordinate band and its 0.36-unit
## UIS.T2 line box fit in it entirely outside the 8x8, and the outer 0.15 carries
## the lit / shadowed wood that makes the board read as one carved object. (At
## 0.10 the earlier 0.16 band overran the 8x8 and its labels landed inside the
## a-file / rank-1 squares — defect #592 rework; the T2 rework of #427 sizes the
## lip for the 23 px glyph line box, and measure_typography() still requires the
## whole bevel to stay inside the frame.) The frame stays outside the lip.
const RIM_OUTER := 0.65                # wooden lip around the 0..8 square bounds
const BEVEL_FRAME := 0.10              # raised frame outside the lip
const BEVEL_LIP_COLOR := Color("8B5A3C")     # PAL.C2 grain, lit from top-left
const BEVEL_SHADOW_COLOR := Color("43281D")  # C5 deepened, shadowed lip
const BEVEL_FRAME_COLOR := Color("5C3A2A")   # PAL.C5 table wood, the frame
const BEVEL_LINE := Color("2E1B13")    # darker than the bevel fill (SRF.O1)
## The coordinate bands (left for ranks, bottom for files) are a PAL.C1 light
## wood inlay in the lip, so the PAL.C9 ink reads 9.95:1 (PER.R7; see
## _build_bevel). The earlier build darkened the band to #6E4430 and had to use
## cream ink: PAL.C9 reached only 1.72:1 there.
const BEVEL_LIP_INK_COLOR := Color("E8D5B5")  # PAL.C1 light wood inlay
const BEVEL_LIP_INK_BAND := 0.50       # depth of each coordinate band, units
## PER.R7: file letters and rank numbers sit on the wooden lip, never inside a
## square, at >= UIS.T2 and >= 4.5:1 for every glyph pixel. Ink is PAL.C9 on the
## PAL.C1 light wood inlay: 9.95:1, over R7's 4.5:1 floor (defect #427 item 3;
## the issue and PO direction ask for black/ink coordinates).
##
## The label must fit the field it is painted on: the glyph's whole ink box has
## to stay inside the BEVEL_LIP_INK_BAND-wide band, or the part that hangs over
## the light PAL.C1 table margin reads at 1.28:1 (defect #592). The labels are
## centred in the band, not in the lip.
##
## UIS.T2 states its floor in screen px "at the 640 px reference frame height",
## so the reference is a screen whose short axis is 640 px and whose frame is
## the 10-unit short axis of PRJ.P1: one board unit is 64 screen px there, and
## 16 screen px is a quarter of a unit. The coordinate canvas therefore runs at
## COORD_UNIT_PX per unit (= 640 / 10) and the face is T2's 16 px, scaled up by
## the screen with the board (PRJ.X1). It used to be "clamped" to 6.5 px to fit
## the band, and the renderer drew 3-4 px smudges: legibility and the
## rendered-ink probe both fail on the same cause (defect #427 rework, 3rd
## verification). The band is half a unit because of the glyph line box: ascent
## + descent at 16 px is 23 px (1.44 px above the em), and the band is given
## 0.8 fit headroom, so 0.50 units of the board are the coordinate band and the
## rest of the 0.65 lip is lit wood (PRJ.P1 keeps the whole bevel inside the
## frame's 1-unit margin around the 8x8).
const COORD_TYPE_PX := 16.0            # UIS.T2 at the 640 px reference frame
## UIS.T2's floor, as the spec states it. Kept apart from COORD_TYPE_PX so the
## type check fails when the face shrinks: comparing the face to itself let a
## 6.5 px face pass its own check (defect #427 rework).
const UIS_T2_PX := 16.0
## The fewest rendered ink pixels one coordinate glyph of the UIS.T2 face
## leaves with this probe; eight glyphs make a band's floor. Measured ~40 px per
## glyph at the demo frame, ~3 px for the whole band at the 6.5 px face.
const MIN_GLYPH_INK_PX := 20.0
const COORD_BAND_SHARE := 0.8          # share of the band the glyph line box may ink
const COORD_UNIT_PX := 64.0            # 640 reference px over the 10-unit frame
const FRAME_SIZE := Vector2(720.0, 1280.0)  # demo frame (main.gd, project.godot)
const COORD_CANVAS_UNITS := 10.0       # canvas spans the 10-unit frame
## The canvas is pinned to the 0..8 board bounds, so its origin is the board's
## own (0, 0) in board units (defect #427 item 3: the labels used to shift by
## this inset on top of an inset that was already part of their positions, which
## put the files one rank below and the ranks one file left). The bands are
## placed in the same canvas coordinates, so they run negative in x (the left
## band) and past 8 in y (the bottom band); see CoordLabels.spots().
const COORD_CANVAS_POSITION := Vector2.ZERO
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
var _probe_hidden := {}


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
	# a 4.5:1 field. On the lit PAL.C2 lip PAL.C9 ink reaches only 2.5:1, so the
	# left and bottom lips — where the ranks and files are — take a PAL.C1 light
	# wood inlay, and the labels are drawn in PAL.C9 ink: 9.95:1 on the band (the
	# earlier darkened band could only carry cream). The bands lie on the lip,
	# outside the 8x8, so no piece square is covered.
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
	# A Control's transform starts at its own top-left, so the labels are placed
	# in canvas pixels and the node is scaled to the board's px-per-unit: a
	# Label under the board's Node2D would keep its screen font size, and a
	# one-unit Node2D glyph is below the font rasterizer's minimum size.
	var coords := CoordLabels.new()
	coords.name = "Coordinates"
	coords.font = font_resource
	coords.font_px = coord_font_px()
	coords.size = Vector2.ONE * (COORD_CANVAS_UNITS * COORD_UNIT_PX)
	coords.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# A Control added under a Node2D still lays out against the viewport, so its
	# anchors are pinned to the top-left and every layout anchor is cleared;
	# otherwise the stretch of the demo's 720 px viewport re-derived its rect and
	# shifted the whole canvas off the board (defect #427 rework).
	coords.set_anchors_preset(Control.PRESET_TOP_LEFT)
	coords.anchor_right = 0.0
	coords.anchor_bottom = 0.0
	coords.offset_left = 0.0
	coords.offset_top = 0.0
	coords.offset_right = coords.size.x
	coords.offset_bottom = coords.size.y
	coords.scale = Vector2.ONE / COORD_UNIT_PX
	coords.position = COORD_CANVAS_POSITION
	coords.z_index = 1  # above the bevel and the squares, below the pieces
	add_child(coords)


## UIS.T2 label size (PER.R7): a quarter of a board unit at the 640 px reference
## frame, so the letters and numbers grow with the board on any screen
## (PRJ.X1). The band is cut to the glyph's line box (ascent + descent, the ink
## box the rasterizer uses) plus a small breathing margin, and must still fit the
## lip outside the 8x8: the autodrive check measure_typography() enforces all
## three, so a face or band edit that breaks PER.R7 fails the run instead of
## shrinking the type.
func coord_font_px() -> float:
	return COORD_TYPE_PX


## The ink height of the shipped face at `px`: ascent + descent, as the
## rasterizer reports them. The line box the label is fitted into.
func coord_text_height(px: float) -> float:
	if font_resource == null:
		return 0.0
	return float(font_resource.get_ascent(px) + font_resource.get_descent(px))


## PER.R7 type and frame check for the autodrive: the face delivers UIS.T2 at the
## 640 px reference frame, its glyph line box fits the drawn band with margin,
## the bands are drawn, and the whole bevel stays inside the frame (PRJ.P1).
## Geometry in canvas px, the label's own unit.
func measure_typography() -> Array:
	var problems: Array = []
	if font_resource == null:
		return ["no font for the coordinate labels"]
	var px := coord_font_px()
	var ink_px := coord_text_height(px)
	var unit_ref := FRAME_SIZE.x / COORD_CANVAS_UNITS  # reference-frame px per unit
	var t2_px := COORD_TYPE_PX * unit_ref / COORD_UNIT_PX
	var band_px := BEVEL_LIP_INK_BAND * COORD_UNIT_PX
	print("[demo] coordinates: UIS.T2 face %.1f px (%.1f screen px at the 640 px reference frame), line box %.1f px in a %.1f px band; %s" % [
		px, t2_px, ink_px, band_px,
		"OK" if t2_px >= UIS_T2_PX and ink_px <= band_px * COORD_BAND_SHARE else "FAIL",
	])
	if t2_px < UIS_T2_PX:
		problems.append("coordinate face %.1f screen px is under UIS.T2 (16 px at 640)" % t2_px)
	if ink_px > band_px * COORD_BAND_SHARE:
		problems.append("coordinate line box %.1f px does not fit the %.1f px band" % [
			ink_px, band_px,
		])
	# PRJ.P1: the carved board (lip + frame) must stay inside the demo frame.
	# Measured through the board's own on-frame transform, since the canvas'
	# 64 px reference unit is not the demo's 72 px board unit.
	var xf := get_global_transform()
	var scale_px := absf(xf.get_scale().x)
	var board_px := (8.0 + RIM_OUTER + BEVEL_FRAME) * scale_px
	var board_left := xf.origin.x - RIM_OUTER * scale_px
	var board_right := xf.origin.x + board_px
	var board_bottom := xf.origin.y + board_px
	var lip_px := RIM_OUTER * scale_px
	print("[demo] board bevel %.0f px wide at (%.0f..%.0f) in the %.0f x %.0f frame; lip %.0f px, band %.0f px (PRJ.P1)" % [
		board_px, board_left, board_right, FRAME_SIZE.x, FRAME_SIZE.y, lip_px,
		BEVEL_LIP_INK_BAND * scale_px,
	])
	if board_left < 0.0 or board_right > FRAME_SIZE.x or board_bottom > FRAME_SIZE.y:
		problems.append("board bevel (%.0f..%.0f, bottom %.0f) escapes the %.0f x %.0f frame" % [
			board_left, board_right, board_bottom, FRAME_SIZE.x, FRAME_SIZE.y,
		])
	var drawn := _drawn_band_rects()
	if drawn.size() != 2:
		problems.append("coordinate bands not drawn: %d of 2 found" % drawn.size())
	return problems


## PER.R7 geometric check for the autodrive: every label's ink box (the whole
## glyph, x and y) inside the wooden coordinate band it sits on, so none of its
## ink can land on the 1.28:1 table margin or inside the 8x8. Canvas pixels;
## the coordinates node scales them to board units unchanged.
##
## The band rectangles are read back from the drawn `BevelLipLeftInk` /
## `BevelLipBottomInk` polygons, not from `CoordLabels.spots()`: the check that
## compared label boxes against the same geometry that placed them passed while
## the rank numerals were painted inside the a-file (defect #592 rework).
func measure_coord_labels() -> Array:
	var problems: Array = []
	if font_resource == null:
		return ["no font for the coordinate labels"]
	var px := coord_font_px()
	print("[demo] coordinates %.1f px glyph ink %.1f px in a %.1f px band (PER.R7)" % [
		px, coord_text_height(px), BEVEL_LIP_INK_BAND * COORD_UNIT_PX,
	])
	var drawn := _drawn_band_rects()
	if drawn.size() != 2:
		problems.append("coordinate bands not drawn: %d of 2 found" % drawn.size())
	for spot in CoordLabels.spots():
		var text: String = spot["text"]
		var rect := CoordLabels.text_rect(font_resource, text, spot["at"] as Vector2, px)
		var band_name: String = spot["band"]
		if not drawn.has(band_name):
			problems.append("%s label has no drawn band %s" % [text, band_name])
			continue
		var band: Rect2 = drawn[band_name]
		print("[demo]   %s box x %.1f..%.1f y %.1f..%.1f px; band %s x %.1f..%.1f y %.1f..%.1f" % [
			text, rect.position.x, rect.end.x, rect.position.y, rect.end.y,
			band_name, band.position.x, band.end.x, band.position.y, band.end.y,
		])
		if not band.encloses(rect):
			problems.append("%s label %s leaves its coordinate band %s" % [text, rect, band])
	return problems


## The coordinate bands as drawn, in canvas pixels: the axis-aligned bounds of
## the bevel polygons that carry them. Bands must also sit entirely outside the
## 8x8 (PER.R7 "never inside squares").
func _drawn_band_rects() -> Dictionary:
	var out := {}
	var square_lo := Vector2.ZERO
	var square_hi := Vector2.ONE * (8.0 * COORD_UNIT_PX)
	for band_name in ["BevelLipLeftInk", "BevelLipBottomInk"]:
		var band := get_node_or_null(NodePath(band_name)) as Polygon2D
		if band == null or band.polygon.is_empty():
			continue
		var lo := band.polygon[0]
		var hi := band.polygon[0]
		for point in band.polygon:
			lo = Vector2(minf(lo.x, point.x), minf(lo.y, point.y))
			hi = Vector2(maxf(hi.x, point.x), maxf(hi.y, point.y))
		var rect := Rect2(lo * COORD_UNIT_PX, (hi - lo) * COORD_UNIT_PX)
		out[band_name] = rect
		if rect.intersects(Rect2(square_lo, square_hi - square_lo)):
			push_warning("%s overlaps the 8x8: %s" % [band_name, rect])
			out[band_name] = Rect2()  # force every label on it to fail
	return out


## Hides everything except the backdrop, bevel, squares, and coordinate labels so
## the rendered-ink probe sees only coordinate glyph pixels.
func set_coord_probe_visibility(on: bool) -> void:
	if on:
		_probe_hidden.clear()
		for child_name in ["Pieces", "Fragments", "Overlays", "PromoChoice"]:
			var node := get_node_or_null(NodePath(child_name)) as CanvasItem
			if node != null:
				_probe_hidden[child_name] = node.visible
				node.visible = false
	else:
		for child_name in _probe_hidden:
			var node := get_node_or_null(NodePath(child_name)) as CanvasItem
			if node != null:
				node.visible = bool(_probe_hidden[child_name])
		_probe_hidden.clear()


## Rendered-ink check for the graphical autodrive: the only allowed home for the
## coordinate ink is the two wooden bands, and each band must carry a legible
## amount of it (_min_band_ink). It fails on cream PAL.C10 found inside the 8x8
## (PER.R7 forbids the ink on any square; on a light PAL.C1 square it reads
## 1.28:1), on the table outside the board, or anywhere on the board that is not
## a coordinate band, and on a band whose ink is a smudge rather than eight UIS.T2
## glyphs. This measures what the renderer drew, unlike measure_coord_labels()
## which checks geometry; set_coord_probe_visibility() hides the piece sprites
## first, so every cream pixel here has the coordinates as its only source.
func coord_ink_problems(image: Image) -> Array:
	var problems: Array = []
	var drawn := _drawn_band_rects()
	if drawn.size() != 2:
		return ["coordinate bands not drawn: %d of 2" % drawn.size()]
	var to_px := Vector2(image.get_width(), image.get_height()) / Vector2(FRAME_SIZE)
	var xf := get_global_transform()
	var origin := xf.origin * to_px
	var scale_px := xf.get_scale() * to_px
	var square := _to_image_rect(_canvas_rect(Vector2.ZERO, Vector2.ONE * 8.0), origin, scale_px)
	var board := _to_image_rect(
		_canvas_rect(Vector2.ONE * -RIM_OUTER, Vector2.ONE * (8.0 + RIM_OUTER)), origin, scale_px)
	var bands := {}
	for band_name in drawn:
		bands[band_name] = _to_image_rect(drawn[band_name], origin, scale_px)
	var ink := {}
	for band_name in bands:
		ink[band_name] = 0
	var inside_square := 0
	var off_band := 0
	var unit_px := scale_px.x  # frame px per board unit, this screenshot's scale
	var min_ink := _min_band_ink(unit_px)
	# The band's own rendered wood color, read from the frame: sRGB blending and
	# the renderer's color management can shift the constant, and the ink test
	# must be judged against what the glyphs were actually painted on.
	var wood := _band_wood(image, bands)
	# One pass over the board and its lip: every ink pixel is counted once, in
	# the band it sits in or in the bucket of the forbidden field it lands in.
	for y in range(maxi(int(board.position.y), 0), mini(int(board.end.y) + 1, image.get_height())):
		for x in range(maxi(int(board.position.x), 0), mini(int(board.end.x) + 1, image.get_width())):
			if not _is_coord_ink(image.get_pixel(x, y), wood):
				continue
			var pixel := Vector2(x, y)
			var band_hit := ""
			for band_name in bands:
				if (bands[band_name] as Rect2).grow(0.5).has_point(pixel):
					band_hit = band_name
					break
			if band_hit != "":
				ink[band_hit] += 1
			elif square.has_point(pixel):
				inside_square += 1
			else:
				off_band += 1
	print("[demo] rendered coordinate ink: left band %d px, bottom band %d px (floor %d), inside 8x8 %d px, off-band %d px" % [
		int(ink.get("BevelLipLeftInk", 0)), int(ink.get("BevelLipBottomInk", 0)),
		min_ink, inside_square, off_band,
	])
	for band_name in ink:
		if int(ink[band_name]) < min_ink:
			problems.append("%s carries %d px of coordinate ink, under the %d px floor of eight UIS.T2 glyphs" % [
				band_name, int(ink[band_name]), min_ink,
			])
	if inside_square > 0:
		problems.append("%d rendered coordinate-ink pixels inside the 8x8" % inside_square)
	if off_band > 0:
		problems.append("%d rendered coordinate-ink pixels off their coordinate bands" % off_band)
	return problems


## The ink floor for one band: eight glyphs (a-h, or 1-8) of the coordinate face,
## each inking at least MIN_GLYPH_INK_PX. The 16 px glyphs ink ~40 px each of
## their box on this renderer, and the 6.5 px face that failed verification drew
## 3 px in the whole band, so this floor passes legible type and fails type that
## has shrunk back under UIS.T2. `unit_px` is the screenshot's own px per board
## unit, so the floor follows any resize.
func _min_band_ink(unit_px: float) -> int:
	var scale := unit_px / COORD_UNIT_PX
	return maxi(1, int(8.0 * MIN_GLYPH_INK_PX * scale * scale))


## One rectangle in board units as canvas pixels (the unit of the coordinate canvas).
static func _canvas_rect(lo: Vector2, hi: Vector2) -> Rect2:
	return Rect2(lo * COORD_UNIT_PX, (hi - lo) * COORD_UNIT_PX)


## A coordinate-canvas rectangle in frame pixels: canvas px -> board units ->
## the board's frame placement, rescaled to the screenshot's own size.
func _to_image_rect(canvas_rect: Rect2, origin: Vector2, scale_px: Vector2) -> Rect2:
	var lo := origin + canvas_rect.position / COORD_UNIT_PX * scale_px
	var hi := origin + canvas_rect.end / COORD_UNIT_PX * scale_px
	return Rect2(lo, hi - lo)


## The rendered band wood: the most common color inside the two coordinate
## band rectangles. `bands` are frame-pixel rects.
func _band_wood(image: Image, bands: Dictionary) -> Color:
	var counts := {}
	for band_name in bands:
		var rect: Rect2 = bands[band_name]
		for y in range(maxi(int(rect.position.y), 0), mini(int(rect.end.y), image.get_height())):
			for x in range(maxi(int(rect.position.x), 0), mini(int(rect.end.x), image.get_width())):
				var key := image.get_pixel(x, y).to_rgba32()
				counts[key] = int(counts.get(key, 0)) + 1
	var best := BEVEL_LIP_INK_COLOR
	var best_count := 0
	for key in counts:
		if int(counts[key]) > best_count:
			best_count = int(counts[key])
			best = Color(int(key))
	return best


## True when a rendered pixel is coordinate ink: the band's PAL.C9 ink or its
## antialiased edge over the PAL.C1 band wood. Each channel must be at least 60%
## of the way from the band wood to the ink, and the demo's flat painted fields
## are excluded first (_is_flat_fill) — the ink is darker than the light band, so
## the dark PAL.C2 square and the table wood would otherwise look like ink on the
## light field. Compared in RGB only: the frame may be read back in RGBA8, and
## reading alpha there would reject every pixel.
func _is_coord_ink(color: Color, wood: Color) -> bool:
	if _is_flat_fill(color):
		return false
	for axis in ["r", "g", "b"]:
		var span: float = wood[axis] - COORD_COLOR[axis]
		if absf(span) < 0.01:
			continue
		if (wood[axis] - color[axis]) / span < 0.6:
			return false
	return true


## True for the demo's flat painted fields (squares, table, bevel wood and line,
## overlay marks). Every one is drawn as a flat color, so a pixel this close to a
## palette fill is that field and not glyph ink. The ink itself (PAL.C9) is
## deliberately absent, and so is its band: both are what the probe is looking
## for. (Fragment and promo fills use PAL.C9 internally, but those nodes are
## hidden for the probe.)
func _is_flat_fill(color: Color) -> bool:
	for fill in [
		COLOR_LIGHT, COLOR_DARK, COLOR_TABLE,
		BEVEL_LIP_COLOR, BEVEL_SHADOW_COLOR, BEVEL_FRAME_COLOR, BEVEL_LINE,
		BEVEL_LIP_INK_COLOR, COLOR_SELECT, COLOR_LEGAL, COLOR_ROSE,
	]:
		var flat: Color = fill
		if absf(color.r - flat.r) < 0.02 \
			and absf(color.g - flat.g) < 0.02 \
			and absf(color.b - flat.b) < 0.02:
			return true
	return false


## PER.R7: files a-h and ranks 1-8 in cream PAL.C10 on the coordinate bands of
## the wooden bevel (7.4:1 against the band). Painted in canvas pixels; the
## node's scale maps them to board units. Canvas x runs files (0 at file a) and
## canvas y runs ranks (0 at rank 8), matching the board's own axes.
class CoordLabels extends Control:
	var font: Font
	var font_px := 0.0    # the PER.R7 clamped size, set when the labels are built

	## The file and rank label spots: centred along their column/row and centred
	## in the band they sit on. Canvas x runs files (0 at file a) and canvas y
	## runs ranks (0 at rank 8), matching the board's own axes; the coordinate
	## bands lie on the lip outside the 8x8, so their rectangles run negative in
	## x (ranks) or past 8 in y (files).
	static func spots() -> Array:
		var left := DemoBoardView._canvas_rect(
			Vector2(-RIM_OUTER, -RIM_OUTER),
			Vector2(-RIM_OUTER + BEVEL_LIP_INK_BAND, 8.0 + RIM_OUTER))
		var bottom := DemoBoardView._canvas_rect(
			Vector2(-RIM_OUTER, 8.0 + RIM_OUTER - BEVEL_LIP_INK_BAND),
			Vector2(8.0 + RIM_OUTER, 8.0 + RIM_OUTER))
		var out: Array = []
		for file in range(8):
			out.append({
				"text": String.chr(97 + file),
				"at": Vector2((float(file) + 0.5) * COORD_UNIT_PX, bottom.get_center().y),
				"band": "BevelLipBottomInk",
			})
		for rank_index in range(1, 9):
			out.append({
				"text": str(rank_index),
				"at": Vector2(left.get_center().x,
					(float(8 - rank_index) + 0.5) * COORD_UNIT_PX),
				"band": "BevelLipLeftInk",
			})
		return out

	## The ink box of one label of font size `px` centred on `at` (canvas px). draw_string takes
	## the glyph's baseline, not its top, so the top is one ascent above it and
	## the ink height is ascent + descent (defect #592: the old stamp took the
	## baseline for the top and drew every label ~0.43 unit too high).
	## The rectangle is returned in canvas pixels, the unit of `at`.
	static func text_rect(f: Font, text: String, at: Vector2, px: float) -> Rect2:
		var width := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var ascent := float(f.get_ascent(px))
		var descent := float(f.get_descent(px))
		return Rect2(at - Vector2(width / 2.0, (ascent + descent) / 2.0),
			Vector2(width, ascent + descent))

	func _draw() -> void:
		for spot in spots():
			_stamp(str(spot["text"]), spot["at"] as Vector2)

	func _stamp(text: String, at: Vector2) -> void:
		var box := text_rect(font, text, at, font_px)  # `at` is already canvas px
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
	sprite.name = "Sprite2D"  # PoC move code finds it by name
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
