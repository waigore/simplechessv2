class_name BoardPieceLayer
extends Node2D
## The pieces a board draws: one node a square, its sprite, and the capture break
## fragments (SPC.L4). Owns the square→node index so a move can re-key it without
## a re-render.

## Emitted when a piece's texture is not held yet, so the caller can request it.
signal assets_needed(asset_ids: PackedStringArray)

var _nodes: Dictionary = {}

## R8 / `LOC.L9` — the play screen and locale the accessible names resolve for,
## fed by the board on every screen show and locale change (`CTR-localization` O1).
var _name_screen := ""
var _name_locale := ""


func _init() -> void:
	name = "Pieces"
	z_index = 3


## Point the piece names at `screen`'s owner and `locale`; re-apply the name every
## held node carries so it follows the screen and locale, never the tautology of
## one last-applied pair. NODE R8: #643.
func set_name_context(screen: String, locale: String) -> void:
	if screen == _name_screen and locale == _name_locale:
		return
	_name_screen = screen
	_name_locale = locale
	for square in _nodes.keys():
		var node := _nodes[square] as Node2D
		if node != null and node.has_meta("piece_kind"):
			_apply_name(node, str(node.get_meta("piece_kind")))


## The node for a square, or null when the square holds no drawn piece.
func node_for(square: String) -> Node2D:
	return _nodes.get(square) as Node2D


## The squares that currently hold a drawn piece.
func squares() -> Array:
	return _nodes.keys()


## Draw the occupied squares: create a node a new piece, re-apply the others.
## `motion_busy` and `drag_square` keep a piece where the motion or drag put it.
func sync(
	occupancy: Dictionary,
	assets: Dictionary,
	motion_busy: bool,
	drag_square: String,
	asset_id: Callable
) -> void:
	var keep: Dictionary = {}
	for square in occupancy.keys():
		var piece: Dictionary = occupancy[square]
		keep[square] = true
		var node: Node2D = _nodes.get(square) as Node2D
		if node == null:
			node = _make_node(str(square), piece, assets, asset_id)
			_nodes[square] = node
		else:
			apply_kind_texture(
				node, str(piece.get("color", "")), str(piece.get("kind", "")), assets, asset_id
			)
			if drag_square != square and not motion_busy:
				node.position = BoardGeometry.square_center(str(square))
	var stale: Array = []
	for square in _nodes.keys():
		if not keep.has(square) and square != drag_square:
			stale.append(square)
	for square in stale:
		remove(str(square))


## Re-apply every held piece's texture, for a late asset arrival.
func refresh_textures(occupancy: Dictionary, assets: Dictionary, asset_id: Callable) -> void:
	for square in _nodes.keys():
		var piece: Dictionary = occupancy.get(square, {})
		if piece.is_empty():
			continue
		apply_kind_texture(
			_nodes[square] as Node2D,
			str(piece.get("color", "")),
			str(piece.get("kind", "")),
			assets,
			asset_id
		)


## Re-key a piece node from one square to another, for a move that lands.
func rekey(from_square: String, to_square: String, node: Node2D) -> void:
	_nodes.erase(from_square)
	_nodes[to_square] = node
	node.name = "piece_%s" % to_square
	node.z_index = 0
	node.position = BoardGeometry.square_center(to_square)


## Drop a square's node, freeing it.
func remove(square: String) -> void:
	var node: Node2D = _nodes.get(square) as Node2D
	_nodes.erase(square)
	if node != null:
		node.queue_free()


## The ink fragments a captured piece leaves at its square.
func spawn_capture_break(square: String, ink: Color) -> Array[Node2D]:
	var out: Array[Node2D] = []
	var origin := BoardGeometry.square_center(square)
	for i in range(4):
		var frag := Polygon2D.new()
		frag.color = Color(ink, 0.85)
		var o := Vector2(0.12 if i % 2 == 0 else -0.12, 0.12 if i < 2 else -0.12)
		frag.polygon = PackedVector2Array(
			[origin + o, origin + o + Vector2(0.15, 0), origin + o + Vector2(0.08, 0.15)]
		)
		add_child(frag)
		out.append(frag)
	return out


## Re-apply one node's sprite, colour, kind, and accessible name.
func apply_kind_texture(
	node: Node2D, color: String, kind: String, assets: Dictionary, asset_id: Callable
) -> void:
	var sprite := node.get_node_or_null("Sprite") as Sprite2D
	if sprite == null:
		return
	node.set_meta("piece_color", color)
	node.set_meta("piece_kind", kind)
	# R8: the name rides the same node metadata; promotion re-applies it here.
	_apply_name(node, kind)
	var id := str(asset_id.call("%s|%s" % [color, kind]))
	if id.is_empty():
		return
	var texture: Texture2D = assets.get(id) as Texture2D
	if texture == null:
		assets_needed.emit(PackedStringArray([id]))
		sprite.texture = null
		return
	sprite.texture = texture
	var px := float(maxi(texture.get_width(), texture.get_height()))
	if px <= 0.0:
		px = 1.0
	# The board mirrors its Y axis (board y up, screen y down). Raster art cancels
	# that locally so pieces read as authored and still rotate with CAM-board.M2 (#617).
	var s := BoardGeometry.PIECE_EXTENT / px
	sprite.scale = Vector2(s, -s)


## R8 — resolve `kind` against `LOC.L9`'s key through O1 for the name context
## the board set, and only once that context exists: a node is never left
## carrying a name resolved at a screen or locale that was not asked for.
func _apply_name(node: Node2D, kind: String) -> void:
	if _name_screen.is_empty() or _name_locale.is_empty():
		return
	node.set_meta(
		"accessible_name", BoardPresentation.accessible_name(kind, _name_screen, _name_locale)
	)


func _make_node(
	square: String, piece: Dictionary, assets: Dictionary, asset_id: Callable
) -> Node2D:
	var root := Node2D.new()
	root.name = "piece_%s" % square
	root.position = BoardGeometry.square_center(square)
	root.set_meta("piece_color", str(piece.get("color", "white")))
	root.set_meta("piece_kind", str(piece.get("kind", "pawn")))
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = true
	root.add_child(sprite)
	apply_kind_texture(
		root, str(piece.get("color", "")), str(piece.get("kind", "")), assets, asset_id
	)
	add_child(root)
	return root
