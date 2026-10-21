class_name ChessRules
extends RefCounted
## CMP-chess-rules (L3). CTR-local-move O1, O2, E1, and E2.

signal move_applied(move: Dictionary, side_to_move: String)
signal move_rejected(reason: String)

const SIDE_WHITE := "white"
const SIDE_BLACK := "black"
const KIND_KING := "king"
const KIND_QUEEN := "queen"
const KIND_ROOK := "rook"
const KIND_BISHOP := "bishop"
const KIND_KNIGHT := "knight"
const KIND_PAWN := "pawn"
const REASON_PROMOTION := "promotion"
const REASON_SQUARE := "square"
const REASON_EMPTY := "empty"
const REASON_SIDE := "wrong_side"
const REASON_ILLEGAL := "illegal"

const _PROMOTE_KINDS: Array = [KIND_QUEEN, KIND_ROOK, KIND_BISHOP, KIND_KNIGHT]
const _ORTHO: Array = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]
const _DIAG: Array = [
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1),
]
const _KING_OFFSETS: Array = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1),
]
const _KNIGHT_OFFSETS: Array = [
	Vector2i(1, 2),
	Vector2i(1, -2),
	Vector2i(-1, 2),
	Vector2i(-1, -2),
	Vector2i(2, 1),
	Vector2i(2, -1),
	Vector2i(-2, 1),
	Vector2i(-2, -1),
]

var _occupancy: Dictionary = {}
var _side_to_move := SIDE_WHITE
var _castling: Dictionary = {}
var _en_passant := ""
var _geometries: Dictionary = {}


func _init() -> void:
	var queen_dirs: Array = []
	queen_dirs.append_array(_ORTHO)
	queen_dirs.append_array(_DIAG)
	_geometries = {
		KIND_KNIGHT: {"offsets": _KNIGHT_OFFSETS, "slide": false},
		KIND_KING: {"offsets": _KING_OFFSETS, "slide": false},
		KIND_ROOK: {"offsets": _ORTHO, "slide": true},
		KIND_BISHOP: {"offsets": _DIAG, "slide": true},
		KIND_QUEEN: {"offsets": queen_dirs, "slide": true},
	}


func reset_opening() -> void:
	var pieces: Array = []
	var back_rank: Array = [
		KIND_ROOK,
		KIND_KNIGHT,
		KIND_BISHOP,
		KIND_QUEEN,
		KIND_KING,
		KIND_BISHOP,
		KIND_KNIGHT,
		KIND_ROOK,
	]
	for index in range(8):
		var file := char(97 + index)
		pieces.append(_placed("%s1" % file, SIDE_WHITE, back_rank[index]))
		pieces.append(_placed("%s2" % file, SIDE_WHITE, KIND_PAWN))
		pieces.append(_placed("%s7" % file, SIDE_BLACK, KIND_PAWN))
		pieces.append(_placed("%s8" % file, SIDE_BLACK, back_rank[index]))
	load_position(pieces, SIDE_WHITE)


func load_position(
	pieces: Array,
	side: String,
	castling: Dictionary = {},
	en_passant: String = "",
) -> void:
	_occupancy = {}
	for entry in pieces:
		var square := str(entry["square"])
		_occupancy[square] = {"color": str(entry["color"]), "kind": str(entry["kind"])}
	_side_to_move = side
	if castling.is_empty():
		_castling = _full_castling()
	else:
		_castling = {
			"white_kingside": bool(castling.get("white_kingside", false)),
			"white_queenside": bool(castling.get("white_queenside", false)),
			"black_kingside": bool(castling.get("black_kingside", false)),
			"black_queenside": bool(castling.get("black_queenside", false)),
		}
	_en_passant = en_passant if _is_square(en_passant) else ""


func position_field() -> Dictionary:
	return {
		"occupancy": _occupancy.duplicate(true),
		"side_to_move": _side_to_move,
	}


func castling_ep() -> Dictionary:
	var rights := _castling.duplicate()
	rights["en_passant"] = _en_passant
	return rights


func piece_on(square: String) -> Dictionary:
	return (_occupancy.get(square, {}) as Dictionary).duplicate(true)


func squares() -> PackedStringArray:
	var names := PackedStringArray()
	for file in range(1, 9):
		for rank in range(1, 9):
			names.append(_square_name(Vector2i(file, rank)))
	return names


func orthogonal_neighbors(square: String) -> PackedStringArray:
	var names := PackedStringArray()
	if not _is_square(square):
		return names
	var start := _coords(square)
	for direction in _ORTHO:
		var cursor: Vector2i = start + (direction as Vector2i)
		if _on_board(cursor):
			names.append(_square_name(cursor))
	return names


func is_dark_square(square: String) -> bool:
	if not _is_square(square):
		return false
	return (_file_index(square) + _rank_index(square)) % 2 == 0


func in_check(side: String) -> bool:
	var king_square := _king_square(side)
	if king_square.is_empty():
		return false
	return attacks(_opponent(side), king_square)


func attacks(attacker_side: String, square: String) -> bool:
	if not _is_square(square):
		return false
	for origin in _occupancy.keys():
		var piece: Dictionary = _occupancy[origin]
		if str(piece["color"]) != attacker_side:
			continue
		if _candidate_squares(str(origin), piece, true).has(square):
			return true
	return false


func legal_targets(from_square: String) -> PackedStringArray:
	var targets := PackedStringArray()
	if not _is_square(from_square):
		return targets
	var piece: Dictionary = _occupancy.get(from_square, {})
	if piece.is_empty():
		return targets
	if str(piece["color"]) != _side_to_move:
		return targets
	var color := str(piece["color"])
	for square in _candidate_squares(from_square, piece, false):
		if _king_safe_after(from_square, str(square), color):
			targets.append(str(square))
	targets.sort()
	return targets


func is_pseudo_legal(from_square: String, to_square: String) -> bool:
	if not _is_square(from_square) or not _is_square(to_square):
		return false
	var piece: Dictionary = _occupancy.get(from_square, {})
	if piece.is_empty():
		return false
	if str(piece["color"]) != _side_to_move:
		return false
	return _candidate_squares(from_square, piece, false).has(to_square)


func try_move(from_square: String, to_square: String, promotion: String = "") -> bool:
	var reason := _reject_reason(from_square, to_square, promotion)
	if not reason.is_empty():
		move_rejected.emit(reason)
		return false
	_apply_move(from_square, to_square, promotion)
	move_applied.emit({"from": from_square, "to": to_square}, _side_to_move)
	return true


func _reject_reason(from_square: String, to_square: String, promotion: String) -> String:
	var reason := ""
	var piece: Dictionary = _occupancy.get(from_square, {})
	if not _is_square(from_square) or not _is_square(to_square):
		reason = REASON_SQUARE
	elif piece.is_empty():
		reason = REASON_EMPTY
	elif str(piece["color"]) != _side_to_move:
		reason = REASON_SIDE
	elif not legal_targets(from_square).has(to_square):
		reason = REASON_ILLEGAL
	elif _is_promotion_move(piece, to_square) and not _PROMOTE_KINDS.has(promotion):
		reason = REASON_PROMOTION
	elif not _is_promotion_move(piece, to_square) and not promotion.is_empty():
		reason = REASON_PROMOTION
	return reason


func _apply_move(from_square: String, to_square: String, promotion: String) -> void:
	var piece: Dictionary = _occupancy[from_square].duplicate(true)
	var color := str(piece["color"])
	var kind := str(piece["kind"])
	if kind == KIND_PAWN and to_square == _en_passant:
		_occupancy.erase(_en_passant_capture_square(to_square, color))
	if kind == KIND_KING and absi(_file_index(to_square) - _file_index(from_square)) == 2:
		_move_castle_rook(from_square, to_square)
	_occupancy[to_square] = piece
	_occupancy.erase(from_square)
	if kind == KIND_PAWN and _promotes(_rank_index(to_square), color):
		_occupancy[to_square] = {"color": color, "kind": promotion}
	_update_castling_ep(from_square, to_square, piece)
	_side_to_move = _opponent(_side_to_move)


func _king_safe_after(from_square: String, to_square: String, color: String) -> bool:
	var saved_occ := _occupancy.duplicate(true)
	var saved_ep := _en_passant
	var piece: Dictionary = _occupancy[from_square].duplicate(true)
	var kind := str(piece["kind"])
	if kind == KIND_PAWN and to_square == _en_passant:
		_occupancy.erase(_en_passant_capture_square(to_square, color))
	if kind == KIND_KING and absi(_file_index(to_square) - _file_index(from_square)) == 2:
		_move_castle_rook(from_square, to_square)
	_occupancy[to_square] = piece
	_occupancy.erase(from_square)
	var king_square := _king_square(color)
	var safe := king_square.is_empty() or not attacks(_opponent(color), king_square)
	_occupancy = saved_occ
	_en_passant = saved_ep
	return safe


func _candidate_squares(origin: String, piece: Dictionary, for_attack: bool) -> Array:
	var kind := str(piece["kind"])
	if kind == KIND_PAWN:
		return _pawn_squares(origin, piece, for_attack)
	if kind == KIND_KING and not for_attack:
		var found := _offset_squares(origin, piece, _KING_OFFSETS, false, for_attack)
		found.append_array(_castling_squares(origin, piece))
		return found
	if not _geometries.has(kind):
		return []
	var geometry: Dictionary = _geometries[kind]
	return _offset_squares(
		origin,
		piece,
		geometry["offsets"],
		bool(geometry["slide"]),
		for_attack,
	)


func _offset_squares(
	origin: String,
	piece: Dictionary,
	offsets: Array,
	slide: bool,
	for_attack: bool,
) -> Array:
	var found: Array = []
	var start := _coords(origin)
	for dir_value in offsets:
		var direction := dir_value as Vector2i
		var cursor := start + direction
		while _on_board(cursor):
			var square := _square_name(cursor)
			var occupier: Dictionary = _occupancy.get(square, {})
			if occupier.is_empty():
				found.append(square)
			else:
				if for_attack or _can_capture(piece, occupier):
					found.append(square)
				break
			if not slide:
				break
			cursor += direction
	return found


func _pawn_squares(origin: String, piece: Dictionary, for_attack: bool) -> Array:
	var found: Array = []
	var start := _coords(origin)
	var color := str(piece["color"])
	var forward := 1 if color == SIDE_WHITE else -1
	for file_delta in [-1, 1]:
		var cursor := Vector2i(start.x + file_delta, start.y + forward)
		if not _on_board(cursor):
			continue
		var square := _square_name(cursor)
		if for_attack:
			found.append(square)
			continue
		if square == _en_passant:
			found.append(square)
			continue
		var occupier: Dictionary = _occupancy.get(square, {})
		if not occupier.is_empty() and _can_capture(piece, occupier):
			found.append(square)
	if for_attack:
		return found
	return _pawn_advances(start, color, forward, found)


func _pawn_advances(start: Vector2i, color: String, forward: int, found: Array) -> Array:
	var one := Vector2i(start.x, start.y + forward)
	if not _on_board(one):
		return found
	var one_square := _square_name(one)
	if not (_occupancy.get(one_square, {}) as Dictionary).is_empty():
		return found
	found.append(one_square)
	var home := 2 if color == SIDE_WHITE else 7
	if start.y != home:
		return found
	var two := Vector2i(start.x, start.y + forward * 2)
	var two_square := _square_name(two)
	if (_occupancy.get(two_square, {}) as Dictionary).is_empty():
		found.append(two_square)
	return found


func _castling_squares(origin: String, piece: Dictionary) -> Array:
	var found: Array = []
	var color := str(piece["color"])
	if color == SIDE_WHITE and origin != "e1":
		return found
	if color == SIDE_BLACK and origin != "e8":
		return found
	if in_check(color):
		return found
	var rank := "1" if color == SIDE_WHITE else "8"
	if _castling_ready(color, true, rank):
		found.append("g%s" % rank)
	if _castling_ready(color, false, rank):
		found.append("c%s" % rank)
	return found


func _castling_ready(color: String, kingside: bool, rank: String) -> bool:
	var right_key := ("%s_kingside" % color) if kingside else ("%s_queenside" % color)
	if not bool(_castling.get(right_key, false)):
		return false
	var rook_square := ("h%s" % rank) if kingside else ("a%s" % rank)
	var rook: Dictionary = _occupancy.get(rook_square, {})
	if rook.is_empty() or str(rook["color"]) != color or str(rook["kind"]) != KIND_ROOK:
		return false
	var between: Array = (
		["f%s" % rank, "g%s" % rank] if kingside else ["b%s" % rank, "c%s" % rank, "d%s" % rank]
	)
	for square in between:
		if not (_occupancy.get(str(square), {}) as Dictionary).is_empty():
			return false
	var path: Array = ["f%s" % rank, "g%s" % rank] if kingside else ["d%s" % rank, "c%s" % rank]
	for square in path:
		if attacks(_opponent(color), str(square)):
			return false
	return true


func _move_castle_rook(from_square: String, to_square: String) -> void:
	var rank := from_square.substr(1, 1)
	var kingside := _file_index(to_square) > _file_index(from_square)
	var rook_from := ("h%s" % rank) if kingside else ("a%s" % rank)
	var rook_to := ("f%s" % rank) if kingside else ("d%s" % rank)
	_occupancy[rook_to] = _occupancy[rook_from]
	_occupancy.erase(rook_from)


func _update_castling_ep(from_square: String, to_square: String, piece: Dictionary) -> void:
	var color := str(piece["color"])
	var kind := str(piece["kind"])
	var next_ep := ""
	if kind == KIND_PAWN and absi(_rank_index(to_square) - _rank_index(from_square)) == 2:
		var mid := Vector2i(
			_file_index(from_square),
			(_rank_index(from_square) + _rank_index(to_square)) / 2,
		)
		next_ep = _square_name(mid)
	_en_passant = next_ep
	if kind == KIND_KING:
		_clear_side_castling(color)
	if kind == KIND_ROOK:
		_clear_rook_right(from_square, color)
	_clear_rook_right(to_square, _opponent(color))


func _clear_side_castling(color: String) -> void:
	_castling["%s_kingside" % color] = false
	_castling["%s_queenside" % color] = false


func _clear_rook_right(square: String, color: String) -> void:
	if square == "a1" and color == SIDE_WHITE:
		_castling["white_queenside"] = false
	elif square == "h1" and color == SIDE_WHITE:
		_castling["white_kingside"] = false
	elif square == "a8" and color == SIDE_BLACK:
		_castling["black_queenside"] = false
	elif square == "h8" and color == SIDE_BLACK:
		_castling["black_kingside"] = false


func _en_passant_capture_square(to_square: String, capturer_color: String) -> String:
	var rank := _rank_index(to_square) + (-1 if capturer_color == SIDE_WHITE else 1)
	return _square_name(Vector2i(_file_index(to_square), rank))


func _is_promotion_move(piece: Dictionary, to_square: String) -> bool:
	if str(piece["kind"]) != KIND_PAWN:
		return false
	return _promotes(_rank_index(to_square), str(piece["color"]))


func _can_capture(mover: Dictionary, occupier: Dictionary) -> bool:
	if str(occupier["color"]) == str(mover["color"]):
		return false
	return str(occupier["kind"]) != KIND_KING


func _promotes(rank: int, color: String) -> bool:
	if color == SIDE_WHITE:
		return rank == 8
	return rank == 1


func _king_square(side: String) -> String:
	for square in _occupancy.keys():
		var piece: Dictionary = _occupancy[square]
		if str(piece["color"]) == side and str(piece["kind"]) == KIND_KING:
			return str(square)
	return ""


func _opponent(side: String) -> String:
	if side == SIDE_WHITE:
		return SIDE_BLACK
	return SIDE_WHITE


func _full_castling() -> Dictionary:
	return {
		"white_kingside": true,
		"white_queenside": true,
		"black_kingside": true,
		"black_queenside": true,
	}


func _placed(square: String, color: String, kind: String) -> Dictionary:
	return {"square": square, "color": color, "kind": kind}


func _is_square(square: String) -> bool:
	if square.length() != 2:
		return false
	var file := square.unicode_at(0)
	var rank := square.unicode_at(1)
	return file >= 97 and file <= 104 and rank >= 49 and rank <= 56


func _coords(square: String) -> Vector2i:
	return Vector2i(_file_index(square), _rank_index(square))


func _file_index(square: String) -> int:
	return square.unicode_at(0) - 96


func _rank_index(square: String) -> int:
	return square.unicode_at(1) - 48


func _square_name(coords: Vector2i) -> String:
	return char(coords.x + 96) + str(coords.y)


func _on_board(coords: Vector2i) -> bool:
	return coords.x >= 1 and coords.x <= 8 and coords.y >= 1 and coords.y <= 8
