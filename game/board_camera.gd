class_name BoardCamera
extends Node2D
## The board camera's world mapping: the seat's 180° flip (CAM-board.M2) and
## CMP-presentation.R2's canvas↔world pair, plus the frame's world box (PRJ).
##
## The camera owns no board face. `content` is the node the board draws inside
## (`Seat/Content`), so this pair is the same one a pointer event reaches the
## presentation in, and the seat rotation, zoom, and stretch are all included.

## The node a world point is drawn in; set by the board when it builds its face.
var content: Node2D

## Which seat sits at the bottom; a top seat turns the whole board 180°.
var white_seat := "bottom"


## CMP-presentation.R2 — canvas space in, world out. `to_local` walks every
## ancestor transform, so the seat flip, zoom, and stretch are inverted exactly.
func screen_to_world(screen: Vector2) -> Vector2:
	if content == null:
		return Vector2.ZERO
	return content.to_local(screen)


## CMP-presentation.R2 — world out to canvas space, the exact inverse above.
func world_to_screen(world: Vector2) -> Vector2:
	if content == null:
		return Vector2.ZERO
	return content.to_global(world)


## The square centre as drawn for the current seat (CAM-board.M2).
func framed_center(square: String) -> Vector2:
	return BoardGeometry.apply_seat(BoardGeometry.square_center(square), white_seat)


## The frame's width against its height.
func aspect_ratio(face_size: Vector2) -> float:
	if face_size.y <= 0.0:
		return 1.0
	return face_size.x / face_size.y


## The board frame's visible world box at a face ratio (PRJ).
func visible_world_size(face_size: Vector2) -> Vector2:
	return BoardGeometry.visible_size(aspect_ratio(face_size))
