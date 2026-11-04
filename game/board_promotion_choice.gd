class_name BoardPromotionChoice
extends Node2D
## Ex.promote — the Q/R/B/N chooser the board opens on a promoting destination:
## four upright sprites in a 2×2 on the square (E-pieces.I33 / I34), rebuilt only
## when the square or colour changes, so a clock-tick refresh keeps an open chooser.

## C6 chooser sprites scaled to fit a 2×2 on the destination square.
const PROMOTE_SPRITE_SCALE := 0.42

var _square := ""
var _color := ""


func _init() -> void:
	name = "PromoteChoice"
	visible = false
	z_index = 2


## Open the chooser on `square`. `kinds` defaults to the session's promote order;
## `draw_kind` paints one chooser sprite (the board supplies piece art).
func show_choice(square: String, color: String, kinds_var: Variant, draw_kind: Callable) -> void:
	var kinds: Array = []
	if kinds_var is Array or kinds_var is PackedStringArray:
		for item in kinds_var:
			kinds.append(str(item))
	else:
		kinds = SharedGameSession.PROMOTE_ORDER.duplicate()
	if kinds.is_empty():
		kinds = SharedGameSession.PROMOTE_ORDER.duplicate()
	# Clock-tick refresh must not rebuild an open chooser.
	if visible and _square == square and _color == color:
		return
	_square = square
	_color = color
	for child in get_children():
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
		draw_kind.call(node, color, kind)
		_scale_sprite(sprite)
		add_child(node)
	visible = true


## Close the chooser.
func clear_choice() -> void:
	_square = ""
	_color = ""
	for child in get_children():
		child.queue_free()
	visible = false


## Hit-test the chooser sprites in world space; returns the kind or `""`.
func kind_at(world: Vector2) -> String:
	if not visible:
		return ""
	var best := ""
	var best_d := 0.38
	for child in get_children():
		var node := child as Node2D
		if node == null:
			continue
		var d := node.position.distance_to(world)
		if d < best_d:
			best_d = d
			best = str(node.get_meta("promote_kind", ""))
	return best


func _scale_sprite(sprite: Sprite2D) -> void:
	if sprite.texture == null:
		return
	var px := float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
	if px <= 0.0:
		px = 1.0
	# Same local Y cancel as the piece sprites: the chooser overrides that scale (#617).
	var s := BoardGeometry.PIECE_EXTENT * PROMOTE_SPRITE_SCALE / px
	sprite.scale = Vector2(s, -s)
