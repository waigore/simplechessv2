class_name PresentationTest
extends SceneTree

## #616 — chrome panels are a centred column, not a fixed 40 px corner. The guard
## measures each panel's **drawn** rect (`get_global_rect()`) against its parent
## rect: center x within 1 px and the landed vertical top. It runs at the
## reference frame, a larger frame and the SIT.6 phone frame, so a fixed offset
## or a rect that grows only to the right from its anchor fails, while the
## vertical composition stays as landed (centring is horizontal only).
const CHROME_REFERENCE_SIZE := Vector2(1280, 720)
const CHROME_SECOND_SIZE := Vector2(1600, 900)
## SIT.6 phone-width frame — narrower than the 320 px panel, so only a centre
## anchor can pass here.
const CHROME_PHONE_SIZE := Vector2(390, 844)
const CHROME_TOPS := {
	"ScreenHost/ModePick": 80.0,
	"ScreenHost/SharedSetup": 60.0,
	"ScreenHost/SharedResult": 120.0,
	"ScreenHost/SharedPlay/ResignConfirm": 200.0,
	"ScreenHost/PuzzlePlay/StreamConfirm": 220.0,
	"ScreenHost/PuzzlePlay/SaveFailure": 220.0,
}

## Every panel is measured only while the game itself shows it: a hidden control
## is not laid out, so `get_global_rect()` would be stale. The three screens come
## from `show_screen`; the three dialogs are raised by their own state ids (S2
## confirm, S3 save failure), so no visibility is forced from the test.
const CHROME_STEPS := [
	{"screen": "mode-pick", "panels": ["ScreenHost/ModePick"]},
	{"screen": "shared-setup", "panels": ["ScreenHost/SharedSetup"]},
	{"screen": "shared-result", "panels": ["ScreenHost/SharedResult"]},
	{
		"screen": "shared-play",
		"state": {"ui_state": "S2", "confirm_kind": "resign"},
		"panels": ["ScreenHost/SharedPlay/ResignConfirm"],
	},
	{
		"screen": "puzzle-play",
		"state": {"ui_state": "S2", "puzzle_open": true, "confirm_kind": "reveal"},
		"panels": ["ScreenHost/PuzzlePlay/StreamConfirm"],
	},
	{
		"screen": "puzzle-play",
		"state": {"ui_state": "S3", "puzzle_open": true},
		"panels": ["ScreenHost/PuzzlePlay/SaveFailure"],
	},
]

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
	if not await _check_chrome_placement():
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


func _check_chrome_placement() -> bool:
	for frame_size in [CHROME_REFERENCE_SIZE, CHROME_SECOND_SIZE, CHROME_PHONE_SIZE]:
		_presentation.size = frame_size
		await process_frame
		for step in CHROME_STEPS:
			_presentation.show_screen(str(step["screen"]), step.get("state", {}))
			await process_frame
			var problem := _chrome_placement_problem(frame_size, step["panels"])
			if not problem.is_empty():
				return _fail(problem)
	return true


## A panel is placed correctly when what it *draws* is centred: the global rect
## the renderer uses, not `position` (the left edge) and not `position + pivot`.
## A fixed x, or a rect that grows only to the right from its anchor, both fail
## this at 1600×900 and at the phone frame.
func _chrome_placement_problem(frame_size: Vector2, paths: Array) -> String:
	for path in paths:
		var panel := _presentation.get_node_or_null(str(path)) as Control
		if panel == null:
			return "missing chrome panel %s" % path
		if not panel.is_visible_in_tree():
			return "%s is not visible when measured at %s" % [path, frame_size]
		var drawn := panel.get_global_rect()
		var parent_rect := (panel.get_parent() as Control).get_global_rect()
		if absf(drawn.get_center().x - parent_rect.get_center().x) > 1.0:
			return (
				"%s drawn center x %.1f != parent center x %.1f at %s (rect %s)"
				% [path, drawn.get_center().x, parent_rect.get_center().x, frame_size, drawn]
			)
		var top_px := float(CHROME_TOPS[path])
		if absf(drawn.position.y - top_px) > 1.0:
			return "%s top %.1f != %.1f at %s" % [path, drawn.position.y, top_px, frame_size]
	return ""


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
