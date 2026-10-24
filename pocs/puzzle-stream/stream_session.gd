class_name DemoStreamSession
extends RefCounted
## CMP-puzzle-session for demo #335: owns the open puzzle's game-state fields,
## judges a Solving-side move against GS.requiredSequence, resets the puzzle on
## a Wrong move, and scores the four puzzle endings through DemoProgression
## (CTR-puzzle-progress O1). Never draws; main.gd reads the fields it exposes.
##
## Spec sources: L-puzzle-stream K1-K4 (steps), END.W1/L4/L5/L6 and END.P1
## (end-conditions), F-puzzle-catalog R3/R4/R5 and I2/I3 (deal + sequence),
## GS.puzzleId / GS.puzzleElo / GS.requiredSequence / GS.sequenceIndex /
## GS.solvingSide / GS.wrongMoveOnPuzzle / GS.playerElo / GS.recentSolved.

var player_elo := 0.0
var recent_solved: Array = []

var puzzle_id := ""
var puzzle_elo := 0.0
var sequence: Array = []     # GS.requiredSequence: UCI strings, length >= 1
var index := 0               # GS.sequenceIndex
var solving_side := ""       # GS.solvingSide on deal
var mate_in_one := false     # F-puzzle-catalog R5 (F13 / themes)
var wrong_move := false      # GS.wrongMoveOnPuzzle
var open := false
var ended := false
var pos: Dictionary = {}       # GS.position, current
var start_pos: Dictionary = {}  # the presented position a Wrong move resets to


## K1 / PRG: entering the stream binds the persistent Player Elo and history and
## clears any open puzzle.
func enter(first_elo: float, history: Array) -> void:
	player_elo = first_elo
	recent_solved = history.duplicate()
	_clear_puzzle()


## One deal: build GS.position from the served record's FEN, apply the first
## (opponent) move, then present that position (R3). Returns false when the
## record cannot be dealt (X1: no required sequence; bad FEN or move).
func open_puzzle(record: Dictionary) -> bool:
	if record.is_empty():
		return false
	var moves: Array = record.get("moves", [])
	if moves.size() < 2:
		_clear_puzzle()  # X1: moves after the first would be empty -> not dealt
		return false
	var board := DemoFenCodec.to_position(str(record["fen"]))
	if board.is_empty():
		_clear_puzzle()
		return false
	DemoChessRules.init_king(board)
	var first := _find_legal(board, str(moves[0]))
	if first.is_empty():
		_clear_puzzle()
		return false
	var presented := DemoChessRules.apply(board, first)
	DemoChessRules.init_king(presented)
	puzzle_id = str(record["puzzle_id"])
	puzzle_elo = float(record["rating"])
	sequence = moves.slice(1)
	index = 0
	mate_in_one = bool(record.get("any_checkmate_wins", false))
	wrong_move = false
	ended = false
	open = true
	pos = presented
	start_pos = DemoChessRules.duplicate_position(presented)
	solving_side = str(presented["side"])
	return true


func is_player_turn() -> bool:
	return open and not ended and str(pos["side"]) == solving_side


func legal_from(from_index: int) -> Array:
	if not is_player_turn():
		return []
	return DemoChessRules.legal_moves(pos, from_index)


## K2: judge one legal Solving-side move. Returns {outcome, replies, wrong}:
##   outcome "W1"/"L4" when the Required sequence is completed, else "";
##   replies: the required replies the game plays at once;
##   wrong: true when the move missed the next step (the puzzle reset).
func try_move(move: Dictionary) -> Dictionary:
	var result := {"outcome": "", "replies": [], "wrong": false}
	if not is_player_turn():
		return result
	var expected := str(sequence[index]) if index < sequence.size() else ""
	var matched := uci(move) == expected
	if not matched and mate_in_one and _is_checkmate(pos, move):
		matched = true  # R5: any legal checkmating move matches the mate-in-one step
	if not matched:
		# K2 / end-conditions: a Wrong move returns the puzzle to its start,
		# blocks W1, and does not deal the next puzzle.
		wrong_move = true
		index = 0
		pos = DemoChessRules.duplicate_position(start_pos)
		result["wrong"] = true
		return result
	pos = DemoChessRules.apply(pos, move)
	index += 1
	# K2 / I2: when the sequence then has a required reply, the game plays it at
	# once for the other side, and the player moves again.
	while index < sequence.size() and index % 2 == 1:
		var reply := _find_legal(pos, str(sequence[index]))
		if reply.is_empty():
			break
		pos = DemoChessRules.apply(pos, reply)
		result["replies"].append(reply)
		index += 1
	if index >= sequence.size():
		ended = true
		result["outcome"] = "L4" if wrong_move else "W1"
	return result


## END.L5: revealing the solution scores a loss without a move.
func reveal() -> String:
	ended = true
	return "L5"


## END.L6: abandoning the puzzle scores a loss (not the same as leaving).
func abandon() -> String:
	ended = true
	return "L6"


## K4: leaving the stream keeps Player Elo and clears the open puzzle unscored.
func leave() -> void:
	_clear_puzzle()


## DIF.Y1 / CTR-puzzle-progress O1: the session commits the Domain-returned
## values and never computes them itself.
func score(outcome: String) -> Dictionary:
	var result := DemoProgression.score(
		player_elo, puzzle_elo, outcome, puzzle_id, recent_solved, _cfg())
	player_elo = float(result["playerElo"])
	recent_solved = result["recentSolved"]
	return result


## The expected UCI at the current index (the next step the player must make).
func next_step() -> String:
	if index < sequence.size():
		return str(sequence[index])
	return ""


static func uci(move: Dictionary) -> String:
	var text := DemoChessRules.square_name(int(move["from"])) \
		+ DemoChessRules.square_name(int(move["to"]))
	var promo := str(move.get("promo", ""))
	if promo != "":
		text += promo
	return text


func _is_checkmate(board: Dictionary, move: Dictionary) -> bool:
	var after := DemoChessRules.apply(board, move)
	var opponent := str(after["side"])
	return DemoChessRules.in_check(after, opponent) \
		and not DemoChessRules.any_legal_move(after)


## Resolve one UCI string to a legal move of the side to move in `board`.
func _find_legal(board: Dictionary, text: String) -> Dictionary:
	if text.length() < 4:
		return {}
	var from := DemoChessRules.square_index(text.substr(0, 2))
	var to := DemoChessRules.square_index(text.substr(2, 2))
	var promo := text.substr(4, 1) if text.length() > 4 else ""
	for move in DemoChessRules.legal_moves(board, from):
		if int(move["to"]) != to:
			continue
		if promo != "" and str(move["promo"]) != promo:
			continue
		return move
	return {}


func _clear_puzzle() -> void:
	puzzle_id = ""
	puzzle_elo = 0.0
	sequence = []
	index = 0
	solving_side = ""
	mate_in_one = false
	wrong_move = false
	open = false
	ended = false
	pos = {}
	start_pos = {}


func _cfg() -> Dictionary:
	# CFG defaults owned by difficulty.md / configuration.md (single source in
	# main.gd; repeated here so the session is scoreable on its own).
	return {
		"elo_k": 20.0,
		"elo_recent_window": 20,
	}
