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
		_check_w1_elo_and_recent,
		_check_l5_reveal,
		_check_l6_abandon,
		_check_outcomes_exclusive,
		_check_elo_formula_and_start,
		_check_elo_k_default,
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
	session.deal([_record("abc", 1000, ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5"])])
	var first := session.place("e7", "e5")
	if str(first.get("outcome", "")) != "progress" or int(first.get("advance", -1)) != 2:
		return "K2 must advance past the matched step and the required reply"
	if str(first.get("reply", {}).get("from", "")) != "g1":
		return "K2 must play the required reply at once, for the other side"
	return _check_sequence_outcomes()


## Sequence steps share one session; this half runs after the first K2 step passes.
func _check_sequence_outcomes() -> String:
	var no_wrong := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	no_wrong.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	var final := no_wrong.place("e7", "e5")
	if str(final.get("end_reason", "")) != PuzzleSession.END_W1:
		return "completing the sequence with no wrong move must be END.W1"

	var wrong_session := _session([_record("abc", 1000, ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5"])])
	wrong_session.deal([_record("abc", 1000, ["e2e4", "e7e5", "g1f3", "b8c6", "f1b5"])])
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
	failed.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	failed.place("e7", "e6")
	var before := failed.player_elo
	var l4: Dictionary = failed.place("e7", "e5")
	var scored_down := failed.player_elo < before and not failed.recent_solved.has("abc")
	if str(l4.get("end_reason", "")) != PuzzleSession.END_L4 or not scored_down:
		return "END.L4 must fire after a Wrong move and apply S = 0 (got %s)" % l4
	if failed.sequence_index != failed.required_sequence.size():
		return "END.L4 must follow a completed sequence"
	return ""


## A session at `elo`; the test hands the dealt record to `deal()` itself, as the
## production caller hands over the one record CatalogDealClient fetched.
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
	return {"PuzzleId": id, "FEN": fen, "Moves": moves, "Rating": rating, "Themes": themes}


# --- R1 dealing -------------------------------------------------------------------


func _check_deal_within_window() -> String:
	var session := _session([_record("near", 1040), _record("far", 1400)])
	var dealt := session.deal([_record("near", 1040), _record("far", 1400)])
	if not bool(dealt.get("ok", false)) or session.puzzle_id != "near":
		return "DIF.Y1 must deal within ±CFG.ELO_MATCH_RANGE (got %s)" % session.puzzle_id
	if absi(int(session.puzzle_elo) - int(session.player_elo)) > PuzzleSession.ELO_MATCH_RANGE:
		return "dealt rating outside the match window"
	return ""


func _check_deal_skips_recent() -> String:
	var session := _session([_record("old1", 1000), _record("new1", 1000)])
	session.recent_solved = ["old1"]
	session.deal([_record("old1", 1000), _record("new1", 1000)])
	if session.puzzle_id != "new1":
		return "DIF.Y1 I1 must prefer a puzzle not in recentSolved (got %s)" % session.puzzle_id
	return ""


func _check_deal_widens() -> String:
	var session := _session([_record("wide", 1150)])
	session.deal([_record("wide", 1150)])
	if session.puzzle_id != "wide":
		return "DIF.Y1 D1 must widen by CFG.ELO_BAND_WIDEN until a puzzle fits"
	return ""


func _check_deal_allows_recent() -> String:
	var session := _session([_record("seen", 1000)])
	session.recent_solved = ["seen"]
	session.deal([_record("seen", 1000)])
	if session.puzzle_id != "seen":
		return "DIF.Y1 must allow a recently solved puzzle when nothing else fits"
	return ""


func _check_deal_still_deals_when_only_far() -> String:
	var session := _session([_record("faraway", 2000)])
	session.deal([_record("faraway", 2000)])
	if session.puzzle_id != "faraway":
		return "DIF.Y1 relax must keep widening until a puzzle is found"
	return ""


func _check_first_move_is_applied() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	var dealt := session.deal([_record("empty", 1000, ["e2e4"])])
	if bool(dealt.get("ok", true)) or session.puzzle_id != "" or session.puzzle_elo != null:
		return "F-puzzle-catalog X1: a record with one move must not be dealt"
	return ""


func _check_x2_failed_read() -> String:
	var session := _session([])
	var before := session.player_elo
	var due := [0]
	session.deal_due.connect(func() -> void: due[0] += 1)
	var dealt := session.deal([])
	if bool(dealt.get("ok", true)) or session.puzzle_id != "":
		return "F-puzzle-catalog X2: a failed catalog read must deal nothing"
	if int(due[0]) != 1:
		return "R1: a deal with no record must raise deal_due so the caller fetches one"
	if session.player_elo != before:
		return "F-puzzle-catalog X2 must leave GS.playerElo unchanged"
	return ""


# --- R2 judging --------------------------------------------------------------------


func _check_w1_elo_and_recent() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	var before := session.player_elo
	var solved := session.place("e7", "e5")
	if str(solved.get("end_reason", "")) != PuzzleSession.END_W1:
		return "W1 must fire when the sequence completes"
	var gained := session.player_elo - before
	if gained <= 0.0 or gained > session.elo_k:
		return "DIF.Y1 must raise Elo gently on a win (Δ=%s)" % gained
	if not session.recent_solved.has("abc"):
		return "PRG.M1 must append the solved PuzzleId to recentSolved"
	return _check_w1_equal_ratings()


## END.W1 at equal ratings — the numeric case the spec states: 1000 + CFG.ELO_K × (1 − 0.5).
func _check_w1_equal_ratings() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])], 1000.0)
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.place("e7", "e5")
	if absf(session.player_elo - 1010.0) > 0.0001:
		return (
			"END.W1 at equal ratings must reach 1010 with CFG.ELO_K 20 (got %s)"
			% session.player_elo
		)
	if not is_equal_approx(session.player_elo, 1000.0 + session.elo_k * 0.5):
		return "DIF.Y1 must apply CFG.ELO_K, not a local constant"
	return ""


func _check_l5_reveal() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	var before := session.player_elo
	var revealed := session.reveal()
	if str(revealed.get("end_reason", "")) != PuzzleSession.END_L5:
		return "revealing the solution must be END.L5"
	if session.player_elo >= before:
		return "END.L5 must apply S = 0"
	return ""


func _check_l6_abandon() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	var before := session.player_elo
	var abandoned := session.abandon()
	if str(abandoned.get("end_reason", "")) != PuzzleSession.END_L6:
		return "abandoning the puzzle must be END.L6"
	if session.player_elo >= before:
		return "END.L6 (abandon) must apply S = 0"
	if str(abandoned.get("cue", "")) != "cue_abandon":
		return "END.L6 must show cue_abandon"
	return _check_abandon_deals_next(session, abandoned)


## K3 — an ending asks for the next puzzle after the Elo update; with no record it deals
## nothing (X2) and the caller's next record is the one that deals.
func _check_abandon_deals_next(session: PuzzleSession, abandoned: Dictionary) -> String:
	var dealt: Dictionary = abandoned.get("next", {})
	if str(dealt.get("reason", "")) != "no_record":
		return "K3 must ask for the next deal after the Elo update (got %s)" % dealt
	if session.has_open_puzzle():
		return "K3 must not leave a puzzle open when the deal has no record"
	if not bool(session.deal([_record("next2", 1000, ["e2e4", "e7e5"])]).get("ok", false)):
		return "K3 must deal the next puzzle once the caller supplies its record"
	if not session.has_open_puzzle() or session.puzzle_id != "next2":
		return "K3 must leave the next puzzle open"
	if bool(session.advance().get("ok", true)):
		return "advance must not deal a second puzzle over an open one"
	return ""


func _check_elo_formula_and_start() -> String:
	var session := _session([_record("abc", 1200, ["e2e4", "e7e5"])])
	if session.player_elo != PuzzleSession.ELO_START:
		return "DIF.Y1 first-time Player Elo must be CFG.ELO_START"
	session.deal([_record("abc", 1200, ["e2e4", "e7e5"])])
	var expected := 1.0 / (1.0 + pow(10.0, (1200.0 - 1000.0) / 400.0))
	var solved := session.place("e7", "e5")
	var want := 1000.0 + session.elo_k * (1.0 - expected)
	var got := float((solved.get("elo", {}) as Dictionary).get("player_elo", 0.0))
	if absf(got - want) > 0.0001:
		return "DIF.Y1 Elo formula mismatch (got %s want %s)" % [got, want]
	if session.puzzle_elo != 1200:
		return "Puzzle Elo must never change"
	return ""


## GS.playerElo 3000 solved at equal ratings — 3000 + CFG.ELO_K × (1 − 0.5) = 3010, no cap.
func _check_elo_k_default() -> String:
	var session := PuzzleSession.new()
	if not is_equal_approx(session.elo_k, 20.0):
		return "T3 elo_k must default to CFG.ELO_K 20 (got %s)" % session.elo_k
	if not is_equal_approx(PuzzleSession.ELO_K, 20.0):
		return "CFG.ELO_K mirror must be 20 (got %s)" % PuzzleSession.ELO_K
	var high := _session([_record("abc", 3000, ["e2e4", "e7e5"])], 3000.0)
	high.deal([_record("abc", 3000, ["e2e4", "e7e5"])])
	high.place("e7", "e5")
	if absf(high.player_elo - 3010.0) > 0.0001:
		return "fields-persist: 3000 at equal ratings must reach 3010 (got %s)" % high.player_elo
	return ""


func _check_recent_trim() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.recent_solved = []
	for index in range(PuzzleSession.ELO_RECENT_WINDOW + 5):
		session.recent_solved.append("old%d" % index)
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.place("e7", "e5")
	if session.recent_solved.size() != PuzzleSession.ELO_RECENT_WINDOW:
		return "PRG.M1 must trim recentSolved to CFG.ELO_RECENT_WINDOW"
	if not session.recent_solved.has("abc"):
		return "the newest solve must survive the trim"
	return ""


func _check_leave_keeps_elo_unscored() -> String:
	var store := _stored_session()
	var session := PuzzleSession.new(ChessRules.new(), store)
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	reentered.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	if reentered.player_elo != before:
		return "re-entry must deal at the committed Elo"
	return ""


func _check_commit_failure_keeps_prior() -> String:
	var store := _stored_session()
	var session := PuzzleSession.new(ChessRules.new(), store)
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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


func _check_no_advice() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.place("e7", "e6")
	var wrong := session.place("e7", "e5")
	if str(wrong.get("end_reason", "")) != PuzzleSession.END_L4:
		return "a completed sequence after a Wrong move is L4, never W1 (END.P1)"
	if str(wrong.get("cue", "")) != "cue_failed":
		return "L4 must show cue_failed, never cue_solved"
	session.leave()
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	if session.has_open_puzzle():
		return "END.L5 must ask for the next deal, not present one with no record"
	return _check_l5_deals_next(session)


## The next puzzle deals once its record arrives, from its start.
func _check_l5_deals_next(session: PuzzleSession) -> String:
	if not bool(session.deal([_record("abc", 1000, ["e2e4", "e7e5"])]).get("ok", false)):
		return "END.L5 must deal the next puzzle once its record arrives"
	if not session.has_open_puzzle() or session.sequence_index != 0:
		return "END.L5 must present the next puzzle from its start"
	return _check_l5_equal_ratings()


## END.L5 at equal ratings — 1000 + CFG.ELO_K × (0 − 0.5) = 990.
func _check_l5_equal_ratings() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])], 1000.0)
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.reveal()
	if absf(session.player_elo - 990.0) > 0.0001:
		return (
			"END.L5 at equal ratings must reach 990 with CFG.ELO_K 20 (got %s)" % session.player_elo
		)
	return ""


## S2 leave confirm → Confirm leaves unscored (K4/E1) with the puzzle still open.
func _check_confirm_leave_unscored() -> String:
	var store := _stored_session()
	var session := PuzzleSession.new(ChessRules.new(), store)
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
	if not bool(session.deal([_promotion_record()]).get("ok", false)):
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
## until the caller supplies the next record; L5 asks for one after the Elo update.
func _check_deal_after_ending() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.place("e7", "e5")
	if bool(session.advance().get("ok", true)) or not session.has_open_puzzle():
		return "K3 must not deal over the ended puzzle before the cue"
	var closed := session.leave()
	if not bool(session.deal([_record("next", 1000, ["e2e4", "e7e5"])]).get("ok", false)):
		return "K3 must deal the next puzzle once the caller supplies its record"
	if not session.has_open_puzzle():
		return "K3 must present the next puzzle after a deal"
	if closed.is_empty():
		return "leaving after a solved puzzle must succeed"
	var revealed := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	revealed.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
	return _check_l5_deal_after_ending(revealed.reveal(), revealed)


## END.L5 asks for the next deal; with no record nothing is open, and the caller's
## next record is the one that deals.
func _check_l5_deal_after_ending(l5: Dictionary, revealed: PuzzleSession) -> String:
	if str(l5.get("next", {}).get("reason", "")) != "no_record":
		return "K3: END.L5 must ask for the next deal once the Elo update is applied"
	if revealed.has_open_puzzle():
		return "K3: a deal with no record must leave no puzzle open"
	if not bool(revealed.deal([_record("next", 1000, ["e2e4", "e7e5"])]).get("ok", false)):
		return "END.L5 must deal the next puzzle once its record arrives"
	return ""


## GS.V1 / GS.H1 / CFG.K3 — no clock runs and no shared-game ending can fire in this mode.
func _check_no_clocks() -> String:
	var session := _session([_record("abc", 1000, ["e2e4", "e7e5"])])
	session.deal([_record("abc", 1000, ["e2e4", "e7e5"])])
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
