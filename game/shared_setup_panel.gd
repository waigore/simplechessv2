class_name SharedSetupPanel
extends PanelContainer
## UI-shared-setup options and Start/Back (CFG.K1 for Increment).

signal control_activated(control_id: String)
signal pointed(control_id: String)

const SCREEN_ID := "shared-setup"

var locale := "en"
var white_seat := "bottom"
var clock := "untimed"
var increment := 3
var advice_on := true
var options_locked := false

var _title: Label
var _seat: Button
var _clock: Button
var _increment: Button
var _advice: Button
var _start: Button
var _back: Button
var _ui_font: Font


func _ready() -> void:
	_build()
	refresh()
	focus_first()


func configure(
	next_locale: String,
	seat: String,
	clock_id: String,
	increment_s: int,
	advice: bool,
	locked: bool,
	font: Font = null
) -> void:
	locale = next_locale
	white_seat = seat
	clock = clock_id
	increment = increment_s
	advice_on = advice
	options_locked = locked
	_ui_font = font
	if is_inside_tree():
		_apply_font()
		refresh()


func focusable_controls() -> Array[Control]:
	var out: Array[Control] = []
	for button in [_seat, _clock, _increment, _advice, _start, _back]:
		if button.visible and not button.disabled:
			out.append(button)
	return out


func refresh() -> void:
	_title.text = StringTable.shared_setup("title", locale)
	_seat.text = _option_line("white_seat", "seat_top" if white_seat == "top" else "seat_bottom")
	_clock.text = _option_line("clock", _clock_key())
	_increment.text = _option_line(
		"increment", "increment_5s" if increment == 5 else "increment_3s"
	)
	_advice.text = _option_line("advice", "advice_on" if advice_on else "advice_off")
	_start.text = StringTable.shared_setup("start", locale)
	_back.text = StringTable.shared_setup("back", locale)
	var timed := clock == "blitz" or clock == "rapid"
	_increment.visible = true
	_increment.disabled = options_locked or not timed
	_seat.disabled = options_locked
	_clock.disabled = options_locked
	_style_all()


func focus_first() -> void:
	_focus_first()


func _build() -> void:
	add_theme_stylebox_override("panel", UiChrome.panel_style())
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	add_child(root)

	_title = Label.new()
	UiChrome.style_label(_title, true)
	root.add_child(_title)

	var options := VBoxContainer.new()
	options.add_theme_constant_override("separation", 12)
	root.add_child(options)

	_seat = _make_option("WhiteSeat", "C1", options)
	_clock = _make_option("Clock", "C2", options)
	_increment = _make_option("Increment", "C3", options)
	_advice = _make_option("Advice", "C4", options)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	root.add_child(actions)
	_start = Button.new()
	_start.name = "Start"
	_start.pressed.connect(_on_activate.bind("C5"))
	_start.focus_entered.connect(_on_point.bind("C5"))
	_start.mouse_entered.connect(_on_point.bind("C5"))
	actions.add_child(_start)
	_back = Button.new()
	_back.name = "Back"
	_back.pressed.connect(_on_activate.bind("C6"))
	_back.focus_entered.connect(_on_point.bind("C6"))
	_back.mouse_entered.connect(_on_point.bind("C6"))
	actions.add_child(_back)
	_style_all()


func _make_option(node_name: String, control_id: String, parent: Control) -> Button:
	var button := Button.new()
	button.name = node_name
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(_on_activate.bind(control_id))
	button.focus_entered.connect(_on_point.bind(control_id))
	button.mouse_entered.connect(_on_point.bind(control_id))
	parent.add_child(button)
	return button


func _style_all() -> void:
	UiChrome.style_button(_seat)
	UiChrome.style_button(_clock)
	UiChrome.style_button(_increment)
	UiChrome.style_button(_advice)
	UiChrome.style_button(_start, true)
	UiChrome.style_button(_back)


func _apply_font() -> void:
	if _ui_font == null:
		return
	for node in [_title, _seat, _clock, _increment, _advice, _start, _back]:
		UiChrome.apply_font(node, _ui_font)


func _option_line(label_key: String, value_key: String) -> String:
	return (
		"%s · %s"
		% [
			StringTable.shared_setup(label_key, locale),
			StringTable.shared_setup(value_key, locale),
		]
	)


func _clock_key() -> String:
	match clock:
		"blitz":
			return "clock_blitz"
		"rapid":
			return "clock_rapid"
		_:
			return "clock_untimed"


func _focus_first() -> void:
	var controls := focusable_controls()
	if controls.is_empty():
		return
	controls[0].grab_focus()


func _on_activate(control_id: String) -> void:
	if control_id == "C3" and _increment.disabled:
		return
	if options_locked and control_id in ["C1", "C2", "C3"]:
		return
	control_activated.emit(control_id)
	match control_id:
		"C1":
			UiChrome.tween_value_modulate(_seat)
		"C2":
			UiChrome.tween_value_modulate(_clock)
		"C3":
			UiChrome.tween_value_modulate(_increment)
		"C4":
			UiChrome.tween_value_modulate(_advice)
		_:
			pass


func _on_point(control_id: String) -> void:
	pointed.emit(control_id)
