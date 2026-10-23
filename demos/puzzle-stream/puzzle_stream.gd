class_name DemoPuzzleStream
extends RefCounted
## Puzzle-stream rules for demo #335. Spec source: L-puzzle-stream K1-K4 / E1
## (`specs/design/loops/puzzle-stream.md`), DIF.Y1 / DIF.C1 (`difficulty.md`),
## END.W1 / L4 / L5 / L6 (`end-conditions/conditions.md`), F-puzzle-catalog
## R1-R5 / I1-I3 / X1-X2, PRG.A1 / P1 / M1 / P3, and the `GS.puzzle*` fields.
##
## The demo models only what the demo question needs: the deal at the player's
## level, sequence judging on one Solving side, a Wrong move that resets the
## open puzzle without dealing, and the gentle Elo drift. The catalog is a small
## recorded-format fixture slice (epic #35 Notes); ADR-0008 keeps the real
## snapshot off the client either way.

const SNAPSHOT_ID := "2026-10-05"

## CFG.ELO_START / CFG.ELO_K / CFG.ELO_MATCH_RANGE / CFG.ELO_RECENT_WINDOW /
## CFG.ELO_BAND_WIDEN, at their design defaults (`configuration.md`).
const ELO_START := 1000.0
const ELO_K := 20.0
const ELO_MATCH_RANGE := 100
const ELO_RECENT_WINDOW := 20
const ELO_BAND_WIDEN := 50

const END_W1 := "END.W1"
const END_L4 := "END.L4"
const END_L5 := "END.L5"
const END_L6 := "END.L6"

## END.P1: the score each ending carries into DIF.Y1 (W1 win, the rest loss).
const SCORE_BY_ENDING := {
	END_W1: 1.0,
	END_L4: 0.0,
	END_L5: 0.0,
	END_L6: 0.0,
}

## UI-puzzle-play R2 result cue per ending (Resolvable in `screens/puzzle-play.md`).
const CUE_BY_ENDING := {
	END_W1: "cue_solved",
	END_L4: "cue_failed",
	END_L5: "cue_failed",
	END_L6: "cue_abandon",
}

## F-puzzle-catalog F13 - true iff Themes carries mateIn1 (R5).
const MATE_IN_ONE_THEME := "mateIn1"

## PRG.A1 / PRG.P1: Player Elo, persisted; first-time value CFG.ELO_START.
var player_elo := ELO_START
## PRG.P3 / SCH-persist-doc F4: solved PuzzleIds, newest last, capped.
var recent_solved: Array = []

## GS.puzzleId / GS.puzzleElo / GS.requiredSequence / GS.sequenceIndex /
## GS.solvingSide / GS.wrongMoveOnPuzzle for the open puzzle.
var puzzle_id := ""
var puzzle_elo := 0
var required_sequence: Array = []
var sequence_index := 0
var solving_side := ""
var wrong_move_on_puzzle := false
## GS.position / GS.sideToMove, as the view reads them.
var pos: Dictionary = {}

## The presented position after the deal's opponent move: a Wrong move returns here
## (L-puzzle-stream K2), not to the record's pre-puzzle FEN.
var start_pos: Dictionary = {}
var first_move: Dictionary = {}
var any_checkmate_wins := false

## The ending and R2 cue of the last settled puzzle (cleared by the next deal).
var ending := ""
var cue := ""

## SCH-puzzle-catalog F1-F13 slice the demo deals from.
var catalog: Array = []
var rng := RandomNumberGenerator.new()


func _init(records: Array = []) -> void:
	catalog = records
	rng.randomize()


## True while a puzzle is open (GS.puzzleId set, sequence not settled).
func has_open_puzzle() -> bool:
	return puzzle_id != "" and ending == ""


## F-puzzle-catalog R3 - PGN-style FEN to the demo's position dictionary.
static func position_from_fen(fen: String) -> Dictionary:
	var parts := fen.strip_edges().split(" ", false)
	if parts.size() < 4:
		return {}
	var board := PackedStringArray()
	board.resize(64)
	var rank := 7
	var file := 0
	for ch in parts[0]:
		if ch == "/":
			rank -= 1
			file = 0
		elif ch.is_valid_int():
			file += ch.to_int()
		else:
			if rank < 0 or rank > 7 or file < 0 or file > 7:
				return {}
			var color := "w" if ch == ch.to_upper() else "b"
			board[rank * 8 + file] = color + ch.to_upper()
			file += 1
	var moved := PackedByteArray()
	moved.resize(64)
	# Castling rights are the only thing `moved` decides; a right the FEN does not
	# grant means that king or corner rook has already moved (E-pieces.I16-I17).
	var castling: String = parts[2]
	if not castling.contains("K"):
		moved[DemoChessRules.square_index("e1")] = 1
		moved[DemoChessRules.square_index("h1")] = 1
	if not castling.contains("Q"):
		moved[DemoChessRules.square_index("e1")] = 1
		moved[DemoChessRules.square_index("a1")] = 1
	if not castling.contains("k"):
		moved[DemoChessRules.square_index("e8")] = 1
		moved[DemoChessRules.square_index("h8")] = 1
	if not castling.contains("q"):
		moved[DemoChessRules.square_index("e8")] = 1
		moved[DemoChessRules.square_index("a8")] = 1
	var ep := -1
	if parts[3] != "-":
		ep = DemoChessRules.square_index(parts[3])
	var pos_out := {
		"board": board,
		"moved": moved,
		"ep_target": ep,
		"side": "w" if parts[1] == "w" else "b",
		"king": {},
	}
	DemoChessRules.init_king(pos_out)
	return pos_out


## K1 / DIF.Y1 / F-puzzle-catalog R3 - deal the next puzzle at the player's level.
## Returns {ok, puzzle_id, rating, reason}. X1 and X2 deal nothing.
func deal() -> Dictionary:
	_close_puzzle()
	var record := _select()
	if record.is_empty():
		return {"ok": false, "reason": "no_record"}
	var moved := _opening_of(record)
	if moved.has("reason"):
		return {"ok": false, "reason": moved["reason"]}
	var presented: Dictionary = moved["position"]
	puzzle_id = str(record.get("puzzle_id", ""))
	puzzle_elo = int(record.get("rating", 0))
	any_checkmate_wins = bool(record.get("any_checkmate_wins", false))
	first_move = moved["move"]
	start_pos = DemoChessRules.duplicate_position(presented)
	pos = presented
	# Each later move is checked against the position the records put it in, so a
	# record with a bad entry is refused at deal instead of mid-puzzle.
	required_sequence = []
	var rolling: Dictionary = DemoChessRules.duplicate_position(presented)
	for index in range(1, (record.get("moves", []) as Array).size()):
		var step := _move_of(rolling, str(record["moves"][index]))
		if step.is_empty():
			_close_puzzle()
			return {"ok": false, "reason": "bad_move"}
		required_sequence.append(step)
		rolling = DemoChessRules.apply(rolling, step)
	sequence_index = 0
	solving_side = str(pos["side"])
	wrong_move_on_puzzle = false
	ending = ""
	cue = ""
	return {"ok": true, "puzzle_id": puzzle_id, "rating": puzzle_elo}


## The presented position after the record's opponent move, or {reason} when the
## record cannot be played (F-puzzle-catalog X1, PRG.M1 M4, bad FEN or first move).
func _opening_of(record: Dictionary) -> Dictionary:
	var moves: Array = record.get("moves", [])
	if moves.size() < 2:
		return {"reason": "empty_solution"}
	if str(record.get("snapshot_id", SNAPSHOT_ID)) != SNAPSHOT_ID:
		return {"reason": "snapshot"}
	var opened := position_from_fen(str(record.get("fen", "")))
	if opened.is_empty():
		return {"reason": "bad_fen"}
	# F-puzzle-catalog R3: the first move is the opponent's; the player then solves.
	var mover := _move_of(opened, str(moves[0]))
	if mover.is_empty():
		return {"reason": "bad_first_move"}
	var presented := DemoChessRules.apply(opened, mover)
	if presented["board"] == opened["board"]:
		return {"reason": "bad_first_move"}
	return {"position": presented, "move": mover}


## DIF.Y1 - within +-CFG.ELO_MATCH_RANGE of playerElo, preferring puzzles not in
## GS.recentSolved; then widen by CFG.ELO_BAND_WIDEN and/or allow a recent one.
## GS.Q1 allows any candidate in that set, so the demo picks one at random.
func _select() -> Dictionary:
	var reach: float = ELO_MATCH_RANGE
	for widen_step in range(5):
		var fresh: Array = []
		var recent: Array = []
		for record in catalog:
			if not (record is Dictionary) or not _usable(record):
				continue
			if absf(float(record.get("rating", 0)) - player_elo) > reach:
				continue
			if recent_solved.has(str(record.get("puzzle_id", ""))):
				recent.append(record)
			else:
				fresh.append(record)
		if not fresh.is_empty():
			return fresh[rng.randi_range(0, fresh.size() - 1)]
		# A full widen round with no fresh candidate may allow a recent solve.
		if widen_step >= 1 and not recent.is_empty():
			return recent[rng.randi_range(0, recent.size() - 1)]
		reach += ELO_BAND_WIDEN
	var all_usable: Array = catalog.filter(func(r: Variant) -> bool: return _usable(r))
	if all_usable.is_empty():
		return {}
	return all_usable[rng.randi_range(0, all_usable.size() - 1)]


## F-puzzle-catalog R3 / X1 - a deal needs a FEN and at least the two moves.
static func _usable(record: Variant) -> bool:
	if not (record is Dictionary):
		return false
	return str(record.get("fen", "")) != "" and (record.get("moves", []) as Array).size() >= 2


## One UCI move of a record as the demo's move dictionary, matched against the
## legal moves of `position` so a bad record can never move anything.
static func _move_of(position: Dictionary, uci: String) -> Dictionary:
	if uci.length() < 4:
		return {}
	var from_index := DemoChessRules.square_index(uci.substr(0, 2))
	var to_index := DemoChessRules.square_index(uci.substr(2, 2))
	var promo := uci.substr(4, 1).to_lower()
	if from_index < 0 or to_index < 0:
		return {}
	for move in DemoChessRules.legal_moves(position, from_index):
		if int(move["to"]) != to_index:
			continue
		if promo.is_empty() or str(move["promo"]) == promo:
			return move
	return {}


## UI-puzzle-play C1 / C2 - a Solving-side place. Returns
## {ok, illegal, promote, outcome, ending, cue, wrong_move_seen, reply, advance}.
## `outcome` is "progress", "wrong", or "outcome" (an ending fired).
func play(from_index: int, to_index: int, promo: String = "") -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false, "event": "puzzle.none"}
	var move := _accepted_move(from_index, to_index, promo)
	if move.is_empty():
		return _refused(to_index)
	if promo.is_empty() and _promotion_wanted(from_index, to_index):
		# I33 / EX.promote S4: the type is committed before the move is judged.
		return {"ok": true, "promote": true, "from": from_index, "to": to_index}
	return _play_accepted(move)


## The move a place names, or {} when the place is refused.
func _accepted_move(from_index: int, to_index: int, promo: String) -> Dictionary:
	var live: PackedStringArray = pos["board"]
	if from_index < 0 or from_index > 63 or to_index < 0 or to_index > 63:
		return {}
	# EX.rejected: a piece of the other side or no piece at all is refused.
	if live[from_index] == "" or DemoChessRules.piece_color(live[from_index]) != solving_side:
		return {}
	return _legal_place(from_index, to_index, promo)


## Judges an accepted move: judged Wrong, or lands and runs the required reply.
func _play_accepted(move: Dictionary) -> Dictionary:
	if not _matches_expected(move):
		return _wrong_move()
	pos = DemoChessRules.apply(pos, move)
	sequence_index += 1
	var result := {"ok": true, "illegal": false, "event": "puzzle.move", "outcome": "progress"}
	if _sequence_complete():
		return _settle(result)
	# K2: the required reply plays at once for the other side, then the player moves again.
	var reply: Dictionary = required_sequence[sequence_index]
	pos = DemoChessRules.apply(pos, reply)
	sequence_index += 1
	result["reply"] = reply
	if _sequence_complete():
		var settled := _settle(result)
		settled["reply"] = reply
		return settled
	result["advance"] = sequence_index
	return result


## The legal move the place names, or {} when the piece rules refuse it.
func _legal_place(from_index: int, to_index: int, promo: String) -> Dictionary:
	for move in DemoChessRules.legal_moves(pos, from_index):
		if int(move["to"]) != to_index:
			continue
		if promo.is_empty() or str(move["promo"]) == promo:
			return move
	return {}


## I33 - a pawn reaching the last rank asks for its type before the move lands.
func _promotion_wanted(from_index: int, to_index: int) -> bool:
	var board: PackedStringArray = pos["board"]
	return (
		DemoChessRules.piece_kind(board[from_index]) == "P"
		and absi(to_index / 8 - from_index / 8) == 1
		and (to_index / 8 == 7 or to_index / 8 == 0)
	)


## EX.rejected - the piece rules refuse the place; S5 flashes, not a Wrong move.
func _refused(to_index: int) -> Dictionary:
	return {"ok": false, "illegal": true, "reject_square": to_index, "event": "puzzle.move"}


## F-puzzle-catalog R4-R5 - the mate-in-one step accepts any checkmating move.
func _matches_expected(move: Dictionary) -> bool:
	if sequence_index >= required_sequence.size():
		return false
	if sequence_index == 0 and any_checkmate_wins:
		var after := DemoChessRules.apply(pos, move)
		var defender := str(after["side"])
		return DemoChessRules.in_check(after, defender) and not DemoChessRules.any_legal_move(after)
	var expected: Dictionary = required_sequence[sequence_index]
	if int(expected["from"]) != int(move["from"]) or int(expected["to"]) != int(move["to"]):
		return false
	var wanted := str(expected["promo"])
	return wanted.is_empty() or wanted == str(move["promo"])


## K2 - a Wrong move returns the puzzle to its start, blocks W1, and deals nothing.
func _wrong_move() -> Dictionary:
	wrong_move_on_puzzle = true
	pos = DemoChessRules.duplicate_position(start_pos)
	sequence_index = 0
	cue = "cue_wrong"
	return {
		"ok": true,
		"illegal": false,
		"event": "puzzle.move",
		"outcome": "wrong",
		"wrong_move_seen": true,
		"cue": cue,
	}


func _sequence_complete() -> bool:
	return sequence_index >= required_sequence.size()


## K2 / K3 - END.W1 when no Wrong move was made, else END.L4; then the Elo update.
func _settle(result: Dictionary) -> Dictionary:
	var settled_ending := END_W1 if not wrong_move_on_puzzle else END_L4
	_apply_ending(settled_ending)
	result["outcome"] = "outcome"
	result["ending"] = settled_ending
	result["cue"] = cue
	result["elo"] = player_elo
	return result


## END.L5 - the player reveals the solution: failed, S = 0.
func reveal() -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false}
	_apply_ending(END_L5)
	return {"ok": true, "ending": END_L5, "cue": cue, "elo": player_elo}


## END.L6 - the player abandons the puzzle: failed, S = 0.
func abandon() -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false}
	_apply_ending(END_L6)
	return {"ok": true, "ending": END_L6, "cue": cue, "elo": player_elo}


## K4 / E1 / NAV.T9 - leave the stream. The open puzzle is not scored and the
## Elo stays as it is (PRG.P1, END.L6 is not triggered).
func leave() -> Dictionary:
	var kept_elo := player_elo
	_close_puzzle()
	return {"ok": true, "elo": kept_elo}


## DIF.Y1 - E = 1 / (1 + 10^((puzzleElo - playerElo) / 400)), then
## playerElo <- playerElo + CFG.ELO_K * (S - E). DIF.C1: nothing else sets it.
func _apply_ending(settled_ending: String) -> void:
	var score: float = float(SCORE_BY_ENDING[settled_ending])
	var expected := 1.0 / (1.0 + pow(10.0, (float(puzzle_elo) - player_elo) / 400.0))
	player_elo += ELO_K * (score - expected)
	# F-puzzle-catalog I3 / PRG.M1: only a solve joins GS.recentSolved.
	if settled_ending == END_W1 and not puzzle_id.is_empty():
		recent_solved.append(puzzle_id)
		_trim_recent()
	ending = settled_ending
	cue = str(CUE_BY_ENDING[settled_ending])


## PRG.M1 - GS.recentSolved is capped at CFG.ELO_RECENT_WINDOW puzzles.
func _trim_recent() -> void:
	while recent_solved.size() > ELO_RECENT_WINDOW:
		recent_solved.pop_front()


## GS.puzzleId / puzzleElo / requiredSequence / sequenceIndex / solvingSide /
## wrongMoveOnPuzzle clear together; Player Elo and recentSolved never do.
func _close_puzzle() -> void:
	puzzle_id = ""
	puzzle_elo = 0
	required_sequence = []
	sequence_index = 0
	solving_side = ""
	wrong_move_on_puzzle = false
	pos = {}
	start_pos = {}
	first_move = {}
	any_checkmate_wins = false
	ending = ""
	cue = ""


## SCH-persist-doc: Player Elo, Last mode, and recentSolved are what a stream carries
## across a session (PRG.A1, P2, P3).
func save_document() -> Dictionary:
	return {
		"player_elo": player_elo,
		"last_mode": "puzzle",
		"recent_solved": recent_solved.duplicate(),
	}


## PRG.M1 - restore the committed values; a missing or bad document keeps defaults.
func restore(document: Dictionary) -> void:
	if document.has("player_elo"):
		player_elo = float(document.get("player_elo", ELO_START))
	if document.has("recent_solved"):
		for value in document.get("recent_solved", []):
			recent_solved.append(str(value))
		_trim_recent()


## F-puzzle-catalog I1 - the DIF.Y1 candidate set for the current Elo, for evidence.
func candidate_ids() -> Array:
	var out: Array = []
	for record in catalog:
		if _usable(record) and absf(float(record.get("rating", 0)) - player_elo) <= ELO_MATCH_RANGE:
			if not recent_solved.has(str(record.get("puzzle_id", ""))):
				out.append(str(record.get("puzzle_id", "")))
	return out
