class_name PlaytestSeams
extends Node
## CMP-playtest-seams — CTR-playtest-drive. No-op outside playtest builds.
## G2: absent from `main_release.tscn`, so a release export never loads this script.

signal jump_requested(stage_id: String)
signal input_replayed(record: Dictionary)
signal tel_event(payload: Dictionary)
signal seed_changed(value: int)
signal overlay_changed(enabled: bool, story_ids: PackedStringArray)
signal viewport_changed(report: Dictionary)

## SIT.6 `O12` phone-width targets.
const VIEWPORT_PHONE_WIDTH := 390
const VIEWPORT_PHONE_HEIGHT := 844

## SIT.4 `O10` — the report the seam hands back; the window lives in PlaytestMeasure.
const MEASURE_FRAME_TIMES := PlaytestMeasure.KIND_FRAME_TIMES
const MEASURE_LOADING_READY := PlaytestMeasure.KIND_LOADING_READY

## Headless and editor runs only. Export templates ignore this.
var playtest_override := -1
var playtest_build := false
var session_paused := false
var seed_value := 0
var session_id := ""
var overlay_enabled := false
var active_story_ids: PackedStringArray = PackedStringArray()
var input_log: Array = []
## S11 `O10` — the window and its passive frame source (`CMP-playtest-seams` R6).
var measurement := PlaytestMeasure.new()
var _tel_log: Array = []

var _play_keys := PackedStringArray(
	[
		"position",
		"castling_ep",
		"clocks",
		"advice_best_move",
		"advice_eval",
		"game_ended",
		"mode",
		"stage",
		"seed",
	]
)
var _stages: PackedStringArray = PackedStringArray()
var _state_provider: Callable = Callable()
var _recording := false
var _replaying := false
var _configured := false
var _jump_field: LineEdit
var _overlay_label: Label
var _text_report: Callable = Callable()
var _viewport_report: Dictionary = {}
var _measure_kind: LineEdit


func _ready() -> void:
	configure()


## S11 observes the open window; the move path never calls this (`G3`).
func _process(_delta: float) -> void:
	if not playtest_build:
		return
	measurement.observe()


func configure() -> void:
	if _configured:
		return
	_configured = true
	_tel_log.clear()
	playtest_build = _resolve_playtest()
	session_id = _make_session_id()
	measurement.snapshot_provider = _snapshot
	measurement.frame_provider = _frame_source
	measurement.tel_sink = _emit_measure_tel
	if not playtest_build:
		return
	_build_debug_ui()


func register_stages(stages: PackedStringArray) -> void:
	_stages = stages


func bind_state(provider: Callable) -> void:
	_state_provider = provider


## SIT.6 — `CMP-presentation` supplies body text screen px for a frame height.
func bind_text_report(provider: Callable) -> void:
	_text_report = provider


## O12 set_viewport — apply a window size, then report what that frame renders.
## Viewport work needs `ENV.2`; where no display resizes the window the frame
## stays as it is and the report says so (I6 boundary). The reported sizes are
## the ones the layout renders, never the arguments (S13 / D2).
func set_viewport(width: int, height: int, text_scale: float) -> Dictionary:
	## G2 / I3 — a release build has no O12.
	if not playtest_build:
		return {}
	if width <= 0 or height <= 0 or text_scale <= 0.0:
		emit_tel("set_viewport", "fail")
		return {}
	var window := get_window()
	var graphical := PlaytestGate.has_display() and window != null
	if graphical and window.size != Vector2i(width, height):
		window.size = Vector2i(width, height)
	if graphical:
		_resize_to_frame(window)
		_reflow_layout()
	var report := _frame_report(width, height, text_scale)
	_viewport_report = report.duplicate()
	viewport_changed.emit(report)
	emit_tel("set_viewport", "pass" if graphical else "skip", "SIT.6")
	return report


## #708 — the applied frame is the drawable, not an elastic scale of the
## reference one. The project stretches `canvas_items` with `expand`, so a
## resized window would keep a 1280 project width and grow the project height
## to phone-width × expansion: the layout would draw far larger than the phone
## it claims to be, at sizes that pass `S13` and are judged by none of the
## screen. Turning content scaling off makes the window's own px the frame
## (UIS.T2 stays a ratio of the frame height, so the layout still reflows).
## `S13` reads the rendered frame, so nothing here sets a size.
func _resize_to_frame(window: Window) -> void:
	if window.content_scale_mode == Window.CONTENT_SCALE_MODE_DISABLED:
		return
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	window.content_scale_size = Vector2i(0, 0)


## The layout must take the ratio of the frame just applied, not the one it
## renders before `O12` runs (#708). The seam only asks; the ratio still comes
## from `CMP-presentation` (`D1`).
func _reflow_layout() -> void:
	var host := get_parent()
	var shell := host as Presentation
	if shell != null:
		shell.reflow_text_for_frame()


## The frame the seam applied and the body text that frame renders (D2). Every
## size is read from the viewport after the resize, never from the arguments.
func _frame_report(width: int, height: int, text_scale: float) -> Dictionary:
	## Before the seam has a frame it claims no height rather than the requested
	## one, so `S13` never reads a size that is not on screen (I6). A runner that
	## refuses the resize keeps its own frame.
	var frame_height := PlaytestGate.frame_height(self)
	return {
		"width": width,
		"height": height,
		"text_scale": text_scale,
		"applied": PlaytestGate.has_display(),
		"frame_height_px": frame_height,
		"rendered_text_scale": Presentation.text_scale_for_frame_height(frame_height),
		"body_text_px": _body_text_px(frame_height),
	}


func _last_viewport_report() -> Dictionary:
	return _viewport_report.duplicate()


## What the bound `CMP-presentation` renders for this frame height. The seam
## computes, clamps, and sets no size; with nothing bound the shipped hook
## answers, never a size of the seam's own (D2 / S13).
func _body_text_px(frame_height_px: float) -> float:
	if frame_height_px <= 0.0:
		return 0.0
	if _text_report.is_valid():
		return float(_text_report.call(frame_height_px))
	return Presentation.body_text_screen_px_for_frame_height(frame_height_px)


func pause() -> void:
	if not playtest_build:
		return
	session_paused = true
	emit_tel("pause", "pass")


func resume() -> void:
	if not playtest_build:
		return
	session_paused = false
	emit_tel("resume", "pass")


func is_paused() -> bool:
	return session_paused


func inspect(keys: PackedStringArray) -> Dictionary:
	if not playtest_build:
		return {}
	var snap := _snapshot()
	var picked := {}
	for key in keys:
		if snap.has(key):
			picked[key] = snap[key]
	return picked


func jump(stage_id: String) -> Error:
	if not playtest_build:
		return ERR_UNAVAILABLE
	if not _stages.has(stage_id):
		push_error("Unknown jump id: %s" % stage_id)
		emit_tel("jump", "fail")
		return ERR_INVALID_PARAMETER
	jump_requested.emit(stage_id)
	emit_tel("jump", "pass", stage_id)
	return OK


func set_overlay(enabled: bool, story_ids: PackedStringArray) -> void:
	if not playtest_build:
		return
	overlay_enabled = enabled
	active_story_ids = story_ids.duplicate()
	_apply_overlay_label()
	overlay_changed.emit(enabled, active_story_ids)


func set_seed(value: int) -> void:
	if not playtest_build:
		return
	seed_value = value
	seed(value)
	input_log.clear()
	seed_changed.emit(value)
	emit_tel("set_seed", "pass")


func record_input(enabled: bool) -> void:
	if not playtest_build:
		return
	_recording = enabled


func note_pointer(record: Dictionary) -> void:
	if not playtest_build or not _recording or session_paused or _replaying:
		return
	input_log.append(record)


func replay_input(sequence: Array) -> void:
	if not playtest_build or session_paused:
		return
	_replaying = true
	for record in sequence:
		input_replayed.emit(record)
	_replaying = false


func dump_state() -> Dictionary:
	if not playtest_build:
		return {}
	var full := inspect(_play_keys)
	full["paused"] = session_paused
	full["overlay_on"] = overlay_enabled
	full["story_ids"] = Array(active_story_ids)
	full["input_log"] = input_log.duplicate(true)
	full["session_id"] = session_id
	full["measurement"] = measurement.last()
	full["viewport"] = _last_viewport_report()
	return full


func emit_tel(event_name: String, outcome: String, story_id: String = "") -> void:
	if not playtest_build:
		return
	var payload := {
		"TEL.1": event_name,
		"TEL.2": int(Time.get_unix_time_from_system() * 1000.0),
		"TEL.3": session_id,
		"TEL.5": outcome,
	}
	if not story_id.is_empty():
		payload["TEL.4"] = story_id
	_tel_log.append(payload)
	print(JSON.stringify(payload))
	tel_event.emit(payload)


## O11 — read this run's own emitted events back as a verdict (`SIT.5`).
## Consumers pass `[{event, outcome, story_id}]`; field shape stays `E1`'s.
func assert_telemetry(expected: Array) -> Dictionary:
	var verdict := _empty_verdict()
	if not playtest_build:
		return verdict
	var matched: Array = []
	var missing: Array = []
	var claimed := {}
	for want in expected:
		var expectation := _normalize_expectation(want)
		var hit := _find_event(expectation, claimed)
		if hit < 0:
			missing.append(expectation)
			continue
		claimed[hit] = true
		matched.append(_tel_log[hit])
	verdict["verdict"] = "fail" if not missing.is_empty() else "pass"
	verdict["matched"] = matched
	verdict["missing"] = missing
	return verdict


## SIT.4 / O10 — arm the next window for `kind`. Refuses rather than arming on a
## placeholder, naming the first predicate that failed (`D1`). `C2` / `G3`: it
## reads the same `O3` snapshot as `inspect` and submits no input.
func start_measurement(kind: String) -> Dictionary:
	if not playtest_build:
		return _release_refusal(kind)
	return measurement.start(kind, session_paused)


## SIT.4 / O10 — the report for the armed window; closes and disarms it (`D2`).
## With an empty `kind` it is the disarm: the open window comes back `cancelled`,
## keeping its samples and claiming no `max_ms` (`D1`).
func measure(kind: String) -> Dictionary:
	if not playtest_build:
		return _release_refusal(kind)
	if kind.is_empty():
		return measurement.disarm()
	return measurement.report(kind)


## `D3` — a release build answers with the always-shaped refusal, never samples.
func _release_refusal(kind: String) -> Dictionary:
	return measurement.refuse_release(kind, true)


## The passive frame source: the real frame delta, in milliseconds.
func _frame_source() -> float:
	return get_process_delta_time() * 1000.0


func _emit_measure_tel(event_name: String, outcome: String, story: String) -> Dictionary:
	var count := _tel_log.size()
	emit_tel(event_name, outcome, story)
	if count >= _tel_log.size():
		return {}
	return (_tel_log[count] as Dictionary).duplicate()


func _resolve_playtest() -> bool:
	return PlaytestGate.is_playtest(playtest_override)


func _empty_verdict() -> Dictionary:
	return {
		"verdict": "fail",
		"matched": [],
		"missing": [],
		"session_id": session_id,
		"event_count": _tel_log.size(),
	}


func _normalize_expectation(want: Variant) -> Dictionary:
	var source: Dictionary = want if want is Dictionary else {}
	return {
		"event": str(source.get("event", "")),
		"outcome": str(source.get("outcome", "")),
		"story_id": str(source.get("story_id", "")),
	}


func _find_event(expectation: Dictionary, claimed: Dictionary) -> int:
	for index in _tel_log.size():
		if claimed.has(index):
			continue
		var payload: Dictionary = _tel_log[index]
		if str(payload.get("TEL.5", "")) != expectation["outcome"]:
			continue
		if str(payload.get("TEL.4", "")) != expectation["story_id"]:
			continue
		if str(payload.get("TEL.1", "")) != expectation["event"]:
			continue
		return index
	return -1


## `TEL.3` — one id per seam instance, so repeated runs in one process differ and a
## repeat count is expressible (`SIT.4` / #544 `D2`).
func _make_session_id() -> String:
	var stamp := str(int(Time.get_unix_time_from_system() * 1000.0))
	var process := str(OS.get_process_id())
	var kind := "release"
	if playtest_build:
		kind = "playtest"
	return "sess-%s-%s-%s-%d" % [stamp, process, kind, Time.get_ticks_usec()]


func _snapshot() -> Dictionary:
	if _state_provider.is_valid():
		return _state_provider.call()
	return {}


func _build_debug_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PlaytestDebug"
	add_child(layer)
	var panel := VBoxContainer.new()
	panel.name = "DebugPanel"
	layer.add_child(panel)
	_add_button(panel, "Pause", pause)
	_add_button(panel, "Resume", resume)
	_add_button(panel, "Inspect", _on_inspect_pressed)
	_jump_field = LineEdit.new()
	_jump_field.name = "JumpId"
	_jump_field.placeholder_text = "stage id"
	panel.add_child(_jump_field)
	_add_button(panel, "Jump", _on_debug_jump)
	_add_button(panel, "Overlay", _on_overlay_pressed)
	_add_button(panel, "AssertTelemetry", _on_assert_telemetry_pressed)
	_add_button(panel, "SetViewport", _on_set_viewport_pressed)
	_measure_kind = LineEdit.new()
	_measure_kind.name = "MeasureKind"
	_measure_kind.placeholder_text = "frame_times | loading_ready"
	panel.add_child(_measure_kind)
	_add_button(panel, "Measure", _on_measure_pressed)
	_overlay_label = Label.new()
	_overlay_label.name = "StoryOverlay"
	_overlay_label.visible = false
	layer.add_child(_overlay_label)


func _add_button(panel: VBoxContainer, label: String, handler: Callable) -> void:
	var button := Button.new()
	button.name = label
	button.text = label
	button.pressed.connect(handler)
	panel.add_child(button)


func _apply_overlay_label() -> void:
	_overlay_label.visible = overlay_enabled
	_overlay_label.text = " ".join(active_story_ids)


func _on_inspect_pressed() -> void:
	var keys := PackedStringArray(["stage", "mode", "game_ended", "position"])
	print(JSON.stringify(inspect(keys)))


func _on_debug_jump() -> void:
	jump(_jump_field.text.strip_edges())


func _on_set_viewport_pressed() -> void:
	## SIT.6 — phone width at the reference ratio, driven from the panel for ENV.2.
	## The reported sizes come back from the frame that renders, not from this call.
	set_viewport(VIEWPORT_PHONE_WIDTH, VIEWPORT_PHONE_HEIGHT, 1.0)


func _on_measure_pressed() -> void:
	## SIT.4 — arms the next window only. It never submits input, plays the move,
	## or times itself (D4); the report prints when the window closes.
	var kind := _measure_kind.text.strip_edges()
	var armed := start_measurement(kind)
	print(JSON.stringify(armed))
	if str(armed.get("status", "")) == "refused":
		push_warning("Measure refused: %s" % [armed.get("detail", "")])


func _on_overlay_pressed() -> void:
	if overlay_enabled:
		set_overlay(false, PackedStringArray())
		return
	set_overlay(true, PackedStringArray(["EX.loading"]))


func _on_assert_telemetry_pressed() -> void:
	var expected: Array = []
	for story_id in active_story_ids:
		expected.append({"event": "", "outcome": "pass", "story_id": story_id})
	var verdict := assert_telemetry(expected)
	print(JSON.stringify(verdict))
	if verdict["verdict"] != "pass":
		push_warning("Telemetry assertion failed: %s" % [verdict["missing"]])
