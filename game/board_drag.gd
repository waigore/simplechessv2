class_name BoardDrag
extends Node2D
## B10 drag follow and SPC.L4's refused drop (PER.R1 / R8): the piece under the
## pointer follows it in world space while pressed, returns home on a refused
## drop, and hands a legal drop to the board's move so O2 owns the place animation.
##
## `motion` reports the busy hand-off in both directions: the board's own move
## flag is set while the return animates, and released when it ends.

signal motion(active: bool)

## Last bad-drop return seconds; the board reads it for its timing budget.
var last_return_s := 0.0

## The pieces whose node follows the pointer; set by the board.
var pieces: BoardPieceLayer

var _square := ""
var _world := Vector2.ZERO
var _motion_busy := false


## The square being dragged, or `""`.
func square() -> String:
	return _square


## The pointer's last world point while dragging.
func world() -> Vector2:
	return _world


## B10 drag follow: `begin` with the square and world point, then `move`.
func update_drag(cmd: Variant, payload: Variant) -> void:
	match str(cmd):
		"begin":
			var start: Dictionary = payload
			_begin(str(start.get("square", "")), start.get("world", Vector2.ZERO))
		"move":
			_move(payload)


## A legal drop: hand the pair to `start_legal` and stop following.
func end_legal(to_square: String, start_legal: Callable) -> void:
	if _square.is_empty():
		return
	var from_square := _square
	_square = ""
	await start_legal.call(from_square, to_square)


## A refused drop: return the piece home over the return budget.
func end_illegal() -> void:
	if _square.is_empty():
		return
	var square := _square
	_square = ""
	var node := pieces.node_for(square)
	if node == null:
		return
	var origin := BoardGeometry.square_center(square)
	last_return_s = BoardGeometry.TRAVEL_S
	_set_motion_busy(true)
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(node, "position", origin, last_return_s)
	await tw.finished
	node.z_index = 0
	_set_motion_busy(false)


## Drop the follow without a tween so O2 can own the place animation.
func cancel() -> void:
	if _square.is_empty():
		return
	var square := _square
	_square = ""
	var node := pieces.node_for(square)
	if node == null:
		return
	node.position = BoardGeometry.square_center(square)
	node.z_index = 0


func _begin(square: String, world: Vector2) -> void:
	var node := pieces.node_for(square)
	if node == null or _motion_busy:
		return
	_square = square
	_world = world
	node.z_index = 10
	node.position = world


func _move(world: Vector2) -> void:
	if _square.is_empty():
		return
	_world = world
	var node := pieces.node_for(_square)
	if node != null:
		node.position = world


func _set_motion_busy(active: bool) -> void:
	_motion_busy = active
	motion.emit(active)
