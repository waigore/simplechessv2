class_name ChromePlacementTest
extends SceneTree
## #616 — every chrome panel is horizontally centered in its parent at a fixed
## vertical top, at the 1280×720 reference frame and at a second frame size.
## A fixed x offset fails the second frame, so the guard cannot be satisfied by
## editing a constant (D5).

const TOLERANCE_PX := 1.0
## Panel path → the vertical top it lands at (the mockup's centered column).
const SCREEN_PANELS := {
	"ScreenHost/ModePick": 80.0,
	"ScreenHost/SharedSetup": 60.0,
	"ScreenHost/SharedResult": 120.0,
}
const DIALOGS := {"ResignConfirm": 200.0, "StreamConfirm": 220.0, "SaveFailure": 220.0}
const FRAME_SIZES := [Vector2(1280, 720), Vector2(1600, 720)]

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
	root.add_child(_presentation)
	call_deferred("_run")


func _run() -> void:
	var problem := ""
	for frame: Vector2 in FRAME_SIZES:
		problem = await _check_frame(frame)
		if not problem.is_empty():
			break
	if problem.is_empty():
		quit(0)
		return
	push_error(problem)
	quit(1)


## Every screen panel is a direct child of the full-rect ScreenHost; every
## dialog is a child of a full-rect play panel, so its containing rect is the
## frame. Each is driven open through the router, not by forcing visibility.
func _check_frame(frame: Vector2) -> String:
	_presentation.size = frame
	await _settle()
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	await _settle()
	_router.handle_control("shared-play", "C4")
	await _settle()
	var problem := _sweep(SCREEN_PANELS, frame, "")
	if not problem.is_empty():
		return problem
	_router.handle_control("shared-play", "cancel")
	await _settle()
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	await _settle()
	problem = _sweep(SCREEN_PANELS, frame, "")
	if not problem.is_empty():
		return problem
	return await _sweep_dialogs(frame)


func _sweep(panels: Dictionary, frame: Vector2, _unused: String) -> String:
	for path: String in panels:
		var panel := _presentation.get_node(path) as Control
		var problem := _centered(panel, panels[path], frame)
		if not problem.is_empty():
			return problem
	return ""


func _sweep_dialogs(frame: Vector2) -> String:
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	_router.handle_control("shared-play", "C4")
	await _settle()
	var problem := _centered(_child("SharedPlay", "ResignConfirm"), DIALOGS["ResignConfirm"], frame)
	if not problem.is_empty():
		return problem
	_router.handle_control("shared-play", "cancel")
	_router._go_mode_pick("S1")
	await _settle()
	var puzzle_btn := (
		(_presentation.get_node("ScreenHost/ModePick") as Control).find_child(
			"PuzzleStream", true, false
		)
		as Button
	)
	if puzzle_btn == null:
		return "mode pick has no Puzzle stream control"
	puzzle_btn.pressed.emit()
	await _settle()
	_deal_fixture()
	await _settle()
	_router.handle_control("puzzle-play", "C5")
	await _settle()
	for node_name: String in ["StreamConfirm", "SaveFailure"]:
		problem = _centered(_child("PuzzlePlay", node_name), DIALOGS[node_name], frame)
		if not problem.is_empty():
			return problem
	return ""


## The read path needs a catalog; C5 only needs an open puzzle, so seed one
## directly (the same fixture PuzzlePlayTest deals).
func _deal_fixture() -> void:
	var flow := _router.puzzle_flow
	if flow == null or flow.session == null:
		return
	(
		flow
		. session
		. deal(
			[
				{
					"snapshot_id": PuzzleSession.SNAPSHOT_ID,
					"puzzle_id": "mate1",
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
			]
		)
	)


func _child(panel_name: String, node_name: String) -> Control:
	var panel := _presentation.get_node("ScreenHost/" + panel_name) as Control
	return panel.find_child(node_name, true, false) as Control


func _settle() -> void:
	await process_frame
	await process_frame


func _centered(panel: Control, top_px: float, frame: Vector2) -> String:
	if panel == null:
		return "missing chrome panel"
	var parent_rect := (panel.get_parent() as Control).get_global_rect()
	var rect := panel.get_global_rect()
	var dx := absf(rect.get_center().x - parent_rect.get_center().x)
	if dx > TOLERANCE_PX:
		return "%s centre x off by %s px at %s (left=%s)" % [panel.name, dx, frame, rect.position.x]
	var dy := absf(rect.position.y - parent_rect.position.y - top_px)
	if dy > TOLERANCE_PX:
		return "%s top off by %s px at %s (top=%s)" % [panel.name, dy, frame, rect.position.y]
	return ""
