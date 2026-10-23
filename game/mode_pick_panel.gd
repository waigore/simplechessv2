class_name ModePickPanel
extends PanelContainer
## UI-mode-pick regions R1–R3 and states S1, S3, S4. C2 (Wave 2) enters `puzzle-play`.

signal control_activated(control_id: String)
signal pointed(control_id: String)

const SCREEN_ID := "mode-pick"

var locale := "en"
var last_mode := ""
var ui_state := "S1"

var _title: Label
var _shared: Button
var _puzzle: Button
var _quit: Button
var _locale_btn: Button
var _default_box: VBoxContainer
var _confirm_box: VBoxContainer
var _save_box: VBoxContainer
var _confirm_msg: Label
var _confirm_ok: Button
var _confirm_cancel: Button
var _save_msg: Label
var _dismiss: Button
var _ui_font: Font
var _text_scale := 1.0


func _ready() -> void:
	_build()
	_apply_copy()
	_show_state("S1")


func configure(
	next_locale: String, next_last_mode: String, font: Font = null, text_scale: float = 1.0
) -> void:
	locale = next_locale
	last_mode = next_last_mode
	_ui_font = font
	_text_scale = text_scale
	if is_inside_tree():
		_apply_font()
		_apply_copy()
		_refresh_last_mode()


func set_ui_state(state_id: String) -> void:
	_show_state(state_id)


func focusable_controls() -> Array[Control]:
	match ui_state:
		"S3":
			return [_confirm_ok, _confirm_cancel]
		"S4":
			return [_dismiss, _shared, _puzzle, _quit, _locale_btn]
		_:
			return [_shared, _puzzle, _quit, _locale_btn]


func _build() -> void:
	add_theme_stylebox_override("panel", UiChrome.panel_style())
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	add_child(root)

	_title = Label.new()
	_title.name = "Title"
	UiChrome.style_label(_title, true)
	root.add_child(_title)

	_default_box = VBoxContainer.new()
	_default_box.add_theme_constant_override("separation", 12)
	root.add_child(_default_box)

	_shared = Button.new()
	_shared.name = "SharedGame"
	_shared.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shared.pressed.connect(_on_activate.bind("C1"))
	_shared.focus_entered.connect(_on_point.bind("C1"))
	_shared.mouse_entered.connect(_on_point.bind("C1"))
	_default_box.add_child(_shared)

	# UI-mode-pick.C2 / NAV.T2 — Puzzle stream sits beside Shared game.
	_puzzle = Button.new()
	_puzzle.name = "PuzzleStream"
	_puzzle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_puzzle.pressed.connect(_on_activate.bind("C2"))
	_puzzle.focus_entered.connect(_on_point.bind("C2"))
	_puzzle.mouse_entered.connect(_on_point.bind("C2"))
	_default_box.add_child(_puzzle)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_BEGIN
	footer.add_theme_constant_override("separation", 12)
	_default_box.add_child(footer)

	_quit = Button.new()
	_quit.name = "Quit"
	_quit.pressed.connect(_on_activate.bind("C3"))
	_quit.focus_entered.connect(_on_point.bind("C3"))
	_quit.mouse_entered.connect(_on_point.bind("C3"))
	footer.add_child(_quit)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)

	_locale_btn = Button.new()
	_locale_btn.name = "SwitchLocale"
	_locale_btn.pressed.connect(_on_activate.bind("C4"))
	_locale_btn.focus_entered.connect(_on_point.bind("C4"))
	_locale_btn.mouse_entered.connect(_on_point.bind("C4"))
	footer.add_child(_locale_btn)

	_confirm_box = VBoxContainer.new()
	_confirm_box.add_theme_constant_override("separation", 12)
	_confirm_box.visible = false
	root.add_child(_confirm_box)
	_confirm_msg = Label.new()
	_confirm_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_confirm_msg)
	_confirm_box.add_child(_confirm_msg)
	var confirm_row := HBoxContainer.new()
	confirm_row.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_row.add_theme_constant_override("separation", 12)
	_confirm_box.add_child(confirm_row)
	_confirm_ok = Button.new()
	_confirm_ok.name = "ConfirmQuit"
	_confirm_ok.pressed.connect(_on_activate.bind("confirm"))
	_confirm_ok.focus_entered.connect(_on_point.bind("confirm"))
	_confirm_ok.mouse_entered.connect(_on_point.bind("confirm"))
	confirm_row.add_child(_confirm_ok)
	_confirm_cancel = Button.new()
	_confirm_cancel.name = "CancelQuit"
	_confirm_cancel.pressed.connect(_on_activate.bind("cancel"))
	_confirm_cancel.focus_entered.connect(_on_point.bind("cancel"))
	_confirm_cancel.mouse_entered.connect(_on_point.bind("cancel"))
	confirm_row.add_child(_confirm_cancel)

	_save_box = VBoxContainer.new()
	_save_box.add_theme_constant_override("separation", 12)
	_save_box.visible = false
	root.add_child(_save_box)
	_save_msg = Label.new()
	_save_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_save_msg)
	_save_box.add_child(_save_msg)
	_dismiss = Button.new()
	_dismiss.name = "DismissSave"
	_dismiss.pressed.connect(_on_activate.bind("dismiss"))
	_dismiss.focus_entered.connect(_on_point.bind("dismiss"))
	_dismiss.mouse_entered.connect(_on_point.bind("dismiss"))
	_save_box.add_child(_dismiss)

	_style_all()
	_refresh_last_mode()


func _style_all() -> void:
	UiChrome.style_button(_shared, false, _is_last_shared(), _text_scale)
	UiChrome.style_button(_puzzle, false, _is_last_puzzle(), _text_scale)
	UiChrome.style_button(_quit, false, false, _text_scale)
	UiChrome.style_button(_locale_btn, false, false, _text_scale)
	UiChrome.style_button(_confirm_ok, true, false, _text_scale)
	UiChrome.style_button(_confirm_cancel, false, false, _text_scale)
	UiChrome.style_button(_dismiss, true, false, _text_scale)
	UiChrome.style_label(_title, true, _text_scale)
	UiChrome.style_label(_confirm_msg, false, _text_scale)
	UiChrome.style_label(_save_msg, false, _text_scale)


func _apply_font() -> void:
	if _ui_font == null:
		return
	for node in [
		_title,
		_shared,
		_puzzle,
		_quit,
		_locale_btn,
		_confirm_msg,
		_confirm_ok,
		_confirm_cancel,
		_save_msg,
		_dismiss,
	]:
		UiChrome.apply_font(node, _ui_font)


func _apply_copy() -> void:
	_title.text = StringTable.mode_pick("title", locale)
	_shared_label()
	_puzzle_label()
	_quit.text = StringTable.mode_pick("quit", locale)
	_locale_btn.text = StringTable.mode_pick("locale", locale)
	_confirm_msg.text = StringTable.mode_pick("quit_confirm", locale)
	_confirm_ok.text = StringTable.mode_pick("confirm", locale)
	_confirm_cancel.text = StringTable.mode_pick("cancel", locale)
	_save_msg.text = StringTable.mode_pick("save_failed", locale)
	_dismiss.text = StringTable.mode_pick("dismiss", locale)


func _shared_label() -> void:
	var shared := StringTable.mode_pick("shared", locale)
	if _is_last_shared():
		_shared.text = "%s · %s" % [shared, StringTable.mode_pick("last", locale)]
	else:
		_shared.text = shared


func _puzzle_label() -> void:
	var puzzle := StringTable.mode_pick("puzzle", locale)
	if _is_last_puzzle():
		_puzzle.text = "%s · %s" % [puzzle, StringTable.mode_pick("last", locale)]
	else:
		_puzzle.text = puzzle


func _refresh_last_mode() -> void:
	_shared_label()
	_puzzle_label()
	UiChrome.style_button(_shared, false, _is_last_shared(), _text_scale)
	UiChrome.style_button(_puzzle, false, _is_last_puzzle(), _text_scale)


func _is_last_shared() -> bool:
	## FL-mode-pick.N1: Shared is the default when Last mode is none.
	return last_mode.is_empty() or last_mode == "none" or last_mode == "shared"


## FL-mode-pick.N1 / PRG.M1 — Puzzle is the default when Last mode is puzzle.
func _is_last_puzzle() -> bool:
	return last_mode == PersistStore.MODE_PUZZLE


func _show_state(state_id: String) -> void:
	ui_state = state_id
	_confirm_box.visible = false
	_save_box.visible = false
	_style_all()
	# Animate sub-panels only when this screen is already up (avoid nested M1 fade).
	var animate := visible and modulate.a > 0.5
	match state_id:
		"S3":
			_default_box.visible = false
			_reveal_box(_confirm_box, animate)
		"S4":
			_default_box.visible = true
			_default_box.modulate.a = 1.0
			_reveal_box(_save_box, animate)
		_:
			_default_box.visible = false
			_reveal_box(_default_box, animate)
	_focus_first()


func _reveal_box(box: Control, animate: bool) -> void:
	if animate:
		UiChrome.transition_in(box)
	else:
		box.visible = true
		box.modulate.a = 1.0


func _focus_first() -> void:
	var controls := focusable_controls()
	if controls.is_empty():
		return
	controls[0].grab_focus()


func _on_activate(control_id: String) -> void:
	control_activated.emit(control_id)


func _on_point(control_id: String) -> void:
	pointed.emit(control_id)
