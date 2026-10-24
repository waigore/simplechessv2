class_name AdviceMarks
extends Node2D
## PER.R5 — E4 `show_advice` marks on the board. From/to squares and an arrow in
## PAL.C7, drawn over the piece body, sized so a piece silhouette stays readable
## (PER.R1) and nothing is conveyed by colour alone (the arrow shows the move).
##
## The square mark is the **edge-bracket** form PAL.K9 gives Advice: one stroke per
## edge midpoint, corners open — never the capture mark's corner pairs. Nothing on
## the board sits behind it, so a keyline would change the form; the stroke alone
## carries it, at the palette rules' bracket stroke.

## PAL.C7 advice teal.
const COLOR_ADVICE := Color("53A2BE")
## The palette rules' bracket stroke: 0.10 units = 3.6 px at 360 px over 10 units
## (PRJ.P1), above the UIS.I1 1.5 screen px floor.
const ADVICE_STROKE := 0.10
## Bracket arm length; the four corners stay open.
const ADVICE_ARM := 0.20
const ARROW_SHAFT := 0.04
const ARROW_HEAD := 0.14
## The arrow runs between the two bodies: it leaves the from-piece's edge and
## stops short of the to-piece's, so it never crosses a silhouette.
const ARROW_TAIL := 0.32
const ARROW_TIP_GAP := 0.40
## FRM.P1 body box: the King's 0.85 body inside SPC.E1.
const BODY_BOX := 0.85
## The King's opaque silhouette area in square units, read from the approved
## p-white.png alpha mask at its on-board size (92 426 px of a 512² canvas drawn
## across a 0.85-unit box). It is the largest PER.R5 body, so it bounds the arrow.
const KING_BODY_AREA := 0.1274
## Marks fade in with the calm feedback the experience intent asks for (UIS.M2).
const SHOW_S := UiChrome.M2_S
## The four edge midpoints, in square units from the square's centre.
const EDGES := [Vector2(0.0, -1.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(-1.0, 0.0)]

## The from/to squares currently marked; empty when advice shows nothing.
var last_from := ""
var last_to := ""


func _ready() -> void:
	name = "AdviceMarks"
	z_index = 5


## The innermost point of an edge bracket, along its edge, in square units from
## the square's centre. Must stay outside every body half-width (FRM.P1 / PER.R5).
static func bracket_inner_edge() -> float:
	return 0.5 - ADVICE_STROKE * 0.5 - ADVICE_ARM


## PER.R5 — the fraction of the tall King body the arrow can cover. The arrow
## leaves the from-piece at ARROW_TAIL from its centre; anything between that
## point and the body's half-height is ink over the silhouette.
static func body_coverage() -> float:
	var king_half_height := BODY_BOX * BODY_BOX * 0.5
	var reach := maxf(0.0, king_half_height - ARROW_TAIL)
	return reach * ARROW_SHAFT / KING_BODY_AREA


## E4 `show_advice` with a best move: mark from and to and draw the arrow.
func show_best_move(from_square: String, to_square: String) -> void:
	if not BoardGeometry.is_square(from_square) or not BoardGeometry.is_square(to_square):
		clear()
		return
	if from_square == last_from and to_square == last_to and get_child_count() > 0:
		return
	_clear_nodes()
	last_from = from_square
	last_to = to_square
	_add_square_marks(from_square)
	_add_square_marks(to_square)
	_add_arrow(from_square, to_square)
	_fade_in()


## E4 `show_advice` with no value: clear the marks.
func clear() -> void:
	_clear_nodes()
	last_from = ""
	last_to = ""


func _clear_nodes() -> void:
	for child in get_children():
		child.queue_free()


## Edge brackets, one stroke per edge midpoint, corners open (palette rules).
func _add_square_marks(square: String) -> void:
	var c := BoardGeometry.square_center(square)
	var outer := 0.5 - ADVICE_STROKE * 0.5
	for edge in EDGES:
		var unit: Vector2 = edge
		var out: Vector2 = c + unit * outer
		var along := Vector2(-unit.y, unit.x)
		var points := PackedVector2Array([out - along * ADVICE_ARM, out, out + along * ADVICE_ARM])
		add_child(_line(points, ADVICE_STROKE))


func _add_arrow(from_square: String, to_square: String) -> void:
	var a := BoardGeometry.square_center(from_square)
	var b := BoardGeometry.square_center(to_square)
	var dir := (b - a).normalized()
	if dir == Vector2.ZERO:
		return
	var tail := a + dir * ARROW_TAIL
	var tip := b - dir * ARROW_TIP_GAP
	var side := Vector2(-dir.y, dir.x)
	add_child(_line(PackedVector2Array([tail, tip]), ARROW_SHAFT))
	add_child(
		_line(PackedVector2Array([tip - dir * ARROW_HEAD + side * ARROW_HEAD, tip]), ARROW_SHAFT)
	)
	add_child(
		_line(PackedVector2Array([tip - dir * ARROW_HEAD - side * ARROW_HEAD, tip]), ARROW_SHAFT)
	)


func _line(points: PackedVector2Array, width: float) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = COLOR_ADVICE
	line.antialiased = true
	for point in points:
		line.add_point(point)
	return line


func _fade_in() -> void:
	modulate.a = 0.0
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(self, "modulate:a", 1.0, SHOW_S)
