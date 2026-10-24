extends SceneTree
## Acceptance probe for #333 (puzzle play screen, mode-pick C2 entry, stream journey).
##
## Derived from docs/playtest/evidence/issue-708/graphical-20261024T044500Z/probe/ and
## docs/playtest/evidence/issue-546/graphical-20261024T201500Z/probe/.
##
## It adds no behaviour: it drives the shipped scene through the same control path a
## player uses (mode-pick C2 button press, panel sentinels/buttons pressed, board
## gestures through the router), reads the shipped state, and writes screenshots.
## Throwaway harness, shipped inside the evidence folder it produced.

const SHOT_DIR := "/tmp/opencode/accept333"

var _main: Node
var _seams: Node
var _router: SessionRouter
var _panel: Node
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate()
	root.add_child(_main)
	await _pump(6)

	_seams = _main.get_node("PlaytestSeams")
	_router = _main.get_node("SessionRouter") as SessionRouter
	_panel = _main.get_node("ScreenHost/PuzzlePlay")

	print("display=", DisplayServer.get_name())
	print("playtest_build=", _seams.get("playtest_build"))
	print("session_id=", _seams.get("session_id"))

	await _mode_pick_checks()
	await _enter_from_mode_pick()
	await _deal_mate()
	await _screen_s1()
	await _played_move()
	await _puzzle_session_journey()
	await _refused()
	await _abandon_and_cue()
	await _promotion()
	await _leave_confirmed()

	print("FAILURES=", JSON.stringify(_failures))
	quit(0 if _failures.is_empty() else 1)


func _pump(frames: int) -> void:
	for i in frames:
		await process_frame


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var img := root.get_texture().get_image()
	var path := "%s/%s.png" % [SHOT_DIR, name]
	img.save_png(path)
	print("screenshot=", path, " size=", img.get_size())


func _check(ok: bool, label: String, detail: String = "") -> void:
	var line := "CHECK %s %s %s" % ["PASS" if ok else "FAIL", label, detail]
	print(line)
	if not ok:
		_failures.append(label + (" :: " + detail if not detail.is_empty() else ""))


## PTU-mode-pick S1/S3/S4 — the C2 entry row exists, is labelled from copy, and
## carries the last-mode marker once puzzle is the last mode.
func _mode_pick_checks() -> void:
	(_router as Node).call("_go_mode_pick", "S1")
	await _pump(4)
	var mode_pick: Node = _main.get_node("ScreenHost/ModePick")
	var btn := mode_pick.find_child("PuzzleStream", true, false) as Button
	_check(btn != null, "mode-pick S1 has C2 Puzzle stream")
	if btn == null:
		return
	var want := StringTable.mode_pick("puzzle", "en")
	_check(btn.text.begins_with(want), "C2 label is the mode-pick puzzle key", btn.text)
	print("mode_pick_c2_text=", btn.text)
	await _shot("mode-pick-s1")
	_router.handle_control("mode-pick", "C2")
	await _pump(6)
	_check(
		_router.stage == SessionRouter.STAGE_PUZZLE_PLAY,
		"NAV.T2 C2 enters puzzle-play",
		_router.stage
	)
	_check(
		_router.last_mode == SessionRouter.MODE_PUZZLE,
		"PRG.M1 last mode is puzzle",
		_router.last_mode
	)


func _enter_from_mode_pick() -> void:
	if _panel == null or not _panel.visible:
		_panel = _main.get_node("ScreenHost/PuzzlePlay")
	_check(_panel.visible, "puzzle-play panel visible after C2")
	_check(_router.puzzle_flow != null, "puzzle stream flow open")


## DBG.3 — enter the named scenario the screen's own unit fixture uses (a mate in one on
## the solving side), because the seams build's catalog peer answers no read by default.
func _deal_mate() -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	if flow == null or flow.session == null:
		_check(false, "no puzzle session to deal into")
		return
	if flow.session.has_open_puzzle():
		flow.session.leave()
	flow.session.deal([_mate_record()])
	_router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, flow.state())
	await _pump(4)
	print("dealt_puzzle_id=", flow.session.play_state().get("puzzle_id", "?"))
	_check(flow.session.has_open_puzzle(), "DBG.3 scenario dealt")


func _mate_record() -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": "accept333-mate1",
		"fen": "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1",
		"moves": ["g8h8", "b1b8"],
		"rating": 1000,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": [],
		"game_url": "",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}


## PTU-puzzle-play S5 / UI-puzzle-play.US2 — every region on S1 on deal.
func _screen_s1() -> void:
	await _pump(4)
	var elo := _panel.find_child("PlayerElo", true, false) as Label
	_check(elo != null and elo.visible, "R2 playerElo region visible on deal")
	if elo != null:
		print("r2_elo_text=", elo.text)
	var state := String(_panel.get("ui_state"))
	_check(state == "S1", "S1 play state on deal", state)
	print("solving_side=", _panel.get("solving_side"), " side_to_move=", _router.puzzle_flow.side_to_move())
	print(
		"board_seat=",
		_main.get("_puzzle_seat") if _main.has_method("_puzzle_seat") else "n/a"
	)
	await _shot("puzzle-play-s1")


## PTU-puzzle-session S2/S3, PTU-navigation S2, PTU-exceptions S3 — leave confirm and cancel.
func _puzzle_session_journey() -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	_router.handle_control("puzzle-play", "C5")
	await _pump(4)
	var s2 := String(_panel.get("ui_state"))
	var msg := _panel.find_child("StreamConfirmMsg", true, false) as Label
	_check(s2 == "S2", "C5 Leave asks confirm (S2)", s2)
	if msg != null:
		print("stream_confirm_text=", msg.text)
	await _shot("puzzle-play-s2-leave-confirm")

	# Exceptions S3 / NAV.US2: cancel stays put, the puzzle stays open and unscored.
	var elo_before := float(_panel.get("player_elo"))
	_panel.find_child("CancelStream", true, false).pressed.emit()
	await _pump(4)
	_check(
		_router.stage == SessionRouter.STAGE_PUZZLE_PLAY,
		"S2 cancel stays on puzzle-play",
		_router.stage
	)
	_check(String(_panel.get("ui_state")) == "S1", "S2 cancel returns to S1")
	_check(flow.session != null, "S2 cancel keeps the puzzle open")
	_check(
		is_equal_approx(float(_panel.get("player_elo")), elo_before),
		"S2 cancel does not score the open puzzle"
	)
	await _shot("puzzle-play-s2-cancelled")

	# Confirm leave → mode-pick, unscored (J-puzzle-session S2 / NAV.T9).
	_router.handle_control("puzzle-play", "C5")
	await _pump(3)
	_panel.find_child("ConfirmStream", true, false).pressed.emit()
	await _pump(6)
	_check(
		_router.stage == SessionRouter.STAGE_MODE_PICK,
		"leave confirm → mode-pick",
		_router.stage
	)
	await _shot("mode-pick-after-leave")

	# Re-enter for the remaining steps (C2 again, S3/S4/S5 legs).
	_router.handle_control("mode-pick", "C2")
	await _pump(6)
	_check(_router.stage == SessionRouter.STAGE_PUZZLE_PLAY, "C2 re-enters the stream")


## PTU-puzzle-play S6 — promotion commits the chosen piece (last-rank pawn fixture).
func _promotion() -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	if flow == null or flow.session == null:
		return
	if flow.session.has_open_puzzle():
		flow.session.leave()
	flow.session.deal([_promotion_record()])
	_router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, flow.state())
	await _pump(4)
	print("promotion_fixture_side=", flow.side_to_move(), " state=", _panel.get("ui_state"))
	_router.handle_input_commit("g7", "", "")
	await _pump(3)
	_router.handle_input_commit("g7", "g8", "")
	await _pump(4)
	var state := String(_panel.get("ui_state"))
	print("promotion_choice_state=", state, " promote_row=", _panel.find_child("PromoteRow", true, false))
	_check(state == "S4", "last-rank place enters S4 promotion choice", state)
	await _shot("puzzle-play-s4-promotion")
	var committed := flow.promotion("queen")
	await _pump(4)
	print("promotion_committed_ok=", committed, " ui_state=", _panel.get("ui_state"), " cue=", _panel.get("cue_key"))
	_check(committed, "queen promotion commits")
	await _shot("puzzle-play-after-promotion")


func _promotion_record() -> Dictionary:
	var rec := _mate_record()
	rec["puzzle_id"] = "accept333-promote"
	rec["fen"] = "k7/6P1/8/8/8/8/8/7K b - - 0 1"
	rec["moves"] = ["a8b8", "g7g8q"]
	return rec


## PTU-puzzle-play S1 + PTU-controls S1/S2 — select then place the mate through the
## router's own input-commit path (the board gesture the player uses).
func _played_move() -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	var side := String(flow.side_to_move())
	print("solving_side=", side, " panel_solving_side=", _panel.get("solving_side"))
	_router.handle_input_commit("b1", "", "")
	await _pump(3)
	print("after_select_state=", _panel.get("ui_state"), " selected=", _panel.get("selected_piece"))
	await _shot("puzzle-play-selected")
	_router.handle_input_commit("b1", "b8", "")
	await _pump(4)
	var cue := _panel.find_child("ResultCue", true, false) as Label
	print(
		"after_place_state=",
		_panel.get("ui_state"),
		" cue=",
		_panel.get("cue_key"),
		" cue_text=",
		cue.text if cue != null else "?"
	)
	_check(String(_panel.get("cue_key")) == "cue_solved", "a solved puzzle shows cue_solved", str(_panel.get("cue_key")))
	await _shot("puzzle-play-solved")


## PTU-puzzle-play S7 / PTU-exceptions S2 — a refused place is S5 with no wrong-move cue.
func _refused() -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	if flow == null or flow.session == null:
		return
	_deal_mate()
	await _pump(2)
	_router.handle_input_commit("g1", "g2", "")
	await _pump(4)
	var state := String(_panel.get("ui_state"))
	print("refused_move_ui_state=", state, " cue=", _panel.get("cue_key"))
	_check(state == "S5", "a refused place enters S5", state)
	_check(String(_panel.get("cue_key")) != "cue_wrong", "a refused place is not a wrong move")
	await _shot("puzzle-play-s5-refused")
	flow.finish_reject_flash()
	await _pump(3)


func _abandon_and_cue() -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	if flow == null or flow.session == null:
		return
	var was := String(_panel.get("ui_state"))
	_router.handle_control("puzzle-play", "C4")
	await _pump(3)
	print("abandon_confirm_state=", _panel.get("ui_state"), " was=", was, " confirm_kind=", _panel.get("confirm_kind"))
	await _shot("puzzle-play-s2-abandon-confirm")
	var msg := _panel.find_child("StreamConfirmMsg", true, false) as Label
	if msg != null:
		print("abandon_confirm_text=", msg.text)
	_router.handle_control("puzzle-play", "confirm")
	await _pump(4)
	print("abandon_result_state=", _panel.get("ui_state"), " cue=", _panel.get("cue_key"))
	_check(String(_panel.get("cue_key")) == "cue_abandon", "confirming Abandon shows cue_abandon", str(_panel.get("cue_key")))
	await _shot("puzzle-play-abandoned")


func _leave_confirmed() -> void:
	if _router.stage == SessionRouter.STAGE_PUZZLE_PLAY:
		_router.handle_control("puzzle-play", "C5")
		await _pump(3)
		var ok := _panel.find_child("ConfirmStream", true, false) as Button
		if ok != null and _panel.find_child("StreamConfirm", true, false).visible:
			ok.pressed.emit()
			await _pump(5)
	print("final_stage=", _router.stage)
