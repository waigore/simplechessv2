class_name PuzzlePlayPanel
extends Control
## UI-puzzle-play R2 / R3 chrome, states S1–S5, and the 44px-class control row
## for C3–C6. R1 is the shared BoardPresentation; Presentation owns the gestures.

signal control_activated(control_id: String)
signal pointed(control_id: String)

const SCREEN_ID := "puzzle-play"
## R2–R3 strip; Presentation reserves this so R1 is never covered (PRJ.A1).
const CHROME_TOP_PX := 12.0
const CHROME_RESERVED_PX := 168.0
## The S4 promotion-name line at the 640 px reference frame: one UIS.T2 line as
## the names measure at scale 1.0. See `s4_name_row_px`.
const S4_NAME_ROW_PX := 27.0
## UIS.F1 / controls F1 — every control is at least a 44px-class touch target.
const TOUCH_TARGET_PX := 44

var locale := "en"
var ui_state := "S1"
var player_elo := 0.0
var cue_key := ""
var confirm_kind := ""
var solving_side := ""
## C1–C4 need an open puzzle; Presentation sets this from `PuzzleSession.has_open_puzzle()`.
var puzzle_open := true

var _elo: Label
var _cue: Label
var _status: Label
var _select_focus: Button
var _place_focus: Button
var _reveal: Button
var _abandon: Button
var _leave: Button
var _promote_row: HBoxContainer
var _promote_btns: Dictionary = {}
var _promote_names: Dictionary = {}
var _confirm_box: VBoxContainer
var _confirm_msg: Label
var _confirm_ok: Button
var _confirm_cancel: Button
var _save_box: VBoxContainer
var _save_msg: Label
var _dismiss: Button
var _chrome: VBoxContainer
var _ui_font: Font
var _text_scale := 1.0


## UIS.T2 ratio scaling — the chrome reserve grows with the text it holds. S4 adds
## a line of T2 promotion names (#795), so the reserve grows with the state too,
## rather than squeezing the names into the S1 strip.
static func chrome_reserved_px(text_scale_value: float, state_id: String = "") -> float:
	var ratio := maxf(1.0, text_scale_value)
	return CHROME_RESERVED_PX * ratio + (s4_name_row_px(ratio) if state_id == "S4" else 0.0)


## The name line's own size. It is not the strip's summed term again: the line
## grows with UIS.T2 (`UiChrome` sizes the labels from the frame, not from the
## scale the caller passes), so a reserve that multiplied it by the ratio left the
## names 2 px outside the strip at 1.125.
static func s4_name_row_px(text_scale_value: float) -> float:
	return S4_NAME_ROW_PX * maxf(1.0, text_scale_value)


## The reserve for the state the panel is showing; Presentation reads the same
## value to place R1, so the strip and the board never disagree.
func reserved_px() -> float:
	return chrome_reserved_px(_text_scale, ui_state)


## SIT.6 / S13 — the frame reflowed: take the new ratio and restyle in place.
func set_text_scale(text_scale_value: float) -> void:
	if is_equal_approx(text_scale_value, _text_scale):
		return
	_text_scale = text_scale_value
	if is_inside_tree():
		_style_all()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	refresh()


func configure(state: Dictionary, font: Font = null, text_scale: float = 1.0) -> void:
	_text_scale = text_scale
	locale = str(state.get("locale", locale))
	ui_state = str(state.get("ui_state", "S1"))
	player_elo = float(state.get("player_elo", player_elo))
	cue_key = str(state.get("cue_key", ""))
	confirm_kind = str(state.get("confirm_kind", ""))
	solving_side = str(state.get("solving_side", solving_side))
	puzzle_open = bool(state.get("puzzle_open", puzzle_open))
	_ui_font = font
	if is_inside_tree():
		_apply_font()
		refresh()


## puzzle-play-controls.md availability, measured against the live state.
func control_available(control_id: String) -> bool:
	match control_id:
		"C1", "C2", "C3", "C4":
			return puzzle_open and ui_state != "S2" and ui_state != "S4"
		"C5":
			return ui_state != "S2" and ui_state != "S4"
		"C6":
			return ui_state == "S4"
	return false


func button_for(control_id: String) -> Button:
	if control_id.begins_with("C6:"):
		return _promote_btns.get(control_id.get_slice(":", 1), null) as Button
	var found: Button = null
	match control_id:
		"C3":
			found = _reveal
		"C4":
			found = _abandon
		"C5":
			found = _leave
		"confirm":
			found = _confirm_ok
		"cancel":
			found = _confirm_cancel
		"dismiss":
			found = _dismiss
	return found


## puzzle-play-controls.md focus order (top→bottom, C1 before C2) among available ones.
func focusable_controls() -> Array[Control]:
	var out: Array[Control] = []
	match ui_state:
		"S2":
			out.append(_confirm_ok)
			out.append(_confirm_cancel)
		"S4":
			for kind in PuzzleSession.PROMOTE_ORDER:
				out.append(_promote_btns[kind] as Control)
		_:
			out.append(_select_focus)
			out.append(_place_focus)
			out.append(_reveal)
			out.append(_abandon)
			out.append(_leave)
			if ui_state == "S3":
				out.append(_dismiss)
	var available: Array[Control] = []
	for ctrl in out:
		if ctrl is BaseButton and (ctrl as BaseButton).disabled:
			continue
		available.append(ctrl)
	return available


## S2 / S4 take focus on entry; S1 / S3 / S5 keep whatever the actor was using.
func wants_focus_on_show() -> bool:
	return ui_state == "S2" or ui_state == "S4"


func focus_first() -> void:
	var controls := focusable_controls()
	if controls.is_empty():
		return
	controls[0].grab_focus()


func refresh() -> void:
	_apply_copy()
	_apply_availability()
	_show_state(ui_state)
	# `configure` may have moved `ui_state`; refresh always runs, so the strip is
	# sized here once the state is final rather than from `_build`.
	_apply_strip_size()


## The R2–R3 strip takes exactly this state's reserve, so a taller S4 cannot
## spill its names into R1 (PRJ.A1) or clip them at the old S1 height (#795).
func _apply_strip_size() -> void:
	if _chrome == null:
		return
	# Offsets are measured from the top edge, so the bottom is the whole reserve.
	_chrome.offset_bottom = reserved_px()


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_chrome = VBoxContainer.new()
	_chrome.name = "PuzzleChrome"
	_chrome.mouse_filter = Control.MOUSE_FILTER_STOP
	_chrome.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_chrome.offset_left = 16
	_chrome.offset_right = -16
	_chrome.offset_top = CHROME_TOP_PX
	_chrome.add_theme_constant_override("separation", 8)
	add_child(_chrome)

	# R2 — GS.playerElo always visible; the cue follows an ending only (W1 / L4–L6).
	var r2 := HBoxContainer.new()
	r2.name = "EloAndStatus"
	r2.alignment = BoxContainer.ALIGNMENT_CENTER
	r2.add_theme_constant_override("separation", 16)
	_chrome.add_child(r2)
	_elo = Label.new()
	_elo.name = "PlayerElo"
	r2.add_child(_elo)
	_cue = Label.new()
	_cue.name = "ResultCue"
	r2.add_child(_cue)
	_style_r2_line_labels()

	# Text line for states whose copy is not a control label (S4, S5).
	_status = Label.new()
	_status.name = "PuzzleStatus"
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiChrome.style_label(_status)
	_chrome.add_child(_status)

	# C1/C2/C6 are board surfaces; off-strip sentinels keep the F1 order (44px).
	_select_focus = _sentinel("SelectFocus", "C1", -200.0)
	_place_focus = _sentinel("PlaceFocus", "C2", -170.0)
	var promote_y := -140.0
	for kind in PuzzleSession.PROMOTE_ORDER:
		var btn := _sentinel("Promote%s" % kind.capitalize(), "C6:%s" % kind, promote_y)
		promote_y += 30.0
		_promote_btns[kind] = btn

	# C6 — the four chooser options named in R2 while the sprites stand on the board
	# (S4). Each option gets its own T2 label (#795): the sentinels stay invisible
	# and off-strip for focus order and cannot carry copy the actor reads.
	_promote_row = HBoxContainer.new()
	_promote_row.name = "PromotionRow"
	_promote_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_promote_row.add_theme_constant_override("separation", 28)
	_promote_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_promote_row.visible = false
	_chrome.add_child(_promote_row)
	for kind in PuzzleSession.PROMOTE_ORDER:
		var option := Label.new()
		option.name = "PromoteName%s" % kind.capitalize()
		# No width floor: the label takes the width its word needs at UIS.T2, so
		# the longest name in any locale still reads on one line.
		option.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		option.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		option.autowrap_mode = TextServer.AUTOWRAP_OFF
		option.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_promote_names[kind] = option
		_promote_row.add_child(option)

	# R3 — stream actions C3, C4, C5 in controls-table order.
	var row := HBoxContainer.new()
	row.name = "StreamActions"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chrome.add_child(row)
	_reveal = _action("Reveal", "C3", row)
	_abandon = _action("Abandon", "C4", row)
	_leave = _action("LeaveStream", "C5", row)

	_build_confirm()
	_build_save_failure()
	_style_all()
	_apply_font()


func _sentinel(node_name: String, control_id: String, x: float) -> Button:
	var btn := Button.new()
	btn.name = node_name
	btn.text = control_id
	btn.custom_minimum_size = Vector2(TOUCH_TARGET_PX, TOUCH_TARGET_PX)
	btn.modulate.a = 0.0
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.position = Vector2(x, -200.0)
	btn.focus_entered.connect(_on_point.bind(control_id))
	btn.pressed.connect(_on_activate.bind(control_id))
	add_child(btn)
	return btn


func _action(node_name: String, control_id: String, into: Control) -> Button:
	var btn := Button.new()
	btn.name = node_name
	btn.custom_minimum_size = Vector2(0, TOUCH_TARGET_PX)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_activate.bind(control_id))
	btn.focus_entered.connect(_on_point.bind(control_id))
	btn.mouse_entered.connect(_on_point.bind(control_id))
	into.add_child(btn)
	return btn


## S2 — EX.confirm: named prompt, Confirm runs the action, Cancel → S1.
func _build_confirm() -> void:
	_confirm_box = VBoxContainer.new()
	_confirm_box.name = "StreamConfirm"
	_confirm_box.visible = false
	_confirm_box.custom_minimum_size = Vector2(280, 140)
	Presentation.place_centered_over_board(_confirm_box, 220.0)
	_confirm_box.add_theme_constant_override("separation", 12)
	add_child(_confirm_box)
	# #793 — raised to `Presentation.OVERLAY_Z`; keep it after the chrome so tree
	# order agrees with the band a display paints.
	move_child(_confirm_box, _chrome.get_index() + 1)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiChrome.panel_style())
	_confirm_box.add_child(panel)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	panel.add_child(inner)
	_confirm_msg = Label.new()
	_confirm_msg.name = "StreamConfirmMsg"
	_confirm_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiChrome.style_label(_confirm_msg)
	inner.add_child(_confirm_msg)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	inner.add_child(row)
	_confirm_ok = Button.new()
	_confirm_ok.name = "ConfirmStream"
	_confirm_ok.custom_minimum_size = Vector2(0, TOUCH_TARGET_PX)
	_confirm_ok.pressed.connect(_on_activate.bind("confirm"))
	_confirm_ok.focus_entered.connect(_on_point.bind("confirm"))
	_confirm_ok.mouse_entered.connect(_on_point.bind("confirm"))
	row.add_child(_confirm_ok)
	_confirm_cancel = Button.new()
	_confirm_cancel.name = "CancelStream"
	_confirm_cancel.custom_minimum_size = Vector2(0, TOUCH_TARGET_PX)
	_confirm_cancel.pressed.connect(_on_activate.bind("cancel"))
	_confirm_cancel.focus_entered.connect(_on_point.bind("cancel"))
	_confirm_cancel.mouse_entered.connect(_on_point.bind("cancel"))
	row.add_child(_confirm_cancel)


## S3 — EX.save-failure: non-modal; C1–C5 stay usable and the stream continues.
func _build_save_failure() -> void:
	_save_box = VBoxContainer.new()
	_save_box.name = "SaveFailure"
	_save_box.visible = false
	_save_box.custom_minimum_size = Vector2(280, 120)
	Presentation.place_centered_over_board(_save_box, 220.0)
	_save_box.add_theme_constant_override("separation", 12)
	add_child(_save_box)
	move_child(_save_box, _chrome.get_index() + 1)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiChrome.panel_style())
	_save_box.add_child(panel)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	panel.add_child(inner)
	_save_msg = Label.new()
	_save_msg.name = "SaveFailureMsg"
	_save_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiChrome.style_label(_save_msg)
	inner.add_child(_save_msg)
	_dismiss = Button.new()
	_dismiss.name = "DismissSave"
	_dismiss.custom_minimum_size = Vector2(0, TOUCH_TARGET_PX)
	_dismiss.pressed.connect(_on_activate.bind("dismiss"))
	_dismiss.focus_entered.connect(_on_point.bind("dismiss"))
	_dismiss.mouse_entered.connect(_on_point.bind("dismiss"))
	inner.add_child(_dismiss)


## R2 is one line each (#794): the Elo reading and every result cue are single
## phrases, so they must not word-wrap. `UiChrome.style_label` turns word-wrap on
## for body copy, and a wrapped label in the centred `EloAndStatus` row is offered
## no width and wraps per character (1 px wide, 405 px tall). Kept off
## `style_label` because every other screen relies on that wrap.
func _style_r2_line_labels() -> void:
	for label in [_elo, _cue]:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _style_all() -> void:
	UiChrome.style_label(_elo, true, _text_scale)
	UiChrome.style_label(_cue, true, _text_scale)
	_style_r2_line_labels()
	UiChrome.style_label(_status, false, _text_scale)
	for button in [_reveal, _abandon, _leave, _confirm_ok, _confirm_cancel, _dismiss]:
		UiChrome.style_button(button as Button, false, false, _text_scale)
	for kind in PuzzleSession.PROMOTE_ORDER:
		UiChrome.style_button(_promote_btns[kind] as Button, false, false, _text_scale)
	# UIS.T2 size for the four C6 names (#795). `style_label` turns word-wrap on
	# for body copy; a name is one line, and a wrapped one splits mid-word
	# ("Que/en"), so the wrap it sets is cleared again here.
	for kind in PuzzleSession.PROMOTE_ORDER:
		var name_label := _promote_names[kind] as Label
		UiChrome.style_label(name_label, false, _text_scale)
		name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	UiChrome.style_label(_confirm_msg, false, _text_scale)
	UiChrome.style_label(_save_msg, false, _text_scale)


func _apply_font() -> void:
	if _ui_font == null:
		return
	var nodes: Array = [
		_elo,
		_cue,
		_status,
		_select_focus,
		_place_focus,
		_reveal,
		_abandon,
		_leave,
		_confirm_msg,
		_confirm_ok,
		_confirm_cancel,
		_save_msg,
		_dismiss,
	]
	for kind in PuzzleSession.PROMOTE_ORDER:
		nodes.append(_promote_btns[kind])
		nodes.append(_promote_names[kind])
	for node in nodes:
		UiChrome.apply_font(node, _ui_font)


func _apply_copy() -> void:
	_elo.text = "%s %d" % [StringTable.puzzle_play("elo", locale), roundi(player_elo)]
	_cue.text = StringTable.puzzle_play(cue_key, locale) if not cue_key.is_empty() else ""
	_reveal.text = StringTable.puzzle_play("reveal", locale)
	_abandon.text = StringTable.puzzle_play("abandon", locale)
	_leave.text = StringTable.puzzle_play("leave", locale)
	_confirm_msg.text = StringTable.puzzle_play(confirm_kind, locale)
	_confirm_ok.text = StringTable.puzzle_play("confirm", locale)
	_confirm_cancel.text = StringTable.puzzle_play("cancel", locale)
	_save_msg.text = StringTable.puzzle_play("save_failed", locale)
	_dismiss.text = StringTable.puzzle_play("dismiss", locale)
	_status.text = ""
	if ui_state == "S4":
		_status.text = StringTable.puzzle_play("choose_promotion", locale)
	elif ui_state == "S5":
		_status.text = StringTable.puzzle_play("refused_place", locale)
	for kind in PuzzleSession.PROMOTE_ORDER:
		(_promote_btns[kind] as Button).text = StringTable.puzzle_play(kind, locale)
		(_promote_names[kind] as Label).text = StringTable.puzzle_play(kind, locale)


func _apply_availability() -> void:
	_select_focus.disabled = not control_available("C1")
	_place_focus.disabled = not control_available("C2")
	_reveal.disabled = not control_available("C3")
	_abandon.disabled = not control_available("C4")
	_leave.disabled = not control_available("C5")
	var c6_available := control_available("C6")
	for kind in PuzzleSession.PROMOTE_ORDER:
		(_promote_btns[kind] as Button).disabled = not c6_available
		# PAL.K7 — an unavailable option keeps its name, in inactive ink.
		_apply_disabled_ink(_promote_names[kind] as Label, c6_available)
	_style_all()


## PAL.K7 — the name stays readable yet reads inactive (C5's muted ink at 40%).
func _apply_disabled_ink(label: Label, enabled: bool) -> void:
	if enabled:
		label.remove_theme_color_override("font_color")
	else:
		label.add_theme_color_override("font_color", Color(UiChrome.COLOR_MUTED, 0.4))


## S1 keeps R2/R3 only; S4 adds the C6 names; S5 adds the refused-place text.
func _show_state(state_id: String) -> void:
	ui_state = state_id
	_confirm_box.visible = state_id == "S2"
	_save_box.visible = state_id == "S3"
	_promote_row.visible = state_id == "S4"
	_status.visible = state_id == "S4" or state_id == "S5"
	_apply_copy()


func _on_activate(control_id: String) -> void:
	var button := button_for(control_id)
	if button != null and button.disabled:
		return
	# C1/C2/C6 activate through board gestures (B2/B3/B10 and the chooser); the
	# sentinels only carry focus order and pointed events.
	if control_id == "C1" or control_id == "C2" or control_id.begins_with("C6:"):
		return
	control_activated.emit(control_id)


func _on_point(control_id: String) -> void:
	pointed.emit(control_id)
