class_name Presentation
extends Control
## CMP-presentation scaffold: EX.loading, then the mode-pick-ready hook.

const LOADING_SCREEN := "loading"
const READY_HOOK_ID := "mode-pick-ready"
const LOADING_COPY := {
	"en": "Loading",
	"zh-Hant": "載入中",
	"ja": "読み込み中",
}

var pointer_count := 0
var last_pointer: Dictionary = {}

@onready var _loading: Label = $LoadingLabel
@onready var _ready_hook: Label = $ReadyHook
@onready var _touch_spike: Control = $TouchSpike
@onready var _router: SessionRouter = $SessionRouter


func _ready() -> void:
	_ready_hook.text = READY_HOOK_ID
	_touch_spike.gui_input.connect(handle_gui_input)
	_router.screen_requested.connect(_on_screen_requested)
	_router.replay_pointer.connect(apply_recorded_pointer)
	_show_loading()
	_router.start()


func show_screen(screen_id: String, _state: Dictionary) -> void:
	if screen_id == LOADING_SCREEN:
		_show_loading()
		return
	if screen_id == READY_HOOK_ID:
		_show_ready()
		return
	push_error("Unknown screen id: %s" % screen_id)


func handle_gui_input(event: InputEvent) -> void:
	var record := pointer_record(event)
	if record.is_empty():
		return
	if _router.session_is_paused():
		return
	_accept_pointer(record)
	_router.note_pointer(record)


func apply_recorded_pointer(record: Dictionary) -> void:
	if _router.session_is_paused():
		return
	_accept_pointer(record)


func pointer_record(event: InputEvent) -> Dictionary:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		return _pointer_dict("touch", touch.pressed, touch.index, touch.position)
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index != MOUSE_BUTTON_LEFT:
			return {}
		return _pointer_dict("pointer", button.pressed, 0, button.position)
	return {}


func _on_screen_requested(screen_id: String, state: Dictionary) -> void:
	show_screen(screen_id, state)


func _show_loading() -> void:
	_loading.visible = true
	_loading.text = _loading_text()
	_ready_hook.visible = false


func _show_ready() -> void:
	_loading.visible = false
	_ready_hook.visible = true


func _accept_pointer(record: Dictionary) -> void:
	pointer_count += 1
	last_pointer = record


func _loading_text() -> String:
	if LOADING_COPY.has(_router.locale):
		return str(LOADING_COPY[_router.locale])
	return str(LOADING_COPY["en"])


func _pointer_dict(kind: String, pressed: bool, index: int, at: Vector2) -> Dictionary:
	return {
		"kind": kind,
		"pressed": pressed,
		"index": index,
		"x": at.x,
		"y": at.y,
	}
