class_name BoardMarkLayer
extends Node2D
## The board's square marks: the refused-place hatching (PER.R8) and the last
## move's band plus ticks with their one cream foreground (PER.R9).
##
## Two nodes, one per mark, so a test can ask each what it drew:
## `Hatching` sits above the selection and legal marks and fades with the flash;
## `LastMoveBand` holds the from-square's band over the square's fill, and the
## cream foreground carries the to-square's ticks.

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
## PAL.C8 check rose — the refusal cue the hatch draws in.
const COLOR_DANGER := Color("C28A86")

## Screen px per world unit, for the foreground keyline (UIS.C6 / UIS.I1).
var pixels_per_unit := 36.0

var _hatching: Node2D
var _band: Node2D
var _foreground: MarkForeground
var _last_from := ""
var _last_to := ""
var _checked_square := ""


func _init() -> void:
	name = "Marks"
	# The refused-place hatch sits over the square's own fill and over selection and
	# legal marks; both return as it fades (PER.R8).
	_hatching = Node2D.new()
	_hatching.name = "RejectHatch"
	_hatching.visible = false
	add_child(_hatching)
	# PER.R9 band draws on the square, under the cream foreground.
	_band = Node2D.new()
	_band.name = "LastMoveBand"
	add_child(_band)
	# The one PAL.C10 foreground per marked square (UIS.C6): above the marks the
	# square carries, below the accents that draw on it.
	_foreground = MarkForeground.new()
	add_child(_foreground)


## The PER.R8 refused-place hatching node.
func reject_hatch() -> Node2D:
	return _hatching


## The PER.R9 from-square band node.
func last_move_band() -> Node2D:
	return _band


## The one PAL.C10 foreground layer (UIS.C6), for the layer and form checks.
func mark_foreground() -> MarkForeground:
	return _foreground


## The last move as a from/to pair, both empty when there is none.
func last_move() -> PackedStringArray:
	return PackedStringArray([_last_from, _last_to])


## PER.R9 — the pair replaced only by the move that settles, never by a refusal.
func set_last_move(from_square: String, to_square: String) -> void:
	_last_from = from_square if BoardGeometry.is_square(from_square) else ""
	_last_to = to_square if BoardGeometry.is_square(to_square) else ""
	refresh()


## PER.R9 — leaving the board drops the pair.
func clear_last_move() -> void:
	_last_from = ""
	_last_to = ""
	refresh()


## The square carrying the PER.R6 cream L-frame, empty when nobody is in check.
func set_checked_square(square: String) -> void:
	_checked_square = square if BoardGeometry.is_square(square) else ""


## Rebuild both marks from the current state. `advice_squares` are the advice
## accents' from/to squares, which share the same one layer a square (rules.md
## *One layer*).
func refresh(advice_squares: Array = []) -> void:
	_foreground.pixels_per_unit = pixels_per_unit
	_refresh_band()
	_refresh_foreground(advice_squares)


## Build the hatching for a refused square and add its fade to `tween`, the
## board's refusal-flash tween, so the hatch rides that one 0.3 s flash (SPC.L4)
## with no cream foreground and no keyline.
func start_hatch(square: String, tween: Tween) -> void:
	_build_hatch(BoardGeometry.square_center(square))
	_hatching.modulate.a = 1.0
	tween.tween_property(_hatching, "modulate:a", 0.0, SharedGameSession.REJECT_FLASH_S)


func clear_hatch() -> void:
	_hatching.visible = false
	_hatching.modulate.a = 1.0


## PER.R8 — PAL.C8 hatching across the refused square's own fill, inset inside the
## selection ring and clear of the rim the flash keeps.
func _build_hatch(center: Vector2) -> void:
	for child in _hatching.get_children():
		_hatching.remove_child(child)
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
			_hatching.add_child(line)
		offset += step
	_hatching.visible = true


## One 45° hatch stroke, given its constant x − y and the inset square's reach.
## Returned as the two ends clipped to the square, or empty when it misses it.
static func hatch_span(offset: float, reach: float) -> Array:
	var start := maxf(-reach, offset - reach)
	var end := minf(reach, offset + reach)
	if start >= end:
		return []
	return [Vector2(start, start - offset), Vector2(end, end - offset)]


## The from-square's band, rebuilt from the current seat because it is placed by
## the move's direction, not by the square alone.
func _refresh_band() -> void:
	for child in _band.get_children():
		_band.remove_child(child)
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
		_band.add_child(line)


## One foreground layer per marked square, built from whichever marks want cream
## this frame (UIS.C6, rules.md *One layer*).
func _refresh_foreground(advice_squares: Array) -> void:
	_foreground.clear()
	if not _checked_square.is_empty():
		# PER.R6 — the cream L-frame on the two corners the C8 cue already uses.
		_foreground.set_mark(
			_checked_square,
			"check",
			_foreground_marks(
				CheckMarks.l_frame_polylines(_checked_square),
				Color.TRANSPARENT,
				CheckMarks.CHECK_STROKE
			)
		)
	for square in advice_squares:
		_foreground.set_mark(
			str(square),
			"advice",
			_foreground_marks(
				AdviceMarks.edge_brackets(str(square)),
				AdviceMarks.COLOR_ADVICE,
				AdviceMarks.ADVICE_STROKE
			)
		)
	if not _last_to.is_empty() and not _last_from.is_empty():
		_foreground.set_mark(
			_last_to,
			"ticks",
			_foreground_marks(tick_polylines(_last_to, _last_from), Color.TRANSPARENT, TICK_W)
		)


static func _foreground_marks(
	polylines: Array[PackedVector2Array], accent: Color, width: float
) -> Array:
	var marks: Array = []
	for points in polylines:
		marks.append({"points": points, "accent": accent, "width": width})
	return marks


## The PER.R9 from-square band in world coordinates: a 0.60-long open segment on
## the square's outer edge, on the side facing away from the to-square, beyond
## every body half-width (PER.R1 / SPC.E1) so it covers no body.
static func from_band_points(from_square: String, to_square: String) -> PackedVector2Array:
	var from_center := BoardGeometry.square_center(from_square)
	var to_center := BoardGeometry.square_center(to_square)
	var away := from_center - to_center
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
		Vector2(signf(facing.x), 0.0)
		if absf(facing.x) >= absf(facing.y)
		else Vector2(0.0, signf(facing.y))
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
