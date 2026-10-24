class_name PuzzleSessionMateTest
extends SceneTree
## F-puzzle-catalog R4–R5 / SCH-puzzle-catalog F13, I3, and EX.rejected — the mate-in-one
## arm, its recorded-mate acceptance, the Wrong-move reset and the S5 illegal rejection.
## Split from `puzzle_session_test.gd` to keep both files inside the lint file-length cap.

const MATE_FEN := "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1"
## R4–R5 moves on MATE_FEN after the recorded opponent move `g8h8`. `b1b8` is the recorded
## mate and the only mate at this position, so the recorded move is the mate to check; `b1b7`
## is legal and non-mating and so a Wrong move; `g1g2` is illegal and so an EX.rejected S5
## rejection, never a Wrong move.
const MATE_RECORDED_MOVE := "b1b8"
const MATE_NON_MATING_MOVE := "b1b7"
const MATE_ILLEGAL_MOVE := "g1g2"
const MATE_OPPONENT_MOVE := "g8h8"


func _initialize() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array = [
		_check_mate_in_one_mark,
		_check_mate_in_one_accepts_recorded_mate,
		_check_mate_in_one_rejects_non_mating,
		_check_illegal_move_is_not_a_wrong_move,
		_check_unmarked_record_is_not_armed,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return problem
	return ""


func _session(_records: Array = [], elo: float = 1000.0) -> PuzzleSession:
	var session := PuzzleSession.new()
	session.player_elo = elo
	return session


func _record(
	id: String,
	rating: int,
	moves: Array = ["e2e4", "e7e5"],
	themes: Array = ["fork"],
	fen: String = PuzzleSession.START_FEN
) -> Dictionary:
	## SCH-puzzle-catalog F1–F13 — the one shape CTR-puzzle-catalog-read delivers.
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": id,
		"fen": fen,
		"moves": moves,
		"rating": rating,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": themes,
		"game_url": "https://example.test/game",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": themes.has("mateIn1"),
	}


## F-puzzle-catalog R4–R5 / SCH-puzzle-catalog F13, I3 — only the mateIn1-marked record
## is armed for any checkmating move, and its recorded list stays the required sequence.
func _check_mate_in_one_mark() -> String:
	var mate := _record("m1", 1000, ["e2e4", "e7e5"], ["mateIn1", "short"])
	var other := _record("x2", 1000, ["e2e4", "e7e5"], ["fork"])
	if not PuzzleSession.new().any_checkmate_wins(mate):
		return "F13 must read mateIn1 from the record themes"
	if PuzzleSession.new().any_checkmate_wins(other):
		return "a record without mateIn1 must not be armed"
	var session := _session([mate])
	session.deal([mate])
	if not session.attempt_any_checkmate_wins or session.required_sequence.size() != 1:
		return "R4–R5 must keep the recorded single-step sequence"
	return ""


## R5 on a dealt mate-in-one record: the marked record wins on the recorded mate, a legal
## non-mating move is a Wrong move that resets the puzzle without dealing, and an illegal
## move is an EX.rejected S5 rejection rather than a Wrong move.
func _check_mate_in_one_accepts_recorded_mate() -> String:
	var session := _session([_mate_record(["mateIn1"])])
	if not bool(session.deal([_mate_record(["mateIn1"])]).get("ok", false)):
		return "a mateIn1 record on MATE_FEN must deal"
	if not session.attempt_any_checkmate_wins or session.required_sequence.size() != 1:
		return "R4–R5 must keep the recorded single-step sequence"
	var played := session.place(MATE_RECORDED_MOVE.substr(0, 2), MATE_RECORDED_MOVE.substr(2, 2))
	var accepted := str(played.get("outcome", "")) == "outcome"
	var won := str(played.get("end_reason", "")) == PuzzleSession.END_W1
	if not accepted or not won:
		return (
			"R5: the recorded mate must be accepted and end the puzzle as END.W1 (got %s)" % played
		)
	if session.sequence_index != session.required_sequence.size():
		return "R5: the sequence must advance past an accepted mate"
	var flagged := session.wrong_move_on_puzzle
	var scored := session.recent_solved.has("m1")
	if flagged or not scored:
		return "R5: an accepted mate must be a clean, scored solve"
	return ""


func _check_mate_in_one_rejects_non_mating() -> String:
	var session := _session([_mate_record(["mateIn1"])])
	session.deal([_mate_record(["mateIn1"])])
	var dealt_start := session.rules.position_field()
	var non_mating := session.place(
		MATE_NON_MATING_MOVE.substr(0, 2), MATE_NON_MATING_MOVE.substr(2, 2)
	)
	if str(non_mating.get("outcome", "")) != "wrong":
		return "R5: a legal non-mating move must be a Wrong move (got %s)" % non_mating
	if not session.wrong_move_on_puzzle:
		return "R5: a Wrong move must set GS.wrongMoveOnPuzzle"
	if session.sequence_index != 0:
		return "R5: a Wrong move must reset the sequence to its start"
	return _wrong_move_reset_problem(session, dealt_start, non_mating)


## L-puzzle-stream K2 — the Wrong move reset this puzzle to its start and dealt nothing.
func _wrong_move_reset_problem(
	session: PuzzleSession, dealt_start: Dictionary, played: Dictionary
) -> String:
	if str(played.get("end_reason", "")) != "":
		return "L-puzzle-stream K2: a Wrong move must not end the puzzle"
	if session.rules.position_field() != dealt_start:
		return "L-puzzle-stream K2: a Wrong move must return to the position the deal presented"
	if not session.has_open_puzzle() or session.puzzle_id != "m1":
		return "L-puzzle-stream K2: a Wrong move must not deal"
	return ""


## EX.rejected / UI-puzzle-play S5 — an illegal move is a rejection, never a Wrong move.
func _check_illegal_move_is_not_a_wrong_move() -> String:
	var session := _session([_mate_record(["mateIn1"])])
	session.deal([_mate_record(["mateIn1"])])
	var illegal := session.place(MATE_ILLEGAL_MOVE.substr(0, 2), MATE_ILLEGAL_MOVE.substr(2, 2))
	if not bool(illegal.get("illegal", false)) or str(illegal.get("outcome", "")) == "wrong":
		return (
			"EX.rejected: an illegal move is an S5 rejection, not a Wrong move (got %s)" % illegal
		)
	if session.last_reject != "illegal":
		return "EX.rejected: an illegal move must record the S5 rejection"
	if session.wrong_move_on_puzzle:
		return "EX.rejected: an illegal move must not mark a Wrong move"
	return ""


## I3: the same mate is still accepted without the theme (it is the recorded move), but the
## record is not armed for "any checkmating move" — that reading lives only on mateIn1.
func _check_unmarked_record_is_not_armed() -> String:
	var session := _session([_mate_record(["fork"])])
	if not bool(session.deal([_mate_record(["fork"])]).get("ok", false)):
		return "an unmarked record on MATE_FEN must deal"
	if session.attempt_any_checkmate_wins:
		return "I3: an unmarked record must not be armed for any checkmating move"
	var played := session.place(MATE_RECORDED_MOVE.substr(0, 2), MATE_RECORDED_MOVE.substr(2, 2))
	if str(played.get("outcome", "")) != "outcome":
		return "I3: an unmarked record must still accept its recorded move (got %s)" % played
	return ""


## F-puzzle-catalog R3 — MATE_FEN is the position before Black's move, so the record's
## first UCI move is Black's, and the single Solving-side step is the recorded mate.
func _mate_record(themes: Array) -> Dictionary:
	return _record("m1", 1000, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE], themes, MATE_FEN)
