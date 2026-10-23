class_name PuzzleSession
extends RefCounted
## CMP-puzzle-session (L2). R1 deal, R2 sequence judging, R3 Elo / recentSolved, R4 never Advice.
## Design: DIF.Y1, END.W1/L4/L5/L6 with END.P1, L-puzzle-stream K1–K4 / E1,
## F-puzzle-catalog R3–R5 / X1–X2. Persistence: PRG.M1, SEQ-puzzle-result-commit S1–S4.

## Raised for UI-puzzle-play S3 when the result commit fails (EX.save-failure).
signal save_failed
## R1 — a deal is due but this session was handed no record. The caller reads one
## through CTR-puzzle-catalog-read (CatalogDealClient) and calls `deal([record])`.
signal deal_due

const START_FEN := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

## SCH-puzzle-catalog F1 / persistence M4 — the one served snapshot.
const SNAPSHOT_ID := "2026-10-05"

## SCH-puzzle-catalog F1–F13 — the record shape CTR-puzzle-catalog-read delivers.
const FIELD_SNAPSHOT_ID := "snapshot_id"
const FIELD_PUZZLE_ID := "puzzle_id"
const FIELD_FEN := "fen"
const FIELD_MOVES := "moves"
const FIELD_RATING := "rating"
const FIELD_THEMES := "themes"

const END_W1 := "END.W1"
const END_L4 := "END.L4"
const END_L5 := "END.L5"
const END_L6 := "END.L6"

## SCH-puzzle-attempt F5 outcome for an ending (none until an ending fires).
const OUTCOME_BY_ENDING := {
	END_W1: "solved",
	END_L4: "failed_wrong",
	END_L5: "failed_reveal",
	END_L6: "abandoned",
}

## UI-puzzle-play R2 result cue for an ending (before the next deal).
const CUE_BY_ENDING := {
	END_W1: "cue_solved",
	END_L4: "cue_failed",
	END_L5: "cue_failed",
	END_L6: "cue_abandon",
}

const UI_S1 := "S1"
const UI_S2 := "S2"
const UI_S3 := "S3"
const UI_S4 := "S4"
const UI_S5 := "S5"
const PROMOTE_ORDER := ["queen", "rook", "bishop", "knight"]

## EX.confirm (UI-puzzle-play S2) — the stream verb waiting on Confirm / Cancel.
const CONFIRM_REVEAL := "reveal_confirm"
const CONFIRM_ABANDON := "abandon_confirm"
const CONFIRM_LEAVE := "leave_confirm"

const ELO_START := 1000.0
## S1 / T3 elo_k — mirrors CFG.ELO_K (design default 20, range 10–40).
const ELO_K := 20.0
const ELO_MATCH_RANGE := 100
const ELO_RECENT_WINDOW := 20
const ELO_BAND_WIDEN := 50

## Board gestures are live in S1, S5 (refusal flash) and S3 (save failure); S2/S4 wait.
const GESTURE_STATES := [UI_S1, UI_S3, UI_S5]

var play_ui_state := UI_S1
var selected_piece := ""
var pending_promote_from := ""
var pending_promote_to := ""
var last_reject := ""
var reject_square := ""
var confirm_kind := ""

var rules: ChessRules
## T3 `elo_k` (CFG.ELO_K, default 20, range 10–40) as read at construction; Elo updates
## use this value, so the tunable has one reader rather than a second local constant.
var elo_k := ELO_K
var player_elo := ELO_START
var recent_solved: Array = []
## GS.lastMode — committed by CMP-session-router (R3); kept here so a result commit is whole.
var last_mode := PersistStore.MODE_NONE

## GS.puzzleId / puzzleElo / requiredSequence / sequenceIndex / solvingSide / wrongMoveOnPuzzle.
var puzzle_id := ""
var puzzle_elo: Variant = null
var required_sequence: Array = []
var sequence_index := 0
var solving_side := ""
var wrong_move_on_puzzle := false

## SCH-puzzle-attempt F1–F5.
## The deal's FEN before the opponent move: the puzzle's true start (L-puzzle-stream K2).
var attempt_record_fen := ""
## The opponent move the deal applies, kept so a Wrong move can restore the presented board.
var attempt_first_move: Dictionary = {}
var attempt_any_checkmate_wins := false
## SCH-puzzle-attempt F3 — the attempt's moves so far, kept for F5 / replay.
var played_prefix: Array = []

## The ending this attempt reached, cleared by the next deal (F5).
var outcome := ""

## The most recent settlement: {end_reason, cue, score, player_elo, committed, solved}.
var last_result: Dictionary = {}

## Persistence: CTR-persist-document consumer (C3).
var store: PersistStore = null


func _init(chess_rules: ChessRules = null, persist_store: PersistStore = null) -> void:
	# A fresh CMP-chess-rules instance per session: nothing is cached or shared.
	rules = chess_rules if chess_rules != null else ChessRules.new()
	store = persist_store


## PRG.M1 — restore committed Player Elo, recentSolved and Last mode on entry.
func restore(document: Dictionary) -> void:
	if document.has("player_elo"):
		player_elo = float(document["player_elo"])
	if document.has("last_mode"):
		last_mode = str(document["last_mode"])
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
		"last_mode": last_mode,
		"position": rules.position_field(),
		"ui_state": play_ui_state,
		"confirm_kind": confirm_kind,
		"outcome": outcome if not outcome.is_empty() else "none",
		"played_prefix": played_prefix.duplicate(),
		"last_result": last_result.duplicate(),
		"advice": "none",
		"advice_best_move": null,
		"advice_eval": null,
	}


func has_open_puzzle() -> bool:
	return not puzzle_id.is_empty()


## UI-puzzle-play S1 / S2 / S4 gate the board; S3 and S5 keep it usable.
func gestures_available() -> bool:
	return has_open_puzzle() and GESTURE_STATES.has(play_ui_state)


## R1 / DIF.Y1 / F-puzzle-catalog R3 — deal the next puzzle at the player's level.
## The record is the one CTR-puzzle-catalog-read returned; the service ran DIF.Y1.
## Returns {ok, puzzle_id, rating, reason}. X1 and X2 deal nothing, and a deal with
## no record raises `deal_due` so the caller can fetch one.
## K3 / SCH-puzzle-attempt I3 — the next deal waits for the attempt: while one is open
## the deal refuses, settled or not. `advance()` is the cue-read path that drops the
## settled attempt first; `leave` drops it outright.
func deal(catalog_records: Array = []) -> Dictionary:
	if has_open_puzzle():
		return {"ok": false, "reason": "puzzle_open"}
	_close_puzzle()
	var pick: Dictionary = _select(catalog_records)
	if pick.is_empty():
		deal_due.emit()
		return {"ok": false, "reason": "no_record"}
	# PRG.M1 M4 — only snapshot 2026-10-05 PuzzleIds are ever open or saved.
	if str(pick.get(FIELD_SNAPSHOT_ID, SNAPSHOT_ID)) != SNAPSHOT_ID:
		return {"ok": false, "reason": "snapshot"}
	var problem := _open_puzzle(pick)
	if not problem.is_empty():
		return {"ok": false, "reason": problem}
	return {"ok": true, "puzzle_id": puzzle_id, "rating": puzzle_elo}


## F-puzzle-catalog R3 — present the picked record: apply the opening move, then hold the
## later moves as the required sequence. Returns "" on success or the failure reason.
func _open_puzzle(pick: Dictionary) -> String:
	var moves: Array = _moves_of(pick)
	if moves.size() < 2:
		return "empty_solution"
	var fen := str(pick.get(FIELD_FEN, START_FEN))
	if not rules._load_fen(fen):
		return "bad_fen"
	var first := _uci_parts(str(moves[0]))
	if not rules.try_move(first["from"], first["to"], _promotion_kind(str(first["promotion"]))):
		return "bad_first_move"
	_hold_attempt(pick, moves, fen, first)
	return ""


## SCH-puzzle-attempt L1 — create the attempt for the presented record: new id + sequence,
## the record's opening move as the prefix so far, and no outcome yet.
func _hold_attempt(pick: Dictionary, moves: Array, fen: String, first: Dictionary) -> void:
	puzzle_id = str(pick.get(FIELD_PUZZLE_ID, ""))
	puzzle_elo = int(pick.get(FIELD_RATING, 0))
	attempt_record_fen = fen
	attempt_first_move = first
	attempt_any_checkmate_wins = any_checkmate_wins(pick)
	required_sequence = []
	for index in range(1, moves.size()):
		required_sequence.append(_uci_parts(str(moves[index])))
	sequence_index = 0
	solving_side = str(rules.position_field()["side_to_move"])
	wrong_move_on_puzzle = false
	played_prefix = [first]
	outcome = ""
	last_result = {}
	play_ui_state = UI_S1
	selected_piece = ""
	last_reject = ""


## F-puzzle-catalog F13 / I3 — true iff the record is marked mateIn1.
func any_checkmate_wins(record: Dictionary) -> bool:
	return _themes_of(record).has("mateIn1")


## DIF.Y1 selection: window match, recentSolved preference, then widen / allow-recent relax.
## Unit tests and the in-memory path use it on a small array; the production deal reads
## the one record the service chose (CTR-puzzle-catalog-read G2) and widens nothing.
func _select(records: Array) -> Dictionary:
	if records.is_empty():
		return {}
	var reach: int = ELO_MATCH_RANGE
	for widen_step in range(5):
		var fresh: Array = []
		var recent: Array = []
		for record in records:
			if record is Dictionary and _within(record, reach):
				if recent_solved.has(str(record.get(FIELD_PUZZLE_ID, ""))):
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
	return absi(int(record.get(FIELD_RATING, 0)) - int(round(player_elo))) <= reach


func _pick_lowest(records: Array) -> Dictionary:
	var best: Dictionary = {}
	for record in records:
		if not (record is Dictionary):
			continue
		if best.is_empty() or int(record[FIELD_RATING]) < int(best[FIELD_RATING]):
			best = record
	return best


## R2 / L-puzzle-stream K2 — accept a Solving-side move; returns the judging result.
func place(from_square: String, to_square: String, promotion: String = "") -> Dictionary:
	if not gestures_available():
		return {"ok": false, "illegal": true, "event": "puzzle.none"}
	last_reject = ""
	reject_square = ""
	if (
		not selected_piece.is_empty()
		and from_square == selected_piece
		and rules.piece_on(to_square).is_empty()
		and not rules.legal_targets(selected_piece).has(to_square)
	):
		return clear_selection()
	var mover: Dictionary = rules.piece_on(from_square)
	if promotion.is_empty() and rules._needs_promotion(from_square, to_square):
		if mover.is_empty() or str(mover.get("color", "")) != solving_side:
			return _reject(to_square)
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
	if (
		mover.is_empty()
		or str(mover.get("color", "")) != solving_side
		or not rules.try_move(from_square, to_square, promotion)
	):
		return _reject(to_square)
	pending_promote_from = ""
	pending_promote_to = ""
	play_ui_state = UI_S1
	return _judge({"from": from_square, "to": to_square, "promotion": promotion})


## EX.rejected — the piece rules refuse the place; S5 flashes and the selection stays.
func _reject(to_square: String) -> Dictionary:
	last_reject = "illegal"
	reject_square = to_square
	play_ui_state = UI_S5
	return {"ok": false, "illegal": true, "reject_square": to_square, "event": "puzzle.move"}


## C6 — commit the chosen promotion kind and judge the place.
func commit_promotion(kind: String) -> Dictionary:
	if play_ui_state != UI_S4 or not PROMOTE_ORDER.has(kind):
		return {"ok": false}
	var from_sq := pending_promote_from
	var to_sq := pending_promote_to
	pending_promote_from = ""
	pending_promote_to = ""
	play_ui_state = UI_S1
	return place(from_sq, to_sq, kind)


## IN.deselect — B8 / B9 / B11 / S4 cancel.
func clear_selection() -> Dictionary:
	if play_ui_state == UI_S4:
		# Leave the pawn selected and drop the promotion choice (EX.promote cancel).
		pending_promote_from = ""
		pending_promote_to = ""
		play_ui_state = UI_S1
		return {"ok": true, "event": "puzzle.deselect"}
	if not gestures_available():
		return {"ok": false}
	if selected_piece.is_empty() and play_ui_state != UI_S5:
		return {"ok": false}
	selected_piece = ""
	last_reject = ""
	reject_square = ""
	play_ui_state = UI_S1
	return {"ok": true, "event": "puzzle.deselect"}


func finish_reject_flash() -> Dictionary:
	if play_ui_state != UI_S5:
		return {"ok": false}
	last_reject = ""
	reject_square = ""
	play_ui_state = UI_S1
	return {"ok": true}


func _judge(move: Dictionary) -> Dictionary:
	var result := {"ok": true, "illegal": false, "event": "puzzle.move", "outcome": "progress"}
	if not _matches_expected(move):
		_wrong_move()
		result["outcome"] = "wrong"
		result["wrong_move_seen"] = true
		result["cue"] = "cue_wrong"
		result["story"] = "UI-puzzle-play.US2.5"
		return result
	sequence_index += 1
	played_prefix.append(move)
	if _sequence_complete():
		return _settle(result)
	# Even step: the required reply plays at once for the other side.
	var reply: Dictionary = required_sequence[sequence_index]
	var reply_kind := _promotion_kind(str(reply["promotion"]))
	if not rules.try_move(str(reply["from"]), str(reply["to"]), reply_kind):
		result["outcome"] = "invalid_record"
		return result
	played_prefix.append(reply)
	sequence_index += 1
	if _sequence_complete():
		var settled := _settle(result)
		settled["advance"] = sequence_index
		return settled
	result["advance"] = sequence_index
	result["reply_applied"] = true
	result["reply"] = reply
	return result


## CTR-local-move C1 — a record's promotion letter (e.g. `q`) becomes the kind the rules take.
func _promotion_kind(letter: String) -> String:
	match letter.to_lower():
		"q":
			return ChessRules.KIND_QUEEN
		"r":
			return ChessRules.KIND_ROOK
		"b":
			return ChessRules.KIND_BISHOP
		"n":
			return ChessRules.KIND_KNIGHT
		_:
			return ""


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
	return wanted.is_empty() or _promotion_kind(wanted) == str(move["promotion"])


## L-puzzle-stream K2 / SCH-puzzle-attempt F4 — reset to the puzzle's start; no deal,
## no Elo, no new attempt outcome. The replay applies the record FEN and the opponent
## move again, so the board's move counters and history come back exactly as dealt.
func _wrong_move() -> void:
	wrong_move_on_puzzle = true
	rules._load_fen(attempt_record_fen)
	if not solving_side.is_empty() and not attempt_first_move.is_empty():
		var first := attempt_first_move
		rules.try_move(
			str(first["from"]), str(first["to"]), _promotion_kind(str(first["promotion"]))
		)
	played_prefix = [attempt_first_move.duplicate()]
	sequence_index = 0
	selected_piece = ""
	pending_promote_from = ""
	pending_promote_to = ""
	play_ui_state = UI_S1


func _sequence_complete() -> bool:
	return sequence_index >= required_sequence.size()


## K2 completion → END.W1 (clean) or END.L4 (after a Wrong move), then the result commit.
func _settle(result: Dictionary) -> Dictionary:
	var ending := _settle_ending()
	result["outcome"] = "outcome"
	result["end_reason"] = ending
	result["elo"] = _apply_outcome(ending)
	result["cue"] = str(CUE_BY_ENDING[ending])
	result["story"] = "UI-puzzle-play.US2.7" if ending == END_W1 else "UI-puzzle-play.US2.5"
	return result


## SCH-puzzle-attempt I1 / END.P1 — W1 only with the sequence completed and no Wrong move.
func _settle_ending() -> String:
	if not _sequence_complete():
		return ""
	if wrong_move_on_puzzle:
		return END_L4
	return END_W1


## K3 — the cue was read: drop a settled attempt and ask for the next puzzle at the
## committed Elo. An attempt that has not settled yet refuses, as does a second deal.
func advance() -> Dictionary:
	if has_open_puzzle():
		if outcome.is_empty():
			return {"ok": false, "reason": "puzzle_open"}
		_close_puzzle()
	return deal()


## L-puzzle-stream K4 / E1 — leave; Elo kept; an open puzzle is not scored (PRG.P1).
func leave() -> Dictionary:
	if play_ui_state == UI_S2 and confirm_kind != CONFIRM_LEAVE:
		return {"ok": false, "reason": "confirm"}
	_close_confirm()
	# A settled puzzle was already scored and committed; leaving only drops it.
	_close_puzzle()
	return {
		"ok": true,
		"event": "puzzle.leave",
		"player_elo": player_elo,
		"committed_elo": _committed_elo(),
		"last_mode": last_mode,
	}


## K2 — END.L5 reveal the solution (failed, S = 0), then the next deal per K3.
func reveal() -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false}
	return _end_and_deal(END_L5, "UI-puzzle-play.US1.3")


## K2 — END.L6 abandon this puzzle (failed, S = 0), then the next deal after the update.
func abandon() -> Dictionary:
	if not has_open_puzzle():
		return {"ok": false}
	return _end_and_deal(END_L6, "UI-puzzle-play.US2.8")


## K3 — the ending scores, commits, and the next puzzle deals once, at the updated Elo.
func _end_and_deal(ending: String, story: String) -> Dictionary:
	var result := _end(ending, story)
	result["next"] = advance()
	return result


func _end(ending: String, story: String) -> Dictionary:
	return {
		"ok": true,
		"event": "puzzle.end",
		"end_reason": ending,
		"elo": _apply_outcome(ending),
		"cue": str(CUE_BY_ENDING[ending]),
		"story": story,
	}


## UI-puzzle-play S2 — EX.confirm for Reveal (C3), Abandon (C4) and Leave stream (C5).
func request_confirm(control_id: String) -> Dictionary:
	var kind := ""
	match control_id:
		"C3":
			kind = CONFIRM_REVEAL
		"C4":
			kind = CONFIRM_ABANDON
		"C5":
			kind = CONFIRM_LEAVE
		_:
			return {"ok": false}
	if not has_open_puzzle() or play_ui_state == UI_S2 or play_ui_state == UI_S4:
		return {"ok": false}
	play_ui_state = UI_S2
	confirm_kind = kind
	selected_piece = ""
	return {"ok": true, "event": "puzzle.confirm", "outcome": kind}


## Confirm runs the pending action; Cancel returns to S1 with the puzzle still open.
func confirm() -> Dictionary:
	var kind := confirm_kind
	_close_confirm()
	match kind:
		CONFIRM_REVEAL:
			return reveal()
		CONFIRM_ABANDON:
			return abandon()
		CONFIRM_LEAVE:
			return leave()
	return {"ok": false}


func cancel_confirm() -> Dictionary:
	if play_ui_state != UI_S2:
		return {"ok": false}
	_close_confirm()
	return {"ok": true, "event": "puzzle.cancel"}


## EX.save-failure — S3 shows while the sitting continues; Dismiss returns to S1.
func dismiss_save_failure() -> Dictionary:
	if play_ui_state != UI_S3:
		return {"ok": false}
	play_ui_state = UI_S1
	return {"ok": true, "event": "puzzle.dismiss"}


## DIF.Y1 / PRG.A1 / PRG.M1 — SEQ-puzzle-result-commit S1–S4: one Elo update per
## outcome, the recentSolved append, then the whole-document commit (B1 / B2).
func _apply_outcome(ending: String) -> Dictionary:
	var score := 1.0 if ending == END_W1 else 0.0
	# S1 — DIF.Y1: E = 1 / (1 + 10^((puzzleElo − playerElo) / 400)); no cap.
	var expected := 1.0 / (1.0 + pow(10.0, (float(puzzle_elo) - player_elo) / 400.0))
	player_elo += elo_k * (score - expected)
	# S2 — only a clean solve records the PuzzleId; the window is trimmed to CFG.T7.
	if ending == END_W1 and not puzzle_id.is_empty():
		recent_solved.append(puzzle_id)
		recent_solved = _trim_recent(recent_solved)
	outcome = str(OUTCOME_BY_ENDING.get(ending, ""))
	# S3 / S4 — commit the full document; B2 keeps the prior one and flags S3.
	var committed := _commit()
	if not committed:
		play_ui_state = UI_S3
	last_result = {
		"end_reason": ending,
		"cue": str(CUE_BY_ENDING[ending]),
		"score": score,
		"expected": expected,
		"player_elo": player_elo,
		"committed": committed,
		"solved": ending == END_W1,
	}
	return {"player_elo": player_elo, "score": score, "committed": committed}


## SEQ-puzzle-result-commit S3 — commit the full document through CTR-persist-document O2.
## S4 — true when durable (B1); false leaves the prior document intact (B2).
## A session built without a store (headless judging checks) has nothing to write, so
## the sitting keeps its in-memory Elo and the next deal waits for a caller that stores.
func _commit() -> bool:
	if store == null:
		return true
	var doc := store.read_committed()
	doc["player_elo"] = player_elo
	doc["recent_solved"] = recent_solved.duplicate()
	doc["last_mode"] = last_mode
	var ok := store.commit(doc)
	if not ok:
		save_failed.emit()
	return ok


## PRG.M1 — the committed Player Elo (the sitting's value when nothing is stored yet).
func _committed_elo() -> float:
	if store == null:
		return player_elo
	return float(store.read_committed().get("player_elo", player_elo))


## Returns {ok, event, outcome, story} for telemetry.
func select_own(square: String) -> Dictionary:
	if not gestures_available():
		return {"ok": false}
	last_reject = ""
	reject_square = ""
	var piece: Dictionary = rules.piece_on(square)
	if piece.is_empty() or str(piece.get("color", "")) != solving_side:
		return {"ok": false}
	if selected_piece == square:
		return {"ok": false}
	play_ui_state = UI_S1
	selected_piece = square
	return {"ok": true, "event": "puzzle.select", "outcome": "ok", "story": "UI-puzzle-play.US1.1"}


func legal_targets_for(square: String) -> PackedStringArray:
	return rules.legal_targets(square)


func _close_confirm() -> void:
	if play_ui_state == UI_S2:
		play_ui_state = UI_S1
	confirm_kind = ""


func _close_puzzle() -> void:
	puzzle_id = ""
	puzzle_elo = null
	attempt_record_fen = ""
	attempt_first_move = {}
	attempt_any_checkmate_wins = false
	played_prefix = []
	required_sequence = []
	sequence_index = 0
	solving_side = ""
	wrong_move_on_puzzle = false
	outcome = ""
	confirm_kind = ""
	pending_promote_from = ""
	pending_promote_to = ""
	selected_piece = ""
	last_reject = ""
	reject_square = ""
	play_ui_state = UI_S1


func _trim_recent(ids: Array) -> Array:
	if ids.size() > ELO_RECENT_WINDOW:
		return ids.slice(ids.size() - ELO_RECENT_WINDOW, ids.size())
	return ids


func _moves_of(record: Dictionary) -> Array:
	var raw: Variant = record.get(FIELD_MOVES, [])
	if raw is Array:
		return (raw as Array).duplicate()
	if raw is String:
		return str(raw).split(" ", false)
	return []


func _themes_of(record: Dictionary) -> Array:
	var raw: Variant = record.get(FIELD_THEMES, [])
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
