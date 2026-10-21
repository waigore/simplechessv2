class_name SharedGameSession
extends RefCounted
## CMP-shared-game-session (L2). Moves (R2), clocks (R3), resign / draw-offer, end (R5).

const END_L2 := "END.L2"
const END_L3 := "END.L3"
const END_D2 := "END.D2"
const END_D5 := "END.D5"
const RESULT_WHITE := "result_white"
const RESULT_BLACK := "result_black"
const RESULT_DRAW := "result_draw"
const REASON_ENDED := "ended"
const CLOCK_UNTIMED := "untimed"
const CLOCK_BLITZ := "blitz"
const CLOCK_RAPID := "rapid"
const UI_S1 := "S1"
const UI_S2 := "S2"
## CFG.BLITZ_START / CFG.RAPID_START (technical T1 / T2), seconds.
const BLITZ_START_S := 60
const RAPID_START_S := 600

var rules: ChessRules
var clock_id := CLOCK_UNTIMED
var increment_ms := 0
var white_clock_ms: Variant = null
var black_clock_ms: Variant = null
var draw_offer := ""
var options_locked := false
## GS.selectedPiece — empty or one piece of the side to move.
var selected_piece := ""
## Play UI state: S1 default, S2 resign confirm.
var play_ui_state := UI_S1
## GS.advice — toggle only until advice client is wired (F-move-advice.R2).
var advice_on := true
var last_reject := ""
var _clocks_stopped := false
## Side whose clock is running; empty when none (untimed, stopped, or between moves).
var _active_side := ""


func _init(chess_rules: ChessRules = null) -> void:
	rules = chess_rules if chess_rules != null else ChessRules.new()


## Start a Shared game from runtime options (S3). Locks clock and increment (R1 / CFG.K2).
func start_shared(
	p_clock: String = CLOCK_UNTIMED, p_increment_s: int = 3, p_advice: bool = true
) -> void:
	rules.reset_opening()
	draw_offer = ""
	_clocks_stopped = false
	options_locked = true
	selected_piece = ""
	play_ui_state = UI_S1
	advice_on = p_advice
	last_reject = ""
	_configure_clocks(p_clock, p_increment_s)


## Legacy/test helper: untimed, or both clocks at timed_ms with no increment.
func start_opening(timed_ms: Variant = null) -> void:
	if timed_ms == null:
		start_shared(CLOCK_UNTIMED, 0)
		return
	rules.reset_opening()
	draw_offer = ""
	_clocks_stopped = false
	options_locked = true
	selected_piece = ""
	play_ui_state = UI_S1
	last_reject = ""
	clock_id = CLOCK_BLITZ
	increment_ms = 0
	var ms := int(timed_ms)
	white_clock_ms = ms
	black_clock_ms = ms
	_active_side = ChessRules.SIDE_WHITE


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
		"clock": clock_id,
		"increment_ms": increment_ms,
		"active_clock": _active_side,
		"options_locked": options_locked,
		"selected_piece": selected_piece,
		"play_ui_state": play_ui_state,
		"advice": advice_on,
		"last_reject": last_reject,
	}


func side_to_move() -> String:
	return str(rules.position_field().get("side_to_move", ChessRules.SIDE_WHITE))


func occupancy_at(square: String) -> Dictionary:
	var occ: Dictionary = rules.position_field().get("occupancy", {})
	return occ.get(square, {}) as Dictionary


func legal_targets_for(square: String) -> PackedStringArray:
	return rules.legal_targets(square)


func in_check_now() -> bool:
	return rules.in_check(side_to_move())


func game_ended() -> bool:
	return bool(rules.game_ended_field().get("ended", false))


func gestures_available() -> bool:
	return play_ui_state == UI_S1 and not game_ended()


## Display seconds for the running clock (null when untimed); used to throttle chrome.
func clock_display_key() -> String:
	if white_clock_ms == null:
		return ""
	return "%d:%d:%s" % [int(white_clock_ms) / 1000, int(black_clock_ms) / 1000, play_ui_state]


## C1 / B2 — select an own piece of the side to move.
## Returns {ok, event, outcome, story} for telemetry.
func select_own(square: String) -> Dictionary:
	if not gestures_available():
		return {"ok": false}
	var piece := occupancy_at(square)
	if piece.is_empty():
		return {"ok": false}
	if str(piece.get("color", "")) != side_to_move():
		return {"ok": false}
	if selected_piece == square:
		return {"ok": false}
	selected_piece = square
	last_reject = ""
	return {"ok": true, "event": "shared.select", "outcome": "ok", "story": "UI-shared-play.US1.2"}


func can_place(from_square: String, to_square: String, promotion: String = "") -> bool:
	if not gestures_available():
		return false
	if game_ended():
		return false
	return rules.can_apply_move(from_square, to_square, promotion)


## C2 / B3 / B10 — place; rules-level refuse keeps selection (danger flash is #94).
## Returns {ok, illegal, ended, check, move, event, outcome, story, end_reason}.
func place(from_square: String, to_square: String, promotion: String = "") -> Dictionary:
	if not gestures_available():
		return {"ok": false}
	last_reject = ""
	var before_side := side_to_move()
	var applied := try_move(from_square, to_square, promotion)
	if not applied:
		if selected_piece.is_empty():
			var piece := occupancy_at(from_square)
			if not piece.is_empty() and str(piece.get("color", "")) == before_side:
				selected_piece = from_square
		last_reject = "illegal"
		return {
			"ok": false,
			"illegal": true,
			"event": "shared.move",
			"outcome": "illegal",
			"story": "UI-shared-play.US1.3",
		}
	selected_piece = ""
	var result := {
		"ok": true,
		"illegal": false,
		"event": "shared.move",
		"outcome": "ok",
		"story": "UI-shared-play.US1.3",
		"move": {"from": from_square, "to": to_square},
		"check": in_check_now(),
		"ended": game_ended(),
		"end_reason": str(rules.game_ended_field().get("reason", "")),
	}
	return result


func open_resign_confirm() -> Dictionary:
	if play_ui_state != UI_S1 or game_ended():
		return {"ok": false}
	play_ui_state = UI_S2
	return {
		"ok": true, "event": "shared.resign", "outcome": "confirm", "story": "UI-shared-play.US1.1"
	}


func confirm_resign() -> Dictionary:
	if play_ui_state != UI_S2:
		return {"ok": false}
	if not resign():
		return {"ok": false}
	play_ui_state = UI_S1
	selected_piece = ""
	return {
		"ok": true,
		"ended": true,
		"end_reason": END_L2,
		"event": "shared.resign",
		"outcome": "end",
		"story": "UI-shared-play.US1.1",
	}


func cancel_resign() -> Dictionary:
	if play_ui_state != UI_S2:
		return {"ok": false}
	play_ui_state = UI_S1
	return {"ok": true}


func toggle_advice() -> Dictionary:
	if not gestures_available():
		return {"ok": false}
	advice_on = not advice_on
	return {
		"ok": true, "event": "shared.advice", "outcome": "toggled", "story": "UI-shared-play.US1.4"
	}


func chrome_state(locale: String, white_seat: String) -> Dictionary:
	var ended := game_ended()
	var field := rules.position_field()
	var legal := PackedStringArray()
	if not selected_piece.is_empty():
		legal = legal_targets_for(selected_piece)
	return {
		"locale": locale,
		"white_seat": white_seat,
		"clock": clock_id,
		"increment": increment_ms / 1000 if increment_ms > 0 else 3,
		"advice": advice_on,
		"options_locked": options_locked,
		"ui_state": play_ui_state,
		"position": field,
		"selection": selected_piece,
		"legal": legal,
		"side_to_move": side_to_move(),
		"in_check": in_check_now(),
		"white_clock_ms": white_clock_ms,
		"black_clock_ms": black_clock_ms,
		"game_ended": ended,
		"end_reason": str(rules.game_ended_field().get("reason", "")),
		"resign_available": not ended and play_ui_state == UI_S1,
		"board_unavailable": play_ui_state == UI_S2 or ended,
		"last_reject": last_reject,
	}


func result_copy_key() -> String:
	var ended: Dictionary = rules.game_ended_field()
	if not bool(ended.get("ended", false)):
		return ""
	var reason := str(ended.get("reason", ""))
	if (
		reason == ChessRules.END_D1
		or reason == ChessRules.END_D3
		or reason == ChessRules.END_D4
		or reason == END_D2
		or reason == END_D5
	):
		return RESULT_DRAW
	if reason == ChessRules.END_L1 or reason == END_L2 or reason == END_L3:
		var loser := str(rules.position_field()["side_to_move"])
		if loser == ChessRules.SIDE_WHITE:
			return RESULT_BLACK
		return RESULT_WHITE
	return ""


func try_move(from_square: String, to_square: String, promotion: String = "") -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		rules.move_rejected.emit(REASON_ENDED)
		return false
	var mover := str(rules.position_field()["side_to_move"])
	var ok := rules.try_move(from_square, to_square, promotion)
	if not ok:
		return false
	_after_completed_move(mover)
	return true


func resign() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	# END.L2 even when this side's clock is already zero (never END.D5 here).
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
	if draw_offer != side:
		return false
	_finish(END_D2)
	return true


func set_clock_ms(side: String, ms: int) -> void:
	var clamped := maxi(0, ms)
	if side == ChessRules.SIDE_WHITE:
		white_clock_ms = clamped
	elif side == ChessRules.SIDE_BLACK:
		black_clock_ms = clamped


## After a custom position load: only the side-to-move clock runs (SCH I3 / GS.V2).
func sync_active_to_side_to_move() -> void:
	if white_clock_ms == null or _clocks_stopped:
		_active_side = ""
		return
	if bool(rules.game_ended_field().get("ended", false)):
		_active_side = ""
		return
	_active_side = str(rules.position_field()["side_to_move"])


## concurrency.md U2: frame or fixed idle tick. Does not block presentation.
func tick(delta_ms: int) -> void:
	if delta_ms <= 0 or _clocks_stopped or _active_side.is_empty():
		return
	if bool(rules.game_ended_field().get("ended", false)):
		return
	if white_clock_ms == null:
		return
	var remaining := _clock_of(_active_side) - delta_ms
	if remaining < 0:
		remaining = 0
	set_clock_ms(_active_side, remaining)
	if remaining == 0:
		_expire_active_clock()


func _configure_clocks(p_clock: String, p_increment_s: int) -> void:
	clock_id = p_clock
	if p_clock != CLOCK_BLITZ and p_clock != CLOCK_RAPID:
		clock_id = CLOCK_UNTIMED
		white_clock_ms = null
		black_clock_ms = null
		increment_ms = 0
		_active_side = ""
		return
	# CFG.K1: increment only when Clock is Blitz or Rapid.
	var start_s := BLITZ_START_S if clock_id == CLOCK_BLITZ else RAPID_START_S
	var ms := start_s * 1000
	white_clock_ms = ms
	black_clock_ms = ms
	var inc_s := p_increment_s
	if inc_s != 3 and inc_s != 5:
		inc_s = 3
	increment_ms = inc_s * 1000
	_active_side = ChessRules.SIDE_WHITE


func _after_completed_move(mover: String) -> void:
	_lapse_draw_offer_after_move()
	if white_clock_ms != null:
		var ms := _clock_of(mover)
		# Increment only when that clock has not reached zero.
		if ms > 0 and increment_ms > 0:
			ms += increment_ms
			set_clock_ms(mover, ms)
		_active_side = ""
	_apply_position_ending()
	if bool(rules.game_ended_field().get("ended", false)):
		return
	if white_clock_ms != null:
		_active_side = _opponent(mover)


func _expire_active_clock() -> void:
	var timed_out := _active_side
	_active_side = ""
	# O4: other side can checkmate → L3; else D5. No seconds added (END.P1).
	var mating := _opponent(timed_out)
	if rules.possible_checkmate(mating):
		_finish(END_L3)
	else:
		_finish(END_D5)


func _clock_of(side: String) -> int:
	if side == ChessRules.SIDE_WHITE:
		return int(white_clock_ms)
	return int(black_clock_ms)


func _opponent(side: String) -> String:
	if side == ChessRules.SIDE_WHITE:
		return ChessRules.SIDE_BLACK
	return ChessRules.SIDE_WHITE


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
	_active_side = ""
