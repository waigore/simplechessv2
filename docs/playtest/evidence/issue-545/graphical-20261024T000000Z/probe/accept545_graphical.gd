extends SceneTree
## Graphical run for #545 — PTU-shared-play S6/P4/F3 on a rendered window, with
## screenshots of every judged state. Same build as the headless twin.

const SHOT_DIR := "res://../docs/playtest/evidence/issue-545/graphical-20261024T000000Z/screenshots/"

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
var _failures: Array = []


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
	# ENV.2 — phone-portrait window (project defaults to 1280x720 landscape) so the
	# captures show the whole shared-play screen, not a clipped corner.
	get_root().size = Vector2i(720, 1280)
	DisplayServer.window_set_size(Vector2i(720, 1280))
	await _settle()
	await _settle()
	print("A545G display=%s window=%s" % [DisplayServer.get_name(), get_root().size])
	_expect(DisplayServer.get_name() != "headless", "graphical display present (ENV.2)")

	_router.handle_control("mode-pick", "C1")
	await _settle()
	_shot("01-shared-setup-en.png")

	_router.handle_control("shared-setup", "C5")
	await _settle()
	_shot("02-shared-play-s1.png")

	_router.handle_control("shared-play", "C3")
	await _settle()
	_shot("03-shared-play-advice.png")

	_router.handle_control("shared-play", "C4")
	await _settle()
	_shot("04-shared-play-resign-confirm.png")

	_router.handle_control("shared-play", "confirm")
	await _settle()
	_shot("05-shared-result.png")

	await _judge()
	if _failures.is_empty():
		print("A545G_PROBE pass")
		quit(0)
		return
	for failure in _failures:
		print("A545G FAIL %s" % failure)
	print("A545G_PROBE fail")
	quit(1)


func _settle() -> void:
	for _i in 4:
		await process_frame
	await RenderingServer.frame_post_draw


func _shot(name: String) -> void:
	var image := root.get_texture().get_image()
	var path := SHOT_DIR + name
	var err := image.save_png(path)
	print("A545G shot %s %dx%d err=%d" % [name, image.get_width(), image.get_height(), err])
	_expect(image.get_width() > 0 and image.get_height() > 0, "rendered frame for %s" % name)


func _judge() -> void:
	var window := _seams.assert_telemetry([])
	print("A545G log-window session_id=%s event_count=%d" % [window["session_id"], window["event_count"]])
	_expect(int(window["event_count"]) > 0, "buffer holds this run's events")
	var judged: Array = [
		{"event": "shared.start", "outcome": "ok", "story_id": "UI-shared-play.US1"},
		{"event": "shared.advice", "outcome": "toggled", "story_id": "UI-shared-play.US1.4"},
		{"event": "shared.resign", "outcome": "end", "story_id": "UI-shared-play.US1.1"},
	]
	var verdict := _seams.assert_telemetry(judged)
	print("A545G verdict=%s matched=%d" % [verdict["verdict"], verdict["matched"].size()])
	_expect(verdict["verdict"] == "pass", "S6/P4 every judged story has a correlating event")
	_expect(verdict["matched"].size() == judged.size(), "matched holds one event per judged story")

	var failing := _seams.assert_telemetry([{"event": "", "outcome": "pass", "story_id": "UI-shared-play.US9"}])
	print("A545G f3-verdict=%s" % failing["verdict"])
	_expect(failing["verdict"] == "fail", "F3 an unjudged story is a fail, not a warning")
	_expect(
		failing["missing"].size() == 1 and str(failing["missing"][0]["story_id"]) == "UI-shared-play.US9",
		"F3 missing names the story"
	)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("A545G JUDGE pass — %s" % label)
		return
	_failures.append(label)
	print("A545G JUDGE fail — %s" % label)
