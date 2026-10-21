class_name SharedPlayPanel
extends Control
## UI-shared-play R2/R3/R4 chrome and S2 resign confirm (#58). Board is R1.

signal control_activated(control_id: String)
signal pointed(control_id: String)

const SCREEN_ID := "shared-play"
## Top strip for R2–R4; Presentation reserves this so R1 is never covered (PRJ.A1).
const CHROME_TOP_PX := 12.0
const CHROME_BOTTOM_PX := 156.0
const CHROME_RESERVED_PX := 168.0

var locale := "en"
var ui_state := "S1"
var side_to_move := "white"
var in_check := false
var clock_id := "untimed"
var white_clock_ms: Variant = null
var black_clock_ms: Variant = null
var advice_on := true
var game_ended := false
var resign_available := true
var board_unavailable := false

var _status: Label
var _check: Label
var _clocks: Label
var _select_focus: Button
var _place_focus: Button
var _advice: Button
var _resign: Button
var _confirm_box: VBoxContainer
var _confirm_msg: Label
var _confirm_ok: Button
var _confirm_cancel: Button
var _chrome: VBoxContainer
var _ui_font: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	refresh()


func configure(state: Dictionary, font: Font = null) -> void:
	locale = str(state.get("locale", locale))
	ui_state = str(state.get("ui_state", "S1"))
	side_to_move = str(state.get("side_to_move", "white"))
	in_check = bool(state.get("in_check", false))
	clock_id = str(state.get("clock", "untimed"))
	white_clock_ms = state.get("white_clock_ms", null)
	black_clock_ms = state.get("black_clock_ms", null)
	advice_on = bool(state.get("advice", true))
	game_ended = bool(state.get("game_ended", false))
	resign_available = bool(state.get("resign_available", true))
	board_unavailable = bool(state.get("board_unavailable", false))
	_ui_font = font
	if is_inside_tree():
		_apply_font()
		refresh()


func focusable_controls() -> Array[Control]:
	if ui_state == "S2":
		return [_confirm_ok, _confirm_cancel]
	# controls.md F1 / shared-play: C1 → C2 → C3 → C4 among available controls.
	var out: Array[Control] = []
	if not _select_focus.disabled:
		out.append(_select_focus)
	if not _place_focus.disabled:
		out.append(_place_focus)
	if not _advice.disabled:
		out.append(_advice)
	if not _resign.disabled:
		out.append(_resign)
	return out


func focus_first() -> void:
	var controls := focusable_controls()
	if controls.is_empty():
		return
	controls[0].grab_focus()


func refresh() -> void:
	_apply_copy()
	_apply_availability()
	_show_state(ui_state)


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_chrome = VBoxContainer.new()
	_chrome.name = "PlayChrome"
	_chrome.mouse_filter = Control.MOUSE_FILTER_STOP
	_chrome.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_chrome.offset_left = 16
	_chrome.offset_right = -16
	_chrome.offset_top = CHROME_TOP_PX
	_chrome.offset_bottom = CHROME_BOTTOM_PX
	_chrome.add_theme_constant_override("separation", 8)
	add_child(_chrome)

	_status = Label.new()
	_status.name = "SideToMove"
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_status, true)
	_chrome.add_child(_status)

	_check = Label.new()
	_check.name = "CheckCue"
	_check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_check)
	_check.add_theme_color_override("font_color", UiChrome.COLOR_DANGER)
	_chrome.add_child(_check)

	_clocks = Label.new()
	_clocks.name = "Clocks"
	_clocks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_clocks)
	# UIS.T3 tabular figures when timed clocks show.
	_clocks.add_theme_constant_override("outline_size", 0)
	_chrome.add_child(_clocks)

	# C1/C2 are board gestures; off-strip focus sentinels keep F1 order (44px).
	_select_focus = Button.new()
	_select_focus.name = "SelectFocus"
	_select_focus.text = "C1"
	_select_focus.modulate.a = 0.0
	_select_focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_select_focus.position = Vector2(-200, -200)
	_select_focus.focus_entered.connect(_on_point.bind("C1"))
	_select_focus.pressed.connect(_on_activate.bind("C1"))
	add_child(_select_focus)

	_place_focus = Button.new()
	_place_focus.name = "PlaceFocus"
	_place_focus.text = "C2"
	_place_focus.modulate.a = 0.0
	_place_focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place_focus.position = Vector2(-200, -140)
	_place_focus.focus_entered.connect(_on_point.bind("C2"))
	_place_focus.pressed.connect(_on_activate.bind("C2"))
	add_child(_place_focus)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chrome.add_child(row)

	_advice = Button.new()
	_advice.name = "AdviceToggle"
	_advice.pressed.connect(_on_activate.bind("C3"))
	_advice.focus_entered.connect(_on_point.bind("C3"))
	_advice.mouse_entered.connect(_on_point.bind("C3"))
	row.add_child(_advice)

	_resign = Button.new()
	_resign.name = "Resign"
	_resign.pressed.connect(_on_activate.bind("C4"))
	_resign.focus_entered.connect(_on_point.bind("C4"))
	_resign.mouse_entered.connect(_on_point.bind("C4"))
	row.add_child(_resign)

	_confirm_box = VBoxContainer.new()
	_confirm_box.name = "ResignConfirm"
	_confirm_box.visible = false
	_confirm_box.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_box.custom_minimum_size = Vector2(280, 140)
	_confirm_box.position = Vector2(40, 200)
	_confirm_box.add_theme_constant_override("separation", 12)
	add_child(_confirm_box)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiChrome.panel_style())
	_confirm_box.add_child(panel)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	panel.add_child(inner)
	_confirm_msg = Label.new()
	_confirm_msg.name = "ResignConfirmMsg"
	_confirm_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiChrome.style_label(_confirm_msg)
	inner.add_child(_confirm_msg)
	var confirm_row := HBoxContainer.new()
	confirm_row.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_row.add_theme_constant_override("separation", 12)
	inner.add_child(confirm_row)
	_confirm_ok = Button.new()
	_confirm_ok.name = "ConfirmResign"
	_confirm_ok.pressed.connect(_on_activate.bind("confirm"))
	_confirm_ok.focus_entered.connect(_on_point.bind("confirm"))
	_confirm_ok.mouse_entered.connect(_on_point.bind("confirm"))
	confirm_row.add_child(_confirm_ok)
	_confirm_cancel = Button.new()
	_confirm_cancel.name = "CancelResign"
	_confirm_cancel.pressed.connect(_on_activate.bind("cancel"))
	_confirm_cancel.focus_entered.connect(_on_point.bind("cancel"))
	_confirm_cancel.mouse_entered.connect(_on_point.bind("cancel"))
	confirm_row.add_child(_confirm_cancel)

	_style_all()
	_wire_focus_order()


func _wire_focus_order() -> void:
	## controls.md F1 — top to bottom among C1–C4 (confirm pair is separate in S2).
	_select_focus.focus_next = _place_focus.get_path()
	_place_focus.focus_next = _advice.get_path()
	_advice.focus_next = _resign.get_path()
	_resign.focus_next = _select_focus.get_path()
	_confirm_ok.focus_next = _confirm_cancel.get_path()
	_confirm_cancel.focus_next = _confirm_ok.get_path()


func _style_all() -> void:
	UiChrome.style_button(_select_focus)
	UiChrome.style_button(_place_focus)
	UiChrome.style_button(_advice)
	UiChrome.style_button(_resign)
	UiChrome.style_button(_confirm_ok, true)
	UiChrome.style_button(_confirm_cancel)


func _apply_font() -> void:
	if _ui_font == null:
		return
	for node in [
		_status,
		_check,
		_clocks,
		_select_focus,
		_place_focus,
		_advice,
		_resign,
		_confirm_msg,
		_confirm_ok,
		_confirm_cancel
	]:
		UiChrome.apply_font(node, _ui_font)


func _apply_copy() -> void:
	var side_key := "white_to_move" if side_to_move == "white" else "black_to_move"
	_status.text = StringTable.shared_play(side_key, locale)
	_check.text = StringTable.shared_play("check", locale) if in_check else ""
	_check.visible = in_check
	_advice.text = StringTable.shared_play("advice_on" if advice_on else "advice_off", locale)
	_resign.text = StringTable.shared_play("resign", locale)
	_confirm_msg.text = StringTable.shared_play("resign_confirm", locale)
	_confirm_ok.text = StringTable.shared_play("confirm", locale)
	_confirm_cancel.text = StringTable.shared_play("cancel", locale)
	_refresh_clocks()


func _refresh_clocks() -> void:
	var timed := clock_id == "blitz" or clock_id == "rapid"
	_clocks.visible = timed and white_clock_ms != null and black_clock_ms != null
	if not _clocks.visible:
		_clocks.text = ""
		return
	_clocks.text = (
		"W %s · B %s" % [_format_clock(int(white_clock_ms)), _format_clock(int(black_clock_ms))]
	)


func _format_clock(ms: int) -> String:
	var total_s := maxi(0, ms) / 1000
	var minutes := total_s / 60
	var seconds := total_s % 60
	# Tabular-style fixed width via zero-padded seconds (UIS.T3).
	return "%d:%02d" % [minutes, seconds]


func _apply_availability() -> void:
	var playable := not game_ended and ui_state != "S2"
	_select_focus.disabled = not playable
	_place_focus.disabled = not playable
	_advice.disabled = not playable
	_resign.disabled = not playable or not resign_available
	_style_all()


func _show_state(state_id: String) -> void:
	ui_state = state_id
	var confirm := state_id == "S2"
	_confirm_box.visible = confirm
	# Keep R2/R4 readable; board dimming is owned by presentation via board_unavailable.
	_chrome.modulate.a = 1.0
	if confirm and visible:
		focus_first()


func _on_activate(control_id: String) -> void:
	if control_id == "C1" and _select_focus.disabled:
		return
	if control_id == "C2" and _place_focus.disabled:
		return
	if control_id == "C3" and _advice.disabled:
		return
	if control_id == "C4" and _resign.disabled:
		return
	# C1/C2 activate via board gestures (B2/B3/B10); focus sentinels only emit point.
	if control_id == "C1" or control_id == "C2":
		return
	control_activated.emit(control_id)


func _on_point(control_id: String) -> void:
	pointed.emit(control_id)
