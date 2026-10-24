class_name SharedPlayPanel
extends Control
## UI-shared-play R2/R3/R4 chrome; S2 confirm; S4/S5/S6 choice states (#58/#94).

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
var online := true
var advice_best_move: Variant = null
var advice_eval: Variant = null
## EX.error / S3 — an advice fetch failed; play continues until Dismiss.
var advice_error := false
var game_ended := false
var resign_available := true
var offer_available := true
var board_unavailable := false
var confirm_kind := ""
var c1_available := true
var c2_available := true
var c3_available := true
var c4_available := true
var c5_available := true
var c6_available := false
var c7_available := false
var c8_available := false
var c9_available := false
var c10_available := true

var _status: Label
var _check: Label
var _clocks: Label
var _advice_eval: Label
var _advice_row: HBoxContainer
var _promote_btns: Dictionary = {}
var _select_focus: Button
var _clear_focus: Button
var _place_focus: Button
var _advice: Button
var _advice_error_box: VBoxContainer
var _advice_error_msg: Label
var _advice_dismiss: Button
var _resign: Button
var _offer: Button
var _confirm_box: VBoxContainer
var _confirm_msg: Label
var _confirm_ok: Button
var _confirm_cancel: Button
var _draw_box: VBoxContainer
var _draw_msg: Label
var _accept: Button
var _decline: Button
var _withdraw: Button
var _chrome: VBoxContainer
var _ui_font: Font
var _text_scale := 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	refresh()


## SIT.6 / S13 — the frame reflowed: take the new ratio and restyle in place, so
## later restyles (`_place`, `refresh`) keep the reflowed sizes (AC4).
func set_text_scale(text_scale_value: float) -> void:
	if is_equal_approx(text_scale_value, _text_scale):
		return
	_text_scale = text_scale_value
	_apply_chrome_reserve()
	if is_inside_tree():
		_style_all()


## The R1 strip is `CMP-presentation`'s reserve; the panel never keeps a second
## copy of the formula (F4), and a restyle keeps the strip in step with the text.
func _apply_chrome_reserve() -> void:
	if _chrome == null:
		return
	_chrome.offset_bottom = SharedPlayPanel.CHROME_RESERVED_PX * maxf(1.0, _text_scale)
	_chrome.offset_bottom -= CHROME_TOP_PX


func configure(state: Dictionary, font: Font = null, text_scale: float = 1.0) -> void:
	_text_scale = text_scale
	_apply_chrome_reserve()
	locale = str(state.get("locale", locale))
	ui_state = str(state.get("ui_state", "S1"))
	side_to_move = str(state.get("side_to_move", "white"))
	in_check = bool(state.get("in_check", false))
	clock_id = str(state.get("clock", "untimed"))
	white_clock_ms = state.get("white_clock_ms", null)
	black_clock_ms = state.get("black_clock_ms", null)
	advice_on = bool(state.get("advice", true))
	online = bool(state.get("online", true))
	advice_best_move = state.get("advice_best_move", null)
	advice_eval = state.get("advice_eval", null)
	# S3 `EX.error` — the session raises it; Dismiss clears it (states.md).
	advice_error = bool(state.get("advice_error", false))
	game_ended = bool(state.get("game_ended", false))
	resign_available = bool(state.get("resign_available", true))
	offer_available = bool(state.get("offer_available", true))
	board_unavailable = bool(state.get("board_unavailable", false))
	confirm_kind = str(state.get("confirm_kind", ""))
	c1_available = bool(state.get("c1_available", true))
	c2_available = bool(state.get("c2_available", true))
	c3_available = bool(state.get("c3_available", true))
	c4_available = bool(state.get("c4_available", resign_available))
	c5_available = bool(state.get("c5_available", offer_available))
	c6_available = bool(state.get("c6_available", false))
	c7_available = bool(state.get("c7_available", false))
	c8_available = bool(state.get("c8_available", false))
	c9_available = bool(state.get("c9_available", false))
	c10_available = bool(state.get("c10_available", true))
	_ui_font = font
	if is_inside_tree():
		_apply_font()
		refresh()


## S3 Dismiss — back to S1 with C1–C5 as S1 (board playable throughout).
func dismiss_advice_error() -> void:
	if is_inside_tree():
		control_activated.emit("advice_dismiss")


func focusable_controls() -> Array[Control]:
	## shared-play-controls.md top→bottom among available controls (F1).
	var out: Array[Control] = []
	for ctrl in _focus_order_for_state():
		if ctrl is BaseButton and (ctrl as BaseButton).disabled:
			continue
		out.append(ctrl)
	return out


func _focus_order_for_state() -> Array[Control]:
	if ui_state == "S2":
		return [_confirm_ok, _confirm_cancel]
	if ui_state == "S4":
		var s4: Array[Control] = [_advice, _resign, _offer]
		for kind in SharedGameSession.PROMOTE_ORDER:
			s4.append(_promote_btns[kind] as Control)
		return s4
	if ui_state == "S6":
		return [_select_focus, _clear_focus, _place_focus, _advice, _accept, _decline, _withdraw]
	# S1 / S5 — C1 → C10 → C2 → C3 → C4 → C5.
	return [_select_focus, _clear_focus, _place_focus, _advice, _resign, _offer]


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
	_apply_chrome_reserve()
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

	# C1/C10/C2/C6 are board surfaces; off-strip focus sentinels keep F1 order (44px).
	# Visible C6 chooser stays on the board (PRJ.D1 / shared-play experience).
	_select_focus = Button.new()
	_select_focus.name = "SelectFocus"
	_select_focus.text = "C1"
	_select_focus.modulate.a = 0.0
	_select_focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_select_focus.position = Vector2(-200, -200)
	_select_focus.focus_entered.connect(_on_point.bind("C1"))
	_select_focus.pressed.connect(_on_activate.bind("C1"))
	add_child(_select_focus)

	_clear_focus = Button.new()
	_clear_focus.name = "ClearFocus"
	_clear_focus.text = "C10"
	_clear_focus.modulate.a = 0.0
	_clear_focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clear_focus.position = Vector2(-200, -170)
	_clear_focus.focus_entered.connect(_on_point.bind("C10"))
	_clear_focus.pressed.connect(_on_activate.bind("C10"))
	add_child(_clear_focus)

	_place_focus = Button.new()
	_place_focus.name = "PlaceFocus"
	_place_focus.text = "C2"
	_place_focus.modulate.a = 0.0
	_place_focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place_focus.position = Vector2(-200, -140)
	_place_focus.focus_entered.connect(_on_point.bind("C2"))
	_place_focus.pressed.connect(_on_activate.bind("C2"))
	add_child(_place_focus)

	var promote_y := -110.0
	for kind in SharedGameSession.PROMOTE_ORDER:
		var btn := Button.new()
		btn.name = "Promote%s" % kind.capitalize()
		btn.text = "C6:%s" % kind
		btn.modulate.a = 0.0
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.position = Vector2(-200, promote_y)
		btn.focus_entered.connect(_on_point.bind("C6:%s" % kind))
		btn.pressed.connect(_on_activate.bind("C6:%s" % kind))
		add_child(btn)
		_promote_btns[kind] = btn
		promote_y += 30.0

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chrome.add_child(row)
	_advice_row = row

	_advice_eval = Label.new()
	_advice_eval.name = "AdviceEval"
	_advice_eval.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_advice_eval.visible = false
	# UIS.T3 tabular figures; ≥ UIS.T2 body size (PER.R5), never color alone.
	UiChrome.style_label(_advice_eval)
	_advice_eval.add_theme_constant_override("outline_size", 0)
	_chrome.add_child(_advice_eval)

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

	_offer = Button.new()
	_offer.name = "OfferDraw"
	_offer.pressed.connect(_on_activate.bind("C5"))
	_offer.focus_entered.connect(_on_point.bind("C5"))
	_offer.mouse_entered.connect(_on_point.bind("C5"))
	row.add_child(_offer)

	_confirm_box = VBoxContainer.new()
	_confirm_box.name = "ResignConfirm"
	_confirm_box.visible = false
	_confirm_box.custom_minimum_size = Vector2(280, 140)
	Presentation.place_centered(_confirm_box, 200.0)
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

	# S6: one shared non-blocking panel — board stays playable (states.md).
	_draw_box = VBoxContainer.new()
	_draw_box.name = "DrawOffer"
	_draw_box.visible = false
	_draw_box.mouse_filter = Control.MOUSE_FILTER_STOP
	_draw_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_draw_box.offset_left = 16
	_draw_box.offset_right = -16
	_draw_box.offset_top = CHROME_BOTTOM_PX + 8
	_draw_box.offset_bottom = CHROME_BOTTOM_PX + 120
	_draw_box.add_theme_constant_override("separation", 8)
	add_child(_draw_box)
	var draw_panel := PanelContainer.new()
	draw_panel.add_theme_stylebox_override("panel", UiChrome.panel_style())
	_draw_box.add_child(draw_panel)
	var draw_inner := VBoxContainer.new()
	draw_inner.add_theme_constant_override("separation", 8)
	draw_panel.add_child(draw_inner)
	_draw_msg = Label.new()
	_draw_msg.name = "DrawOfferedMsg"
	_draw_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiChrome.style_label(_draw_msg)
	draw_inner.add_child(_draw_msg)
	var draw_row := HBoxContainer.new()
	draw_row.alignment = BoxContainer.ALIGNMENT_CENTER
	draw_row.add_theme_constant_override("separation", 12)
	draw_inner.add_child(draw_row)
	_accept = Button.new()
	_accept.name = "AcceptDraw"
	_accept.pressed.connect(_on_activate.bind("C7"))
	_accept.focus_entered.connect(_on_point.bind("C7"))
	_accept.mouse_entered.connect(_on_point.bind("C7"))
	draw_row.add_child(_accept)
	_decline = Button.new()
	_decline.name = "DeclineDraw"
	_decline.pressed.connect(_on_activate.bind("C8"))
	_decline.focus_entered.connect(_on_point.bind("C8"))
	_decline.mouse_entered.connect(_on_point.bind("C8"))
	draw_row.add_child(_decline)
	_withdraw = Button.new()
	_withdraw.name = "WithdrawDraw"
	_withdraw.pressed.connect(_on_activate.bind("C9"))
	_withdraw.focus_entered.connect(_on_point.bind("C9"))
	_withdraw.mouse_entered.connect(_on_point.bind("C9"))
	draw_row.add_child(_withdraw)

	_build_advice_error()
	_style_all()
	_wire_focus_order()


## S3 `EX.error` — non-modal: what failed, play continues, Dismiss (exceptions.md).
func _build_advice_error() -> void:
	_advice_error_box = VBoxContainer.new()
	_advice_error_box.name = "AdviceError"
	_advice_error_box.visible = false
	_advice_error_box.mouse_filter = Control.MOUSE_FILTER_STOP
	_advice_error_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_advice_error_box.offset_left = 16
	_advice_error_box.offset_right = -16
	_advice_error_box.offset_top = CHROME_BOTTOM_PX + 8
	_advice_error_box.offset_bottom = CHROME_BOTTOM_PX + 120
	_advice_error_box.add_theme_constant_override("separation", 8)
	add_child(_advice_error_box)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiChrome.panel_style())
	_advice_error_box.add_child(panel)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 8)
	panel.add_child(inner)
	_advice_error_msg = Label.new()
	_advice_error_msg.name = "AdviceErrorMsg"
	_advice_error_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_advice_error_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiChrome.style_label(_advice_error_msg)
	inner.add_child(_advice_error_msg)
	var dismiss_row := HBoxContainer.new()
	dismiss_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dismiss_row.add_theme_constant_override("separation", 12)
	inner.add_child(dismiss_row)
	_advice_dismiss = Button.new()
	_advice_dismiss.name = "AdviceErrorDismiss"
	_advice_dismiss.pressed.connect(dismiss_advice_error)
	_advice_dismiss.focus_entered.connect(_on_point.bind("advice_dismiss"))
	_advice_dismiss.mouse_entered.connect(_on_point.bind("advice_dismiss"))
	dismiss_row.add_child(_advice_dismiss)


func _wire_focus_order() -> void:
	## Single chain from focusable_controls() so S1–S6 stay one edit.
	_link_focus_chain(focusable_controls())


func _link_focus_chain(controls: Array[Control]) -> void:
	if controls.is_empty():
		return
	for i in range(controls.size()):
		var cur := controls[i] as Control
		var nxt := controls[(i + 1) % controls.size()] as Control
		cur.focus_next = nxt.get_path()
		cur.focus_previous = controls[(i - 1 + controls.size()) % controls.size()].get_path()


func _style_all() -> void:
	UiChrome.style_label(_status, true, _text_scale)
	UiChrome.style_label(_check, false, _text_scale)
	UiChrome.style_label(_clocks, false, _text_scale)
	UiChrome.style_label(_advice_eval, false, _text_scale)
	UiChrome.style_label(_confirm_msg, false, _text_scale)
	UiChrome.style_label(_draw_msg, false, _text_scale)
	UiChrome.style_label(_advice_error_msg, false, _text_scale)
	for button in [
		_select_focus,
		_clear_focus,
		_place_focus,
		_advice,
		_resign,
		_offer,
		_confirm_cancel,
		_decline,
		_withdraw,
		_advice_dismiss,
	]:
		UiChrome.style_button(button as Button, false, false, _text_scale)
	for kind in SharedGameSession.PROMOTE_ORDER:
		UiChrome.style_button(_promote_btns[kind] as Button, false, false, _text_scale)
	for primary in [_confirm_ok, _accept]:
		UiChrome.style_button(primary as Button, true, false, _text_scale)


func _apply_font() -> void:
	if _ui_font == null:
		return
	var nodes: Array = [
		_status,
		_check,
		_clocks,
		_select_focus,
		_clear_focus,
		_place_focus,
		_advice,
		_resign,
		_offer,
		_confirm_msg,
		_confirm_ok,
		_confirm_cancel,
		_draw_msg,
		_accept,
		_decline,
		_withdraw,
		_advice_eval,
		_advice_error_msg,
		_advice_dismiss
	]
	for kind in SharedGameSession.PROMOTE_ORDER:
		nodes.append(_promote_btns[kind])
	for node in nodes:
		UiChrome.apply_font(node, _ui_font)


func _apply_copy() -> void:
	var side_key := "white_to_move" if side_to_move == "white" else "black_to_move"
	_status.text = StringTable.shared_play(side_key, locale)
	_check.text = StringTable.shared_play("check", locale) if in_check else ""
	_check.visible = in_check
	_advice.text = StringTable.shared_play("advice_on" if advice_on else "advice_off", locale)
	_resign.text = StringTable.shared_play("resign", locale)
	_offer.text = StringTable.shared_play("offer_draw", locale)
	var confirm_key := (
		"offer_confirm" if confirm_kind == SharedGameSession.CONFIRM_OFFER else "resign_confirm"
	)
	_confirm_msg.text = StringTable.shared_play(confirm_key, locale)
	_confirm_ok.text = StringTable.shared_play("confirm", locale)
	_confirm_cancel.text = StringTable.shared_play("cancel", locale)
	_draw_msg.text = StringTable.shared_play("draw_offered", locale)
	_accept.text = StringTable.shared_play("accept", locale)
	_decline.text = StringTable.shared_play("decline", locale)
	_withdraw.text = StringTable.shared_play("withdraw", locale)
	for kind in SharedGameSession.PROMOTE_ORDER:
		(_promote_btns[kind] as Button).text = StringTable.shared_play(kind, locale)
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
	_select_focus.disabled = not c1_available or game_ended
	_clear_focus.disabled = not c10_available or game_ended
	_place_focus.disabled = not c2_available or game_ended
	_advice.disabled = not c3_available or game_ended
	_resign.disabled = not c4_available or game_ended or not resign_available
	_offer.disabled = not c5_available or game_ended or not offer_available
	for kind in SharedGameSession.PROMOTE_ORDER:
		(_promote_btns[kind] as Button).disabled = not c6_available
	_accept.disabled = not c7_available
	_decline.disabled = not c8_available
	_withdraw.disabled = not c9_available
	_style_all()
	_wire_focus_order()
	_apply_advice_text()


func _apply_advice_text() -> void:
	## R3 — the eval shows only while Advice is On and online and values are set.
	var shown := advice_on and online and advice_best_move is Dictionary and advice_eval is int
	_advice_eval.visible = shown
	_advice_eval.text = format_eval(int(advice_eval)) if shown else ""
	_advice_error_msg.text = StringTable.shared_play("advice_error", locale)
	_advice_dismiss.text = StringTable.shared_play("dismiss", locale)


## Centipawns from White's view as text (F-move-advice.R4).
static func format_eval(cp: int) -> String:
	return "%+.2f" % (float(cp) / 100.0)


func _show_state(state_id: String) -> void:
	ui_state = state_id
	var confirm := state_id == "S2"
	_confirm_box.visible = confirm
	_draw_box.visible = state_id == "S6"
	# S3 — EX.error panel shows over a playable board (states.md).
	_advice_error_box.visible = advice_error
	# Keep R2/R4 readable; board dimming is owned by presentation via board_unavailable.
	_chrome.modulate.a = 1.0
	_wire_focus_order()
	if (confirm or state_id == "S6" or state_id == "S4") and visible:
		focus_first()


func _on_activate(control_id: String) -> void:
	var disabled := false
	match control_id:
		"C1":
			disabled = _select_focus.disabled
		"C10":
			disabled = _clear_focus.disabled
		"C2":
			disabled = _place_focus.disabled
		"C3":
			disabled = _advice.disabled
		"C4":
			disabled = _resign.disabled
		"C5":
			disabled = _offer.disabled
		"C7":
			disabled = _accept.disabled
		"C8":
			disabled = _decline.disabled
		"C9":
			disabled = _withdraw.disabled
		_:
			if control_id.begins_with("C6:"):
				var kind := control_id.get_slice(":", 1)
				disabled = not _promote_btns.has(kind) or (_promote_btns[kind] as Button).disabled
	if disabled:
		return
	# C1/C2 activate via board gestures (B2/B3/B10); focus sentinels only emit point.
	if control_id == "C1" or control_id == "C2":
		return
	control_activated.emit(control_id)


func _on_point(control_id: String) -> void:
	pointed.emit(control_id)
