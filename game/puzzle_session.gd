class_name PuzzleSession
extends RefCounted
## CMP-puzzle-session (L2). R1 deal, R2 sequence judging, R3 Elo / recentSolved, R4 never Advice.
## Design: DIF.Y1, END.W1/L4/L5/L6 with END.P1, L-puzzle-stream K1–K4 / E1,
## F-puzzle-catalog R3–R5 / X1–X2. Persistence: PRG.M1, SEQ-puzzle-result-commit S1–S4.

## Raised for UI-puzzle-play S3 when the result commit fails (EX.save-failure).
signal save_failed

const START_FEN := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

## SCH-puzzle-catalog F1 / persistence M4 — the one served snapshot.
const SNAPSHOT_ID := "2026-10-05"

const END_W1 := "END.W1"
const END_L4 := "END.L4"
const END_L5 := "END.L5"
const END_L6 := "END.L6"

const UI_S1 := "S1"
const UI_S4 := "S4"
const UI_S5 := "S5"
const PROMOTE_ORDER := ["queen", "rook", "bishop", "knight"]

const ELO_START := 1000.0
const ELO_K := 32.0
const ELO_MATCH_RANGE := 100
const ELO_RECENT_WINDOW := 20
const ELO_BAND_WIDEN := 50

var play_ui_state := UI_S1
var selected_piece := ""
var pending_promote_from := ""
var pending_promote_to := ""
var last_reject := ""
var reject_square := ""

var rules: ChessRules
var player_elo := ELO_START
var recent_solved: Array = []

## GS.puzzleId / puzzleElo / requiredSequence / sequenceIndex / solvingSide / wrongMoveOnPuzzle.
var puzzle_id := ""
var puzzle_elo: Variant = null
var required_sequence: Array = []
var sequence_index := 0
var solving_side := ""
var wrong_move_on_puzzle := false

## SCH-puzzle-attempt F1–F5.
var attempt_start_position := ""
var attempt_any_checkmate_wins := false

## What the host catalog serves this sitting. Empty means a failed read (X2).
var catalog: Array = []

## Persistence: CTR-persist-document consumer (C3).
var store: PersistStore = null


func _init(chess_rules: ChessRules = null, persist_store: PersistStore = null) -> void:
	# A fresh CMP-chess-rules instance per session: nothing is cached or shared.
	rules = chess_rules if chess_rules != null else ChessRules.new()
	store = persist_store


## PRG.M1 — restore committed Player Elo and recentSolved on entry.
func restore(document: Dictionary) -> void:
	if document.has("player_elo"):
		player_elo = float(document["player_elo"])
	recent_solved = []
	if document.get("recent_solved") is Array:
		for item in document["recent_solved"]:
			recent_solved.append(str(item))
	recent_solved = _trim_recent(recent_solved)


func play_state() -> Dictionary:
	return {
		"puzzle_id": puzzle_id if not puzzle_id.is_empty() else "none",
		"puzzle_elo": puzzle_elo if puzzle_elo != null else "none",
		"required_sequence": required_sequence.duplicate(),
		"sequence_index": sequence_index,
		"solving_side": solving_side if not solving_side.is_empty() else "none",
		"wrong_move_on_puzzle": wrong_move_on_puzzle,
		"player_elo": player_elo,
		"recent_solved": recent_solved.duplicate(),
		"position": rules.position_field(),
		"ui_state": play_ui_state,
		"advice": "none",
	}


func has_open_puzzle() -> bool:
	return not puzzle_id.is_empty()


## R1 / DIF.Y1 / F-puzzle-catalog R3 — deal the next puzzle at the player's level.
## Returns {ok, puzzle_id, rating, reason}. X1 and X2 deal nothing.
func deal(catalog_records: Array = []) -> Dictionary:
	var records: Array = catalog_records
	if records.is_empty():
		records = catalog
	var pick: Dictionary = _select(records)
	_close_puzzle()
	if pick.is_empty():
		return {"ok": false, "reason": "no_record"}
	var moves: Array = _moves_of(pick)
	if moves.size() < 2:
		return {"ok": false, "reason": "empty_solution"}
	var fen := str(pick.get("FEN", START_FEN))
	if not rules._load_fen(fen):
		return {"ok": false, "reason": "bad_fen"}
	var first := _uci_parts(str(moves[0]))
	if not rules.try_move(first["from"], first["to"], first["promotion"]):
		return {"ok": false, "reason": "bad_first_move"}
	# PRG.M1 M4 — only snapshot 2026-10-05 PuzzleIds are ever open or saved.
	if str(pick.get("snapshot_id", SNAPSHOT_ID)) != SNAPSHOT_ID:
		return {"ok": false, "reason": "snapshot"}
	puzzle_id = str(pick.get("PuzzleId", ""))
	puzzle_elo = int(pick.get("Rating", 0))
	attempt_start_position = fen
	attempt_any_checkmate_wins = any_checkmate_wins(pick)
	required_sequence = []
	for index in range(1, moves.size()):
		required_sequence.append(_uci_parts(str(moves[index])))
	sequence_index = 0
	solving_side = str(rules.position_field()["side_to_move"])
	wrong_move_on_puzzle = false
	play_ui_state = UI_S1
	selected_piece = ""
	last_reject = ""
	return {"ok": true, "puzzle_id": puzzle_id, "rating": puzzle_elo}


## F-puzzle-catalog F13 / I3 — true iff the record is marked mateIn1.
func any_checkmate_wins(record: Dictionary) -> bool:
	return _themes_of(record).has("mateIn1")


## DIF.Y1 selection: window match, recentSolved preference, then widen / allow-recent relax.
func _select(records: Array) -> Dictionary:
	if records.is_empty():
		return {}
	var reach: int = ELO_MATCH_RANGE
	for widen_step in range(5):
		var fresh: Array = []
		var recent: Array = []
		for record in records:
			if record is Dictionary and _within(record, reach):
				if recent_solved.has(str(record.get("PuzzleId", ""))):
					recent.append(record)
				else:
					fresh.append(record)
		if not fresh.is_empty():
			return _pick_lowest(fresh)
		# After a full widen round with no fresh candidate, allow a recent solve.
		if widen_step >= 1 and not recent.is_empty():
			return _pick_lowest(recent)
		reach += ELO_BAND_WIDEN
	return _pick_lowest(records.filter(func(record: Variant) -> bool: return record is Dictionary))


func _within(record: Dictionary, reach: int) -> bool:
	return absi(int(record.get("Rating", 0)) - int(round(player_elo))) <= reach


func _pick_lowest(records: Array) -> Dictionary:
	var best: Dictionary = {}
	for record in records:
		if not (record is Dictionary):
			continue
		if best.is_empty() or int(record["Rating"]) < int(best["Rating"]):
			best = record
	return best


## R2 / L-puzzle-stream K2 — accept a Solving-side move; returns the judging result.
func place(from_square: String, to_square: String, promotion: String = "") -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false, "illegal": true, "event": "puzzle.none"}
	last_reject = ""
	reject_square = ""
	if (
		not selected_piece.is_empty()
		and from_square == selected_piece
		and rules.piece_on(to_square).is_empty()
		and not rules.legal_targets(selected_piece).has(to_square)
	):
		selected_piece = ""
		return {"ok": true, "deselect": true, "event": "puzzle.deselect"}
	if promotion.is_empty() and rules._needs_promotion(from_square, to_square):
		selected_piece = from_square
		pending_promote_from = from_square
		pending_promote_to = to_square
		play_ui_state = UI_S4
		return {
			"ok": true,
			"promote": true,
			"event": "puzzle.promote",
			"pending_from": from_square,
			"pending_to": to_square,
		}
	if not rules.try_move(from_square, to_square, promotion):
		selected_piece = from_square
		last_reject = "illegal"
		reject_square = to_square
		play_ui_state = UI_S5
		return {"ok": false, "illegal": true, "reject_square": to_square, "event": "puzzle.move"}
	pending_promote_from = ""
	pending_promote_to = ""
	play_ui_state = UI_S1
	return _judge({"from": from_square, "to": to_square, "promotion": promotion})


## C6 — commit the chosen promotion kind and judge the place.
func commit_promotion(kind: String) -> Dictionary:
	if play_ui_state != UI_S4 or not PROMOTE_ORDER.has(kind):
		return {"ok": false}
	var from_sq := pending_promote_from
	var to_sq := pending_promote_to
	play_ui_state = UI_S1
	return place(from_sq, to_sq, kind)


func _judge(move: Dictionary) -> Dictionary:
	var result := {"ok": true, "illegal": false, "event": "puzzle.move", "outcome": "progress"}
	if not _matches_expected(move):
		_wrong_move()
		result["outcome"] = "wrong"
		result["wrong_move_seen"] = true
		return result
	sequence_index += 1
	if _sequence_complete():
		var ending := END_W1 if not wrong_move_on_puzzle else END_L4
		result["outcome"] = "outcome"
		result["end_reason"] = ending
		result["elo"] = _apply_outcome(ending)
		return result
	# Even step: the required reply plays at once for the other side.
	var reply: Dictionary = required_sequence[sequence_index]
	if not rules.try_move(str(reply["from"]), str(reply["to"]), str(reply["promotion"])):
		result["outcome"] = "invalid_record"
		return result
	sequence_index += 1
	if _sequence_complete():
		var ending := END_W1 if not wrong_move_on_puzzle else END_L4
		result["outcome"] = "outcome"
		result["end_reason"] = ending
		result["elo"] = _apply_outcome(ending)
		result["advance"] = sequence_index
		return result
	result["advance"] = sequence_index
	result["reply_applied"] = true
	result["reply"] = reply
	return result


## F-puzzle-catalog R4–R5 — the mate-in-one step accepts any legal checkmating move.
func _matches_expected(move: Dictionary) -> bool:
	if sequence_index >= required_sequence.size():
		return false
	if sequence_index == 0 and attempt_any_checkmate_wins:
		var defender := _opponent(solving_side)
		return rules.in_check(defender) and not rules.has_legal_move(defender)
	var expected: Dictionary = required_sequence[sequence_index]
	if str(expected["from"]) != str(move["from"]) or str(expected["to"]) != str(move["to"]):
		return false
	# A promotion kind is only required when the record names one.
	var wanted := str(expected["promotion"])
	return wanted.is_empty() or wanted == str(move["promotion"])


## L-puzzle-stream K2 / SCH-puzzle-attempt F4 — reset to the start; no deal.
func _wrong_move() -> void:
	wrong_move_on_puzzle = true
	rules._load_fen(attempt_start_position)
	sequence_index = 0
	selected_piece = ""


func _sequence_complete() -> bool:
	return sequence_index >= required_sequence.size()


## END.L4 — the required sequence completed after a Wrong move on that puzzle.
func finish_after_wrong_move() -> Dictionary:
	if not has_open_puzzle() or not wrong_move_on_puzzle:
		return {"ok": false}
	return {"ok": true, "end_reason": END_L4, "elo": _apply_outcome(END_L4)}


## L-puzzle-stream K2 — END.L5 reveal the solution (failed, S = 0), no next deal here.
func reveal() -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false}
	return {"ok": true, "end_reason": END_L5, "elo": _apply_outcome(END_L5)}


## L-puzzle-stream K2 — END.L6 abandon this puzzle (failed, S = 0).
func abandon() -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false}
	var ending: Dictionary = {"ok": true, "end_reason": END_L6, "elo": _apply_outcome(END_L6)}
	_close_puzzle()
	return ending


## L-puzzle-stream K3 — an STR outcome is followed by the next deal at the new Elo.
func advance() -> Dictionary:
	if has_open_puzzle():
		return {"ok": false, "reason": "puzzle_open"}
	return deal()


## L-puzzle-stream K4 / E1 — leave; Elo kept; an open puzzle is not scored (PRG.P1).
func leave() -> Dictionary:
	_close_puzzle()
	return {"ok": true, "event": "puzzle.leave", "player_elo": player_elo}


## DIF.Y1 / PRG.A1 / PRG.M1 — one Elo update per outcome, then commit.
func _apply_outcome(ending: String) -> Dictionary:
	var score := 1.0 if ending == END_W1 else 0.0
	var expected := 1.0 / (1.0 + pow(10.0, (float(puzzle_elo) - player_elo) / 400.0))
	player_elo += ELO_K * (score - expected)
	if ending == END_W1 and not puzzle_id.is_empty():
		recent_solved.append(puzzle_id)
		recent_solved = _trim_recent(recent_solved)
	var committed := _commit()
	return {"player_elo": player_elo, "score": score, "committed": committed}


## SEQ-puzzle-result-commit S1–S4 / B1–B2 — whole-document commit; prior kept on failure.
func _commit() -> bool:
	if store == null:
		return false
	var doc := store.read_committed()
	doc["player_elo"] = player_elo
	doc["recent_solved"] = recent_solved.duplicate()
	var ok := store.commit(doc)
	if not ok:
		save_failed.emit()
	return ok


func _close_puzzle() -> void:
	puzzle_id = ""
	puzzle_elo = null
	required_sequence = []
	sequence_index = 0
	solving_side = ""
	wrong_move_on_puzzle = false
	selected_piece = ""
	play_ui_state = UI_S1


func _trim_recent(ids: Array) -> Array:
	if ids.size() > ELO_RECENT_WINDOW:
		return ids.slice(ids.size() - ELO_RECENT_WINDOW, ids.size())
	return ids


func _moves_of(record: Dictionary) -> Array:
	var raw: Variant = record.get("Moves", [])
	if raw is Array:
		return (raw as Array).duplicate()
	if raw is String:
		return str(raw).split(" ", false)
	return []


func _themes_of(record: Dictionary) -> Array:
	var raw: Variant = record.get("Themes", [])
	if raw is Array:
		return raw
	if raw is String:
		return str(raw).split(" ", false)
	return []


func _uci_parts(uci: String) -> Dictionary:
	return {
		"from": uci.substr(0, 2),
		"to": uci.substr(2, 2),
		"promotion": uci.substr(4, 1),
	}


func _opponent(side: String) -> String:
	return ChessRules.SIDE_BLACK if side == ChessRules.SIDE_WHITE else ChessRules.SIDE_WHITE
