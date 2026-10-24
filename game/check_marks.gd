class_name CheckMarks
extends Node2D
## PER.R6 / CMP-presentation.R7 — the checked King's square carries a PAL.C8
## L-frame, the form [PAL.K9] reserves for check, so the cue reads without audio
## and without hue alone. The session says *that* the side to move is in check;
## this node only marks the King it renders (CTR-presentation G2).
##
## [PAL.K9]: ../../specs/aesthetics/palette.md

## PAL.C8 check rose — the same accent as the refused-place flash (PER.R8).
const COLOR_CHECK := Color("C28A86")
## One stroke width for both arms; 0.06 unit is 2.16 screen px at 360 × 640
## (PAL.K9 stroke floor, UIS.I1 1.5 px).
const CHECK_STROKE := 0.06
## Arm lengths, in square units from the corner. The arms are deliberately
## unequal: a check L is asymmetric, so it never reads as a capture bracket.
const CHECK_LONG_ARM := 0.20
const CHECK_SHORT_ARM := 0.10

## The square currently marked; empty when no King is in check.
var marked_square := ""


func _ready() -> void:
	name = "CheckMarks"


## The two corners the L-frames sit on, in square units from the centre:
## opposite corners, and each L turns along the two edges that meet there, so no
## stroke follows the square's diagonal (PAL.K9 "off diagonals").
static func corner_signs() -> Array[Vector2]:
	return [Vector2(-1.0, -1.0), Vector2(1.0, 1.0)]


## Distance from the square centre to the corner the L turns at, so the stroke
## stays inside the square and outside every piece body (PER.R1 / FRM.P1 0.425).
static func corner_offset() -> float:
	return 0.5 - CHECK_STROKE * 0.5


## The L's three points in square units from the centre, for one corner.
static func l_frame_points(sign: Vector2) -> PackedVector2Array:
	var outer := corner_offset()
	var corner := Vector2(sign.x * outer, sign.y * outer)
	var long_end := Vector2(sign.x * outer, sign.y * (outer - CHECK_LONG_ARM))
	var short_end := Vector2(sign.x * (outer - CHECK_SHORT_ARM), sign.y * outer)
	return PackedVector2Array([long_end, corner, short_end])


## Mark `square`; the mark is rebuilt only when the King moves.
func show_square(square: String) -> void:
	if not BoardGeometry.is_square(square):
		clear()
		return
	if square == marked_square and get_child_count() > 0:
		return
	_clear_nodes()
	marked_square = square
	var center := BoardGeometry.square_center(square)
	for sign in corner_signs():
		add_child(_l_frame(center, sign))


## No side to move in check (or no King on the board): no mark.
func clear() -> void:
	_clear_nodes()
	marked_square = ""


func _clear_nodes() -> void:
	for child in get_children():
		child.queue_free()


func _l_frame(center: Vector2, sign: Vector2) -> Line2D:
	var line := Line2D.new()
	line.name = "LFrame"
	line.width = CHECK_STROKE
	line.default_color = COLOR_CHECK
	line.antialiased = true
	for point in l_frame_points(sign):
		line.add_point(center + point)
	return line
