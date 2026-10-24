class_name PuzzlePlayTest
extends SceneTree
## UI-puzzle-play R1–R3 / C1–C6 / S1–S5 and J-puzzle-session S1–S2 / B1 (#333):
## panel copy, availability and focus order, stream actions through the router,
## the solving-side board, the result cue and its X5, S3 save failure, and leave.

const MATE_FEN := "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1"
const MATE_RECORDED_MOVE := "b1b8"
const MATE_NON_MATING_MOVE := "b1b7"
const MATE_ILLEGAL_MOVE := "g1g2"
const MATE_OPPONENT_MOVE := "g8h8"
## Solving side Black: White plays the recorded opponent move `d2d4`, leaving Black to move.
const BLACK_FEN := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
## Last-rank pawn place after the recorded `a8b8` opponent move (S4 fixture).
const PROMOTION_FEN := "k7/6P1/8/8/8/8/8/7K b - - 0 1"

var _presentation: Presentation
var _router: SessionRouter


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_router.locale = "en"
	_router.last_mode = "none"
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	var problem := await _entry_and_leave()
	if problem.is_empty():
		problem = await _actions_and_states()
	if problem.is_empty():
		problem = await _promotion_and_save_failure()
	if problem.is_empty():
		quit(0)
		return
	push_error(problem)
	quit(1)


## UI-mode-pick.C2 → NAV.T2 → J-puzzle-session.S1, then C5 → B1 cancel and NAV.T9.
func _entry_and_leave() -> String:
	_router.locale = "en"
	_router._go_mode_pick("S1")
	await process_frame
	var puzzle_btn := _mode_pick().find_child("PuzzleStream", true, false) as Button
	if puzzle_btn == null:
		return "mode-pick omits C2 Puzzle stream"
	if puzzle_btn.text != StringTable.mode_pick("puzzle", "en"):
		return "C2 label is not the mode-pick puzzle key"
	_router.handle_control("mode-pick", "C2")
	await process_frame
	var problem := ""
	if _router.stage != SessionRouter.STAGE_PUZZLE_PLAY:
		problem = "C2 did not enter puzzle-play (NAV.T2)"
	elif _router.last_mode != SessionRouter.MODE_PUZZLE:
		problem = "C2 did not commit Last mode puzzle (PRG.M1)"
	elif not _panel().visible:
		problem = "puzzle-play panel hidden after C2"
	elif _session() == null:
		problem = "no puzzle session on entering the stream"
	if problem.is_empty():
		_deal_mate()
		var elo := _panel().find_child("PlayerElo", true, false) as Label
		if elo == null or not elo.visible or not elo.text.begins_with("Elo"):
			problem = "R2 does not show GS.playerElo"
		elif _board().white_seat != BoardGeometry.SEAT_BOTTOM:
			problem = "Solving side White must read 0° (CAM-board.M2)"
	if problem.is_empty():
		problem = await _solving_side_black()
	if problem.is_empty():
		# B1 — Cancel on the leave confirm keeps the open puzzle, unscored.
		_router.handle_control("puzzle-play", "C5")
		if _session().play_ui_state != PuzzleSession.UI_S2:
			problem = "C5 did not raise EX.confirm"
		elif _session().confirm_kind != PuzzleSession.CONFIRM_LEAVE:
			problem = "C5 confirm is not named leave_confirm"
	if problem.is_empty():
		var msg := _panel().find_child("StreamConfirmMsg", true, false) as Label
		if msg == null or msg.text != StringTable.puzzle_play("leave_confirm", "en"):
			problem = "leave confirm shows the wrong copy"
	var elo_before := 0.0
	if problem.is_empty():
		elo_before = _session().player_elo
		_router.handle_control("puzzle-play", "cancel")
		if _router.stage != SessionRouter.STAGE_PUZZLE_PLAY:
			problem = "Cancel on leave left puzzle-play (B1)"
		elif _session() == null or not _session().has_open_puzzle():
			problem = "Cancel on leave closed the open puzzle (B1)"
		elif not is_equal_approx(_session().player_elo, elo_before):
			problem = "Cancel on leave scored the puzzle"
	if problem.is_empty():
		# NAV.T9 — Confirm on leave returns to mode-pick without scoring.
		_router.handle_control("puzzle-play", "C5")
		_router.handle_control("puzzle-play", "confirm")
		await process_frame
		if _router.stage != SessionRouter.STAGE_MODE_PICK:
			problem = "leave confirm did not return to mode-pick (NAV.T9)"
		elif _session() != null:
			problem = "leave kept the puzzle session"
	if problem.is_empty():
		var doc := (_presentation.get_node("PersistStore") as PersistStore).read_committed()
		if not is_equal_approx(float(doc.get("player_elo", 0.0)), elo_before):
			problem = "leave scored the open puzzle (K4 / PRG.P1)"
	return problem


## R2 cue + X5 on a Wrong move, C3/C4 copy and outcomes, S1 focus order.
func _actions_and_states() -> String:
	_router.handle_control("mode-pick", "C2")
	await process_frame
	_deal_mate()
	var audio := _presentation.get_node("PresentationAudio") as PresentationAudio
	var cue := _panel().find_child("ResultCue", true, false) as Label
	var problem := ""
	# EX.rejected — an illegal place is S5, not a Wrong move, and plays no cue.
	_router.handle_input_commit(MATE_ILLEGAL_MOVE.substr(0, 2), MATE_ILLEGAL_MOVE.substr(2, 2), "")
	await process_frame
	if _session().play_ui_state != PuzzleSession.UI_S5:
		problem = "an illegal place did not enter S5"
	elif audio.last_cue_id == SharedAudioCues.CUE_X5 and audio.cue_play_count > 0:
		problem = "S5 refused place played SND.X5"
	if problem.is_empty():
		_session().finish_reject_flash()
		# A Wrong move: R2 `cue_wrong` and one SND.X5 through the cue mechanism.
		_router.handle_input_commit(
			MATE_NON_MATING_MOVE.substr(0, 2), MATE_NON_MATING_MOVE.substr(2, 2), ""
		)
		await process_frame
		if cue == null or cue.text != StringTable.puzzle_play("cue_wrong", "en"):
			problem = "R2 does not show cue_wrong after a Wrong move"
		elif audio.last_cue_id != SharedAudioCues.CUE_X5:
			problem = "a Wrong move did not play SND.X5"
		elif audio.cue_play_count != 1:
			problem = "a Wrong move played more than one cue"
	if problem.is_empty():
		# S2 for Reveal: named prompt, Confirm ends the attempt with `cue_failed`.
		_router.handle_control("puzzle-play", "C3")
		var states := _panel().focusable_controls()
		if _session().confirm_kind != PuzzleSession.CONFIRM_REVEAL:
			problem = "C3 confirm is not named reveal_confirm"
		elif states.size() != 2 or states[0].name != "ConfirmStream":
			problem = "S2 focus order is not Confirm then Cancel"
	if problem.is_empty():
		_router.handle_control("puzzle-play", "confirm")
		await process_frame
		if cue == null or cue.text != StringTable.puzzle_play("cue_failed", "en"):
			problem = "L5 did not show cue_failed"
	if problem.is_empty():
		# S2 for Abandon: Confirm → END.L6 → `cue_abandon`.
		_deal_mate()
		_router.handle_control("puzzle-play", "C4")
		_router.handle_control("puzzle-play", "confirm")
		await process_frame
		if cue == null or cue.text != StringTable.puzzle_play("cue_abandon", "en"):
			problem = "L6 did not show cue_abandon"
	if problem.is_empty():
		_deal_mate()
		problem = _s1_focus_order(_panel())
	return problem


## S1 availability and focus order (puzzle-play-controls.md), including the 44px class.
func _s1_focus_order(panel: PuzzlePlayPanel) -> String:
	panel.refresh()
	if not panel.control_available("C1") or not panel.control_available("C5"):
		return "S1 should offer C1 and C5"
	var controls := panel.focusable_controls()
	var names: Array = []
	for ctrl in controls:
		names.append(str(ctrl.name))
	if names != ["SelectFocus", "PlaceFocus", "Reveal", "Abandon", "LeaveStream"]:
		return "S1 focus order is %s" % [str(names)]
	for ctrl in controls:
		if ctrl is Button and (ctrl as Button).size.y + 0.5 < PuzzlePlayPanel.TOUCH_TARGET_PX:
			return "control %s is below the 44px-class target" % [ctrl.name]
	return ""


## S4 promotion (judged only after C6) and S3 save failure with C1–C5 usable.
func _promotion_and_save_failure() -> String:
	_router.handle_control("puzzle-play", "C5")
	_router.handle_control("puzzle-play", "confirm")
	await process_frame
	_router.handle_control("mode-pick", "C2")
	await process_frame
	_deal(_record("promo1", 1000, PROMOTION_FEN, ["a8b8", "g7g8q"]))
	_router.handle_input_commit("g7", "g8", "")
	await process_frame
	var panel := _panel()
	var problem := ""
	if _session().play_ui_state != PuzzleSession.UI_S4:
		problem = "a last-rank pawn place did not enter S4"
	if problem.is_empty():
		var kinds: Array = []
		for ctrl in panel.focusable_controls():
			kinds.append(str(ctrl.name))
		if kinds != ["PromoteQueen", "PromoteRook", "PromoteBishop", "PromoteKnight"]:
			problem = "S4 focus order is %s" % [str(kinds)]
	if problem.is_empty():
		var status := panel.find_child("PuzzleStatus", true, false) as Label
		if status == null or status.text != StringTable.puzzle_play("choose_promotion", "en"):
			problem = "S4 does not show choose_promotion"
	if problem.is_empty():
		# IN.deselect leaves the pawn selected and drops the choice.
		if not _router.handle_deselect():
			problem = "IN.deselect did not cancel S4"
		elif _session().play_ui_state != PuzzleSession.UI_S1:
			problem = "S4 deselect did not return to S1"
		elif _session().selected_piece != "g7":
			problem = "S4 deselect dropped the pawn selection"
	if problem.is_empty():
		_router.handle_input_commit("g7", "g8", "")
		_router.handle_promotion_commit("queen")
		await process_frame
		var cue := panel.find_child("ResultCue", true, false) as Label
		if cue.text != StringTable.puzzle_play("cue_solved", "en"):
			problem = "W1 did not show cue_solved (got %s)" % cue.text
	if problem.is_empty():
		problem = await _save_failure()
	return problem


func _save_failure() -> String:
	var persist := _presentation.get_node("PersistStore") as PersistStore
	_deal_mate()
	persist.force_write_failure = true
	_router.handle_input_commit(
		MATE_RECORDED_MOVE.substr(0, 2), MATE_RECORDED_MOVE.substr(2, 2), ""
	)
	await process_frame
	if _session().play_ui_state != PuzzleSession.UI_S3:
		return "a failed commit did not enter S3"
	var panel := _panel()
	var msg := panel.find_child("SaveFailureMsg", true, false) as Label
	if msg == null or msg.text != StringTable.puzzle_play("save_failed", "en"):
		return "S3 does not show save_failed"
	if not panel.control_available("C3") or not panel.control_available("C4"):
		return "S3 must keep C1–C5 usable"
	if panel.focusable_controls().back().name != "DismissSave":
		return "S3 focus order does not end with Dismiss"
	_router.handle_control("puzzle-play", "dismiss")
	if _session().play_ui_state != PuzzleSession.UI_S1:
		return "S3 Dismiss did not return to S1"
	return ""


## CAM-board.M2 puzzle reading: a Black solving side reads 180° (White seat top).
func _solving_side_black() -> String:
	var rec := _record("black1", 1000, BLACK_FEN, ["d2d4", "g8f6"])
	_deal(rec)
	if _session().solving_side != ChessRules.SIDE_BLACK:
		return "Black-to-move record did not make Black the solving side"
	if _board().white_seat != BoardGeometry.SEAT_TOP:
		return "Solving side Black must read 180° (CAM-board.M2)"
	return ""


func _deal(record: Dictionary = {}) -> void:
	var rec := record if not record.is_empty() else _mate_record()
	var session := _session()
	# PuzzleSession.deal refuses while an attempt is open (K3 / I3), so retire any
	# standing attempt first; leave() keeps Elo and drops it, as a cue-read would.
	if session.has_open_puzzle():
		session.leave()
	session.deal([rec])
	_router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, _router.puzzle_flow.state())


## The L2 session behind the router's puzzle journey.
func _session() -> PuzzleSession:
	return _router.puzzle_flow.session if _router.puzzle_flow != null else null


func _deal_mate() -> void:
	_deal()


func _mate_record() -> Dictionary:
	return _record("mate1", 1000, MATE_FEN, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE])


func _record(id: String, rating: int, fen: String, moves: Array) -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": id,
		"fen": fen,
		"moves": moves,
		"rating": rating,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": [],
		"game_url": "",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}


func _mode_pick() -> ModePickPanel:
	return _presentation.get_node("ScreenHost/ModePick") as ModePickPanel


func _panel() -> PuzzlePlayPanel:
	return _presentation.get_node("ScreenHost/PuzzlePlay") as PuzzlePlayPanel


func _board() -> BoardPresentation:
	return _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
