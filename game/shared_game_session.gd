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
const UI_S4 := "S4"
const UI_S5 := "S5"
const UI_S6 := "S6"
const CONFIRM_RESIGN := "resign"
const CONFIRM_OFFER := "offer"
## PER.R8 refused-place flash duration (seconds).
const REJECT_FLASH_S := 0.3
## CFG.BLITZ_START / CFG.RAPID_START (technical T1 / T2), seconds.
const BLITZ_START_S := 60
const RAPID_START_S := 600
const PROMOTE_ORDER := ["queen", "rook", "bishop", "knight"]

var rules: ChessRules
var clock_id := CLOCK_UNTIMED
var increment_ms := 0
var white_clock_ms: Variant = null
var black_clock_ms: Variant = null
var draw_offer := ""
var options_locked := false
## GS.selectedPiece — empty or one piece of the side to move.
var selected_piece := ""
## Play UI state: S1 default; S2 confirm; S4 promote; S5 reject flash; S6 draw-offer.
var play_ui_state := UI_S1
## GS.advice — whether Advice may run (F-move-advice.R2); toggled by C3.
var advice_on := true
## GS.online — the advice service is reachable (F-move-advice.R2, X3). Web starts
## optimistic until a request or cancel reveals the browser is offline.
var online := true
## R1 — Advice never runs in Puzzle stream (CFG.K3); the router clears this when
## the Shared game is left and a puzzle session takes over.
var in_shared_game := false
## L4 advice client; set by the router once T6 / T9 / T10 are configured.
var advice_client: AdviceClient

var last_reject := ""
## Square that refused a place (PER.R8); cleared when S5 ends.
var reject_square := ""
## S2 confirm kind: resign or offer draw.
var confirm_kind := ""
## Pending last-rank place waiting on C6 (from/to squares).
var pending_promote_from := ""
var pending_promote_to := ""
var _clocks_stopped := false
## Side whose clock is running; empty when none (untimed, stopped, or between moves).
var _active_side := ""
## GS.adviceBestMove / GS.adviceEval (SCH-advice-update F1–F3); null until set.
var _advice_best_move: Variant = null
var _advice_eval: Variant = null
## FAIL.T1 events not yet reported to the session owner (EX.error is UI leaf's).
var _advice_events: Array = []


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
	in_shared_game = true
	last_reject = ""
	reject_square = ""
	confirm_kind = ""
	pending_promote_from = ""
	pending_promote_to = ""
	_clear_advice()
	_configure_clocks(p_clock, p_increment_s)
	_sync_advice()


## Legacy/test helper: untimed, or both clocks at timed_ms with no increment.
func _start_opening(timed_ms: Variant = null) -> void:
	if timed_ms == null:
		start_shared(CLOCK_UNTIMED, 0)
		return
	rules.reset_opening()
	draw_offer = ""
	_clocks_stopped = false
	options_locked = true
	selected_piece = ""
	play_ui_state = UI_S1
	in_shared_game = true
	last_reject = ""
	reject_square = ""
	confirm_kind = ""
	pending_promote_from = ""
	pending_promote_to = ""
	_clear_advice()
	clock_id = CLOCK_BLITZ
	increment_ms = 0
	var ms := int(timed_ms)
	white_clock_ms = ms
	black_clock_ms = ms
	_active_side = ChessRules.SIDE_WHITE
	_sync_advice()


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
		"online": online,
		"advice_best_move": _advice_best_move,
		"advice_eval": _advice_eval,
		"last_reject": last_reject,
		"reject_square": reject_square,
		"confirm_kind": confirm_kind,
		"pending_promote_from": pending_promote_from,
		"pending_promote_to": pending_promote_to,
	}


func side_to_move() -> String:
	return str(rules.position_field().get("side_to_move", ChessRules.SIDE_WHITE))


func occupancy_at(square: String) -> Dictionary:
	var occ: Dictionary = rules.position_field().get("occupancy", {})
	return occ.get(square, {}) as Dictionary


func legal_targets_for(square: String) -> PackedStringArray:
	return rules.legal_targets(square)


func _in_check_now() -> bool:
	return rules.in_check(side_to_move())


func game_ended() -> bool:
	return bool(rules.game_ended_field().get("ended", false))


func _end_reason() -> String:
	return str(rules.game_ended_field().get("reason", ""))


func gestures_available() -> bool:
	## Board stays playable in S1, S5 (flash), and S6 (draw panel). S4 waits on C6.
	if game_ended():
		return false
	return play_ui_state == UI_S1 or play_ui_state == UI_S5 or play_ui_state == UI_S6


## Display seconds for the running clock (null when untimed); used to throttle chrome.
func _clock_display_key() -> String:
	if white_clock_ms == null:
		return ""
	return "%d:%d:%s" % [int(white_clock_ms) / 1000, int(black_clock_ms) / 1000, play_ui_state]


## C1 / B2 — select an own piece of the side to move.
## Returns {ok, event, outcome, story} for telemetry.
func select_own(square: String) -> Dictionary:
	if not gestures_available():
		return {"ok": false}
	_clear_reject_flash()
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


## C10 / B8 / B9 / B11 — clear selection; in S4 drops promotion choice.
func clear_selection() -> Dictionary:
	if game_ended():
		return {"ok": false}
	if play_ui_state == UI_S2:
		return {"ok": false}
	if play_ui_state == UI_S4:
		pending_promote_from = ""
		pending_promote_to = ""
		play_ui_state = UI_S1
		# Leave the pawn selected (states.md S4).
		return {
			"ok": true,
			"event": "shared.deselect",
			"outcome": "promote_cancel",
			"story": "UI-shared-play.US1.5",
		}
	if selected_piece.is_empty() and play_ui_state != UI_S5:
		return {"ok": false}
	selected_piece = ""
	_clear_reject_flash()
	if play_ui_state == UI_S5:
		play_ui_state = UI_S1
	return {
		"ok": true,
		"event": "shared.deselect",
		"outcome": "ok",
		"story": "UI-shared-play.US1.5",
	}


func can_place(from_square: String, to_square: String, promotion: String = "") -> bool:
	if not gestures_available():
		return false
	if game_ended():
		return false
	return rules._can_apply_move(from_square, to_square, promotion)


func _needs_promotion(from_square: String, to_square: String) -> bool:
	return rules._reject_reason(from_square, to_square, "") == ChessRules.REASON_PROMOTION


## C2 / B3 / B10 — place; refused place → S5; last-rank without kind → S4.
## Returns {ok, illegal, ended, check, move, event, outcome, story, end_reason, promote}.
func place(from_square: String, to_square: String, promotion: String = "") -> Dictionary:
	if not gestures_available():
		return {"ok": false}
	_clear_reject_flash()
	last_reject = ""
	var before_side := side_to_move()
	# Empty non-destination while selected → IN.deselect (not EX.rejected).
	if (
		not selected_piece.is_empty()
		and from_square == selected_piece
		and occupancy_at(to_square).is_empty()
		and not legal_targets_for(selected_piece).has(to_square)
	):
		return clear_selection()
	if promotion.is_empty() and _needs_promotion(from_square, to_square):
		if selected_piece.is_empty():
			var piece := occupancy_at(from_square)
			if not piece.is_empty() and str(piece.get("color", "")) == before_side:
				selected_piece = from_square
		pending_promote_from = from_square
		pending_promote_to = to_square
		play_ui_state = UI_S4
		return {
			"ok": true,
			"illegal": false,
			"promote": true,
			"event": "shared.promote",
			"outcome": "choose",
			"story": "UI-shared-play.US1.6",
			"pending_from": from_square,
			"pending_to": to_square,
		}
	var applied := try_move(from_square, to_square, promotion)
	if not applied:
		if selected_piece.is_empty():
			var piece := occupancy_at(from_square)
			if not piece.is_empty() and str(piece.get("color", "")) == before_side:
				selected_piece = from_square
		last_reject = "illegal"
		reject_square = to_square
		play_ui_state = UI_S5
		return {
			"ok": false,
			"illegal": true,
			"reject_square": to_square,
			"event": "shared.move",
			"outcome": "illegal",
			"story": "UI-shared-play.US1.3",
		}
	_on_advice_move_complete()
	selected_piece = ""
	pending_promote_from = ""
	pending_promote_to = ""
	if play_ui_state == UI_S6:
		play_ui_state = UI_S1
	var move_dict := {"from": from_square, "to": to_square}
	if not promotion.is_empty():
		move_dict["promote"] = promotion
	var result := {
		"ok": true,
		"illegal": false,
		"event": "shared.move",
		"outcome": "ok",
		"story": "UI-shared-play.US1.3",
		"move": move_dict,
		"check": _in_check_now(),
		"ended": game_ended(),
		"end_reason": _end_reason(),
	}
	return result


## C6 — commit promotion kind and apply the pending place.
func commit_promotion(kind: String) -> Dictionary:
	if play_ui_state != UI_S4:
		return {"ok": false}
	if not PROMOTE_ORDER.has(kind):
		return {"ok": false}
	var from_sq := pending_promote_from
	var to_sq := pending_promote_to
	play_ui_state = UI_S1
	pending_promote_from = ""
	pending_promote_to = ""
	var result := place(from_sq, to_sq, kind)
	if bool(result.get("ok", false)):
		result["event"] = "shared.promote"
		result["outcome"] = "commit"
		result["story"] = "UI-shared-play.US1.6"
	return result


func finish_reject_flash() -> Dictionary:
	if play_ui_state != UI_S5:
		return {"ok": false}
	reject_square = ""
	last_reject = ""
	play_ui_state = UI_S1
	return {"ok": true}


## Chrome controls C3–C9 / confirm / cancel — one public entry for max-public-methods.
func handle_play_control(control_id: String) -> Dictionary:
	var result := {"ok": false}
	match control_id:
		"C3":
			result = _toggle_advice()
		"C4":
			result = _open_resign_confirm()
		"C5":
			result = _open_offer_confirm()
		"C7":
			result = _accept_draw_choice()
		"C8":
			result = _decline_draw_choice()
		"C9":
			result = _withdraw_draw_choice()
		"confirm":
			if confirm_kind == CONFIRM_OFFER:
				result = _confirm_offer()
			else:
				result = _confirm_resign()
		"cancel":
			result = _cancel_confirm()
	return result


## C4/C5 available in S1/S4/S5 (not S2/S6); see shared-play-controls.md.
func _confirm_openable() -> bool:
	if game_ended():
		return false
	return play_ui_state == UI_S1 or play_ui_state == UI_S4 or play_ui_state == UI_S5


## Drop S4 pending choice / S5 flash before entering EX.confirm (Cancel → S1).
func _leave_choice_for_confirm() -> void:
	if play_ui_state == UI_S4:
		pending_promote_from = ""
		pending_promote_to = ""
	elif play_ui_state == UI_S5:
		reject_square = ""
		last_reject = ""


func _open_resign_confirm() -> Dictionary:
	if not _confirm_openable():
		return {"ok": false}
	_leave_choice_for_confirm()
	play_ui_state = UI_S2
	confirm_kind = CONFIRM_RESIGN
	return {
		"ok": true, "event": "shared.resign", "outcome": "confirm", "story": "UI-shared-play.US1.1"
	}


func _open_offer_confirm() -> Dictionary:
	if not _confirm_openable():
		return {"ok": false}
	_leave_choice_for_confirm()
	play_ui_state = UI_S2
	confirm_kind = CONFIRM_OFFER
	return {
		"ok": true,
		"event": "shared.draw",
		"outcome": "confirm",
		"story": "UI-shared-play.US1.7",
	}


func _confirm_resign() -> Dictionary:
	if play_ui_state != UI_S2 or confirm_kind != CONFIRM_RESIGN:
		return {"ok": false}
	if not resign():
		return {"ok": false}
	play_ui_state = UI_S1
	confirm_kind = ""
	selected_piece = ""
	return {
		"ok": true,
		"ended": true,
		"end_reason": END_L2,
		"event": "shared.resign",
		"outcome": "end",
		"story": "UI-shared-play.US1.1",
	}


func _confirm_offer() -> Dictionary:
	if play_ui_state != UI_S2 or confirm_kind != CONFIRM_OFFER:
		return {"ok": false}
	if not _offer_draw():
		return {"ok": false}
	confirm_kind = ""
	play_ui_state = UI_S6
	return {
		"ok": true,
		"event": "shared.draw",
		"outcome": "offered",
		"story": "UI-shared-play.US1.7",
	}


func _cancel_confirm() -> Dictionary:
	if play_ui_state != UI_S2:
		return {"ok": false}
	play_ui_state = UI_S1
	confirm_kind = ""
	return {"ok": true}


func _accept_draw_choice() -> Dictionary:
	if play_ui_state != UI_S6:
		return {"ok": false}
	if not _accept_draw():
		return {"ok": false}
	play_ui_state = UI_S1
	selected_piece = ""
	return {
		"ok": true,
		"ended": true,
		"end_reason": END_D2,
		"event": "shared.draw",
		"outcome": END_D2,
		"story": "UI-shared-play.US1.7",
	}


func _decline_draw_choice() -> Dictionary:
	if play_ui_state != UI_S6:
		return {"ok": false}
	if not _decline_draw():
		return {"ok": false}
	play_ui_state = UI_S1
	return {
		"ok": true,
		"event": "shared.draw",
		"outcome": "decline",
		"story": "UI-shared-play.US1.7",
	}


func _withdraw_draw_choice() -> Dictionary:
	if play_ui_state != UI_S6:
		return {"ok": false}
	if not _withdraw_draw():
		return {"ok": false}
	play_ui_state = UI_S1
	return {
		"ok": true,
		"event": "shared.draw",
		"outcome": "withdraw",
		"story": "UI-shared-play.US1.7",
	}


func _toggle_advice() -> Dictionary:
	if play_ui_state == UI_S2 or game_ended():
		return {"ok": false}
	advice_on = not advice_on
	_sync_advice()
	return {
		"ok": true, "event": "shared.advice", "outcome": "toggled", "story": "UI-shared-play.US1.4"
	}


func chrome_state(locale: String, white_seat: String) -> Dictionary:
	var ended := game_ended()
	var field := rules.position_field()
	var legal := PackedStringArray()
	if not selected_piece.is_empty() and play_ui_state != UI_S4:
		legal = legal_targets_for(selected_piece)
	var in_s2 := play_ui_state == UI_S2
	var in_s4 := play_ui_state == UI_S4
	var in_s6 := play_ui_state == UI_S6
	var playable_board := not ended and not in_s2 and not in_s4
	return {
		"locale": locale,
		"white_seat": white_seat,
		"clock": clock_id,
		"increment": increment_ms / 1000 if increment_ms > 0 else 3,
		"advice": advice_on,
		"online": online,
		"advice_available": _advice_available(),
		"advice_best_move": _advice_best_move,
		"advice_eval": _advice_eval,
		"options_locked": options_locked,
		"ui_state": play_ui_state,
		"position": field,
		"selection": selected_piece,
		"legal": legal,
		"side_to_move": side_to_move(),
		"in_check": _in_check_now(),
		"white_clock_ms": white_clock_ms,
		"black_clock_ms": black_clock_ms,
		"game_ended": ended,
		"end_reason": _end_reason(),
		"resign_available": not ended and not in_s2 and not in_s6,
		"offer_available": not ended and not in_s2 and not in_s6,
		"board_unavailable": in_s2 or ended,
		"last_reject": last_reject,
		"reject_square": reject_square,
		"confirm_kind": confirm_kind,
		"pending_promote_from": pending_promote_from,
		"pending_promote_to": pending_promote_to,
		"promote_kinds": PROMOTE_ORDER.duplicate() if in_s4 else [],
		"draw_offer": draw_offer,
		"c1_available": playable_board,
		"c2_available": playable_board,
		"c3_available": not ended and not in_s2,
		"c4_available": not ended and not in_s2 and not in_s6,
		"c5_available": not ended and not in_s2 and not in_s6,
		"c6_available": in_s4,
		"c7_available": in_s6,
		"c8_available": in_s6,
		"c9_available": in_s6,
		"c10_available": playable_board,
	}


func _clear_reject_flash() -> void:
	if play_ui_state == UI_S5:
		play_ui_state = UI_S1
	reject_square = ""
	last_reject = ""


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


func _offer_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	draw_offer = str(rules.position_field()["side_to_move"])
	return true


func _withdraw_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	var side := str(rules.position_field()["side_to_move"])
	if draw_offer != side:
		return false
	draw_offer = ""
	return true


func _decline_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	if draw_offer.is_empty():
		return false
	var side := str(rules.position_field()["side_to_move"])
	if draw_offer != side:
		return false
	draw_offer = ""
	return true


func _accept_draw() -> bool:
	if bool(rules.game_ended_field().get("ended", false)):
		return false
	if draw_offer.is_empty():
		return false
	var side := str(rules.position_field()["side_to_move"])
	if draw_offer != side:
		return false
	_finish(END_D2)
	return true


func _set_clock_ms(side: String, ms: int) -> void:
	var clamped := maxi(0, ms)
	if side == ChessRules.SIDE_WHITE:
		white_clock_ms = clamped
	elif side == ChessRules.SIDE_BLACK:
		black_clock_ms = clamped


## After a custom position load: only the side-to-move clock runs (SCH I3 / GS.V2).
func _sync_active_to_side_to_move() -> void:
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
	_set_clock_ms(_active_side, remaining)
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
			_set_clock_ms(mover, ms)
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
	_stop_advice()


## R4 — Advice runs only in a Shared game, when On and online (F-move-advice
## R1, R2, CFG.K3). A puzzle position is never handed to the advice client.
func _advice_allowed() -> bool:
	return advice_on and online and in_shared_game and not game_ended()


## Whether the C3 toggle can fetch advice (B3): a client aimed at T9 with T10.
func _advice_available() -> bool:
	return advice_client != null and advice_client.is_available()


## One public entry for the advice lifecycle the router drives. Returns the
## telemetry events for the caller to report (TEL.4 / TEL.5).
## `poll` drains U3 → U2 without blocking the move path (concurrency.md S1);
## `leave` is R9 (leaving the Shared game); `offline` is X3.
func advice_control(control_id: String) -> Dictionary:
	match control_id:
		"poll":
			_poll_advice()
		"leave":
			in_shared_game = false
			online = true
			_stop_advice()
		"offline":
			_mark_offline()
	var events := _advice_events
	_advice_events = []
	return {"events": events}


func _poll_advice() -> void:
	if advice_client == null:
		return
	var state := _advice_state()
	var ready := advice_client.poll(state)
	var failed := advice_client.failed()
	_advice_best_move = state["advice_best_move"]
	_advice_eval = state["advice_eval"]
	if failed:
		# FAIL.T1 supersedes this tick's `advice ready`: advice is gone.
		_mark_offline()
		_advice_events.append(_unavailable_event())
	elif not ready.is_empty():
		_advice_events.append(ready)


func _unavailable_event() -> Dictionary:
	return {"event": "advice.error", "outcome": "unavailable", "story": "F-move-advice.R2"}


## X3 — the advice service answered with an error or timeout (FAIL.T1).
func _mark_offline() -> void:
	online = false
	_stop_advice()


## Start, restart, or stop the stream so it matches F-move-advice.R2 / R9.
## B3: when T9 or T10 is missing there is nothing to request, so this is a
## configuration state, not a request that failed (no FAIL.T1 without a request).
func _sync_advice() -> void:
	if advice_client == null:
		return
	if not _advice_allowed() or not advice_client.is_available():
		_stop_advice()
		return
	advice_client.start(rules.position_field(), rules.castling_ep())


## R8 / X1 — a completed move clears advice, then the new position if R2 holds.
func _on_advice_move_complete() -> void:
	if advice_client != null:
		advice_client.cancel(_advice_state())
		_advice_best_move = null
		_advice_eval = null
	_sync_advice()


func _stop_advice() -> void:
	if advice_client != null:
		advice_client.cancel(_advice_state())
	_advice_best_move = null
	_advice_eval = null


func _advice_state() -> Dictionary:
	return {"advice_best_move": _advice_best_move, "advice_eval": _advice_eval}


func _clear_advice() -> void:
	_advice_best_move = null
	_advice_eval = null
	_advice_events.clear()
