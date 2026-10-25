class_name SharedGameSessionTest
extends SceneTree
## Clocks (R3), END.L2/D2/L3/D5, PTD-shared-game P1/S3/P3, PTD-end-conditions S4 half.


func _initialize() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array = [
		_check_end_l2,
		_check_end_l2_clock_zero,
		_check_end_d2_accept,
		_check_end_d2_decline_withdraw_lapse,
		_check_end_d2_blocked_by_position,
		_check_ptd_s1_s3,
		_check_refuse_after_end,
		_check_untimed_no_clocks,
		_check_blitz_rapid_init,
		_check_only_side_to_move_runs,
		_check_increment_applied,
		_check_increment_denied_at_zero,
		_check_illegal_keeps_clock,
		_check_expiry_l3,
		_check_expiry_d5,
		_check_knn_not_material_shortcut,
		_check_o4_kb_vs_kn,
		_check_o4_kn_vs_kb,
		_check_o4_bishops_opposite_and_same,
		_check_new_session_reinit,
		_check_stalemate_by_moves,
		_check_in_check_signal,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return problem
	return ""


func _check_end_l2() -> String:
	var session := SharedGameSession.new()
	session._start_opening()
	if not session.resign():
		return "END.L2 resign failed"
	var ended: Dictionary = session.play_state()["game_ended"]
	if (
		not bool(ended.get("ended", false))
		or str(ended.get("reason", "")) != SharedGameSession.END_L2
	):
		return "END.L2 reason missing"
	if session.result_copy_key() != SharedGameSession.RESULT_BLACK:
		return "END.L2 white resigns → result_black"
	if not bool(session.play_state().get("clocks_stopped", false)):
		return "END.L2 clocks must stop"
	return ""


func _check_end_l2_clock_zero() -> String:
	var session := SharedGameSession.new()
	session._start_opening(60_000)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 0)
	if not session.resign():
		return "END.L2 resign at zero failed"
	var reason := str(session.play_state()["game_ended"].get("reason", ""))
	if reason != SharedGameSession.END_L2:
		return "END.L2 at clock zero must stay L2, got %s" % reason
	return ""


func _check_end_d2_accept() -> String:
	var session := SharedGameSession.new()
	session._start_opening(60_000)
	if not session._offer_draw():
		return "END.D2 offer failed"
	if str(session.play_state().get("draw_offer", "")) != ChessRules.SIDE_WHITE:
		return "END.D2 drawOffer must be side to move"
	if not session._accept_draw():
		return "END.D2 accept failed"
	var ended: Dictionary = session.play_state()["game_ended"]
	if str(ended.get("reason", "")) != SharedGameSession.END_D2:
		return "END.D2 reason missing"
	if session.result_copy_key() != SharedGameSession.RESULT_DRAW:
		return "END.D2 result_draw"
	return ""


func _check_end_d2_decline_withdraw_lapse() -> String:
	var problem := _check_end_d2_decline()
	if problem.is_empty():
		problem = _check_end_d2_withdraw_and_lapse()
	return problem


func _check_end_d2_decline() -> String:
	var session := SharedGameSession.new()
	session._start_opening(60_000)
	session._offer_draw()
	if not session._decline_draw():
		return "END.D2 decline failed"
	var state: Dictionary = session.play_state()
	if not str(state.get("draw_offer", "")).is_empty():
		return "END.D2 decline must clear offer"
	if bool(state["game_ended"].get("ended", false)):
		return "END.D2 decline is not an ending"
	if str(state["position"]["side_to_move"]) != ChessRules.SIDE_WHITE:
		return "END.D2 decline keeps side to move"
	if state["clocks"]["white"] == null:
		return "END.D2 decline keeps timed clock"
	return ""


func _check_end_d2_withdraw_and_lapse() -> String:
	var session := SharedGameSession.new()
	session._start_opening(60_000)
	session._offer_draw()
	if not session._withdraw_draw():
		return "END.D2 withdraw failed"
	session._offer_draw()
	if not session.try_move("e2", "e4"):
		return "END.D2 lapse move failed"
	if not str(session.play_state().get("draw_offer", "")).is_empty():
		return "END.D2 lapse must clear offer"
	if bool(session.play_state()["game_ended"].get("ended", false)):
		return "END.D2 lapse is not an ending"
	return ""


func _check_end_d2_blocked_by_position() -> String:
	var session := SharedGameSession.new()
	(
		session
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("c6", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	session._offer_draw()
	if not session.try_move("c7", "b7"):
		return "END.D2 blocked: mate move failed"
	var reason := str(session.play_state()["game_ended"].get("reason", ""))
	if reason != ChessRules.END_L1:
		return "END.P1 position ending wins over D2 offer, got %s" % reason
	if session._accept_draw():
		return "END.D2 must not apply after L1"
	return ""


func _check_ptd_s1_s3() -> String:
	var s1 := SharedGameSession.new()
	(
		s1
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("c6", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	s1.try_move("c7", "b7")
	if str(s1.play_state()["game_ended"].get("reason", "")) != ChessRules.END_L1:
		return "PTD-end-conditions S1 L1"
	if s1.result_copy_key() != SharedGameSession.RESULT_WHITE:
		return "PTD-end-conditions S1 white wins"
	var s2 := SharedGameSession.new()
	s2._start_opening()
	s2.resign()
	if str(s2.play_state()["game_ended"].get("reason", "")) != SharedGameSession.END_L2:
		return "PTD-end-conditions S2 L2"
	var s3 := SharedGameSession.new()
	(
		s3
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("b6", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("c6", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	s3.try_move("b6", "c7")
	if str(s3.play_state()["game_ended"].get("reason", "")) != ChessRules.END_D1:
		return "PTD-end-conditions S3 D1"
	var d2 := SharedGameSession.new()
	d2._start_opening()
	d2._offer_draw()
	d2._accept_draw()
	if str(d2.play_state()["game_ended"].get("reason", "")) != SharedGameSession.END_D2:
		return "PTD-end-conditions S3 D2"
	return _stalemate_end_signal(s3)


## END.D1 rides the same every-ply end-signal step as L1: not in check, no legal
## move, draw copy, both clocks stopped.
func _stalemate_end_signal(session: SharedGameSession) -> String:
	var problem := ""
	if session._in_check_now():
		problem = "END.D1 stalemate must not report check"
	elif session.result_copy_key() != SharedGameSession.RESULT_DRAW:
		problem = "END.D1 stalemate → result_draw"
	elif not bool(session.play_state().get("clocks_stopped", false)):
		problem = "END.D1 clocks must stop"
	return problem


## A4 (#767): END.D1 is computed by the shared `result()` endpoint, not only
## asserted from a loaded {} position. K + Q vs K, stalemate on the last ply:
## White Ka3, Qa4 / Black Ka1. Qa4-b3 covers a2, b1 and b2, the king guards b3,
## so a1 has no legal move and is not in check.
func _check_stalemate_by_moves() -> String:
	var session := SharedGameSession.new()
	(
		session
		. rules
		. load_position(
			[
				_man("a1", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a4", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
				_man("a3", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	session._sync_active_to_side_to_move()
	var problems := []
	if session._in_check_now():
		problems.append("setup must not start in check")
	if not session.rules.legal_targets("a1").is_empty():
		problems.append("setup: a1 must have no legal move yet")
	if not session.try_move("a4", "b3"):
		problems.append("stalemate move a4-b3 must be legal")
	if not problems.is_empty():
		return "A4 %s" % problems[0]
	var ended: Dictionary = session.play_state()["game_ended"]
	if not session.game_ended() or str(ended.get("reason", "")) != ChessRules.END_D1:
		return "A4 stalemate must end the game as END.D1"
	var end_problem := _stalemate_end_signal(session)
	return "A4 %s" % end_problem if not end_problem.is_empty() else ""


## PER.R6 — in-check follows the check only: reported while the side to move is
## in check, cleared once the check resolves (the mark reads this field).
func _check_in_check_signal() -> String:
	var state := {}
	var session := SharedGameSession.new()
	(
		session
		. rules
		. load_position(
			[
				_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a5", ChessRules.SIDE_BLACK, ChessRules.KIND_ROOK),
			],
			ChessRules.SIDE_BLACK,
			_no_castle(),
		)
	)
	session._sync_active_to_side_to_move()
	# The router's own read: `chrome_state` is what every play render carries.
	state = session.chrome_state("en", BoardGeometry.SEAT_BOTTOM)
	if bool(state.get("in_check", false)):
		return "R6 no check reported before the check"
	if not session.try_move("a5", "a1") or not session._in_check_now():
		return "R6 setup move must give check"
	state = session.chrome_state("en", BoardGeometry.SEAT_BOTTOM)
	if not bool(state.get("in_check", false)):
		return "R6 in-check must ride the play render"
	if not session.try_move("e1", "e2"):
		return "R6 escape move e1-e2 must be legal"
	state = session.chrome_state("en", BoardGeometry.SEAT_BOTTOM)
	if bool(state.get("in_check", false)):
		return "R6 in-check must clear once the check resolves"
	return ""


func _check_refuse_after_end() -> String:
	var session := SharedGameSession.new()
	session._start_opening()
	session.resign()
	if session.try_move("e2", "e4"):
		return "ended session must refuse moves"
	return ""


func _check_untimed_no_clocks() -> String:
	## PTD-shared-game P1
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_UNTIMED, 3)
	var state: Dictionary = session.play_state()
	if state["clocks"]["white"] != null or state["clocks"]["black"] != null:
		return "PTD-shared-game P1 clocks must be none"
	if str(state.get("active_clock", "")) != "":
		return "untimed must not run a clock"
	session.tick(5_000)
	if bool(session.play_state()["game_ended"].get("ended", false)):
		return "untimed has no expiry path"
	if int(state.get("increment_ms", -1)) != 0:
		return "untimed increment must be zero (CFG.K1)"
	return ""


func _check_blitz_rapid_init() -> String:
	var problem := _check_blitz_init()
	if problem.is_empty():
		problem = _check_rapid_init()
	return problem


func _check_blitz_init() -> String:
	var blitz := SharedGameSession.new()
	blitz.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	var b: Dictionary = blitz.play_state()
	var start_ms := SharedGameSession.BLITZ_START_S * 1000
	if int(b["clocks"]["white"]) != start_ms or int(b["clocks"]["black"]) != start_ms:
		return "Blitz start must be CFG.BLITZ_START ms for both"
	if int(b.get("increment_ms", 0)) != 3_000:
		return "Blitz increment 3 s"
	if str(b.get("active_clock", "")) != ChessRules.SIDE_WHITE:
		return "Blitz only White's clock runs at start"
	if not bool(b.get("options_locked", false)):
		return "clock options lock at start"
	return ""


func _check_rapid_init() -> String:
	var rapid := SharedGameSession.new()
	rapid.start_shared(SharedGameSession.CLOCK_RAPID, 5)
	var r: Dictionary = rapid.play_state()
	if int(r["clocks"]["white"]) != SharedGameSession.RAPID_START_S * 1000:
		return "Rapid start must be CFG.RAPID_START ms"
	if int(r.get("increment_ms", 0)) != 5_000:
		return "Rapid increment 5 s"
	return ""


func _check_only_side_to_move_runs() -> String:
	## PTD-shared-game S3 / P3 and GS.V2
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	session.tick(1_000)
	var problem := _check_side_to_move_white_phase(session)
	if problem.is_empty():
		problem = _check_side_to_move_black_tick(session)
	return problem


func _check_side_to_move_white_phase(session: SharedGameSession) -> String:
	var after_tick: Dictionary = session.play_state()
	var start_ms := SharedGameSession.BLITZ_START_S * 1000
	if int(after_tick["clocks"]["white"]) != start_ms - 1_000:
		return "only White clock should tick"
	if int(after_tick["clocks"]["black"]) != start_ms:
		return "Black clock must stay while White to move"
	if not session.try_move("e2", "e4"):
		return "side-to-move move failed"
	var after_move: Dictionary = session.play_state()
	if str(after_move.get("active_clock", "")) != ChessRules.SIDE_BLACK:
		return "after move only Black's clock runs"
	if int(after_move["clocks"]["white"]) != start_ms - 1_000 + 3_000:
		return "White stopped with increment after move"
	session.set_meta("white_after_move", int(after_move["clocks"]["white"]))
	return ""


func _check_side_to_move_black_tick(session: SharedGameSession) -> String:
	var white_after := int(session.get_meta("white_after_move", -1))
	session.tick(500)
	var mid: Dictionary = session.play_state()
	if int(mid["clocks"]["black"]) != SharedGameSession.BLITZ_START_S * 1000 - 500:
		return "Black ticks while Black to move"
	if int(mid["clocks"]["white"]) != white_after:
		return "White must not tick off-turn (GS.V2)"
	return ""


func _check_increment_applied() -> String:
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 50_000)
	if not session.try_move("e2", "e4"):
		return "increment move failed"
	if int(session.play_state()["clocks"]["white"]) != 53_000:
		return "increment 3 s must apply when clock > 0"
	return ""


func _check_increment_denied_at_zero() -> String:
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 0)
	# Move completes at zero without a prior tick expiry: no increment (design story).
	if not session.try_move("e2", "e4"):
		return "zero-clock completed move failed"
	if int(session.play_state()["clocks"]["white"]) != 0:
		return "increment denied at zero"
	if str(session.play_state().get("active_clock", "")) != ChessRules.SIDE_BLACK:
		return "after zero-clock move Black starts"
	return ""


func _check_illegal_keeps_clock() -> String:
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	session.tick(2_000)
	var before := int(session.play_state()["clocks"]["white"])
	var active := str(session.play_state().get("active_clock", ""))
	if session.try_move("e2", "e5"):
		return "illegal move must fail"
	var after: Dictionary = session.play_state()
	if int(after["clocks"]["white"]) != before:
		return "illegal attempt must not change clocks"
	if str(after.get("active_clock", "")) != active:
		return "illegal attempt keeps same running clock"
	return ""


func _check_expiry_l3() -> String:
	## PTD-end-conditions S4 L3 half: other side can checkmate
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	(
		session
		. rules
		. load_position(
			[
				_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("d1", ChessRules.SIDE_WHITE, ChessRules.KIND_QUEEN),
			],
			ChessRules.SIDE_BLACK,
			_no_castle(),
		)
	)
	session._set_clock_ms(ChessRules.SIDE_BLACK, 100)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 60_000)
	session._sync_active_to_side_to_move()
	session.tick(100)
	var state: Dictionary = session.play_state()
	if str(state["game_ended"].get("reason", "")) != SharedGameSession.END_L3:
		return (
			"END.L3 expected when other side can checkmate, got %s"
			% state["game_ended"].get("reason", "")
		)
	if str(state.get("active_clock", "")) != "":
		return "L3 must stop both clocks"
	if not bool(state.get("clocks_stopped", false)):
		return "L3 clocks_stopped"
	if session.result_copy_key() != SharedGameSession.RESULT_WHITE:
		return "L3 Black flags → White wins"
	return ""


func _check_expiry_d5() -> String:
	## PTD-end-conditions S4 D5 half: other side cannot checkmate (bare kings)
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	(
		session
		. rules
		. load_position(
			[
				_man("e8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("e1", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
			],
			ChessRules.SIDE_WHITE,
			_no_castle(),
		)
	)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 50)
	session._set_clock_ms(ChessRules.SIDE_BLACK, 60_000)
	session._sync_active_to_side_to_move()
	session.tick(50)
	var reason := str(session.play_state()["game_ended"].get("reason", ""))
	if reason != SharedGameSession.END_D5:
		return "END.D5 expected when other side cannot checkmate, got %s" % reason
	if session.result_copy_key() != SharedGameSession.RESULT_DRAW:
		return "D5 is a draw"
	return ""


func _check_knn_not_material_shortcut() -> String:
	## Two knights versus king can still reach checkmate (not a material-count deny).
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	(
		session
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("c3", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("b3", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
				_man("c2", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			],
			ChessRules.SIDE_BLACK,
			_no_castle(),
		)
	)
	if not session.rules.possible_checkmate(ChessRules.SIDE_WHITE):
		return "K+N+N vs K must allow possible checkmate (O4)"
	session._set_clock_ms(ChessRules.SIDE_BLACK, 10)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 60_000)
	session._sync_active_to_side_to_move()
	session.tick(10)
	if str(session.play_state()["game_ended"].get("reason", "")) != SharedGameSession.END_L3:
		return "KNN vs K expiry must be L3, not D5 from a material shortcut"
	return ""


func _check_o4_kb_vs_kn() -> String:
	## Verification counterexample: K+B vs K+N is helpmate-capable → L3, not D5.
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	(
		session
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a7", ChessRules.SIDE_BLACK, ChessRules.KIND_KNIGHT),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("b7", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			],
			ChessRules.SIDE_BLACK,
			_no_castle(),
		)
	)
	if not session.rules.possible_checkmate(ChessRules.SIDE_WHITE):
		return "O4 K+B vs K+N must allow possible checkmate"
	session._set_clock_ms(ChessRules.SIDE_BLACK, 10)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 60_000)
	session._sync_active_to_side_to_move()
	session.tick(10)
	var reason := str(session.play_state()["game_ended"].get("reason", ""))
	if reason != SharedGameSession.END_L3:
		return "K+B vs K+N expiry must be END.L3, got %s" % reason
	return ""


func _check_o4_kn_vs_kb() -> String:
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	(
		session
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a7", ChessRules.SIDE_BLACK, ChessRules.KIND_BISHOP),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("b5", ChessRules.SIDE_WHITE, ChessRules.KIND_KNIGHT),
			],
			ChessRules.SIDE_BLACK,
			_no_castle(),
		)
	)
	if not session.rules.possible_checkmate(ChessRules.SIDE_WHITE):
		return "O4 K+N vs K+B must allow possible checkmate"
	session._set_clock_ms(ChessRules.SIDE_BLACK, 10)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 60_000)
	session._sync_active_to_side_to_move()
	session.tick(10)
	if str(session.play_state()["game_ended"].get("reason", "")) != SharedGameSession.END_L3:
		return "K+N vs K+B expiry must be END.L3"
	return ""


func _check_o4_bishops_opposite_and_same() -> String:
	var problem := _check_o4_opposite_bishops_l3()
	if problem.is_empty():
		problem = _check_o4_same_bishops_d5()
	return problem


func _check_o4_opposite_bishops_l3() -> String:
	## b7 light, a7 dark — opposite-colored bishops; helpmate possible → L3.
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	(
		session
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("a7", ChessRules.SIDE_BLACK, ChessRules.KIND_BISHOP),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("b7", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			],
			ChessRules.SIDE_BLACK,
			_no_castle(),
		)
	)
	if not session.rules.possible_checkmate(ChessRules.SIDE_WHITE):
		return "O4 opposite-colored K+B vs K+B must allow possible checkmate"
	session._set_clock_ms(ChessRules.SIDE_BLACK, 10)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 60_000)
	session._sync_active_to_side_to_move()
	session.tick(10)
	if str(session.play_state()["game_ended"].get("reason", "")) != SharedGameSession.END_L3:
		return "opposite-bishop expiry must be END.L3"
	return ""


func _check_o4_same_bishops_d5() -> String:
	## b7 light, c8 light — same-colored bishops; dead → D5.
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	(
		session
		. rules
		. load_position(
			[
				_man("a8", ChessRules.SIDE_BLACK, ChessRules.KIND_KING),
				_man("c8", ChessRules.SIDE_BLACK, ChessRules.KIND_BISHOP),
				_man("c7", ChessRules.SIDE_WHITE, ChessRules.KIND_KING),
				_man("b7", ChessRules.SIDE_WHITE, ChessRules.KIND_BISHOP),
			],
			ChessRules.SIDE_BLACK,
			_no_castle(),
		)
	)
	if session.rules.possible_checkmate(ChessRules.SIDE_WHITE):
		return "O4 same-colored K+B vs K+B must deny possible checkmate"
	session._set_clock_ms(ChessRules.SIDE_BLACK, 10)
	session._set_clock_ms(ChessRules.SIDE_WHITE, 60_000)
	session._sync_active_to_side_to_move()
	session.tick(10)
	var reason := str(session.play_state()["game_ended"].get("reason", ""))
	if reason != SharedGameSession.END_D5:
		return "same-bishop expiry must be END.D5, got %s" % reason
	return ""


func _check_new_session_reinit() -> String:
	var session := SharedGameSession.new()
	session.start_shared(SharedGameSession.CLOCK_BLITZ, 3)
	session.tick(5_000)
	session.start_shared(SharedGameSession.CLOCK_RAPID, 5)
	var state: Dictionary = session.play_state()
	if int(state["clocks"]["white"]) != SharedGameSession.RAPID_START_S * 1000:
		return "new session re-inits from newly chosen options (K3)"
	if int(state.get("increment_ms", 0)) != 5_000:
		return "new session picks new increment"
	if str(state.get("active_clock", "")) != ChessRules.SIDE_WHITE:
		return "new timed session starts White's clock"
	return ""


func _man(square: String, color: String, kind: String) -> Dictionary:
	return {"square": square, "color": color, "kind": kind}


func _no_castle() -> Dictionary:
	return {
		"white_kingside": false,
		"white_queenside": false,
		"black_kingside": false,
		"black_queenside": false,
	}
