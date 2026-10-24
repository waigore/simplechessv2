class_name ChromePlacementTest
extends SceneTree
## #616 — every chrome panel draws horizontally centered in its parent at a
## fixed vertical top, at the 1280×720 reference frame and at two other frame
## sizes. A fixed x offset fails the second frame, so the guard cannot be
## satisfied by editing a constant (D5).
##
## Each panel is measured on its **drawn** rect (`get_global_rect()`) after the
## layout has settled: `Control.size` and `position` can agree with each other
## while the drawn box has grown to one side of the anchor. The copy case grows
## a panel's content past its `custom_minimum_size` — what localized copy does —
## which is the shape that drifts when `grow_horizontal` is left at `FILL`.

const TOLERANCE_PX := 1.0
## Panel path → the vertical top it lands at (the mockup's centered column).
const SCREEN_PANELS := {
	"ScreenHost/ModePick": 80.0,
	"ScreenHost/SharedSetup": 60.0,
	"ScreenHost/SharedResult": 120.0,
}
const DIALOGS := {"ResignConfirm": 200.0, "StreamConfirm": 220.0, "SaveFailure": 220.0}
const FRAME_SIZES := [Vector2(1280, 720), Vector2(1600, 900), Vector2(390, 844)]
## Longer than any shipped string, and unwrapped, so the label's own min width
## forces its containing box past the width it was placed at.
const WIDENING_COPY := "Résignez la partie et retournez au choix du mode, s'il vous plaît"

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
## frame. Each is driven open through the router, never by forcing visibility.
func _check_frame(frame: Vector2) -> String:
	_presentation.size = frame
	await _settle()
	_router._go_mode_pick("S1")
	await _settle()
	var problem := await _sweep_screens(frame)
	if not problem.is_empty():
		return problem
	problem = await _sweep_shared_dialogs(frame)
	if not problem.is_empty():
		return problem
	return await _sweep_puzzle_dialogs(frame)


func _sweep_screens(frame: Vector2) -> String:
	var problem := _sweep(SCREEN_PANELS, frame)
	if not problem.is_empty():
		return problem
	_widen_copy(_presentation.get_node("ScreenHost/ModePick"))
	await _settle()
	return _sweep(SCREEN_PANELS, frame)


func _sweep_shared_dialogs(frame: Vector2) -> String:
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	await _settle()
	_router.handle_control("shared-play", "C4")
	await _settle()
	var problem := _centered(_child("SharedPlay", "ResignConfirm"), DIALOGS["ResignConfirm"], frame)
	if not problem.is_empty():
		return problem
	_widen_copy(_child("SharedPlay", "ResignConfirm"))
	await _settle()
	problem = _centered(_child("SharedPlay", "ResignConfirm"), DIALOGS["ResignConfirm"], frame)
	if not problem.is_empty():
		return problem
	_router.handle_control("shared-play", "cancel")
	await _settle()
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	await _settle()
	return _sweep(SCREEN_PANELS, frame)


func _sweep_puzzle_dialogs(frame: Vector2) -> String:
	## S2 (leave stream) — the only dialog C5 raises.
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C2")
	await _settle()
	_deal_fixture()
	await _settle()
	_router.handle_control("puzzle-play", "C5")
	await _settle()
	var problem := _measured("PuzzlePlay", "StreamConfirm", frame)
	if not problem.is_empty():
		return problem
	problem = _children_inside("PuzzlePlay", "StreamConfirm", frame)
	if not problem.is_empty():
		return problem
	_widen_copy(_child("PuzzlePlay", "StreamConfirm"))
	await _settle()
	problem = _measured("PuzzlePlay", "StreamConfirm", frame)
	if not problem.is_empty():
		return problem
	## S3 (EX.save-failure) has its own entry: a failed puzzle commit, not C5.
	return await _sweep_save_failure(frame)


func _sweep_save_failure(frame: Vector2) -> String:
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C2")
	await _settle()
	_deal_fixture()
	await _settle()
	var persist := _presentation.get_node("PersistStore") as PersistStore
	persist.force_write_failure = true
	_router.handle_input_commit("b1", "b8", "")
	await _settle()
	var problem := _measured("PuzzlePlay", "SaveFailure", frame)
	if not problem.is_empty():
		return problem
	problem = _children_inside("PuzzlePlay", "SaveFailure", frame)
	if not problem.is_empty():
		return problem
	_widen_copy(_child("PuzzlePlay", "SaveFailure"))
	await _settle()
	return _measured("PuzzlePlay", "SaveFailure", frame)


## #793 — the prompt is only readable if its copy and controls are drawn inside
## the panel that carries it, at every frame the box itself is measured at. Read
## on the drawn rects, like `_centered`, and on the shipped copy (`_widen_copy`
## deliberately grows a label past its box, which is #616's case, not this one).
func _children_inside(panel_name: String, node_name: String, frame: Vector2) -> String:
	var dialog := _child(panel_name, node_name)
	if dialog == null:
		return "missing dialog %s" % node_name
	var panel := dialog.find_child("*", true, false) as Control
	if panel == null:
		return "%s has no panel at %s" % [node_name, frame]
	var panel_rect := panel.get_global_rect()
	for node: Node in dialog.find_children("*", "", true, false):
		var drawn := node as Control
		if drawn == null or not drawn.is_visible_in_tree():
			continue
		if not (drawn is Label or drawn is Button):
			continue
		if not panel_rect.encloses(drawn.get_global_rect()):
			return (
				"%s draws %s outside its panel at %s (child %s, panel %s)"
				% [node_name, drawn.name, frame, drawn.get_global_rect(), panel_rect]
			)
	return ""


## A dialog is only placed for the player if it is on screen: measure it only
## when it is visible, so a hidden node cannot pass the geometry check.
func _measured(panel_name: String, node_name: String, frame: Vector2) -> String:
	var dialog := _child(panel_name, node_name)
	if dialog == null:
		return "missing dialog %s" % node_name
	if not dialog.is_visible_in_tree():
		return (
			"%s is not visible in tree at %s (player cannot see it; state=%s)"
			% [node_name, frame, _router.puzzle_flow.session.play_ui_state]
		)
	return _centered(dialog, DIALOGS[node_name], frame)


func _sweep(panels: Dictionary, frame: Vector2) -> String:
	for path: String in panels:
		var panel := _presentation.get_node(path) as Control
		var problem := _centered(panel, panels[path], frame)
		if not problem.is_empty():
			return problem
	return ""


## #616 — what a translation does to a panel: a label that cannot wrap grows the
## box past the width it was placed at, so the drawn centre can drift off the
## anchor while `position.x` still reads centered.
func _widen_copy(box: Control) -> void:
	if box == null:
		return
	for node: Node in box.find_children("*", "Label", true, false):
		var label := node as Label
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.text = WIDENING_COPY


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
	for _i in 4:
		await process_frame


func _centered(panel: Control, top_px: float, frame: Vector2) -> String:
	if panel == null:
		return "missing chrome panel"
	var parent_rect := (panel.get_parent() as Control).get_global_rect()
	var rect := panel.get_global_rect()
	var dx := absf(rect.get_center().x - parent_rect.get_center().x)
	if dx > TOLERANCE_PX:
		return (
			"%s drawn centre x off by %s px at %s (drawn width=%s, placed width=%s)"
			% [panel.name, dx, frame, rect.size.x, panel.custom_minimum_size.x]
		)
	var dy := absf(rect.position.y - parent_rect.position.y - top_px)
	if dy > TOLERANCE_PX:
		return "%s top off by %s px at %s (top=%s)" % [panel.name, dy, frame, rect.position.y]
	return ""
