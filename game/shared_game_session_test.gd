class_name SharedGameSessionTest
extends SceneTree
## END.L2, END.D2, session handoff, and PTD-end-conditions S1–S3 (non-clock).


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
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return problem
	return ""


func _check_end_l2() -> String:
	var session := SharedGameSession.new()
	session.start_opening()
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
	session.start_opening(60_000)
	session.set_clock_ms(ChessRules.SIDE_WHITE, 0)
	if not session.resign():
		return "END.L2 resign at zero failed"
	var reason := str(session.play_state()["game_ended"].get("reason", ""))
	if reason != SharedGameSession.END_L2:
		return "END.L2 at clock zero must stay L2, got %s" % reason
	return ""


func _check_end_d2_accept() -> String:
	var session := SharedGameSession.new()
	session.start_opening(60_000)
	if not session.offer_draw():
		return "END.D2 offer failed"
	if str(session.play_state().get("draw_offer", "")) != ChessRules.SIDE_WHITE:
		return "END.D2 drawOffer must be side to move"
	if not session.accept_draw():
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
	session.start_opening(60_000)
	session.offer_draw()
	if not session.decline_draw():
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
	session.start_opening(60_000)
	session.offer_draw()
	if not session.withdraw_draw():
		return "END.D2 withdraw failed"
	session.offer_draw()
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
	session.offer_draw()
	if not session.try_move("c7", "b7"):
		return "END.D2 blocked: mate move failed"
	var reason := str(session.play_state()["game_ended"].get("reason", ""))
	if reason != ChessRules.END_L1:
		return "END.P1 position ending wins over D2 offer, got %s" % reason
	if session.accept_draw():
		return "END.D2 must not apply after L1"
	return ""


func _check_ptd_s1_s3() -> String:
	# PTD-end-conditions S1 checkmate
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
	# S2 resign
	var s2 := SharedGameSession.new()
	s2.start_opening()
	s2.resign()
	if str(s2.play_state()["game_ended"].get("reason", "")) != SharedGameSession.END_L2:
		return "PTD-end-conditions S2 L2"
	# S3 stalemate
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
	# S3 agreement
	var d2 := SharedGameSession.new()
	d2.start_opening()
	d2.offer_draw()
	d2.accept_draw()
	if str(d2.play_state()["game_ended"].get("reason", "")) != SharedGameSession.END_D2:
		return "PTD-end-conditions S3 D2"
	return ""


func _check_refuse_after_end() -> String:
	var session := SharedGameSession.new()
	session.start_opening()
	session.resign()
	if session.try_move("e2", "e4"):
		return "ended session must refuse moves"
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
