class_name SharedResultTest
extends SceneTree
## Headless coverage for UI-shared-result + J-shared-session (#59).

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
var _error := ""


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	_router.locale = "en"
	_router.last_mode = "none"
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_presentation.set_deferred("size", Vector2(720, 1280))
	await process_frame
	await process_frame
	_error = _copy_keys()
	if _error.is_empty():
		_error = _journey_stop_path()
	if _error.is_empty():
		_error = _play_again_resets()
	if _error.is_empty():
		_error = _clocks_stay_stopped_on_result()
	if _error.is_empty():
		_error = _back_from_setup_branch()
	if _error.is_empty():
		_error = await _interrupt_reopens_mode_pick()
	if _error.is_empty():
		_error = _uis_m1_on_result()
	if _error.is_empty():
		quit(0)
		return
	_fail(_error)


func _copy_keys() -> String:
	for key in [
		"title",
		"shared_game",
		"result_white",
		"result_black",
		"result_draw",
		"play_again",
		"stop",
	]:
		var text := StringTable.shared_result(key, "en")
		if text.is_empty() or text == key:
			return "missing shared-result copy %s" % key
	if StringTable.shared_result("shared_game", "en") != "Shared game":
		return "shared_game copy"
	return ""


func _journey_stop_path() -> String:
	## J-shared-session S1–S4 + N1/N2 (Stop ends on mode-pick).
	var err := ""
	if _router.stage != "mode-pick":
		err = "N1 cold open mode-pick"
	if err.is_empty():
		_router.handle_control("mode-pick", "C1")
		if _router.stage != "shared-setup":
			err = "S1 → shared-setup"
	if err.is_empty():
		_router.handle_control("shared-setup", "C5")
		if _router.stage != "shared-play":
			err = "S2 → shared-play"
	if err.is_empty():
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		var result := _result_panel()
		var ok := (
			_router.stage == "shared-result"
			and result != null
			and result.visible
			and result.result_key == "result_black"
			and result.find_child("SharedGameCopy", true, false) != null
			and (result.find_child("SharedGameCopy", true, false) as Label).text == "Shared game"
			and (result.find_child("ResultCopy", true, false) as Label).text == "Black wins"
		)
		if not ok:
			err = "S3 resign → shared-result R1 copy"
	if err.is_empty():
		_router.handle_control("shared-result", "C2")
		if _router.stage != "mode-pick":
			err = "S4 Stop → mode-pick NAV.T8"
		elif _router.shared_session != null:
			err = "Stop must drop shared session"
		elif _router.options_locked:
			err = "Stop must unlock options"
	return err


func _play_again_resets() -> String:
	## B1 / NAV.T7 / PRG.F1 / K3 — Play again → unlocked setup; Start is fresh.
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C2")  # blitz
	_router.increment = 5
	_router.handle_control("shared-setup", "C5")
	var first := _router.shared_session
	var err := ""
	if first == null or first.white_clock_ms == null:
		err = "play-again setup timed game"
	if err.is_empty():
		first.tick(1_000)
		_router.handle_input_commit("e2", "")
		if _router.selected_piece != "e2":
			err = "play-again need selection before resign"
	if err.is_empty():
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		if _router.stage != "shared-result":
			err = "play-again need shared-result"
	var ended_clock := 0
	if err.is_empty():
		ended_clock = int(_router.shared_session.white_clock_ms)
		_router.handle_control("shared-result", "C1")
		var setup_ok := (
			_router.stage == "shared-setup"
			and not _router.options_locked
			and _router.shared_session == null
		)
		if not setup_ok:
			err = "C1 Play again → unlocked shared-setup"
	if err.is_empty():
		err = _assert_fresh_after_play_again(first, ended_clock)
	if err.is_empty():
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		_router.handle_control("shared-result", "C2")
	return err


func _assert_fresh_after_play_again(first: SharedGameSession, ended_clock: int) -> String:
	_router.handle_control("shared-setup", "C5")
	var second := _router.shared_session
	if second == null or second == first:
		return "Start after Play again must create a new session"
	var state: Dictionary = second.play_state()
	var checks := [
		[not bool(state["game_ended"].get("ended", false)), "new session gameEnded must be false"],
		[
			str(state["position"].get("side_to_move", "")) == ChessRules.SIDE_WHITE,
			"new session side to move White"
		],
		[str(second.selected_piece).is_empty(), "new session selection cleared"],
		[
			int(state["clocks"]["white"]) == SharedGameSession.BLITZ_START_S * 1000,
			"new session clocks re-init from options"
		],
		[int(state["clocks"]["white"]) != ended_clock, "finished clock must not carry forward"],
		[int(state.get("fifty_move_count", -1)) == 0, "fifty-move counter cleared"],
		[
			(state.get("repetition_history", []) as Array).size() == 1,
			"repetition history reset to opening"
		],
	]
	for pair in checks:
		if not bool(pair[0]):
			return str(pair[1])
	return ""


func _clocks_stay_stopped_on_result() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C2")  # blitz
	_router.handle_control("shared-setup", "C5")
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	var err := ""
	if _router.stage != "shared-result" or _router.shared_session == null:
		err = "clocks-stopped need shared-result"
	elif not bool(_router.shared_session.play_state().get("clocks_stopped", false)):
		err = "K3 endings stop both clocks"
	else:
		var before_w := int(_router.shared_session.white_clock_ms)
		var before_b := int(_router.shared_session.black_clock_ms)
		_router._process(0.5)
		_router.shared_session.tick(500)
		var after_w := int(_router.shared_session.white_clock_ms)
		var after_b := int(_router.shared_session.black_clock_ms)
		if after_w != before_w or after_b != before_b:
			err = "clocks must stay stopped on shared-result"
	if err.is_empty():
		_router.handle_control("shared-result", "C2")
	return err


func _back_from_setup_branch() -> String:
	## J-shared-session.B2
	_router.handle_control("mode-pick", "C1")
	var err := ""
	if _router.stage != "shared-setup":
		err = "B2 need shared-setup"
	else:
		_router.handle_control("shared-setup", "C6")
		if _router.stage != "mode-pick":
			err = "B2 Back → mode-pick"
	return err


func _interrupt_reopens_mode_pick() -> String:
	## EX.interrupt / NAV.N2 / FL-mode-pick.U1 — no mid-game resume.
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	var err := ""
	if _router.stage != "shared-play":
		err = "interrupt need mid shared-play"
	else:
		_router.handle_input_commit("e2", "")
		## Cold-open path after close/refresh: loading → boot → mode-pick; no shared resume.
		_router._on_seed_changed(_seams.seed_value + 1)
		await process_frame
		await process_frame
		await process_frame
		if _router.stage != "mode-pick":
			err = "interrupt reopen must be mode-pick, got %s" % _router.stage
		elif _router.shared_session != null:
			err = "interrupt must not resume shared game"
	return err


func _uis_m1_on_result() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	var result := _result_panel()
	var err := ""
	if result == null or not result.visible:
		err = "UIS.M1 need visible result"
	elif result.find_child("Tournament", true, false) != null:
		err = "AES.P3 no tournament chrome"
	elif result.custom_minimum_size.y < UiChrome.MIN_TOUCH * 2:
		err = "touch-class controls height"
	if err.is_empty():
		_router.handle_control("shared-result", "C2")
	return err


func _result_panel() -> SharedResultPanel:
	return _presentation.get_node("ScreenHost/SharedResult") as SharedResultPanel


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
