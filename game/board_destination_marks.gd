class_name BoardDestinationMarks
extends Node2D
## The board's overlay root: the destination marks a board draws for the square
## under the pointer's owner — the one selection frame (PER.R3) and the legal
## destinations (PER.R4) — and the parent the other overlay marks join.
##
## `Selection` is the only closed ring on the board; `LegalMarks` holds one form a
## destination — a solid disk for an empty square, corner brackets for a capture —
## so the shapes alone say which is which with the hue removed (rules-k9.md).

## PAL.C11 — the legal destination's ink.
const COLOR_LEGAL := Color("6EA746")
## PAL.C7 — the selection frame.
const COLOR_SELECT := Color("B8940C")

## Selection frame stroke in world units (≪ 10% of piece body — PER.R1 / R3).
const SELECT_STROKE := 0.06
## PER.R4 empty destination: a solid PAL.C11 disk at the square centre, radius
## 0.36, so its area πr² = 0.407 square clears PER.R4's 1/4 (rules-k9.md *Mark
## table*).
const LEGAL_EMPTY_R := 0.36
## The empty disk is drawn as a 32-gon: 0.6% under its circle, and read as a disk.
const LEGAL_DISK_SEGMENTS := 32
## PER.R4 capture destination: PAL.C11 corner brackets — two strokes per corner,
## inside the square, never a ring (rules-k9.md *Mark table*). rules-k9.md states
## the 1/4 area bound but no size for this form (conflict 1, #792), so the size is
## this body's choice: at stroke 0.06 unit — the ring's own width, so a bracket
## reads as a bracket and not a hairline — an arm of 0.52 reaches 8 × 0.06 × 0.52 =
## 0.25 exactly; arm 0.56 clears it with margin (8 × 0.06 × 0.56 = 0.2688). The arm
## is longer than the PER.R9 tick's 0.10 and changes neither the two-strokes-per-
## corner form nor the corner placement, and it stays inside the square's 1.0.
const LEGAL_BRACKET_W := 0.06
const LEGAL_BRACKET_ARM := 0.56

var _selection_frame: Line2D
var _legal_root: Node2D


func _init() -> void:
	# This layer is the overlay root itself, so every drawn node keeps the path it
	# has always had (`World/Seat/Content/Overlays/...`).
	name = "Overlays"
	_selection_frame = Line2D.new()
	_selection_frame.name = "Selection"
	_selection_frame.width = SELECT_STROKE
	_selection_frame.default_color = COLOR_SELECT
	_selection_frame.closed = true
	_selection_frame.visible = false
	add_child(_selection_frame)
	_legal_root = Node2D.new()
	_legal_root.name = "LegalMarks"
	add_child(_legal_root)


## The one closed ring: the selected square's frame.
func selection_frame() -> Line2D:
	return _selection_frame


## The legal destinations' parent node.
func legal_root() -> Node2D:
	return _legal_root


## PER.R3 — ring the selected square, or show no ring when nothing is selected.
func set_selection(square: String) -> void:
	if square.is_empty() or not BoardGeometry.is_square(square):
		_selection_frame.visible = false
		return
	var c := BoardGeometry.square_center(square)
	var half := 0.5 - SELECT_STROKE * 0.5
	_selection_frame.clear_points()
	_selection_frame.add_point(c + Vector2(-half, -half))
	_selection_frame.add_point(c + Vector2(half, -half))
	_selection_frame.add_point(c + Vector2(half, half))
	_selection_frame.add_point(c + Vector2(-half, half))
	_selection_frame.default_color = COLOR_SELECT
	_selection_frame.width = SELECT_STROKE
	_selection_frame.visible = true


## PER.R4 — one form a destination: a disk for an empty square, brackets for a
## capture. `captures` names the destinations that hold a piece.
func show_destinations(squares: PackedStringArray, captures: PackedStringArray) -> void:
	for child in _legal_root.get_children():
		_legal_root.remove_child(child)
		child.queue_free()
	for square in squares:
		var sq := str(square)
		if not BoardGeometry.is_square(sq):
			continue
		if captures.has(sq):
			_legal_root.add_child(capture_brackets(sq))
		else:
			_legal_root.add_child(empty_disk(sq))


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
