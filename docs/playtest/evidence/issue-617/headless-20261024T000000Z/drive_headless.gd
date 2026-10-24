extends SceneTree
## #617 acceptance — HEADLESS leg of `PTU-shared-play` on the same build.
## Boots the same node set as `main.tscn` minus the auto smoke harness (which would
## quit the tree before the drive starts). Drives both seats through the real router
## control/gesture paths. Board art cannot be seen headless, so
## "does the artwork read upright" is `not-judged` here; the graphical run judges it.

var pres: Control
var router: Node
var seams: Node


func _initialize() -> void:
	_run.call_deferred()
	_watchdog()


func _watchdog() -> void:
	await create_timer(180.0).timeout
	print("STEP WATCHDOG_TIMEOUT")
	quit(3)


func log_line(s: String) -> void:
	print("STEP %s" % s)


## Same node set as `main.tscn`, minus `PlaytestHarness`: the harness quits the tree
## after its own smoke run, which would end this drive before it starts.
func _boot_same_as_main() -> Control:
	var scene := Control.new()
	scene.name = "Presentation"
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_script(load("res://presentation.gd"))
	for entry in [
		["SessionRouter", "res://session_router.gd"],
		["PersistStore", "res://persist_store.gd"],
		["AssetResolver", "res://asset_resolver.gd"],
		["PlaytestSeams", "res://playtest_seams.gd"],
	]:
		var node := Node.new()
		node.name = entry[0]
		node.set_script(load(entry[1]))
		scene.add_child(node)
	return scene


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _board_state(label: String) -> void:
	var board: Control = pres.get("_board")
	var world: Node2D = board.get("_world")
	var seat: Node2D = board.get("_seat")
	log_line("%s board_visible=%s world_scale=%s seat_rotation=%.4f" % [
		label, str(board.visible), str(world.scale), seat.rotation
	])
	var spine: Node = board.find_child("*", true, false)
	log_line("%s board_has_pieces_root=%s" % [
		label, str(board.get("_pieces_root") != null)
	])


func _run() -> void:
	pres = _boot_same_as_main()
	root.add_child(pres)
	await _frames(60)
	router = pres.get_node("SessionRouter")
	seams = pres.get_node("PlaytestSeams")
	log_line("booted display=%s godot=%s" % [
		DisplayServer.get_name(), str(Engine.get_version_info().string)
	])

	router.call("handle_control", "mode-pick", "C1")
	await _frames(20)
	log_line("stage_after_mode_pick=%s" % router.stage)
	router.call("handle_control", "shared-setup", "C5")
	await _frames(60)
	log_line("seat_bottom_ready stage=%s white_seat=%s" % [router.stage, router.white_seat])
	_board_state("seat_bottom")

	var ok1: bool = router.call("handle_input_commit", "e2", "e4", "")
	await _frames(20)
	log_line("S1 bottom_select_place accepted=%s occupancy_e4=%s side=%s" % [
		str(ok1), str(router.occupancy_at("e4")), str(router.side_to_move())
	])
	var ok2: bool = router.call("handle_input_commit", "e7", "e5", "")
	await _frames(20)
	log_line("S2 top_select_place accepted=%s occupancy_e5=%s side=%s" % [
		str(ok2), str(router.occupancy_at("e5")), str(router.side_to_move())
	])

	router.call("handle_control", "shared-play", "C4")
	await _frames(10)
	log_line("S3 resign_ui_state=%s" % router.play_ui_state)
	router.call("handle_control", "shared-play", "cancel")
	await _frames(10)
	log_line("S3 cancel_ui_state=%s" % router.play_ui_state)

	router.call("handle_control", "shared-play", "C4")
	await _frames(10)
	router.call("handle_control", "shared-play", "confirm")
	await _frames(30)
	log_line("resign_end_stage=%s" % router.stage)
	router.call("handle_control", "shared-result", "C1")
	await _frames(30)
	router.call("handle_control", "shared-setup", "C1")
	await _frames(15)
	log_line("seat_toggled=%s" % router.white_seat)
	router.call("handle_control", "shared-setup", "C5")
	await _frames(60)
	log_line("seat_top_ready stage=%s white_seat=%s" % [router.stage, router.white_seat])
	_board_state("seat_top")
	var ok3: bool = router.call("handle_input_commit", "d2", "d4", "")
	await _frames(20)
	log_line("S1b seat_top_select_place accepted=%s occupancy_d4=%s side=%s" % [
		str(ok3), str(router.occupancy_at("d4")), str(router.side_to_move())
	])
	var ok4: bool = router.call("handle_input_commit", "d7", "d5", "")
	await _frames(20)
	log_line("S2b seat_top_black accepted=%s occupancy_d5=%s side=%s" % [
		str(ok4), str(router.occupancy_at("d5")), str(router.side_to_move())
	])

	var verdict: Dictionary = seams.call("assert_telemetry", [
		{"event": "shared.start", "outcome": "ok", "story_id": "UI-shared-play.US1"},
		{"event": "shared.move", "outcome": "ok", "story_id": "UI-shared-play.US1.3"},
		{"event": "shared.resign", "outcome": "confirm", "story_id": "UI-shared-play.US1.1"},
	])
	log_line("S6 TEL_VERDICT=%s" % str(verdict.get("verdict", "")))
	log_line("S6 TEL_MISSING=%s" % JSON.stringify(verdict.get("missing", [])))
	log_line("DONE")
	quit(0)
