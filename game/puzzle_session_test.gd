class_name PuzzleSessionTest
extends SceneTree
## CMP-puzzle-session R1–R4, DIF.Y1, END.W1/L4/L5/L6, F-puzzle-catalog R3–R5 / X1–X2,
## PRG.M1 commit path. PTD-difficulty deal cases, PTD-puzzle-stream K1–K4.

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
		_check_deal_within_window,
		_check_deal_skips_recent,
		_check_deal_widens,
		_check_deal_allows_recent,
		_check_deal_still_deals_when_only_far,
		_check_first_move_is_applied,
		_check_x1_empty_solution,
		_check_x2_failed_read,
		_check_w1_elo_and_recent,
		_check_l5_reveal,
		_check_l6_abandon,
		_check_elo_formula_and_start,
		_check_recent_trim,
		_check_leave_keeps_elo_unscored,
		_check_commit_failure_keeps_prior,
		_check_restore,
		_check_no_advice,
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
	return _check_sequences()


## Sequence steps share one session: separate check methods are fragile when each one
## is a Callable buffer, so the multi-move K2 path runs here in one pass.
func _check_sequences() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5"])])
	session.deal()
	var first := session.place("e7", "e5")
	if str(first.get("outcome", "")) != "progress" or int(first.get("advance", -1)) != 2:
		return "K2 must advance past the matched step and the required reply"
	if str(first.get("reply", {}).get("from", "")) != "g1":
		return "K2 must play the required reply at once, for the other side"
	return _check_sequence_outcomes()


## Sequence steps share one session; this half runs after the first K2 step passes.
func _check_sequence_outcomes() -> String:
	var no_wrong := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	no_wrong.deal()
	var final := no_wrong.place("e7", "e5")
	if str(final.get("end_reason", "")) != PuzzleSession.END_W1:
		return "completing the sequence with no wrong move must be END.W1"

	var wrong_session := _session([_record("abc", 1000, ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5"])])
	wrong_session.deal()
	var wrong := wrong_session.place("e7", "e6")
	var wrong_ok := str(wrong.get("outcome", "")) == "wrong"
	var reset_home := not wrong_session.rules.piece_on("e7").is_empty()
	if not wrong_ok or not wrong_session.wrong_move_on_puzzle or not reset_home:
		return "a Wrong move must set GS.wrongMoveOnPuzzle and reset the puzzle"
	if wrong_session.sequence_index != 0 or wrong_session.puzzle_id != "abc":
		return "a Wrong move must not deal the next puzzle"
	if not str(wrong.get("end_reason", "")).is_empty():
		return "a Wrong move must not end the puzzle"

	# END.L4 — a completed sequence after a Wrong move scores S = 0 as a failure.
	var failed := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	failed.deal()
	failed.place("e7", "e6")
	var before := failed.player_elo
	var l4 := failed.finish_after_wrong_move()
	var scored_down := failed.player_elo < before and not failed.recent_solved.has("abc")
	if str(l4.get("end_reason", "")) != PuzzleSession.END_L4 or not scored_down:
		return "END.L4 must fire after a Wrong move and apply S = 0"
	return ""


func _session(records: Array = [], elo: float = 1000.0) -> PuzzleSession:
	var session := PuzzleSession.new()
	session.player_elo = elo
	session.catalog = records
	return session


func _record(
	id: String,
	rating: int,
	moves: Array = ["e2e4", "e7e5"],
	themes: Array = ["fork"],
	fen: String = PuzzleSession.START_FEN
) -> Dictionary:
	return {"PuzzleId": id, "FEN": fen, "Moves": moves, "Rating": rating, "Themes": themes}


# --- R1 dealing -------------------------------------------------------------------


func _check_deal_within_window() -> String:
	var session := _session([_record("near", 1040), _record("far", 1400)])
	var dealt := session.deal()
	if not bool(dealt.get("ok", false)) or session.puzzle_id != "near":
		return "DIF.Y1 must deal within ±CFG.ELO_MATCH_RANGE (got %s)" % session.puzzle_id
	if absi(int(session.puzzle_elo) - int(session.player_elo)) > PuzzleSession.ELO_MATCH_RANGE:
		return "dealt rating outside the match window"
	return ""


func _check_deal_skips_recent() -> String:
	var session := _session([_record("old1", 1000), _record("new1", 1000)])
	session.recent_solved = ["old1"]
	session.deal()
	if session.puzzle_id != "new1":
		return "DIF.Y1 I1 must prefer a puzzle not in recentSolved (got %s)" % session.puzzle_id
	return ""


func _check_deal_widens() -> String:
	var session := _session([_record("wide", 1150)])
	session.deal()
	if session.puzzle_id != "wide":
		return "DIF.Y1 D1 must widen by CFG.ELO_BAND_WIDEN until a puzzle fits"
	return ""


func _check_deal_allows_recent() -> String:
	var session := _session([_record("seen", 1000)])
	session.recent_solved = ["seen"]
	session.deal()
	if session.puzzle_id != "seen":
		return "DIF.Y1 must allow a recently solved puzzle when nothing else fits"
	return ""


func _check_deal_still_deals_when_only_far() -> String:
	var session := _session([_record("faraway", 2000)])
	session.deal()
	if session.puzzle_id != "faraway":
		return "DIF.Y1 relax must keep widening until a puzzle is found"
	return ""


func _check_first_move_is_applied() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	if str(session.rules.position_field()["side_to_move"]) != ChessRules.SIDE_BLACK:
		return "F-puzzle-catalog R3 must apply the first move before presenting"
	if session.solving_side != ChessRules.SIDE_BLACK:
		return "GS.solvingSide must be the side to move in the presented position"
	if session.required_sequence.size() != 1 or str(session.required_sequence[0]["from"]) != "e7":
		return "GS.requiredSequence must be the later moves as UCI steps"
	if session.sequence_index != 0 or session.wrong_move_on_puzzle:
		return "a deal must start at sequence index 0 with no wrong move"
	return ""


func _check_x1_empty_solution() -> String:
	var session := _session([_record("empty", 1000, ["e2e4"])])
	var dealt := session.deal()
	if bool(dealt.get("ok", true)) or session.puzzle_id != "" or session.puzzle_elo != null:
		return "F-puzzle-catalog X1: a record with one move must not be dealt"
	return ""


func _check_x2_failed_read() -> String:
	var session := _session([])
	var before := session.player_elo
	var dealt := session.deal()
	if bool(dealt.get("ok", true)) or session.puzzle_id != "":
		return "F-puzzle-catalog X2: a failed catalog read must deal nothing"
	if session.player_elo != before:
		return "F-puzzle-catalog X2 must leave GS.playerElo unchanged"
	return ""


# --- R2 judging --------------------------------------------------------------------


func _check_w1_elo_and_recent() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	var before := session.player_elo
	var solved := session.place("e7", "e5")
	if str(solved.get("end_reason", "")) != PuzzleSession.END_W1:
		return "W1 must fire when the sequence completes"
	var gained := session.player_elo - before
	if gained <= 0.0 or gained > PuzzleSession.ELO_K:
		return "DIF.Y1 must raise Elo gently on a win (Δ=%s)" % gained
	if not session.recent_solved.has("abc"):
		return "PRG.M1 must append the solved PuzzleId to recentSolved"
	return ""


func _check_l5_reveal() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	var before := session.player_elo
	var revealed := session.reveal()
	if str(revealed.get("end_reason", "")) != PuzzleSession.END_L5:
		return "revealing the solution must be END.L5"
	if session.player_elo >= before:
		return "END.L5 must apply S = 0"
	return ""


func _check_l6_abandon() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	var before := session.player_elo
	var abandoned := session.abandon()
	if str(abandoned.get("end_reason", "")) != PuzzleSession.END_L6:
		return "abandoning the puzzle must be END.L6"
	if session.player_elo >= before:
		return "END.L6 (abandon) must apply S = 0"
	if session.has_open_puzzle():
		return "END.L6 must close the puzzle before the next deal"
	var next := session.advance()
	if not bool(next.get("ok", false)) or next.get("puzzle_id") != "abc":
		return "K3 must deal the next puzzle after the Elo update"
	return ""


func _check_elo_formula_and_start() -> String:
	var session := _session([_record("abc", 1200, ["e2e4", "e7e5"])])
	if session.player_elo != PuzzleSession.ELO_START:
		return "DIF.Y1 first-time Player Elo must be CFG.ELO_START"
	session.deal()
	var expected := 1.0 / (1.0 + pow(10.0, (1200.0 - 1000.0) / 400.0))
	var solved := session.place("e7", "e5")
	var want := 1000.0 + PuzzleSession.ELO_K * (1.0 - expected)
	var got := float((solved.get("elo", {}) as Dictionary).get("player_elo", 0.0))
	if absf(got - want) > 0.0001:
		return "DIF.Y1 Elo formula mismatch (got %s want %s)" % [got, want]
	if session.puzzle_elo != 1200:
		return "Puzzle Elo must never change"
	return ""


func _check_recent_trim() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.recent_solved = []
	for index in range(PuzzleSession.ELO_RECENT_WINDOW + 5):
		session.recent_solved.append("old%d" % index)
	session.deal()
	session.place("e7", "e5")
	if session.recent_solved.size() != PuzzleSession.ELO_RECENT_WINDOW:
		return "PRG.M1 must trim recentSolved to CFG.ELO_RECENT_WINDOW"
	if not session.recent_solved.has("abc"):
		return "the newest solve must survive the trim"
	return ""


func _check_leave_keeps_elo_unscored() -> String:
	var store := _stored_session()
	var session := PuzzleSession.new(ChessRules.new(), store)
	session.catalog = [_record("abc", 1000, ["e2e4", "e7e5"])]
	session.deal()
	var before := session.player_elo
	var committed_before: float = float(store.read_committed()["player_elo"])
	var left := session.leave()
	if not bool(left.get("ok", false)):
		return "K4/E1 leave must succeed"
	if (
		session.player_elo != before
		or float(store.read_committed()["player_elo"]) != committed_before
	):
		return "K4/E1 must keep Player Elo and not score the open puzzle"
	if session.has_open_puzzle():
		return "leave must close the open puzzle"
	var reentered := PuzzleSession.new(ChessRules.new(), store)
	reentered.restore(store.load_document())
	reentered.catalog = session.catalog
	reentered.deal()
	if reentered.player_elo != before:
		return "re-entry must deal at the committed Elo"
	return ""


func _check_commit_failure_keeps_prior() -> String:
	var store := _stored_session()
	var session := PuzzleSession.new(ChessRules.new(), store)
	session.catalog = [_record("abc", 1000, ["e2e4", "e7e5"])]
	session.deal()
	var failures: Array = []
	session.save_failed.connect(func() -> void: failures.append(true))
	store.force_write_failure = true
	session.place("e7", "e5")
	if failures.is_empty():
		return "SEQ-puzzle-result-commit B2 must raise the save-failure signal"
	if float(store.read_committed()["player_elo"]) != PuzzleSession.ELO_START:
		return "a failed commit must leave the prior document intact"
	if session.player_elo <= PuzzleSession.ELO_START:
		return "a failed commit must keep in-memory values for the sitting"
	return ""


func _check_restore() -> String:
	var session := _session([])
	(
		session
		. restore(
			{
				"version": 1,
				"player_elo": 1234.0,
				"recent_solved": ["a", "b"],
				"last_mode": "puzzle",
			}
		)
	)
	if session.player_elo != 1234.0 or session.recent_solved.size() != 2:
		return "PRG.M1 must restore Player Elo and recentSolved on entry"
	return ""


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
	session.deal()
	if not session.attempt_any_checkmate_wins or session.required_sequence.size() != 1:
		return "R4–R5 must keep the recorded single-step sequence"
	return ""


## R5 on a dealt mate-in-one record: the marked record wins on the recorded mate, a legal
## non-mating move is a Wrong move that resets the puzzle without dealing, and an illegal
## move is an EX.rejected S5 rejection rather than a Wrong move.
func _check_mate_in_one_accepts_recorded_mate() -> String:
	var session := _session([_mate_record(["mateIn1"])])
	if not bool(session.deal().get("ok", false)):
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
	session.deal()
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
	session.deal()
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
	if not bool(session.deal().get("ok", false)):
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


func _check_no_advice() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	var state := session.play_state()
	if str(state.get("advice", "")) != "none":
		return "GS.V3: advice must stay none in Puzzle stream"
	return ""


func _stored_session() -> PersistStore:
	var store := PersistStore.new()
	store.memory_backend = {}
	store.load_document()
	return store
