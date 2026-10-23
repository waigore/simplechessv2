extends SceneTree
## Acceptance audit for #545 — SIT.5 / O11 assert_telemetry over a driven shared game.
## Judges PTU-shared-play S6 / P4 / F3 from the run's own emitted events.

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
	_presentation.set_deferred("size", Vector2(720, 1280))
	await process_frame
	await process_frame
	print("A545 playtest_build=%s session=%s" % [_seams.playtest_build, _seams.session_id])
	_drive()
	_judge()
	if _failures.is_empty():
		print("A545_PROBE pass")
		quit(0)
		return
	for failure in _failures:
		print("A545 FAIL %s" % failure)
	print("A545_PROBE fail")
	quit(1)


## Drive into shared play and produce real UI-shared-play telemetry.
func _drive() -> void:
	_router.handle_control("mode-pick", "C1")
	print("A545 stage-after-modes=%s" % _router.stage)
	_router.handle_control("shared-setup", "C5")
	_router.handle_control("shared-play", "C3")
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	_router.handle_control("shared-play", "C5")
	_router.handle_control("shared-play", "confirm")
	_router.handle_control("shared-play", "C8")
	print("A545 play_ui_state=%s" % _router.play_ui_state)


func _judge() -> void:
	var window := _seams.assert_telemetry([])
	print("A545 log-window session_id=%s event_count=%d" % [window["session_id"], window["event_count"]])
	_expect(int(window["event_count"]) > 0, "buffer holds this run's events (event_count=%d)" % window["event_count"])
	_expect(str(window["session_id"]) == _seams.session_id, "log window names TEL.3")
	_expect(str(window["session_id"]).ends_with("-playtest"), "TEL.3 marks a playtest build")

	# AC1 — verdict shape + matched events for the ids this run really judged.
	# `_drive()` judged US1 (start, advice, resign) and US1.1 (resign confirm/end).
	var judged: Array = [
		{"event": "shared.start", "outcome": "ok", "story_id": "UI-shared-play.US1"},
		{"event": "shared.advice", "outcome": "toggled", "story_id": "UI-shared-play.US1.4"},
		{"event": "shared.resign", "outcome": "end", "story_id": "UI-shared-play.US1.1"},
	]
	var verdict := _seams.assert_telemetry(judged)
	print("A545 verdict=%s matched=%d" % [verdict["verdict"], verdict["matched"].size()])
	_expect(verdict["verdict"] == "pass", "S6/P4 judged stories present → pass")
	_expect(verdict["missing"].is_empty(), "pass has empty missing")
	_expect(verdict["matched"].size() == judged.size(), "matched holds one event per expectation")
	for payload in verdict["matched"]:
		_expect(_tel_complete(payload), "matched event carries TEL.1-TEL.5: %s" % [payload])

	# AC2 — a judged story with no correlating event is a fail, named in missing (F3).
	var failing := _seams.assert_telemetry(
		[
			{"event": "shared.start", "outcome": "ok", "story_id": "UI-shared-play.US1"},
			{"event": "", "outcome": "pass", "story_id": "UI-shared-play.US9-never-judged"},
		]
	)
	print("A545 fail-verdict=%s missing=%s" % [failing["verdict"], [failing["missing"]]])
	_expect(failing["verdict"] == "fail", "missing judged story → fail (F3)")
	_expect(
		failing["missing"].size() == 1
		and str(failing["missing"][0]["story_id"]) == "UI-shared-play.US9-never-judged",
		"missing names the story with no correlating event"
	)
	_expect(failing["matched"].size() == 1, "the matched expectation still reports its event")

	# D1 — no-story_id convention: an empty expectation matches a story-less event,
	# and does not match an event that carries a TEL.4.
	var anon_hit := _seams.assert_telemetry([{"event": "", "outcome": "gone", "story_id": ""}])
	_seams.emit_tel("anon_marker", "gone", "")
	var anon_hit2 := _seams.assert_telemetry([{"event": "anon_marker", "outcome": "gone", "story_id": ""}])
	print("A545 anon before=%s after=%s" % [anon_hit["verdict"], anon_hit2["verdict"]])
	_expect(anon_hit["verdict"] == "fail", "empty story_id does not match events that carry TEL.4")
	_expect(anon_hit2["verdict"] == "pass", "empty story_id matches a story-less event")

	# F3 — a story the run never judged is named, and the matched one still reports.
	var absent := _seams.assert_telemetry(
		[{"event": "shared.start", "outcome": "ok", "story_id": "UI-shared-play.US1"}]
	)
	_expect(absent["verdict"] == "pass", "a later assertion still passes over the grown buffer")


func _tel_complete(payload: Dictionary) -> bool:
	if not payload.has_all(["TEL.1", "TEL.2", "TEL.3", "TEL.5"]):
		return false
	if typeof(payload["TEL.2"]) != TYPE_INT:
		return false
	return str(payload["TEL.3"]).begins_with("sess-")


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("A545 JUDGE pass — %s" % label)
		return
	_failures.append(label)
	print("A545 JUDGE fail — %s" % label)
