class_name PuzzleSessionTest
extends SceneTree
## CMP-puzzle-session R1–R4, DIF.Y1, END.W1/L4/L5/L6, F-puzzle-catalog R3–R5 / X1–X2,
## PRG.M1 commit path. PTD-difficulty deal cases, PTD-puzzle-stream K1–K4.

const PROMOTION_FEN := "7p/5PP1/8/8/8/8/8/K7 b - - 0 1"
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
		_check_deal_requests_one_record,
		_check_deal_never_waits_on_the_read,
		_check_dealt_record_is_the_served_one,
		_check_read_failure_deals_nothing,
		_check_leave_drops_a_read_in_flight,
		_check_hand_in_list_is_not_a_production_path,
		_check_w1_elo_and_recent,
		_check_l5_reveal,
		_check_l6_abandon,
		_check_outcomes_exclusive,
		_check_elo_formula_and_start,
		_check_recent_trim,
		_check_leave_keeps_elo_unscored,
		_check_commit_failure_keeps_prior,
		_check_restore,
		_check_no_advice,
		_check_mate_in_one_mark,
		_check_confirm_reveal,
		_check_confirm_leave_unscored,
		_check_confirm_blocks_board,
		_check_save_failure_state,
		_check_selection_and_flash,
		_check_promotion_judged_after_commit,
		_check_deal_after_ending,
		_check_no_clocks,
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

	return _check_l4_after_wrong_move()


## END.L4 — the completed sequence after a Wrong move (second half of the K2 pass).
func _check_l4_after_wrong_move() -> String:
	# END.L4 — a completed sequence after a Wrong move scores S = 0 as a failure. The player
	# tries again from the reset start, and completing it now ends L4, never W1.
	var failed := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	failed.deal()
	failed.place("e7", "e6")
	var before := failed.player_elo
	var l4: Dictionary = failed.place("e7", "e5")
	var scored_down := failed.player_elo < before and not failed.recent_solved.has("abc")
	if str(l4.get("end_reason", "")) != PuzzleSession.END_L4 or not scored_down:
		return "END.L4 must fire after a Wrong move and apply S = 0 (got %s)" % l4
	if failed.sequence_index != failed.required_sequence.size():
		return "END.L4 must follow a completed sequence"
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


# --- C5 deal read ------------------------------------------------------------------


## A session whose deal read goes to a simulated catalog service.
func _reading_session(peer: FakeCatalogTransport, elo: float = 1000.0) -> PuzzleSession:
	var client := CatalogDealClient.new(func() -> RefCounted: return peer)
	client.configure("http://advice.test/catalog/deal", "test-key")
	var session := PuzzleSession.new()
	session.player_elo = elo
	session.catalog = []
	session.catalog_client = client
	return session


## The O1 success body CTR-puzzle-catalog-read returns: one F1–F13 record.
func _served_record(id: String = "served", rating: int = 1040) -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": id,
		"fen": PuzzleSession.START_FEN,
		"moves": ["e2e4", "e7e5"],
		"rating": rating,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": ["fork"],
		"game_url": "https://example.test/game",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}


## CMP-puzzle-session R1 — the production deal asks C5 and sends Elo and recent ids.
func _check_deal_requests_one_record() -> String:
	FakeCatalogTransport.all_requests.clear()
	var peer := FakeCatalogTransport.new()
	var session := _reading_session(peer, 1234.0)
	session.recent_solved = ["old1"]
	var dealt := session.deal()
	if not bool(dealt.get("pending", false)):
		return "a production deal must wait for the read (got %s)" % dealt
	if FakeCatalogTransport.all_requests.size() != 1:
		return "a production deal must send exactly one O1 request"
	var sent: Dictionary = FakeCatalogTransport.all_requests[0]
	if not is_equal_approx(float(sent.get("player_elo", 0.0)), 1234.0):
		return "O1 must carry GS.playerElo"
	if sent.get("recent_solved", []) != ["old1"]:
		return "O1 must carry the recent solved ids"
	return ""


## G3 — a deal never waits on the read, and a move is unaffected while one is in flight.
func _check_deal_never_waits_on_the_read() -> String:
	var peer := FakeCatalogTransport.new()
	peer.blocking = true
	var session := _reading_session(peer)
	session.deal()
	if session.has_open_puzzle():
		return "nothing may be dealt before the record arrives"
	if not session.catalog_client.in_flight():
		return "the session must report the read in flight"
	var second := session.deal()
	if bool(second.get("pending", false)) or not session.catalog_client.in_flight():
		return "a deal while a read is in flight must not start another"
	var moved := session.place("e2", "e4")
	if not bool(moved.get("illegal", false)):
		return "an in-flight read must not open the board"
	return ""


## The dealt puzzle is the single record the server sent, by its wire names.
func _check_dealt_record_is_the_served_one() -> String:
	var peer := FakeCatalogTransport.new()
	var session := _reading_session(peer, 1040.0)
	session.deal()
	if not session.poll_deal().is_empty():
		return "the tick must not deal before the record was pushed"
	peer.push_record(_served_record())
	var outcome := session.poll_deal()
	if str(outcome.get("event", "")) != "puzzle.dealt":
		return "a record handed to the tick must deal (got %s)" % outcome
	if session.puzzle_id != "served" or int(session.puzzle_elo) != 1040:
		return "GS.puzzleId / GS.puzzleElo must be the served record"
	if session.required_sequence.size() != 1:
		return "the served record's later moves are the required sequence"
	return ""


## X2 / FAIL.T14 — one failed read shape: nothing dealt, Elo kept, failure surfaced.
func _check_read_failure_deals_nothing() -> String:
	var reasons: Array = [
		CatalogWireReader.REASON_ERROR,
		CatalogWireReader.REASON_STATUS,
		CatalogWireReader.REASON_TIMEOUT,
		CatalogWireReader.REASON_BULK,
		CatalogWireReader.REASON_MALFORMED,
	]
	for reason in reasons:
		var existing_problem := _failed_read_deals_nothing(str(reason))
		if not existing_problem.is_empty():
			return existing_problem
	return ""


func _failed_read_deals_nothing(reason: String) -> String:
	var peer := FakeCatalogTransport.new()
	var session := _reading_session(peer, 1040.0)
	var before := session.player_elo
	session.deal()
	peer.push_failure(reason)
	var outcome := session.poll_deal()
	if str(outcome.get("event", "")) != "puzzle.read_failed":
		return "a failed read must surface as puzzle.read_failed (got %s)" % outcome
	if session.has_open_puzzle() or session.puzzle_id != "":
		return "X2: a failed read (%s) must deal nothing" % reason
	if session.player_elo != before:
		return "X2: a failed read (%s) must keep GS.playerElo" % reason
	var next := session.deal()
	if bool(next.get("ok", false)):
		return "the deal after a failed read must not reuse the failure"
	return ""


## A deal still in flight when the stream is left never deals.
func _check_leave_drops_a_read_in_flight() -> String:
	var peer := FakeCatalogTransport.new()
	peer.blocking = true
	var session := _reading_session(peer)
	session.deal()
	session.leave()
	peer.blocking = false
	peer.push_record(_served_record())
	if not session.poll_deal().is_empty():
		return "a read retired by leave must never deal"
	if session.has_open_puzzle():
		return "leave must leave no puzzle open"
	return ""


## A hand-in record list (tests) backs one deal; the next deal goes to C5.
func _check_hand_in_list_is_not_a_production_path() -> String:
	FakeCatalogTransport.all_requests.clear()
	var peer := FakeCatalogTransport.new()
	var session := _reading_session(peer)
	session.catalog = [_record("byhand", 1000)]
	if session.has_open_puzzle():
		return "a hand-in list must not deal before a deal is asked"
	if not bool(session.deal(session.catalog).get("ok", false)):
		return "a test's hand-in list must back the deal it is given to"
	FakeCatalogTransport.all_requests.clear()
	var next := session.deal()
	if not bool(next.get("pending", false)) or not session.catalog_client.in_flight():
		return "after the hand-in, the production path must ask C5"
	if FakeCatalogTransport.all_requests.size() == 1:
		return ""
	return "after the hand-in, the deal must send one O1 request"


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
	if str(abandoned.get("cue", "")) != "cue_abandon":
		return "END.L6 must show cue_abandon"
	return _check_abandon_deals_next(session, abandoned)


## K3 — L6 deals the next puzzle itself, after the Elo update.
func _check_abandon_deals_next(session: PuzzleSession, abandoned: Dictionary) -> String:
	var dealt: Dictionary = abandoned.get("next", {})
	if not bool(dealt.get("ok", false)) or dealt.get("puzzle_id") != "abc":
		return "K3 must deal the next puzzle after the Elo update"
	if not session.has_open_puzzle() or session.puzzle_id != "abc":
		return "K3 must leave the next puzzle open"
	if session.wrong_move_on_puzzle:
		return "the next deal must start clean"
	if bool(session.advance().get("ok", true)):
		return "advance must not deal a second puzzle over an open one"
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


## END.P1 — W1, L4, L5, L6 are never true together, and a Wrong move blocks W1 for that
## puzzle only: the same session deals the next puzzle clean.
func _check_outcomes_exclusive() -> String:
	var endings := PuzzleSession.CUE_BY_ENDING
	if not endings.has(PuzzleSession.END_W1) or endings.size() != 4:
		return "END.P1: one cue per ending and no more"
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	session.place("e7", "e6")
	var wrong := session.place("e7", "e5")
	if str(wrong.get("end_reason", "")) != PuzzleSession.END_L4:
		return "a completed sequence after a Wrong move is L4, never W1 (END.P1)"
	if str(wrong.get("cue", "")) != "cue_failed":
		return "L4 must show cue_failed, never cue_solved"
	session.leave()
	session.advance()
	if session.sequence_index != 0 or session.wrong_move_on_puzzle:
		return "a fresh deal must clear GS.wrongMoveOnPuzzle so W1 can fire"
	return _check_clean_w1(session)


## The block is per puzzle: the next deal can still be W1.
func _check_clean_w1(session: PuzzleSession) -> String:
	var clean: Dictionary = session.place("e7", "e5")
	if str(clean.get("end_reason", "")) != PuzzleSession.END_W1:
		return "a clean completion after a new deal is W1"
	if str(clean.get("cue", "")) != "cue_solved":
		return "W1 must show cue_solved"
	return ""


## UI-puzzle-play S2 / EX.confirm / J-puzzle-session B1 — C3 raises reveal_confirm, and
## Confirm (never the C3 tap itself) runs END.L5.
func _check_confirm_reveal() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	var before := session.player_elo
	var raised := session.request_confirm("C3")
	if not bool(raised.get("ok", false)) or session.play_ui_state != PuzzleSession.UI_S2:
		return "C3 must raise EX.confirm (S2), not reveal at once"
	if session.confirm_kind != PuzzleSession.CONFIRM_REVEAL:
		return "C3 must raise the named reveal_confirm"
	if session.player_elo != before or not session.has_open_puzzle():
		return "opening a confirm must not score or close the puzzle"
	if not bool(session.cancel_confirm().get("ok", false)) or not session.has_open_puzzle():
		return "Cancel must return to S1 with the puzzle still open"
	return _check_reveal_commit(session, before)


## Confirm — the reveal runs END.L5, scores S = 0, and K3 deals the next puzzle.
func _check_reveal_commit(session: PuzzleSession, before: float) -> String:
	session.request_confirm("C3")
	var confirmed := session.confirm()
	if str(confirmed.get("end_reason", "")) != PuzzleSession.END_L5:
		return "Confirm on reveal_confirm must end END.L5 (got %s)" % confirmed
	if str(confirmed.get("cue", "")) != "cue_failed" or session.player_elo >= before:
		return "END.L5 must show cue_failed and apply S = 0"
	var scored: Dictionary = confirmed.get("elo", {})
	if float(scored.get("score", -1.0)) != 0.0:
		return "END.L5 must score S = 0"
	if not session.has_open_puzzle():
		return "END.L5 must deal the next puzzle after the Elo update"
	return ""


## S2 leave confirm → Confirm leaves unscored (K4/E1) with the puzzle still open.
func _check_confirm_leave_unscored() -> String:
	var store := _stored_session()
	var session := PuzzleSession.new(ChessRules.new(), store)
	session.catalog = [_record("abc", 1000, ["e2e4", "e7e5"])]
	session.deal()
	var committed_before: float = float(store.read_committed()["player_elo"])
	session.request_confirm("C5")
	if session.confirm_kind != PuzzleSession.CONFIRM_LEAVE:
		return "C5 must raise the named leave_confirm"
	var left := session.confirm()
	if not bool(left.get("ok", false)) or session.has_open_puzzle():
		return "Confirm on leave_confirm must leave the stream"
	if session.player_elo != committed_before:
		return "leaving must not score the open puzzle as abandon (K4/E1)"
	if session.play_ui_state != PuzzleSession.UI_S1:
		return "leaving must drop the confirm state"
	return ""


## US5.4 / US1.10 — S2 blocks select and place; the open puzzle is untouched.
func _check_confirm_blocks_board() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	session.request_confirm("C4")
	if bool(session.select_own("e7").get("ok", true)):
		return "C1 must be unavailable in S2"
	var placed := session.place("e7", "e5")
	if bool(placed.get("ok", true)) or session.play_ui_state != PuzzleSession.UI_S2:
		return "C2 must place nothing in S2"
	return ""


## US1.8 / US1.11 / EX.save-failure — S3 shows on the failure, the sitting keeps its Elo,
## and Dismiss returns to S1.
func _check_save_failure_state() -> String:
	var store := _stored_session()
	var session := PuzzleSession.new(ChessRules.new(), store)
	session.catalog = [_record("abc", 1000, ["e2e4", "e7e5"])]
	session.deal()
	store.force_write_failure = true
	var solved := session.place("e7", "e5")
	var elo: Dictionary = solved.get("elo", {})
	if bool(elo.get("committed", true)):
		return "SEQ-puzzle-result-commit B2 must report the failed commit"
	if session.play_ui_state != PuzzleSession.UI_S3:
		return "EX.save-failure must put the screen in S3"
	if not session.gestures_available():
		return "C1–C5 must stay usable in S3"
	if not bool(session.dismiss_save_failure().get("ok", false)):
		return "Dismiss must close S3"
	if (
		session.play_ui_state != PuzzleSession.UI_S1
		or session.player_elo <= PuzzleSession.ELO_START
	):
		return "Dismiss must return to S1 with the sitting's in-memory Elo kept"
	return ""


## US1.1 / US3.3 / US2.3, US2.9 — select a Solving-side piece, then a refused place
## flashes S5 with the selection kept and is not a Wrong move.
func _check_selection_and_flash() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	if bool(session.select_own("e2").get("ok", true)):
		return "C1 must only select the Solving side"
	if not bool(session.select_own("e7").get("ok", false)) or session.selected_piece != "e7":
		return "C1 must select a Solving-side piece"
	if not session.legal_targets_for("e7").has("e5"):
		return "R1 legal marks must come from the puzzle position"
	var refused := session.place("e7", "e4")
	if not bool(refused.get("illegal", false)) or session.play_ui_state != PuzzleSession.UI_S5:
		return "EX.rejected must flash S5 (got %s)" % refused
	if session.selected_piece != "e7" or session.wrong_move_on_puzzle:
		return "a refused place keeps the selection and is not a Wrong move"
	return _check_flash_clears(session)


## US3.3 — the flash clears, then a real Wrong move resets the puzzle.
func _check_flash_clears(session: PuzzleSession) -> String:
	if not bool(session.finish_reject_flash().get("ok", false)):
		return "the S5 flash must clear back to S1"
	if session.place("e7", "e6").get("outcome", "") != "wrong":
		return "a Wrong move resets the puzzle"
	return ""


## US3.4 / S4 / C6 — a last-rank pawn place opens S4, C6 commits the type, and only then
## does the puzzle judge the move (L-puzzle-stream K2).
func _check_promotion_judged_after_commit() -> String:
	var session := _session([_promotion_record()])
	session.player_elo = 1400.0
	if not bool(session.deal().get("ok", false)):
		return "the promotion fixture must deal"
	var opened := session.place("g7", "g8")
	if not bool(opened.get("promote", false)) or session.play_ui_state != PuzzleSession.UI_S4:
		return "a last-rank pawn place must enter S4 (got %s)" % opened
	if session.wrong_move_on_puzzle or session.outcome != "":
		return "S4 must not judge the move before C6"
	return _check_promotion_deselect(session)


## S4 waits on C6; IN.deselect drops the choice but keeps the pawn selected.
func _check_promotion_deselect(session: PuzzleSession) -> String:
	if bool(session.select_own("a1").get("ok", true)):
		return "the board must wait on C6 in S4"
	var cleared := session.clear_selection()
	if not bool(cleared.get("ok", false)) or session.play_ui_state != PuzzleSession.UI_S1:
		return "IN.deselect in S4 must drop the promotion choice (got %s)" % cleared
	if session.selected_piece != "g7":
		return "IN.deselect in S4 must keep the pawn selected"
	return _check_promotion_commit(session)


## C6 — the committed type is judged as the puzzle move.
func _check_promotion_commit(session: PuzzleSession) -> String:
	session.place("g7", "g8")
	var committed := session.commit_promotion("queen")
	if str(committed.get("outcome", "")) != "outcome":
		return "C6 must commit the type and then judge the place (got %s)" % committed
	if str(committed.get("end_reason", "")) != PuzzleSession.END_W1:
		return "the recorded promotion must solve the puzzle"
	if str(session.rules.piece_on("g8").get("kind", "")) != ChessRules.KIND_QUEEN:
		return "the committed type must be the piece placed"
	return ""


## K3 — after W1 the dealt puzzle stays open behind the cue and the next deal is refused
## until the stream advances once; after L5/L6 the ending itself deals the next.
func _check_deal_after_ending() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	session.place("e7", "e5")
	if bool(session.advance().get("ok", true)) or not session.has_open_puzzle():
		return "K3 must not deal over the ended puzzle before the cue"
	var closed := session.leave()
	if not bool(session.advance().get("ok", false)) or not session.has_open_puzzle():
		return "K3 must deal the next puzzle once the stream moves on"
	if closed.is_empty():
		return "leaving after a solved puzzle must succeed"
	var revealed := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	revealed.deal()
	var l5 := revealed.reveal()
	if not bool(l5.get("next", {}).get("ok", false)) or not revealed.has_open_puzzle():
		return "END.L5 must deal the next puzzle after the Elo update"
	return ""


## GS.V1 / GS.H1 / CFG.K3 — no clock runs and no shared-game ending can fire in this mode.
func _check_no_clocks() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal()
	if session.play_state().has("clocks"):
		return "CFG.K3: no clock runs in Puzzle stream"
	var ended := false
	session.place("e7", "e5")
	ended = bool(session.rules.game_ended_field().get("ended", false))
	if ended:
		return "no shared-game ending may fire in Puzzle stream (END.L1–L3/D1–D5)"
	if not session.rules.end_signals().has("ending"):
		return "the domain still reports the move's signals (GS.V1)"
	if session.play_state().get("advice", "x") != "none":
		return "GS.V3: advice must stay none after a move"
	return ""


## FEN before the recorded first move `h8h7`; White's `g7g8q` is the required Solving-side
## step. The kings sit clear of the g-file so the push does not leave White in check.
func _promotion_record() -> Dictionary:
	# R3 — the first move is the opponent's and is applied before presenting; the last-rank
	# push is the required Solving-side step.
	var record := _record("promo", 1400, ["h8h7", "g7g8q"])
	record["FEN"] = PROMOTION_FEN
	return record


func _stored_session() -> PersistStore:
	var store := PersistStore.new()
	store.memory_backend = {}
	store.load_document()
	return store
