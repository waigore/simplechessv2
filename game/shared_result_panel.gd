class_name SharedResultPanel
extends PanelContainer
## Minimal UI-shared-result shell for NAV.T6 (#58). Full journey is #59.

signal control_activated(control_id: String)
signal pointed(control_id: String)

const SCREEN_ID := "shared-result"

var locale := "en"
var result_key := "result_draw"

var _title: Label
var _result: Label
var _play_again: Button
var _stop: Button
var _ui_font: Font


func _ready() -> void:
	_build()
	_apply_copy()


func configure(next_locale: String, next_result_key: String, font: Font = null) -> void:
	locale = next_locale
	result_key = next_result_key if not next_result_key.is_empty() else "result_draw"
	_ui_font = font
	if is_inside_tree():
		_apply_font()
		_apply_copy()


func focusable_controls() -> Array[Control]:
	return [_play_again, _stop]


func focus_first() -> void:
	_play_again.grab_focus()


func _build() -> void:
	add_theme_stylebox_override("panel", UiChrome.panel_style())
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	add_child(root)

	_title = Label.new()
	_title.name = "ResultTitle"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_title, true)
	root.add_child(_title)

	_result = Label.new()
	_result.name = "ResultCopy"
	_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_result)
	root.add_child(_result)

	_play_again = Button.new()
	_play_again.name = "PlayAgain"
	_play_again.pressed.connect(_on_activate.bind("C1"))
	_play_again.focus_entered.connect(_on_point.bind("C1"))
	_play_again.mouse_entered.connect(_on_point.bind("C1"))
	root.add_child(_play_again)

	_stop = Button.new()
	_stop.name = "Stop"
	_stop.pressed.connect(_on_activate.bind("C2"))
	_stop.focus_entered.connect(_on_point.bind("C2"))
	_stop.mouse_entered.connect(_on_point.bind("C2"))
	root.add_child(_stop)

	UiChrome.style_button(_play_again, true)
	UiChrome.style_button(_stop)


func _apply_font() -> void:
	if _ui_font == null:
		return
	for node in [_title, _result, _play_again, _stop]:
		UiChrome.apply_font(node, _ui_font)


func _apply_copy() -> void:
	_title.text = StringTable.shared_result("title", locale)
	_result.text = StringTable.shared_result(result_key, locale)
	_play_again.text = StringTable.shared_result("play_again", locale)
	_stop.text = StringTable.shared_result("stop", locale)


func _on_activate(control_id: String) -> void:
	control_activated.emit(control_id)


func _on_point(control_id: String) -> void:
	pointed.emit(control_id)
