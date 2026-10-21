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
	_router.locale = "ja"
	root.add_child(_presentation)
	var loading := _presentation.get_node("LoadingLabel") as Label
	if not loading.visible or loading.text != "読み込み中":
		_fail("EX.loading should show before the boot hook")
		return
	call_deferred("_after_boot")


func _after_boot() -> void:
	var ready := _presentation.get_node("ReadyHook") as Label
	var loading := _presentation.get_node("LoadingLabel") as Label
	if loading.visible or not ready.visible or ready.text != "mode-pick-ready":
		_fail("mode-pick-ready hook did not replace loading")
		return
	if _router.stage != "mode-pick-ready":
		_fail("router stage")
		return
	if not _exercise_pointers():
		return
	if not _exercise_screens():
		return
	_seams.set_seed(42)
	call_deferred("_after_seed")


func _after_seed() -> void:
	var ready := _presentation.get_node("ReadyHook") as Label
	if _router.stage != "mode-pick-ready" or not ready.visible:
		_fail("seed did not return to the ready hook")
		return
	var dumped := _seams.dump_state()
	if int(dumped.get("seed", -1)) != 42:
		_fail("seed was not repeatable")
		return
	var spike := _presentation.get_node("TouchSpike") as Control
	var width := spike.offset_right - spike.offset_left
	var height := spike.offset_bottom - spike.offset_top
	if width != 576.0 or height != 576.0:
		_fail("touch spike is not board-sized")
		return
	for child in _presentation.get_children():
		if child is Button:
			_fail("mode controls are present")
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
	_presentation.handle_gui_input(InputEventKey.new())
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
	var ready_visible := (_presentation.get_node("ReadyHook") as Label).visible
	_presentation.show_screen("mode-pick", {})
	var still := (_presentation.get_node("ReadyHook") as Label).visible
	var jump_loading := _seams.jump("loading")
	var stage_after := _router.stage
	var unknown := _seams.jump("not-a-stage")
	var stage_unknown := _router.stage
	var problem := ""
	if zh != "載入中" or not zh_visible:
		problem = "zh-Hant loading copy"
	elif fallback != "Loading":
		problem = "locale fallback"
	elif still != ready_visible:
		problem = "unknown screen changed state"
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
