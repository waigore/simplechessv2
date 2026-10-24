class_name PresentationTest
extends SceneTree

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams


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
	root.add_child(_presentation)
	_router.locale = "ja"
	_presentation.show_screen("loading", {})
	var loading := _presentation.get_node("LoadingLabel") as Label
	if not loading.visible or not loading.text.contains("読み込み"):
		_fail("EX.loading should show before the boot hook")
		return
	call_deferred("_after_boot")


func _after_boot() -> void:
	var loading := _presentation.get_node("LoadingLabel") as Label
	var mode_pick := _presentation.get_node("ScreenHost/ModePick") as ModePickPanel
	if loading.visible or not mode_pick.visible:
		_fail("mode-pick did not replace loading")
		return
	if _router.stage != "mode-pick":
		_fail("router stage")
		return
	if mode_pick.find_child("PuzzleStream", true, false) == null:
		_fail("mode-pick must offer UI-mode-pick.C2 Puzzle stream (Wave 2)")
		return
	if not _exercise_pointers():
		return
	if not _exercise_screens():
		return
	_seams.set_seed(42)
	call_deferred("_after_seed")


func _after_seed() -> void:
	var mode_pick := _presentation.get_node("ScreenHost/ModePick") as ModePickPanel
	if _router.stage != "mode-pick" or not mode_pick.visible:
		_fail("seed did not return to mode-pick")
		return
	var dumped := _seams.dump_state()
	if int(dumped.get("seed", -1)) != 42:
		_fail("seed was not repeatable")
		return
	quit(0)


func _exercise_pointers() -> bool:
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.index = 1
	touch.position = Vector2(12, 34)
	_seams.record_input(true)
	_presentation.handle_gui_input(touch)
	var after_touch := _presentation.pointer_count
	var recorded := _log_size()
	_seams.replay_input(_seams.dump_state()["input_log"])
	var after_replay := _presentation.pointer_count
	var log_after := _log_size()
	_seams.pause()
	_presentation.handle_gui_input(touch)
	var while_paused := _presentation.pointer_count
	_seams.resume()
	var problem := ""
	if after_touch != 1 or recorded != 1:
		problem = "touch was not recorded"
	elif after_replay != 2 or log_after != 1:
		problem = "replay did not reach the control"
	elif while_paused != 2:
		problem = "paused touch was accepted"
	if not problem.is_empty():
		return _fail(problem)
	var right := InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	right.pressed = true
	right.position = Vector2(1, 1)
	_presentation.handle_gui_input(right)
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_A
	_presentation.handle_gui_input(key)
	var unsupported := _presentation.get_node("UnsupportedInput") as Label
	if not unsupported.visible:
		return _fail("EX.unsupported-input missing for key")
	var left := InputEventMouseButton.new()
	left.button_index = MOUSE_BUTTON_LEFT
	left.pressed = true
	left.position = Vector2(8, 9)
	_presentation.handle_gui_input(left)
	problem = ""
	if _presentation.pointer_count != 3:
		problem = "pointer was not received"
	elif str(_presentation.last_pointer.get("kind", "")) != "pointer":
		problem = "pointer kind"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _log_size() -> int:
	return (_seams.dump_state()["input_log"] as Array).size()


func _exercise_screens() -> bool:
	var loading := _presentation.get_node("LoadingLabel") as Label
	_router.locale = "zh-Hant"
	_presentation.show_screen("loading", {})
	var zh := loading.text
	var zh_visible := loading.visible
	_router.locale = "zz"
	_presentation.show_screen("loading", {})
	var fallback := loading.text
	_presentation.show_screen("not-a-screen", {})
	var jump_loading := _seams.jump("loading")
	var stage_after := _router.stage
	var unknown := _seams.jump("not-a-stage")
	var stage_unknown := _router.stage
	var problem := ""
	if not zh.contains("載入") or not zh_visible:
		problem = "zh-Hant loading copy"
	elif not fallback.contains("Loading"):
		problem = "locale fallback"
	elif jump_loading != OK or stage_after != "loading":
		problem = "jump loading"
	elif unknown != ERR_INVALID_PARAMETER or stage_unknown != "loading":
		problem = "unknown jump"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
