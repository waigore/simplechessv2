class_name Presentation
extends Control
## CMP-presentation: screens, board gestures (B2/B3/B8–B11), status chrome (#58/#94), audio (#60).

signal control_activate(screen_id: String, control_id: String)
## CTR-presentation.E1 — from/to (+ optional promotion); empty to means select-only.
signal input_commit(from_square: String, to_square: String, promotion: String)
## CTR-presentation.E3 — L1 never resolves assets; L2 returns them via O5.
signal asset_needed(asset_ids: PackedStringArray)

const LOADING_SCREEN := "loading"
const MODE_PICK := "mode-pick"
const SHARED_SETUP := "shared-setup"
const SHARED_PLAY := "shared-play"
const SHARED_RESULT := "shared-result"
const SESSION_ENDED := "session-ended"
const DRAG_THRESHOLD_PX := 12.0
## Reserve R2–R4 chrome so R1 is not covered at 16:9 (PRJ.A1).
const PLAY_CHROME_TOP_PX := SharedPlayPanel.CHROME_RESERVED_PX

var pointer_count := 0
var last_pointer: Dictionary = {}
var last_point_control := ""
var current_screen := LOADING_SCREEN

var _loading: Label
var _host: Control
var _mode_pick: ModePickPanel
var _shared_setup: SharedSetupPanel
var _shared_play: SharedPlayPanel
var _shared_result: SharedResultPanel
var _board: BoardPresentation
var _ended_label: Label
var _unsupported: Label
var _ui_font: Font
var _router: SessionRouter
var _audio: PresentationAudio
var _play_assets_bound := false

var _press_active := false
var _press_index := 0
var _press_square := ""
var _press_screen := Vector2.ZERO
var _dragging := false
var _drag_from := ""


func _ready() -> void:
	_router = $SessionRouter as SessionRouter
	_build_shell()
	_router.screen_requested.connect(_on_screen_requested)
	_router.replay_pointer.connect(apply_recorded_pointer)
	control_activate.connect(_router.handle_control)
	input_commit.connect(
		func(from_sq: String, to_sq: String, promotion: String = "") -> void:
			_router.handle_input_commit(from_sq, to_sq, promotion)
	)
	_show_loading()
	_router.start()


func show_screen(screen_id: String, state: Dictionary) -> void:
	match screen_id:
		LOADING_SCREEN:
			_show_loading()
		MODE_PICK:
			_show_mode_pick(state)
		SHARED_SETUP:
			_show_shared_setup(state)
		SHARED_PLAY:
			_show_shared_play(state)
		SHARED_RESULT:
			_show_shared_result(state)
		SESSION_ENDED:
			_show_ended()
		_:
			push_error("Unknown screen id: %s" % screen_id)


func handle_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_flash_unsupported()
		return
	if _router.session_is_paused():
		return
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if _press_active and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_on_pointer_move(motion.position)
		return
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _press_active and drag.index == _press_index:
			_on_pointer_move(drag.position)
		return
	var record := pointer_record(event)
	if record.is_empty():
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


func _build_shell() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_audio = PresentationAudio.new()
	_audio.name = "PresentationAudio"
	add_child(_audio)

	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = UiChrome.COLOR_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	move_child(bg, 0)

	_loading = Label.new()
	_loading.name = "LoadingLabel"
	_loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_loading.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiChrome.style_label(_loading, true)
	add_child(_loading)

	_host = Control.new()
	_host.name = "ScreenHost"
	_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_host)

	_mode_pick = ModePickPanel.new()
	_mode_pick.name = "ModePick"
	_mode_pick.visible = false
	_mode_pick.set_anchors_preset(Control.PRESET_CENTER)
	_mode_pick.custom_minimum_size = Vector2(320, 280)
	_mode_pick.position = Vector2(40, 80)
	_mode_pick.control_activated.connect(_on_mode_pick_control)
	_mode_pick.pointed.connect(_on_pointed)
	_host.add_child(_mode_pick)

	_shared_setup = SharedSetupPanel.new()
	_shared_setup.name = "SharedSetup"
	_shared_setup.visible = false
	_shared_setup.set_anchors_preset(Control.PRESET_CENTER)
	_shared_setup.custom_minimum_size = Vector2(320, 360)
	_shared_setup.position = Vector2(40, 60)
	_shared_setup.control_activated.connect(_on_shared_setup_control)
	_shared_setup.pointed.connect(_on_pointed)
	_host.add_child(_shared_setup)

	_board = BoardPresentation.new()
	_board.name = "BoardPresentation"
	_board.visible = false
	_board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board.assets_needed.connect(func(ids: PackedStringArray) -> void: asset_needed.emit(ids))
	_board.reject_flash_finished.connect(func() -> void: _router.finish_reject_flash())
	_host.add_child(_board)

	_shared_play = SharedPlayPanel.new()
	_shared_play.name = "SharedPlay"
	_shared_play.visible = false
	_shared_play.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shared_play.control_activated.connect(_on_shared_play_control)
	_shared_play.pointed.connect(_on_pointed)
	_host.add_child(_shared_play)
	_layout_shared_play_regions()

	_shared_result = SharedResultPanel.new()
	_shared_result.name = "SharedResult"
	_shared_result.visible = false
	_shared_result.set_anchors_preset(Control.PRESET_CENTER)
	_shared_result.custom_minimum_size = Vector2(320, 220)
	_shared_result.position = Vector2(40, 120)
	_shared_result.control_activated.connect(_on_shared_result_control)
	_shared_result.pointed.connect(_on_pointed)
	_host.add_child(_shared_result)

	_ended_label = Label.new()
	_ended_label.name = "SessionEnded"
	_ended_label.visible = false
	_ended_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ended_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ended_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ended_label.text = SESSION_ENDED
	UiChrome.style_label(_ended_label)
	_host.add_child(_ended_label)

	_unsupported = Label.new()
	_unsupported.name = "UnsupportedInput"
	_unsupported.visible = false
	_unsupported.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_unsupported.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_unsupported.offset_top = -72
	UiChrome.style_label(_unsupported)
	_unsupported.add_theme_color_override("font_color", UiChrome.COLOR_DANGER)
	add_child(_unsupported)

	gui_input.connect(handle_gui_input)


func _on_screen_requested(screen_id: String, state: Dictionary) -> void:
	show_screen(screen_id, state)


func _show_loading() -> void:
	current_screen = LOADING_SCREEN
	_hide_panels()
	_loading.text = StringTable.mode_pick("loading", _router.locale)
	UiChrome.transition_in(_loading)


func render_position(
	position: Dictionary,
	selection: String = "",
	legal: PackedStringArray = PackedStringArray(),
	options: Dictionary = {}
) -> void:
	## CTR-presentation.O2 — board + status via SharedPlayPanel.
	if _board == null:
		return
	var opts := options.duplicate()
	if not opts.has("white_seat"):
		opts["white_seat"] = _router.white_seat
	_board.render_position(position, selection, legal, opts)


func provide_assets(resources_by_id: Dictionary) -> void:
	## CTR-presentation.O5 — bind catalog resources by asset ID (from L2 only).
	_apply_ui_fonts(resources_by_id)
	if _audio != null:
		_audio.bind_assets(resources_by_id)
	if _board != null:
		_board.provide_assets(resources_by_id)
	if not resources_by_id.is_empty():
		_play_assets_bound = true


func play_cue(cue_id: String) -> void:
	## CTR-presentation.O3 — Shared SFX or Ambient start; never awaits network (G1).
	if _audio != null:
		_audio.play_cue(cue_id)


func _apply_ui_fonts(resources_by_id: Dictionary) -> void:
	var latin: Variant = resources_by_id.get(UiChrome.FONT_LATIN, null)
	if latin is Font:
		_ui_font = latin as Font
		var cjk: Variant = resources_by_id.get(UiChrome.FONT_CJK, null)
		if cjk is Font:
			var faces: Array[Font] = [cjk as Font]
			_ui_font.fallbacks = faces
		UiChrome.apply_font(_loading, _ui_font)
		UiChrome.apply_font(_ended_label, _ui_font)
		UiChrome.apply_font(_unsupported, _ui_font)


func _show_mode_pick(state: Dictionary) -> void:
	current_screen = MODE_PICK
	_loading.visible = false
	_shared_setup.visible = false
	_board.visible = false
	_shared_play.visible = false
	_shared_result.visible = false
	_ended_label.visible = false
	_reset_gesture()
	var ui_state := str(state.get("ui_state", "S1"))
	_mode_pick.configure(
		str(state.get("locale", _router.locale)),
		str(state.get("last_mode", _router.last_mode)),
		_ui_font
	)
	_mode_pick.set_ui_state(ui_state)
	UiChrome.transition_in(_mode_pick)


func _show_shared_setup(state: Dictionary) -> void:
	current_screen = SHARED_SETUP
	_loading.visible = false
	_mode_pick.visible = false
	_board.visible = false
	_shared_play.visible = false
	_shared_result.visible = false
	_ended_label.visible = false
	_reset_gesture()
	_shared_setup.configure(
		str(state.get("locale", _router.locale)),
		str(state.get("white_seat", _router.white_seat)),
		str(state.get("clock", _router.clock)),
		int(state.get("increment", _router.increment)),
		bool(state.get("advice", _router.advice_on)),
		bool(state.get("options_locked", _router.options_locked)),
		_ui_font
	)
	UiChrome.transition_in(_shared_setup)
	_shared_setup.focus_first()


func _show_shared_play(state: Dictionary) -> void:
	current_screen = SHARED_PLAY
	_loading.visible = false
	_mode_pick.visible = false
	_shared_setup.visible = false
	_shared_result.visible = false
	_ended_label.visible = false
	_layout_shared_play_regions()
	var position: Dictionary = state.get("position", {}) as Dictionary
	if position.is_empty():
		var rules := ChessRules.new()
		rules.reset_opening()
		position = rules.position_field()
	var selection := str(state.get("selection", ""))
	var legal: PackedStringArray = PackedStringArray()
	var legal_var: Variant = state.get("legal", PackedStringArray())
	if legal_var is PackedStringArray:
		legal = legal_var
	elif legal_var is Array:
		for item in legal_var:
			legal.append(str(item))
	var opts := {
		"white_seat": str(state.get("white_seat", _router.white_seat)),
		"ui_state": str(state.get("ui_state", "S1")),
		"reject_square": str(state.get("reject_square", "")),
		"pending_promote_to": str(state.get("pending_promote_to", "")),
		"side_to_move": str(state.get("side_to_move", "white")),
		"promote_kinds": state.get("promote_kinds", SharedGameSession.PROMOTE_ORDER),
	}
	var move_var: Variant = state.get("move", null)
	if move_var is Dictionary:
		opts["move"] = move_var
	_board.set_white_seat(str(opts["white_seat"]))
	_board.render_position(position, selection, legal, opts)
	var board_dim := bool(state.get("board_unavailable", false))
	var board_alpha := 0.45 if board_dim else 1.0
	if not _board.visible:
		UiChrome.transition_in(_board)
		_board.modulate.a = board_alpha
	else:
		_board.visible = true
		_board.modulate.a = board_alpha
	var first_show := not _shared_play.visible
	_shared_play.configure(state, _ui_font)
	if first_show:
		UiChrome.transition_in(_shared_play)
		_shared_play.focus_first()
	else:
		_shared_play.visible = true
		_shared_play.modulate.a = 1.0
	if not _play_assets_bound:
		# Ask L2 for play IDs if O5 has not arrived yet (CTR-presentation.E3).
		var needed: PackedStringArray = PackedStringArray()
		for asset_id in BoardPresentation.PIECE_IDS.values():
			needed.append(str(asset_id))
		needed.append(BoardPresentation.BOARD_BG_ID)
		needed.append(UiChrome.FONT_LATIN)
		asset_needed.emit(needed)


func _layout_shared_play_regions() -> void:
	## R2–R4 stay in the top strip; R1 board fills the remaining viewport.
	if _board == null or _shared_play == null:
		return
	_board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board.offset_top = PLAY_CHROME_TOP_PX
	_board.offset_bottom = 0.0
	_board.offset_left = 0.0
	_board.offset_right = 0.0
	_shared_play.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _show_shared_result(state: Dictionary) -> void:
	current_screen = SHARED_RESULT
	_loading.visible = false
	_mode_pick.visible = false
	_shared_setup.visible = false
	_board.visible = false
	_shared_play.visible = false
	_ended_label.visible = false
	_reset_gesture()
	_shared_result.configure(
		str(state.get("locale", _router.locale)),
		str(state.get("result_key", "result_draw")),
		_ui_font
	)
	UiChrome.transition_in(_shared_result)
	_shared_result.focus_first()


func _show_ended() -> void:
	current_screen = SESSION_ENDED
	_loading.visible = false
	_hide_panels()
	UiChrome.transition_in(_ended_label)


func _hide_panels() -> void:
	_mode_pick.visible = false
	_mode_pick.modulate.a = 1.0
	_shared_setup.visible = false
	_shared_setup.modulate.a = 1.0
	_board.visible = false
	_board.modulate.a = 1.0
	_shared_play.visible = false
	_shared_play.modulate.a = 1.0
	_shared_result.visible = false
	_shared_result.modulate.a = 1.0
	_ended_label.visible = false
	_ended_label.modulate.a = 1.0
	_reset_gesture()


func _on_mode_pick_control(control_id: String) -> void:
	control_activate.emit(MODE_PICK, control_id)


func _on_shared_setup_control(control_id: String) -> void:
	control_activate.emit(SHARED_SETUP, control_id)


func _on_shared_play_control(control_id: String) -> void:
	control_activate.emit(SHARED_PLAY, control_id)


func _on_shared_result_control(control_id: String) -> void:
	control_activate.emit(SHARED_RESULT, control_id)


func _on_pointed(control_id: String) -> void:
	last_point_control = control_id


func _flash_unsupported() -> void:
	_unsupported.text = StringTable.exception_text("unsupported_input", _router.locale)
	_unsupported.visible = true
	get_tree().create_timer(1.2).timeout.connect(func() -> void: _unsupported.visible = false)


func _accept_pointer(record: Dictionary) -> void:
	pointer_count += 1
	last_pointer = record
	if current_screen != SHARED_PLAY:
		return
	var pressed := bool(record.get("pressed", false))
	var at := Vector2(float(record.get("x", 0.0)), float(record.get("y", 0.0)))
	var index := int(record.get("index", 0))
	if pressed:
		_on_pointer_down(at, index)
	else:
		_on_pointer_up(at, index)


func _on_pointer_down(at: Vector2, index: int) -> void:
	# S4: C6 promotion taps (board gestures otherwise blocked).
	if _router.play_ui_state == SharedGameSession.UI_S4:
		_press_active = true
		_press_index = index
		_press_screen = at
		_dragging = false
		_drag_from = ""
		_press_square = ""
		return
	if not _router.play_gestures_available():
		return
	_press_active = true
	_press_index = index
	_press_screen = at
	_dragging = false
	_drag_from = ""
	_press_square = _square_at_screen(at)
	if _press_square.is_empty():
		return
	var piece := _router.occupancy_at(_press_square)
	var side := _router.side_to_move()
	if not piece.is_empty() and str(piece.get("color", "")) == side:
		# B10 may start with nothing selected; begin drag follow from this square.
		_drag_from = _press_square
		var world := _board.screen_to_world(at)
		_board.begin_drag(_press_square, world)
		return
	# B3: press on a destination square while a piece is already selected.


func _on_pointer_move(at: Vector2) -> void:
	if not _press_active or _drag_from.is_empty():
		return
	if not _dragging and _press_screen.distance_to(at) >= DRAG_THRESHOLD_PX:
		_dragging = true
	if _dragging:
		_board.update_drag(_board.screen_to_world(at))


func _on_pointer_up(at: Vector2, index: int) -> void:
	if not _press_active or index != _press_index:
		return
	var drag_from := _drag_from
	var to_sq := _square_at_screen(at)
	var was_dragging := _dragging
	_press_active = false
	_dragging = false
	_press_square = ""
	_drag_from = ""
	# S4: tap a promotion sprite (C6) or deselect (IN.deselect drops choice).
	if _router.play_ui_state == SharedGameSession.UI_S4:
		_finish_drag(true)
		var kind := _board.promotion_kind_at(_board.screen_to_world(at))
		if not kind.is_empty():
			_router.handle_promotion_commit(kind)
		else:
			# Tap selected pawn / empty → deselect drops choice.
			_router.handle_deselect()
	elif not _router.play_gestures_available():
		_finish_drag(false)
	elif was_dragging and not drag_from.is_empty() and not to_sq.is_empty() and to_sq != drag_from:
		# B10: drag own piece onto a destination (may start unselected).
		# PHY.M5 before chrome emit so _motion_busy skips piece rebuild on refuse.
		if _router.can_place(drag_from, to_sq, ""):
			_board.cancel_drag()
			input_commit.emit(drag_from, to_sq, "")
		else:
			# B11: illegal / empty non-destination → clear selection (IN.deselect).
			_board.end_drag_illegal()
			_router.handle_deselect()
	elif was_dragging and not drag_from.is_empty() and (to_sq.is_empty() or to_sq == drag_from):
		# B11: drag off-board or release with no destination.
		_board.end_drag_illegal()
		_router.handle_deselect()
	else:
		_on_pointer_up_tap(drag_from, to_sq, was_dragging)


func _on_pointer_up_tap(drag_from: String, to_sq: String, was_dragging: bool) -> void:
	var selected := _router.selected_piece
	var side := _router.side_to_move()
	# B8: tap the selected piece → IN.deselect (before B2 re-select).
	if not was_dragging and not selected.is_empty() and to_sq == selected:
		_finish_drag(true)
		_router.handle_deselect()
	elif not was_dragging and not to_sq.is_empty():
		var at_dest := _router.occupancy_at(to_sq)
		# B2 before B3: tap an own piece (including changing selection).
		if not at_dest.is_empty() and str(at_dest.get("color", "")) == side:
			_finish_drag(true)
			input_commit.emit(to_sq, "", "")
		elif not selected.is_empty() and to_sq != selected:
			# B3 / B9: tap empty or capture target while a piece is selected.
			_finish_drag(true)
			input_commit.emit(selected, to_sq, "")
		elif not drag_from.is_empty() and to_sq == drag_from:
			# B2: tap an own piece in place → select.
			_finish_drag(true)
			input_commit.emit(drag_from, "", "")
		else:
			_finish_drag(true)
	elif not was_dragging and not drag_from.is_empty() and (to_sq.is_empty() or to_sq == drag_from):
		# B2: tap an own piece in place → select.
		_finish_drag(true)
		input_commit.emit(drag_from, "", "")
	else:
		# Idle release with no action.
		_finish_drag(true)


func _finish_drag(legal_or_idle: bool) -> void:
	if _board == null:
		return
	if legal_or_idle:
		_board.cancel_drag()
	else:
		_board.end_drag_illegal()


func _square_at_screen(at: Vector2) -> String:
	if _board == null or not _board.visible:
		return ""
	return BoardGeometry.square_at(_board.screen_to_world(at))


func _reset_gesture() -> void:
	_press_active = false
	_dragging = false
	_press_square = ""
	_drag_from = ""


func _pointer_dict(kind: String, pressed: bool, index: int, at: Vector2) -> Dictionary:
	return {
		"kind": kind,
		"pressed": pressed,
		"index": index,
		"x": at.x,
		"y": at.y,
	}
