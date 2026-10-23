class_name DemoChessRules
extends RefCounted
## Pure chess rules for demo #335, reused unchanged from demo #63.
## Spec source: specs/design/entities/pieces (common I1-I11, officers I23-I27,
## king I12-I22, pawn I28-I34, I35). The positions these rules play are read
## from a FEN by fen_codec.gd (F-puzzle-catalog R3). The one changed line is
## castle_rights below, which asks the position for its own castling rights.

const WHITE := "w"
const BLACK := "b"
const FILES := ["a", "b", "c", "d", "e", "f", "g", "h"]
const PROMO_ORDER := ["q", "r", "b", "n"]  # I33/I34 - queen first is the demo default choice

# 64-square board as codes "wP"/"bN"/"" (r*8+f index, a1=0, h8=63).
# moved[i] tracks E-pieces.P4 per square (flags follow the piece on every move).
# ep_target is the square an en passant capture may land on this ply (-1 none).

static func square_name(index: int) -> String:
	return FILES[index % 8] + str(index / 8 + 1)


static func square_index(name: String) -> int:
	return (name.substr(1).to_int() - 1) * 8 + FILES.find(name[0])


static func is_light_square(file: int, rank: int) -> bool:
	# E-pieces.I35: a1 is dark; file index + rank odd means light (0-based).
	return (file + rank) % 2 == 1


static func piece_color(code: String) -> String:
	return code.substr(0, 1)


static func piece_kind(code: String) -> String:
	return code.substr(1, 1)


static func _empty_board() -> PackedStringArray:
	var board := PackedStringArray()
	for i in range(64):
		board.append("")
	return board


static func start_position() -> Dictionary:
	var board := _empty_board()
	for file in range(8):
		board[8 + file] = "wP"
		board[6 * 8 + file] = "bP"
	var back := ["R", "N", "B", "Q", "K", "B", "N", "R"]
	for file in range(8):
		board[0 * 8 + file] = "w" + back[file]
		board[7 * 8 + file] = "b" + back[file]
	return {
		"board": board,
		"moved": PackedByteArray(),
		"ep_target": -1,
		"castling": "KQkq",
		"side": WHITE,
		"king": {},
	}


static func duplicate_position(pos: Dictionary) -> Dictionary:
	var king: Variant = pos["king"]
	var moved: PackedByteArray = (pos["moved"] as PackedByteArray).duplicate()
	var copy := {
		"board": (pos["board"] as PackedStringArray).duplicate(),
		"moved": moved,
		"ep_target": int(pos["ep_target"]),
		"castling": str(pos.get("castling", "")),
		"side": str(pos["side"]),
		"king": (king as Dictionary).duplicate(true) if king is Dictionary else {},
	}
	return copy


static func init_king(pos: Dictionary) -> void:
	var king: Dictionary = {}
	var board: PackedStringArray = pos["board"]
	for i in range(64):
		if piece_kind(board[i]) == "K":
			king[piece_color(board[i])] = i
	pos["king"] = king


static func has_moved(pos: Dictionary, index: int) -> bool:
	# A fresh position created an empty flag array; unset pieces have not moved.
	var moved: PackedByteArray = pos["moved"]
	return index >= 0 and index < moved.size() and moved[index] == 1


static func _mark_moved(pos: Dictionary, index: int) -> void:
	var moved: PackedByteArray = pos["moved"]
	if moved.size() < 64:
		moved.resize(64)
	if index >= 0 and index < 64:
		moved[index] = 1


static func castle_rights(pos: Dictionary, color: String) -> Dictionary:
	# I16-I17: the king and the corner rook have never moved and are still there,
	# and the FEN's castling field grants the right. A puzzle position's FEN
	# carries no castling rights (fen_codec.gd), so a puzzle never offers castling.
	var board: PackedStringArray = pos["board"]
	var rights := str(pos.get("castling", ""))
	var rank := 0 if color == WHITE else 7
	var king_sq := rank * 8 + 4
	var king_ok := board[king_sq] == color + "K" and not has_moved(pos, king_sq)
	var k_char := "K" if color == WHITE else "k"
	var q_char := "Q" if color == WHITE else "q"
	return {
		"k": king_ok and rights.find(k_char) >= 0 \
			and board[rank * 8 + 7] == color + "R" and not has_moved(pos, rank * 8 + 7),
		"q": king_ok and rights.find(q_char) >= 0 \
			and board[rank * 8 + 0] == color + "R" and not has_moved(pos, rank * 8 + 0),
	}


static func ray_squares(pos: Dictionary, index: int, directions: Array, jump: bool) -> Array:
	# I23 sliders stop at their first occupied square; I27 knights jump (I6).
	var board: PackedStringArray = pos["board"]
	var file := index % 8
	var rank := index / 8
	var out: Array = []
	for dir in directions:
		var f := file
		var r := rank
		for step in range(8):
			f += int(dir[0])
			r += int(dir[1])
			if f < 0 or f > 7 or r < 0 or r > 7:
				break
			var target := r * 8 + f
			var code := board[target]
			out.append(target)
			if code != "" or jump:
				break
	return out


const KnightDirs := [
	Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1),
	Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1),
]
const KingDirs := [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]
const RookDirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const BishopDirs := [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]


static func knight_targets(pos: Dictionary, index: int) -> Array:
	# I27: eight 2x1 targets; jumps intervening pieces.
	var file := index % 8
	var rank := index / 8
	var out: Array = []
	for dir in KnightDirs:
		var f := file + int(dir.x)
		var r := rank + int(dir.y)
		if f >= 0 and f <= 7 and r >= 0 and r <= 7:
			out.append(r * 8 + f)
	return out


static func is_attacked_by(pos: Dictionary, index: int, by_color: String) -> bool:
	# I5/I6: pawn captures count, pawn steps do not; the king attacks adjacent squares;
	# the target square is treated as opponent-occupied, so own-king safety is ignored.
	var board: PackedStringArray = pos["board"]
	var file := index % 8
	var rank := index / 8
	# Pawn diagonals toward the attacking side's forward direction.
	var pawn_rank := rank + (1 if by_color == WHITE else -1) * -1
	if pawn_rank >= 0 and pawn_rank <= 7:
		for df: int in [-1, 1]:
			var f := file + df
			if f >= 0 and f <= 7 and board[pawn_rank * 8 + f] == by_color + "P":
				return true
	for t in knight_targets(pos, index):
		if board[t] == by_color + "N":
			return true
	for dir in KingDirs:
		var f := file + int(dir.x)
		var r := rank + int(dir.y)
		if f >= 0 and f <= 7 and r >= 0 and r <= 7 and board[r * 8 + f] == by_color + "K":
			return true
	# Sliders: first occupied square on the ray is the attack point (I5).
	var ort := [RookDirs, BishopDirs]
	var kinds := ["R", "B"]
	for pair in range(2):
		for dir in ort[pair]:
			var f := index % 8 + int(dir.x)
			var r := index / 8 + int(dir.y)
			for step in range(8):
				if f < 0 or f > 7 or r < 0 or r > 7:
					break
				var code := board[r * 8 + f]
				if code != "":
					if piece_color(code) == by_color:
						var kind := piece_kind(code)
						if kind == "Q" or kind == kinds[pair]:
							return true
					break
				f += int(dir.x)
				r += int(dir.y)
	return false


static func king_square(pos: Dictionary, color: String) -> int:
	var king: Dictionary = pos["king"]
	if king.has(color):
		return int(king[color])
	return -1


static func in_check(pos: Dictionary, color: String) -> bool:
	# I7: the king sits on a square attacked by the opponent.
	var sq := king_square(pos, color)
	if sq < 0:
		return false
	return is_attacked_by(pos, sq, BLACK if color == WHITE else WHITE)


static func _pseudo_move(pos: Dictionary, from: int, to: int) -> Dictionary:
	var board: PackedStringArray = pos["board"]
	var code := board[from]
	var move := {
		"from": from, "to": to, "capture": -1, "is_ep": false,
		"rook_from": -1, "rook_to": -1, "promo": "",
	}
	var target := board[to]
	if target != "":
		if piece_color(target) == piece_color(code):
			return {}
		move["capture"] = to
	return move


static func _add_pawn_moves(pos: Dictionary, from: int, out: Array) -> void:
	# I28-I34: steps, double step, captures, en passant, promotion choices.
	var board: PackedStringArray = pos["board"]
	var code: String = board[from]
	var color := piece_color(code)
	var dir := 1 if color == WHITE else -1
	var start_rank := 1 if color == WHITE else 6
	var last_rank := 7 if color == WHITE else 0
	var file := from % 8
	var rank := from / 8
	# I28/I29: one-step forward; two-step from the start rank only.
	if rank + dir >= 0 and rank + dir <= 7:
		var r := rank + dir
		var to := r * 8 + file
		if board[to] == "":
			for promo_kind in _promo_kinds(r, last_rank):
				out.append(_pawn_move(pos, from, to, -1, false, promo_kind))
			if rank == start_rank and not has_moved(pos, from):
				var twice := (rank + 2 * dir) * 8 + file
				if board[twice] == "":
					out.append(_pawn_move(pos, from, twice, -1, false, ""))
	for df: int in [-1, 1]:
		# I30: one-square diagonal capture onto an opponent piece.
		var f_capture := file + df
		if f_capture < 0 or f_capture > 7:
			continue
		var r_cap := rank + dir
		if r_cap < 0 or r_cap > 7:
			continue
		var to_cap := r_cap * 8 + f_capture
		var target := board[to_cap]
		if target != "" and piece_color(target) != color:
			for promo_kind in _promo_kinds(r_cap, last_rank):
				out.append(_pawn_move(pos, from, to_cap, to_cap, false, promo_kind))
	# I31/I32: the immediately-following-move-only en passant capture.
	var ep := int(pos["ep_target"])
	if ep >= 0 and ep / 8 == rank + dir and absi(ep % 8 - file) == 1:
		# I3: the removed pawn sits behind the landing square, not on it.
		out.append(_pawn_move(pos, from, ep, ep - dir * 8, true, ""))


static func _promo_kinds(rank: int, last_rank: int) -> Array:
	# I33/I34: choose q, rook, bishop, or knight; never a pawn or king.
	if rank != last_rank:
		return [""]
	return PROMO_ORDER


static func _pawn_move(pos: Dictionary, from: int, to: int, captures: int, ep: bool, promo: String) -> Dictionary:
	# I3: en passant removes the passed pawn from its arrival square, not the landing square.
	return {
		"from": from, "to": to, "capture": captures, "is_ep": ep,
		"rook_from": -1, "rook_to": -1, "promo": promo,
	}


static func _add_king_moves(pos: Dictionary, from: int, out: Array) -> void:
	# I12: one square any direction. I13-I22: castling.
	var board: PackedStringArray = pos["board"]
	var code := board[from]
	var color := piece_color(code)
	var opponent := BLACK if color == WHITE else WHITE
	for t in ray_squares(pos, from, KingDirs, true):
		var to := int(t)
		var target := board[to]
		if target == "" or piece_color(target) != color:
			out.append(_pseudo_move(pos, from, to))
	# I19: not while in check; I20: crossing and landing squares not attacked.
	if is_attacked_by(pos, from, opponent):
		return
	var rights: Dictionary = castle_rights(pos, color)
	var rank := 0 if color == WHITE else 7
	if rights["k"]:
		if board[rank * 8 + 5] == "" and board[rank * 8 + 6] == "":
			if not is_attacked_by(pos, rank * 8 + 5, opponent) \
					and not is_attacked_by(pos, rank * 8 + 6, opponent):
				# I14: e1-g1 / h1-f1 (White), e8-g8 / h8-f8 (Black).
				out.append({
					"from": from, "to": rank * 8 + 6, "capture": -1, "is_ep": false,
					"rook_from": rank * 8 + 7, "rook_to": rank * 8 + 5, "promo": "",
				})
	if rights["q"]:
		var queen_clear := board[rank * 8 + 1] == "" and board[rank * 8 + 2] == ""
		if queen_clear and board[rank * 8 + 3] == "":
			if not is_attacked_by(pos, rank * 8 + 2, opponent) \
					and not is_attacked_by(pos, rank * 8 + 3, opponent):
				# I15: e1-c1 / a1-d1 (White), e8-c8 / a8-d8 (Black).
				out.append({
					"from": from, "to": rank * 8 + 2, "capture": -1, "is_ep": false,
					"rook_from": rank * 8 + 0, "rook_to": rank * 8 + 3, "promo": "",
				})


static func pseudo_moves(pos: Dictionary, from: int) -> Array:
	var board: PackedStringArray = pos["board"]
	var code := board[from]
	if code == "" or piece_color(code) != str(pos["side"]):
		return []
	var out: Array = []
	match piece_kind(code):
		"P":
			_add_pawn_moves(pos, from, out)
		"N":
			for t in knight_targets(pos, from):
				var mv := _pseudo_move(pos, from, int(t))
				if not mv.is_empty():
					out.append(mv)
		"B":
			_add_slider_moves(pos, from, BishopDirs, out)
		"R":
			_add_slider_moves(pos, from, RookDirs, out)
		"Q":
			_add_slider_moves(pos, from, RookDirs, out)
			_add_slider_moves(pos, from, BishopDirs, out)
		"K":
			_add_king_moves(pos, from, out)
	return out


static func _add_slider_moves(pos: Dictionary, from: int, dirs: Array, out: Array) -> void:
	var board: PackedStringArray = pos["board"]
	for dir in dirs:
		var step := dir as Vector2i
		var f := from % 8 + step.x
		var r := from / 8 + step.y
		for i in range(8):
			if f < 0 or f > 7 or r < 0 or r > 7:
				break
			var mv := _pseudo_move(pos, from, r * 8 + f)
			if mv.is_empty():
				break
			out.append(mv)
			if int(mv["capture"]) != -1:
				break
			f += step.x
			r += step.y


static func legal_moves(pos: Dictionary, from: int) -> Array:
	# I9/I10: pseudo-legal moves that leave the mover's king out of check are legal.
	var out: Array = []
	var side := str(pos["side"])
	for mv in pseudo_moves(pos, from):
		if not in_check(apply(pos, mv), side):
			out.append(mv)
	return out


static func all_legal_moves(pos: Dictionary) -> Array:
	var out: Array = []
	for i in range(64):
		out.append_array(legal_moves(pos, i))
	return out


static func apply(pos: Dictionary, move: Dictionary) -> Dictionary:
	# I11: only the side to move moves; a refused attempt changes nothing.
	var board: PackedStringArray = pos["board"]
	var code := board[int(move["from"])]
	if code == "" or piece_color(code) != str(pos["side"]):
		return duplicate_position(pos)
	var trial := duplicate_position(pos)
	var t_board: PackedStringArray = trial["board"]
	var to: int = int(move["to"])
	var moving := code
	if str(move["promo"]) != "":
		moving = piece_color(code) + str(move["promo"])  # I33/I34 same-color replacement
	t_board[int(move["from"])] = ""
	t_board[to] = moving
	_mark_moved(trial, int(move["from"]))
	_mark_moved(trial, to)
	# I3/I22: clear the captured square (en passant removes the passed pawn elsewhere).
	var cap := int(move["capture"])
	if cap >= 0 and cap != to:
		t_board[cap] = ""
	if int(move["rook_from"]) >= 0:
		# I13: the rook lands where the king crossed.
		t_board[int(move["rook_from"])] = ""
		t_board[int(move["rook_to"])] = piece_color(code) + "R"
		_mark_moved(trial, int(move["rook_to"]))
	# I31/I32: record the passed square after a double step; expire otherwise.
	if piece_kind(code) == "P" and absi(to / 8 - int(move["from"]) / 8) == 2:
		trial["ep_target"] = (int(move["from"]) / 8 + to / 8) / 2 * 8 + to % 8
	else:
		trial["ep_target"] = -1
	var king: Dictionary = trial["king"]
	if piece_kind(code) == "K":
		king[piece_color(code)] = to
	trial["side"] = BLACK if str(pos["side"]) == WHITE else WHITE
	return trial


static func any_legal_move(pos: Dictionary) -> bool:
	return not all_legal_moves(pos).is_empty()


static func result(pos: Dictionary) -> String:
	# L1: the side to move is in check with no legal move -> mate (loop E1).
	# The same query with no check is stalemate (D1).
	if any_legal_move(pos):
		return ""
	if in_check(pos, str(pos["side"])):
		var winner := BLACK if str(pos["side"]) == WHITE else WHITE
		return "checkmate:%s" % winner
	return "stalemate"
