class_name CheckMark
extends Node2D
## PER.R6 check presentation on the board, under CMP-presentation R7: the checked
## King carries a PAL.C8 rose treatment, non-audio, with the side to move visible.
## The rose is an L-frame in the square's corners (PAL.K9 form table), off the
## diagonals, so the mark never crosses a piece silhouette (PER.R1).

## PAL.C8 check rose.
const COLOR_CHECK := Color("C28A86")
## PAL.C10 mark foreground and the PAL.C9 keyline around it. K9's layer split:
## C8 on C10 is 2.57:1, so the keyline (C9 on C10 12.73:1) separates the mark
## from both square colours while the rose keeps its mark-surface strength.
const COLOR_SURFACE := Color("F7F1E8")
const COLOR_KEYLINE := Color("2C2A28")
## Palette pairs this module is held to, checked by its test.
const INK_ON_ROSE := 4.95
const KEYLINE_ON_SURFACE := 12.73
## The rose inside the keyline stays the mark's colour at mark-surface strength,
## so the keyline carries the separation and the rose carries the meaning.
const ROSE_OPACITY := 0.34
## Stroke and arm in square units, one L-frame per corner (K9 "Check" row).
const STROKE := 0.08
const ARM := 0.26
const KEYLINE_PAD := 0.04

## The square currently carrying the mark; empty when not showing.
var square := ""


func _ready() -> void:
	name = "CheckMark"
	z_index = 1
	visible = false


## PER.R6 — mark the given king square, or clear the mark for any other value,
## so a resolved check never lingers.
func set_square(square_id: String) -> void:
	if not BoardGeometry.is_square(square_id):
		clear()
		return
	# A clock tick re-renders chrome; the mark must not be rebuilt under motion.
	if visible and square == square_id and get_child_count() > 0:
		return
	square = square_id
	_build(square_id)
	visible = true


## One L-frame's geometry: a corner vertex in a square corner with one arm along
## a file and one along a rank (K9 "off diagonals"). "" when it holds.
static func shape_problem(stroke: Line2D, center: Vector2) -> String:
	if stroke == null or stroke.points.size() != 3:
		return "every L-frame must be one 3-point stroke"
	# The corner vertex is the middle point; it must sit in a square corner.
	if stroke.points[1].distance_to(center) <= 0.35:
		return "L-frame corner sits on the square centre, not a corner"
	var arm_a := stroke.points[0] - stroke.points[1]
	var arm_b := stroke.points[2] - stroke.points[1]
	if absf(arm_a.x) > 0.001 and absf(arm_a.y) > 0.001:
		return "arm must run along a file or rank, not a diagonal"
	if absf(arm_b.x) > 0.001 and absf(arm_b.y) > 0.001:
		return "arm must run along a file or rank, not a diagonal"
	return ""


## The mark under a board's overlay root, if the board has one built.
static func under(board: Node) -> CheckMark:
	var root := board.get_node_or_null("World/Seat/Content/Overlays")
	return root.get_node_or_null("CheckMark") as CheckMark if root != null else null


func clear() -> void:
	square = ""
	visible = false
	for child in get_children():
		child.queue_free()


## Four L-frames, one per corner, each with an arm along the file and one along
## the rank: the K9 form that no other overlay uses.
func _build(square_id: String) -> void:
	for child in get_children():
		child.queue_free()
	var c := BoardGeometry.square_center(square_id)
	var base := 0.5 - STROKE * 0.5
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			var corner := c + Vector2(sx * base, sy * base)
			var points := PackedVector2Array(
				[
					corner + Vector2(0.0, -sy * ARM),
					corner,
					corner + Vector2(-sx * ARM, 0.0),
				]
			)
			# Keylined C10 foreground first, then the rose inside it (K9 layer split).
			add_child(_line(points, COLOR_SURFACE, STROKE))
			add_child(_line(points, Color(COLOR_CHECK, ROSE_OPACITY), STROKE - KEYLINE_PAD * 2.0))


func _line(points: PackedVector2Array, color: Color, width: float) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.points = points
	return line
