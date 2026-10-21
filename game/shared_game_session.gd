class_name SharedGameSession
extends RefCounted
## CMP-shared-game-session (L2). Resign / draw-offer ops and end handoff (END.L1–D4, L2, D2).

const END_L2 := "END.L2"
const END_D2 := "END.D2"
const RESULT_WHITE := "result_white"
const RESULT_BLACK := "result_black"
const RESULT_DRAW := "result_draw"
const REASON_ENDED := "ended"

var rules: ChessRules
var white_clock_ms: Variant = null
var black_clock_ms: Variant = null
var draw_offer := ""
var _clocks_stopped := false


func _init(chess_rules: ChessRules = null) -> void:
	rules = chess_rules if chess_rules != null else ChessRules.new()


func start_opening(timed_ms: Variant = null) -> void:
	rules.reset_opening()
	draw_offer = ""
	_clocks_stopped = false
	if timed_ms == null:
		white_clock_ms = null
		black_clock_ms = null
	else:
		var ms := int(timed_ms)
		white_clock_ms = ms
		black_clock_ms = ms


func play_state() -> Dictionary:
	var ended: Dictionary = rules.game_ended_field()
	return {
		"position": rules.position_field(),
		"castling_ep": rules.castling_ep(),
		"clocks": {"white": white_clock_ms, "black": black_clock_ms},
		"game_ended": ended,
		"mode": "shared",
		"repetition_history": rules.repetition_history(),
		"fifty_move_count": rules.fifty_move_count(),
		"draw_offer": draw_offer,
		"result_copy": result_copy_key(),
		"clocks_stopped": _clocks_stopped,
	}


func result_copy_key() -> String:
	var ended: Dictionary = rules.game_ended_field()
	if not bool(ended.get("ended", false)):
		return ""
	var reason := str(ended.get("reason", ""))
	if reason == ChessRules.END_D1 or reason == ChessRules.END_D3 or reason == ChessRules.END_D4:
		return RESULT_DRAW
	if reason == END_D2:
		return RESULT_DRAW
	if reason == ChessRules.END_L1 or reason == END_L2:
		var loser := str(rules.position_field()["side_to_move"])
		if loser == ChessRules.SIDE_WHITE:
			return RESULT_BLACK
		return RESULT_WHITE
	return ""


func try_move(from_square: String, to_square: String, promotion: String = "") -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		rules.move_rejected.emit(REASON_ENDED)
		return false
	var ok := rules.try_move(from_square, to_square, promotion)
	if not ok:
		return false
	_lapse_draw_offer_after_move()
	_apply_position_ending()
	return true


func resign() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	# END.L2 even when this side's clock is already zero (never END.D5 here; clocks are #55).
	_finish(END_L2)
	return true


func offer_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	draw_offer = str(rules.position_field()["side_to_move"])
	return true


func withdraw_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	var side := str(rules.position_field()["side_to_move"])
	if draw_offer != side:
		return false
	draw_offer = ""
	return true


func decline_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	if draw_offer.is_empty():
		return false
	var side := str(rules.position_field()["side_to_move"])
	# Other side declines while GS.drawOffer is the side to move.
	if draw_offer != side:
		return false
	draw_offer = ""
	return true


func accept_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	if draw_offer.is_empty():
		return false
	var side := str(rules.position_field()["side_to_move"])
	# GS.drawOffer is the side to move; the other side accepts.
	if draw_offer != side:
		return false
	_finish(END_D2)
	return true


func set_clock_ms(side: String, ms: int) -> void:
	if side == ChessRules.SIDE_WHITE:
		white_clock_ms = ms
	elif side == ChessRules.SIDE_BLACK:
		black_clock_ms = ms


func _lapse_draw_offer_after_move() -> void:
	draw_offer = ""


func _apply_position_ending() -> void:
	var signals: Dictionary = rules.end_signals()
	var ending := str(signals.get("ending", ""))
	if ending.is_empty():
		return
	_finish(ending)


func _finish(reason: String) -> void:
	rules.mark_ended(reason)
	draw_offer = ""
	_clocks_stopped = true
