class_name PuzzleSessionTest
extends SceneTree
## CMP-puzzle-session R1–R4, DIF.Y1, END.W1/L4/L5/L6, F-puzzle-catalog R3–R5 / X1–X2,
## PRG.M1 commit path. PTD-difficulty deal cases, PTD-puzzle-stream K1–K4.

const MATE_FEN := "6k1/5ppp/8/8/8/8/5PPP/1R4K1 w - - 0 1"


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


## Sequence steps share one session, so this half runs after the first K2 step is proven.
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
	id: String, rating: int, moves: Array = ["e2e4", "e7e5"], themes: Array = ["fork"]
) -> Dictionary:
	return {
		"PuzzleId": id,
		"FEN": PuzzleSession.START_FEN,
		"Moves": moves,
		"Rating": rating,
		"Themes": themes
	}


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
