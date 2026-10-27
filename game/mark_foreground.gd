class_name MarkForeground
extends Node2D
## PAL.K9 *Layer split* / *One layer*, UIS.C6 — the one cream foreground a marked
## square carries. Check's L-frame, Advice's edge brackets, and the last-move
## corner ticks draw on it; the selection ring, the last-move band, and refusal's
## hatching draw on the square itself and never touch this layer (#792).
##
## The plate is PAL.C10 at full opacity under the mark's own stroke band, keylined
## in PAL.C9 at 1.5 screen px (`UIS.I1`). It covers the mark's footprint only — the
## stroke band plus a small cream margin — never the whole square, so a board of
## eight legal destinations does not turn cream (`UIS.C6`).
##
## A square owns exactly one node here whatever number of marks draw on it, so a
## square never carries two cream layers (`rules.md` *One layer*): a ticked square
## that also shows Advice shares the one foreground. Strokes and plate are built
## from the same polylines, so the plate is always the mark's own shape.

## PAL.C10 cream foreground (UIS.C6).
const COLOR_CREAM := Color("F7F1E8")
## PAL.C9 ink keyline (UIS.C6 / UIS.I1).
const COLOR_INK := Color("2C2A28")
## UIS.C6 / UIS.I1 stroke floor: the keyline is 1.5 screen px, converted to world
## units at the frame being drawn (`keyline_width()`).
const KEYLINE_PX := 1.5
## Cream kept beyond the stroke it carries, in square units. Without it the mark
## stroke would fill the plate and only the keyline would read as the form.
const CREAM_MARGIN := 0.03

## Pixels per world unit at the frame being drawn; set by the board on every
## camera layout. 36 at the 360 × 640 narrowest viewport (PRJ.P1).
var pixels_per_unit := 36.0

## square → Array of mark dictionaries {source, points, accent, width}. `accent`
## with alpha 0 means the plate alone carries the mark (check's cream L-frame).
var _marks: Dictionary = {}
## square → the one drawn node for that square.
var _nodes: Dictionary = {}


func _ready() -> void:
	name = "MarkForeground"


## World width that draws as `KEYLINE_PX` screen px at the current frame.
func keyline_width() -> float:
	return KEYLINE_PX / maxf(pixels_per_unit, 0.001)


## Register (or replace) one source's marks on `square`. Each mark is a dictionary:
## `{"points": PackedVector2Array (world), "accent": Color, "width": float}`.
## `accent` alpha 0 draws the plate and keyline only.
func set_mark(square: String, source: String, marks: Array) -> void:
	if not BoardGeometry.is_square(square) or marks.is_empty():
		clear_mark(square, source)
		return
	var kept: Array = []
	for mark in _marks.get(square, []) as Array:
		if str((mark as Dictionary).get("source", "")) != source:
			kept.append(mark)
	for mark in marks:
		var entry: Dictionary = (mark as Dictionary).duplicate()
		entry["source"] = source
		kept.append(entry)
	_marks[square] = kept
	_rebuild(square)


## Drop one source's marks from every square; a square left with none is freed.
func clear_source(source: String) -> void:
	for square in _marks.keys():
		clear_mark(str(square), source)


## Drop one source's marks from one square.
func clear_mark(square: String, source: String) -> void:
	var kept: Array = []
	for mark in _marks.get(square, []) as Array:
		if str((mark as Dictionary).get("source", "")) != source:
			kept.append(mark)
	if kept.is_empty():
		_marks.erase(square)
	else:
		_marks[square] = kept
	_rebuild(square)


func clear() -> void:
	_marks.clear()
	for square in _nodes.keys():
		_free_node(str(square))
	_nodes.clear()


## The squares that carry a foreground, for the one-layer checks.
func marked_squares() -> PackedStringArray:
	var out := PackedStringArray()
	for square in _marks.keys():
		if (_marks[square] as Array).is_empty():
			continue
		out.append(str(square))
	out.sort()
	return out


func node_for(square: String) -> Node2D:
	return _nodes.get(square) as Node2D


## Strokes currently drawn on `square`, for the form checks.
func marks_on(square: String) -> Array:
	return _marks.get(square, [])


func _rebuild(square: String) -> void:
	_free_node(square)
	var marks: Array = _marks.get(square, [])
	if marks.is_empty():
		return
	var node := Node2D.new()
	node.name = "Mark_%s" % square
	node.set_meta("mark_square", square)
	add_child(node)
	_add_plate(node, marks)
	_add_strokes(node, marks)
	_nodes[square] = node


func _free_node(square: String) -> void:
	var node := _nodes.get(square) as Node2D
	_nodes.erase(square)
	if node == null:
		return
	remove_child(node)
	node.queue_free()


## PAL.C10 plate under every stroke's own band, then its PAL.C9 keyline on the
## plate's edge: the fill is the area between keylines, the keyline is the visible
## edge (`UIS.I1`). Each mark keeps its own plate and keyline, so a square's cream
## reads as the forms it carries — the four tick Ls stay four Ls — while still
## being one node and one cream surface (`rules.md` *One layer*, `UIS.C6`).
func _add_plate(node: Node2D, marks: Array) -> void:
	for mark_var in marks:
		var mark: Dictionary = mark_var
		var points: PackedVector2Array = mark.get("points", PackedVector2Array())
		if points.size() < 2:
			continue
		var polygon := band_polygon(
			points, float(mark.get("width", 0.0)) * 0.5 + CREAM_MARGIN
		)
		if polygon.is_empty():
			continue
		var plate := Polygon2D.new()
		plate.name = "Plate"
		plate.color = COLOR_CREAM
		plate.polygon = polygon
		node.add_child(plate)
		var line := Line2D.new()
		line.name = "Keyline"
		line.width = keyline_width()
		line.default_color = COLOR_INK
		line.antialiased = true
		line.closed = true
		for point in polygon:
			line.add_point(point)
		node.add_child(line)


func _add_strokes(node: Node2D, marks: Array) -> void:
	for mark_var in marks:
		var mark: Dictionary = mark_var
		var accent: Color = mark.get("accent", COLOR_CREAM)
		if accent.a <= 0.0 or accent == COLOR_CREAM:
			continue
		var points: PackedVector2Array = mark.get("points", PackedVector2Array())
		if points.size() < 2:
			continue
		var stroke := Line2D.new()
		stroke.name = "Stroke"
		stroke.width = float(mark.get("width", 0.0))
		stroke.default_color = accent
		stroke.antialiased = true
		for point in points:
			stroke.add_point(point)
		node.add_child(stroke)


## The outline of a stroked polyline: `points` widened to `half` on both sides,
## mitred at the joins, so an L keeps a square elbow instead of a notch.
static func band_polygon(points: PackedVector2Array, half: float) -> PackedVector2Array:
	var count := points.size()
	if count < 2:
		return PackedVector2Array()
	var left: Array[Vector2] = []
	var right: Array[Vector2] = []
	for i in range(count):
		var dir_in := (
			(points[i] - points[i - 1]).normalized() if i > 0 else (points[1] - points[0]).normalized()
		)
		var dir_out := (
			(points[i + 1] - points[i]).normalized()
			if i < count - 1
			else (points[count - 1] - points[count - 2]).normalized()
		)
		var normal_in := Vector2(-dir_in.y, dir_in.x)
		var normal_out := Vector2(-dir_out.y, dir_out.x)
		var miter := normal_in + normal_out
		if miter.length() < 0.0001:
			miter = normal_in
		miter = miter.normalized()
		# Miter length: the join is square, never a spike, so a 90° elbow widens by √2.
		var reach := half / maxf(miter.dot(normal_in), 0.35)
		left.append(points[i] + miter * reach)
		right.append(points[i] - miter * reach)
	var polygon := PackedVector2Array()
	for point in left:
		polygon.append(point)
	for i in range(count - 1, -1, -1):
		polygon.append(right[i])
	return polygon
