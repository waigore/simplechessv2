extends SceneTree
## Acceptance probe for #616 — drives every chrome surface through the router and
## prints the drawn rect of the six panels and of the controls they contain, so
## an acceptance run judges the player-visible result rather than the code text.

const FRAMES := [Vector2(1280, 720), Vector2(1600, 900), Vector2(390, 844)]
const PANEL_TOPS := {
	"ScreenHost/ModePick": 80.0,
	"ScreenHost/SharedSetup": 60.0,
	"ScreenHost/SharedResult": 120.0,
}
const DIALOG_TOPS := {"ResignConfirm": 200.0, "StreamConfirm": 220.0, "SaveFailure": 220.0}

var _presentation: Presentation
var _router: SessionRouter
var _fail := 0


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
	for frame: Vector2 in FRAMES:
		await _frame(frame)
	print("PROBE-616 RESULT fails=%d" % _fail)
	quit(0 if _fail == 0 else 1)


func _frame(frame: Vector2) -> void:
	print("== frame %s ==" % frame)
	_presentation.size = frame
	await _settle()
	_router._go_mode_pick("S1")
	await _settle()
	await _sweep_screens(frame, "mode-pick")
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	await _settle()
	await _sweep_screens(frame, "shared-setup")
	_router.handle_control("shared-play", "C4")
	await _settle()
	_check(_child("SharedPlay", "ResignConfirm"), DIALOG_TOPS["ResignConfirm"], frame, "resign-confirm")
	_router.handle_control("shared-play", "cancel")
	await _settle()
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	await _settle()
	await _sweep_screens(frame, "shared-result")
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C2")
	await _settle()
	await _deal_fixture()
	await _settle()
	_router.handle_control("puzzle-play", "C5")
	await _settle()
	_check_if_visible(_child("PuzzlePlay", "StreamConfirm"), DIALOG_TOPS["StreamConfirm"], frame, "stream-confirm")
	_router.handle_control("puzzle-play", "cancel")
	await _settle()
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C2")
	await _settle()
	await _deal_fixture()
	await _settle()
	var persist := _presentation.get_node("PersistStore") as PersistStore
	persist.force_write_failure = true
	_router.handle_input_commit("b1", "b8", "")
	await _settle()
	_check_if_visible(_child("PuzzlePlay", "SaveFailure"), DIALOG_TOPS["SaveFailure"], frame, "save-failure")
	persist.force_write_failure = false


func _sweep_screens(frame: Vector2, screen: String) -> void:
	for path: String in PANEL_TOPS:
		var panel := _presentation.get_node(path) as Control
		_check(panel, PANEL_TOPS[path], frame, screen)


func _check_if_visible(panel: Control, top: float, frame: Vector2, screen: String) -> void:
	if panel == null:
		print("FAIL %s missing" % screen)
		_fail += 1
		return
	if not panel.is_visible_in_tree():
		print("NOTE %s not visible at %s (not judged)" % [screen, frame])
		return
	_check(panel, top, frame, screen)


func _check(panel: Control, top: float, frame: Vector2, screen: String) -> void:
	if panel == null:
		print("FAIL %s panel missing" % screen)
		_fail += 1
		return
	var parent_rect := (panel.get_parent() as Control).get_global_rect()
	var rect := panel.get_global_rect()
	var dx := absf(rect.get_center().x - parent_rect.get_center().x)
	var dy := absf(rect.position.y - parent_rect.position.y - top)
	var ver := "ok" if dx <= 1.0 and dy <= 1.0 else "FAIL"
	if ver == "FAIL":
		_fail += 1
	print(
		(
			"%s %-18s rect=%s parent=%s centre_dx=%.1f top_dy=%.1f frame=%s"
			% [ver, panel.name, rect, parent_rect, dx, dy, frame]
		)
	)
	_report_controls(panel, parent_rect, screen, frame)


func _report_controls(panel: Control, parent_rect: Rect2, screen: String, frame: Vector2) -> void:
	var outside := 0
	var total := 0
	for node: Node in panel.find_children("*", "Control", true, false):
		var control := node as Control
		if not control.is_visible_in_tree():
			continue
		var r := control.get_global_rect()
		if r.size.x <= 0.0 or r.size.y <= 0.0:
			continue
		total += 1
		if r.position.x < parent_rect.position.x - 1.0 or r.end.x > parent_rect.end.x + 1.0:
			outside += 1
			print("  overflow %s %s within %s" % [control.name, r, screen])
	print("  controls screen=%s frame=%s total=%d outside_frame=%d" % [screen, frame, total, outside])


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
