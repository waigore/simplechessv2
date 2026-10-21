class_name Presentation
extends Control
## CMP-presentation: EX.loading, mode-pick, shared-setup, board view, entry exceptions.

signal control_activate(screen_id: String, control_id: String)
## CTR-presentation.E3 — L1 never resolves assets; L2 returns them via O5.
signal asset_needed(asset_ids: PackedStringArray)

const LOADING_SCREEN := "loading"
const MODE_PICK := "mode-pick"
const SHARED_SETUP := "shared-setup"
const SHARED_PLAY := "shared-play"
const SESSION_ENDED := "session-ended"

var pointer_count := 0
var last_pointer: Dictionary = {}
var last_point_control := ""
var current_screen := LOADING_SCREEN

var _loading: Label
var _host: Control
var _mode_pick: ModePickPanel
var _shared_setup: SharedSetupPanel
var _board: BoardPresentation
var _ended_label: Label
var _unsupported: Label
var _ui_font: Font
var _router: SessionRouter
var _play_assets_bound := false


func _ready() -> void:
	_router = $SessionRouter as SessionRouter
	_build_shell()
	_router.screen_requested.connect(_on_screen_requested)
	_router.replay_pointer.connect(apply_recorded_pointer)
	control_activate.connect(_router.handle_control)
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
		SESSION_ENDED:
			_show_ended()
		_:
			push_error("Unknown screen id: %s" % screen_id)


func handle_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_flash_unsupported()
		return
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


func _build_shell() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

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
	_host.add_child(_board)

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
	## CTR-presentation.O2 — board portion (status R2 is #58).
	if _board == null:
		return
	var opts := options.duplicate()
	if not opts.has("white_seat"):
		opts["white_seat"] = _router.white_seat
	_board.render_position(position, selection, legal, opts)


func provide_assets(resources_by_id: Dictionary) -> void:
	## CTR-presentation.O5 — bind catalog resources by asset ID (from L2 only).
	_apply_ui_fonts(resources_by_id)
	if _board != null:
		_board.provide_assets(resources_by_id)
	if not resources_by_id.is_empty():
		_play_assets_bound = true


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
	_ended_label.visible = false
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
	_ended_label.visible = false
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
	_ended_label.visible = false
	var position: Dictionary = state.get("position", {}) as Dictionary
	if position.is_empty():
		var rules := ChessRules.new()
		rules.reset_opening()
		position = rules.position_field()
	_board.set_white_seat(str(state.get("white_seat", _router.white_seat)))
	_board.render_position(position, str(state.get("selection", "")), PackedStringArray())
	UiChrome.transition_in(_board)
	_router.note_board_playable()
	if not _play_assets_bound:
		# Ask L2 for play IDs if O5 has not arrived yet (CTR-presentation.E3).
		var needed: PackedStringArray = PackedStringArray()
		for asset_id in BoardPresentation.PIECE_IDS.values():
			needed.append(str(asset_id))
		needed.append(BoardPresentation.BOARD_BG_ID)
		needed.append(UiChrome.FONT_LATIN)
		asset_needed.emit(needed)


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
	_ended_label.visible = false
	_ended_label.modulate.a = 1.0


func _on_mode_pick_control(control_id: String) -> void:
	control_activate.emit(MODE_PICK, control_id)


func _on_shared_setup_control(control_id: String) -> void:
	control_activate.emit(SHARED_SETUP, control_id)


func _on_pointed(control_id: String) -> void:
	last_point_control = control_id


func _flash_unsupported() -> void:
	_unsupported.text = StringTable.exception_text("unsupported_input", _router.locale)
	_unsupported.visible = true
	get_tree().create_timer(1.2).timeout.connect(func() -> void: _unsupported.visible = false)


func _accept_pointer(record: Dictionary) -> void:
	pointer_count += 1
	last_pointer = record


func _pointer_dict(kind: String, pressed: bool, index: int, at: Vector2) -> Dictionary:
	return {
		"kind": kind,
		"pressed": pressed,
		"index": index,
		"x": at.x,
		"y": at.y,
	}
