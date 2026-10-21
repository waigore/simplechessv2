class_name BoardGeometry
extends RefCounted
## SPC / PRJ / CAM-board math for CMP-presentation board view (#56).

const BOARD_SIZE := 8.0
const SHORT_AXIS := 10.0
const BOARD_CENTER := Vector2(4.0, 4.0)
const PIECE_EXTENT := 0.85
const SAFE_FRACTION := 0.9
const ASPECT_MIN := 9.0 / 16.0
const ASPECT_MAX := 16.0 / 9.0
const TRAVEL_S := 0.15
const SETTLE_S := 0.03
const SEAT_TOP := "top"
const SEAT_BOTTOM := "bottom"


static func is_square(square: String) -> bool:
	if square.length() != 2:
		return false
	var file_ch := square.unicode_at(0)
	var rank_ch := square.unicode_at(1)
	return file_ch >= 97 and file_ch <= 104 and rank_ch >= 49 and rank_ch <= 56


static func file_index(square: String) -> int:
	return square.unicode_at(0) - 96


static func rank_index(square: String) -> int:
	return square.unicode_at(1) - 48


## SPC.P1 / E2: square center in White-fixed world units (origin at a1 outer corner).
static func square_center(square: String) -> Vector2:
	if not is_square(square):
		return Vector2.ZERO
	return Vector2(float(file_index(square)) - 0.5, float(rank_index(square)) - 0.5)


static func clamp_aspect(aspect: float) -> float:
	if aspect <= 0.0:
		return 1.0
	if aspect < ASPECT_MIN:
		return ASPECT_MIN
	if aspect > ASPECT_MAX:
		return ASPECT_MAX
	return aspect


## PRJ.A1 / V1: visible width × height in world units for a (clamped) aspect.
static func visible_size(aspect: float) -> Vector2:
	var a := clamp_aspect(aspect)
	if a >= 1.0:
		return Vector2(SHORT_AXIS * a, SHORT_AXIS)
	return Vector2(SHORT_AXIS, SHORT_AXIS / a)


## CAM-board.M2: rotate 180° about board center when White seat is Top.
static func apply_seat(world: Vector2, white_seat: String) -> Vector2:
	if white_seat != SEAT_TOP:
		return world
	return BOARD_CENTER * 2.0 - world


static func invert_seat(framed: Vector2, white_seat: String) -> Vector2:
	return apply_seat(framed, white_seat)


## Inner 90% frame in world units (PRJ.A2), centered on the board.
static func safe_rect(aspect: float) -> Rect2:
	var vis := visible_size(aspect)
	var safe := vis * SAFE_FRACTION
	var origin := BOARD_CENTER - safe * 0.5
	return Rect2(origin, safe)


static func point_in_safe_area(world: Vector2, aspect: float) -> bool:
	return safe_rect(aspect).has_point(apply_seat(world, SEAT_BOTTOM))


static func board_bounds() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(BOARD_SIZE, BOARD_SIZE))


static func is_light_square(square: String) -> bool:
	if not is_square(square):
		return false
	return (file_index(square) + rank_index(square)) % 2 == 1


## White-fixed world → algebraic square, or "" if outside the board.
static func square_at(world: Vector2) -> String:
	if world.x < 0.0 or world.y < 0.0 or world.x >= BOARD_SIZE or world.y >= BOARD_SIZE:
		return ""
	var file_i := int(floor(world.x))
	var rank_i := int(floor(world.y))
	return "%s%d" % [String.chr(97 + file_i), rank_i + 1]
