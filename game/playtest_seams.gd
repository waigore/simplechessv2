class_name PlaytestSeams
extends Node
## CMP-playtest-seams — CTR-playtest-drive. No-op outside playtest builds.
## G2: absent from `main_release.tscn`, so a release export never loads this script.

signal jump_requested(stage_id: String)
signal input_replayed(record: Dictionary)
signal tel_event(payload: Dictionary)
signal seed_changed(value: int)
signal overlay_changed(enabled: bool, story_ids: PackedStringArray)

## Headless and editor runs only. Export templates ignore this.
var playtest_override := -1
var playtest_build := false
var session_paused := false
var seed_value := 0
var session_id := ""
var overlay_enabled := false
var active_story_ids: PackedStringArray = PackedStringArray()
var input_log: Array = []

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


func _ready() -> void:
	configure()


func configure() -> void:
	if _configured:
		return
	_configured = true
	playtest_build = _resolve_playtest()
	session_id = _make_session_id()
	if not playtest_build:
		return
	_build_debug_ui()


func register_stages(stages: PackedStringArray) -> void:
	_stages = stages


func bind_state(provider: Callable) -> void:
	_state_provider = provider


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
	print(JSON.stringify(payload))
	tel_event.emit(payload)


func _resolve_playtest() -> bool:
	return PlaytestGate.is_playtest(playtest_override)


func _make_session_id() -> String:
	var stamp := str(int(Time.get_unix_time_from_system() * 1000.0))
	var process := str(OS.get_process_id())
	var kind := "release"
	if playtest_build:
		kind = "playtest"
	return "sess-%s-%s-%s" % [stamp, process, kind]


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


func _on_overlay_pressed() -> void:
	if overlay_enabled:
		set_overlay(false, PackedStringArray())
		return
	set_overlay(true, PackedStringArray(["EX.loading"]))
