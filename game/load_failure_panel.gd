class_name LoadFailurePanel
extends PanelContainer
## UI-mode-pick S5 / EX.load-failure — the cold open's Boot load failed, so the
## `EX.loading` wait ends on this surface. It names what failed and offers C5
## Reload and nothing else (exceptions.md; mode-pick Controls C5 / States S5).

signal control_activated(control_id: String)
signal pointed(control_id: String)

const SCREEN_ID := "loading"
const CONTROL_RELOAD := "C5"

var locale := "en"

var _message: Label
var _reload: Button
var _ui_font: Font
var _text_scale := 1.0


func _ready() -> void:
	_build()
	_apply_copy()


func configure(next_locale: String, font: Font = null, text_scale: float = 1.0) -> void:
	locale = next_locale
	_ui_font = font
	_text_scale = text_scale
	if is_inside_tree():
		_apply_font()
		_apply_copy()
		_style_all()


## S5's only available control; every other id changes nothing (panel and router).
func control_available(control_id: String) -> bool:
	return control_id == CONTROL_RELOAD


func button_for(control_id: String) -> Button:
	if control_id == CONTROL_RELOAD:
		return _reload
	return null


func focusable_controls() -> Array[Control]:
	return [_reload]


func set_text_scale(text_scale_value: float) -> void:
	if is_equal_approx(text_scale_value, _text_scale):
		return
	_text_scale = text_scale_value
	if is_inside_tree():
		_style_all()


func _build() -> void:
	add_theme_stylebox_override("panel", UiChrome.panel_style())
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	add_child(root)

	_message = Label.new()
	_message.name = "LoadFailureMessage"
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_message, true)
	root.add_child(_message)

	_reload = Button.new()
	_reload.name = "Reload"
	_reload.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reload.pressed.connect(_on_activate.bind(CONTROL_RELOAD))
	_reload.focus_entered.connect(_on_point.bind(CONTROL_RELOAD))
	_reload.mouse_entered.connect(_on_point.bind(CONTROL_RELOAD))
	root.add_child(_reload)

	_style_all()


func _style_all() -> void:
	UiChrome.style_label(_message, true, _text_scale)
	UiChrome.style_button(_reload, true, false, _text_scale)


func _apply_font() -> void:
	if _ui_font == null:
		return
	UiChrome.apply_font(_message, _ui_font)
	UiChrome.apply_font(_reload, _ui_font)


## exceptions.md Key column owns `load_failure` and `reload` (localization.md L2).
func _apply_copy() -> void:
	_message.text = StringTable.exception_text("load_failure", locale)
	_reload.text = StringTable.exception_text("reload", locale)


func _on_activate(control_id: String) -> void:
	control_activated.emit(control_id)


func _on_point(control_id: String) -> void:
	pointed.emit(control_id)
