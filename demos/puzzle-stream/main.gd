extends Node2D
## Puzzle-stream demo #335 (scene script; the autodrive lives in `autodrive.gd`).
## Spec source: L-puzzle-stream K1-K4 / E1, DIF.Y1 / DIF.C1,
## END.W1 / L4 / L5 / L6, F-puzzle-catalog R1-R5 / I1-I3 / X1-X2, PRG.A1 / P1 / M1 /
## P3 / F1 / Z1, FL-mode-pick P1 / P3 / T2 / T4 / U1, UI-mode-pick C2,
## UI-puzzle-play R1-R3 / C1-C6 / S1-S5, J-puzzle-session N1-N2 / S1-S2 / B1,
## NAV.T2 / T9, EX.confirm / EX.rejected / EX.promote / EX.save-failure, SND.X5,
## and the wave-1 input, view, motion, and audio elements it reuses.
##
## Reference artifact, not production code (`docs/demos.md`). The rules the demo
## encodes live in `puzzle_stream.gd` and the copied `chess_rules.gd`.

const COLOR_TABLE := Color("5C3A2A")  # PAL.C5
const COLOR_CREAM := Color("F7F1E8")  # PAL.C10
const COLOR_INK := Color("2C2A28")  # PAL.C9
const COLOR_ROSE := Color("C28A86")  # PAL.C8 refusal flash (PER.R8)

const FONT_ID := "01a15215-15bd-7e3f-a3f8-ffcb1333a0ab"
const BOARD_BG_ID := "01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855"
const SFX_IDS := {
	"select": "01a151f8-b7d8-7ae6-84af-767ba53d09f6",  # SND.X1 touch-select
	"land": "01a151f8-b7d8-710a-b767-92c9137bfd63",  # SND.X2 move-settle
	"end": "01a151f8-b7d8-7fe3-b94f-e3a562395d96",  # SND.X4 end-resolve
	"wrong": "01a151f8-b7d8-759c-89c5-e1be5eecb2b2",  # SND.X5 puzzle-fail
}
## SND.L2: the soft cues stay under the settle knock; the wrong-move tap is the
## one negative cue and never loud (SND.X5).
const CUE_GAIN_DB := {
	"select": -5.4,
	"land": 0.0,
	"end": -2.0,
	"wrong": -3.0,
}
const BED_IDS := [
	"01a15200-69b2-7d13-a30d-696fa4ff390b",  # music/cafe-ambient-a, SND.M1
	"01a15200-69b2-7964-a602-ad5b19583125",  # music/cafe-ambient-b, SND.M2
]
const PIECE_IDS := {
	"wK": "01a15dab-051c-75dc-8624-91f1c45f98f7",
	"bK": "01a15dab-051c-7392-9318-e8b69bf7abf2",
	"wQ": "01a15dab-051c-7023-973b-0b37ef3aa1b3",
	"bQ": "01a15dab-051c-784b-859a-1d347edf39f0",
	"wR": "01a15dab-051c-7c3f-94fc-ce51926b3549",
	"bR": "01a15dab-051c-73b7-bad0-e6df05f4d2b6",
	"wB": "01a15dab-051c-73ff-96fa-a75c6719313a",
	"bB": "01a15dab-051c-7061-9aaf-f2ba5a069413",
	"wN": "01a15dab-051c-7155-b8ec-6de860bae114",
	"bN": "01a15dab-051c-72b6-8859-f3edab33c514",
	"wP": "01a15dab-051c-7db1-8f3e-9cb5e68058d8",
	"bP": "01a15dab-051c-73c8-9edc-c4e82957f267",
}

## PRJ.P1 / SPC.A1: 72 px per board unit; SPC.P1 margins centre the 8x8 on the frame.
const UNIT := 72.0
const FRAME_SIZE := Vector2(720.0, 1280.0)
const BOARD_ORIGIN := Vector2(72.0, 326.0)
const HUD_TOP := 24.0
const ACTION_TOP := 986.0

const AUTODRIVE := "DEMO_AUTODRIVE"
const SAVE_PATH := "user://puzzle-stream-demo-save.json"
const CATALOG_PATH := "res://catalog_slice.json"

## UI-puzzle-play S1-S5 and the EX.confirm verb waiting on Confirm / Cancel.
const S1 := "S1"
const S2 := "S2"
const S3 := "S3"
const S4 := "S4"
const S5 := "S5"
const CONFIRM_REVEAL := "reveal_confirm"
const CONFIRM_ABANDON := "abandon_confirm"
const CONFIRM_LEAVE := "leave_confirm"
const CONFIRM_COPY := {
	CONFIRM_REVEAL: "Reveal the solution?",
	CONFIRM_ABANDON: "Abandon this puzzle?",
	CONFIRM_LEAVE: "Leave the puzzle stream?",
}

const MODE_PICK := "mode_pick"
const PUZZLE_PLAY := "puzzle_play"

var stream := DemoPuzzleStream.new()
var screen := MODE_PICK
var ui_state := S1
var confirmation := ""
var selection := -1
var legal_to: Array = []
var pending_from := -1
var pending_to := -1
var committed := {}  # the last saved document, kept for EX.save-failure

## The demo's save-failure seam (assumption A7): a graphical look at S3 sets this
## before `_commit_save()`, because an unwritable device cannot be provoked here.
var commit_failed := false

var view: DemoBoardView
var font: Font
var _sfx: Dictionary = {}
var _bed_streams: Array = []
var _bed_player: AudioStreamPlayer
var _bed_index := 0
var _press := -1
var _drag_moved := false

var _mode_screen: Control
var _puzzle_screen: Control
var _elo_label: Label
var _cue_label: Label
var _status_label: Label
var _confirm_panel: PanelContainer
var _confirm_text: Label
var _save_panel: PanelContainer
var _actions: Array = []

## Scripted run's failure list (filled only by `autodrive.gd`).
var _problems: PackedStringArray = PackedStringArray()


## A headless run or an explicit DEMO_AUTODRIVE=1 drives the scripted stream
## (`autodrive.gd`).
func _is_autodrive() -> bool:
	return DisplayServer.get_name() == "headless" or OS.get_environment(AUTODRIVE) == "1"


## The scripted run is `autodrive.gd`, which extends this scene. A plain scene
## run (DEMO_AUTODRIVE unset, a graphical window) does not start it.
func _run_autodrive() -> void:
	push_error("demo: the scripted run lives in autodrive.gd")


func _ready() -> void:
	_setup_frame()
	view = DemoBoardView.new()
	view.position = BOARD_ORIGIN
	view.scale = Vector2(UNIT, UNIT)
	add_child(view)
	var loader := DemoAssetLoader.new()
	font = loader.resolve(FONT_ID)
	var bg: Texture2D = loader.resolve(BOARD_BG_ID)
	view.setup(PIECE_IDS, font, bg)
	view.provide_assets(_load_pieces(loader))
	for problem in loader.problems:
		push_warning("demo asset: %s" % problem)
	_setup_audio(loader)
	stream.catalog = _load_catalog()
	stream.restore(_read_save())
	committed = stream.save_document()
	_setup_hud()
	_setup_actions()
	_setup_mode_pick()
	_setup_confirm()
	_setup_save_panel()
	_show_mode_pick()
	if _is_autodrive():
		_run_autodrive()


func _load_pieces(loader: DemoAssetLoader) -> Dictionary:
	var out: Dictionary = {}
	for asset_id in PIECE_IDS.values():
		var resource: Resource = loader.resolve(asset_id)
		if resource != null:
			out[asset_id] = resource
	return out


## The recorded-format fixture slice that stands in for the host-served snapshot
## (epic #35 Notes; F-puzzle-catalog R1 and ADR-0008 keep the export off the client).
func _load_catalog() -> Array:
	var text := FileAccess.get_file_as_string(CATALOG_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		push_warning("demo: catalog slice unreadable")
		return []
	return parsed.get("records", [])


func _setup_frame() -> void:
	# SPC.L1: the cafe-table ground extends the whole frame.
	var cafe := ColorRect.new()
	cafe.color = COLOR_TABLE
	cafe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cafe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cafe)


func _setup_audio(loader: DemoAssetLoader) -> void:
	for cue_name in SFX_IDS:
		var player := AudioStreamPlayer.new()
		player.stream = loader.resolve(SFX_IDS[cue_name])
		player.volume_db = float(CUE_GAIN_DB.get(cue_name, 0.0))  # SND.L2
		add_child(player)
		_sfx[cue_name] = player
	for bed_id in BED_IDS:
		_bed_streams.append(loader.resolve(bed_id))
	_bed_player = AudioStreamPlayer.new()
	_bed_player.volume_db = -14.0  # SND.L1: the bed stays under the cues
	_bed_player.finished.connect(_on_bed_finished)
	add_child(_bed_player)
	_bed_player.stream = _bed_streams[_bed_index]
	_bed_player.play()


func _on_bed_finished() -> void:
	# SND.M1 -> SND.M2 -> SND.M1 with a hard handoff, no crossfade (SND.L2).
	_bed_index = (_bed_index + 1) % _bed_streams.size()
	_bed_player.stream = _bed_streams[_bed_index]
	_bed_player.play()


func _cue(cue_name: String) -> void:
	var player: AudioStreamPlayer = _sfx.get(cue_name, null)
	if player != null:
		player.play()


# --- UI ---------------------------------------------------------------------


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.set_corner_radius_all(12)
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	return style


func _label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", COLOR_INK)
	if font != null:
		label.add_theme_font_override("font", font)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


## UI-puzzle-play R2: Player Elo always, plus the result cue after an ending.
func _setup_hud() -> void:
	_puzzle_screen = Control.new()
	_puzzle_screen.name = "PuzzlePlay"
	_puzzle_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_puzzle_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_puzzle_screen)
	var hud := PanelContainer.new()
	hud.add_theme_stylebox_override("panel", _panel_style())
	hud.position = Vector2(48.0, HUD_TOP)
	hud.size = Vector2(624.0, 190.0)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_puzzle_screen.add_child(hud)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	hud.add_child(box)
	_elo_label = _label("Elo 1000", 52)
	box.add_child(_elo_label)
	_cue_label = _label("", 40)
	box.add_child(_cue_label)
	_status_label = _label("", 28)
	box.add_child(_status_label)


func _setup_actions() -> void:
	# UI-puzzle-play R3 / C3-C5: Reveal, Abandon, Leave stream.
	var bar := HBoxContainer.new()
	bar.position = Vector2(40.0, ACTION_TOP)
	bar.size = Vector2(640.0, 96.0)
	bar.add_theme_constant_override("separation", 20)
	_puzzle_screen.add_child(bar)
	for entry in [
		["Reveal", func() -> void: _ask(CONFIRM_REVEAL)],
		["Abandon", func() -> void: _ask(CONFIRM_ABANDON)],
		["Leave stream", func() -> void: _ask(CONFIRM_LEAVE)],
	]:
		var button := Button.new()
		button.text = str(entry[0])
		button.custom_minimum_size = Vector2(200.0, 96.0)  # 44px-class targets
		button.add_theme_font_size_override("font_size", 30)
		if font != null:
			button.add_theme_font_override("font", font)
		button.pressed.connect(entry[1])
		bar.add_child(button)
		_actions.append(button)


## UI-mode-pick R1 / C2 / C3: choose Puzzle stream straight into the stream.
func _setup_mode_pick() -> void:
	_mode_screen = Control.new()
	_mode_screen.name = "ModePick"
	_mode_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mode_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mode_screen)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _panel_style())
	card.position = Vector2(48.0, 300.0)
	card.size = Vector2(624.0, 470.0)
	_mode_screen.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 28)
	card.add_child(box)
	box.add_child(_label("Choose how to play", 44))
	# GS.lastMode highlight (PRG.P2): the demo remembers the stream as Last mode.
	var puzzle_button := Button.new()
	puzzle_button.text = "Puzzle stream\nLast"
	puzzle_button.custom_minimum_size = Vector2(560.0, 150.0)
	puzzle_button.add_theme_font_size_override("font_size", 34)
	if font != null:
		puzzle_button.add_theme_font_override("font", font)
	puzzle_button.pressed.connect(_enter_puzzle_stream)
	box.add_child(puzzle_button)
	var quit_button := Button.new()
	quit_button.text = "Quit"
	quit_button.custom_minimum_size = Vector2(560.0, 96.0)
	quit_button.add_theme_font_size_override("font_size", 30)
	if font != null:
		quit_button.add_theme_font_override("font", font)
	quit_button.pressed.connect(_end_session)
	box.add_child(quit_button)


## UI-puzzle-play S2 / EX.confirm: the action is named and confirmed.
func _setup_confirm() -> void:
	_confirm_panel = PanelContainer.new()
	_confirm_panel.name = "Confirm"
	_confirm_panel.add_theme_stylebox_override("panel", _panel_style())
	_confirm_panel.position = Vector2(80.0, 470.0)
	_confirm_panel.size = Vector2(560.0, 300.0)
	_confirm_panel.visible = false
	add_child(_confirm_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	_confirm_panel.add_child(box)
	_confirm_text = _label("", 34)
	box.add_child(_confirm_text)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	var confirm := Button.new()
	confirm.text = "Confirm"
	confirm.custom_minimum_size = Vector2(250.0, 96.0)
	confirm.add_theme_font_size_override("font_size", 30)
	if font != null:
		confirm.add_theme_font_override("font", font)
	confirm.pressed.connect(_confirm_action)
	row.add_child(confirm)
	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.custom_minimum_size = Vector2(250.0, 96.0)
	cancel.add_theme_font_size_override("font_size", 30)
	if font != null:
		cancel.add_theme_font_override("font", font)
	cancel.pressed.connect(_cancel_confirm)
	row.add_child(cancel)


## UI-puzzle-play S3 / EX.save-failure: the write failed, prior Elo kept.
func _setup_save_panel() -> void:
	_save_panel = PanelContainer.new()
	_save_panel.name = "SaveFailure"
	_save_panel.add_theme_stylebox_override("panel", _panel_style())
	_save_panel.position = Vector2(80.0, 470.0)
	_save_panel.size = Vector2(560.0, 300.0)
	_save_panel.visible = false
	add_child(_save_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	_save_panel.add_child(box)
	box.add_child(_label("Save failed.\nPrior Elo kept.", 34))
	var dismiss := Button.new()
	dismiss.text = "Dismiss"
	dismiss.custom_minimum_size = Vector2(250.0, 96.0)
	dismiss.add_theme_font_size_override("font_size", 30)
	if font != null:
		dismiss.add_theme_font_override("font", font)
	dismiss.pressed.connect(_dismiss_save_failure)
	box.add_child(dismiss)


func _show_mode_pick() -> void:
	# FL-mode-pick T4 / NAV.T9: back at mode pick; the board is out of reach.
	screen = MODE_PICK
	ui_state = S1
	view.visible = false
	_puzzle_screen.visible = false
	_mode_screen.visible = true
	_confirm_panel.visible = false
	_save_panel.visible = false


func _update_hud() -> void:
	# R2: Player Elo always visible (DIF.Y1: the player sees their Elo).
	_elo_label.text = "Elo %d" % int(round(stream.player_elo))
	_cue_label.text = _cue_copy()
	_status_label.text = _status_copy()


func _cue_copy() -> String:
	match stream.cue:
		"cue_solved":
			return "Solved"
		"cue_wrong":
			return "Wrong move"
		"cue_failed":
			return "Failed"
		"cue_abandon":
			return "Abandoned"
		_:
			return ""


## Side to move and the deal the stream opened (K1: position, side, Elo are clear).
func _status_copy() -> String:
	if not stream.has_open_puzzle():
		return ""
	var side := "White" if stream.solving_side == DemoChessRules.WHITE else "Black"
	return "%s to move · puzzle %d" % [side, stream.puzzle_elo]


# --- Flow -------------------------------------------------------------------


## UI-mode-pick C2 / FL-mode-pick T2 / NAV.T2: into the stream and the first deal.
func _enter_puzzle_stream() -> void:
	screen = PUZZLE_PLAY
	_mode_screen.visible = false
	_puzzle_screen.visible = true
	view.visible = true
	var dealt := stream.deal()
	if not bool(dealt.get("ok", false)):
		# F-puzzle-catalog X2: no deal, so the Elo is untouched and the stream is idle.
		push_warning("demo: no puzzle dealt (%s)" % str(dealt.get("reason", "")))
		_show_mode_pick()
		return
	_draw_board()
	_save_last_mode()
	_update_hud()
	_refresh_actions()


func _draw_board() -> void:
	if stream.pos.is_empty():
		return
	view.setup_position(stream.pos)
	view.clear_selection()
	view.hide_promo_choice()
	ui_state = S1
	selection = -1
	legal_to = []


## K3: an ending updates Player Elo once, then the next puzzle is dealt once.
func _after_ending() -> void:
	_commit_save()
	_update_hud()
	# R2: the result cue shows after W1 / L4-L6 before the next deal.
	await get_tree().create_timer(0.45).timeout
	if screen == PUZZLE_PLAY:
		var dealt := stream.deal()
		if bool(dealt.get("ok", false)):
			_draw_board()
		_update_hud()
		_refresh_actions()


## EX.confirm - a stream verb waits for Confirm; Cancel returns to S1.
func _ask(verb: String) -> void:
	if ui_state == S2 or ui_state == S3:
		return
	confirmation = verb
	ui_state = S2
	_confirm_text.text = str(CONFIRM_COPY.get(verb, ""))
	_confirm_panel.visible = true
	_refresh_actions()


func _cancel_confirm() -> void:
	# B1 / EX.confirm Cancel: stays on puzzle-play S1 with the puzzle untouched.
	confirmation = ""
	ui_state = S1
	_confirm_panel.visible = false
	_refresh_actions()


func _confirm_action() -> void:
	var verb := confirmation
	confirmation = ""
	ui_state = S1
	_confirm_panel.visible = false
	match verb:
		CONFIRM_REVEAL:
			stream.reveal()  # END.L5
			await _after_ending()
		CONFIRM_ABANDON:
			stream.abandon()  # END.L6
			await _after_ending()
		CONFIRM_LEAVE:
			# K4 / E1: leaving scores nothing; the open puzzle is not an abandon.
			stream.leave()
			_save_last_mode()
			view.clear_selection()
			_show_mode_pick()
			stream.ending = ""
			stream.cue = ""
	_refresh_actions()


func _end_session() -> void:
	# FL-mode-pick T5: the session ends; nothing is left open.
	stream.leave()
	_save_last_mode()
	get_tree().quit()


func _refresh_actions() -> void:
	var open := stream.has_open_puzzle()
	var blocked := ui_state == S2 or ui_state == S4
	for index in range(_actions.size()):
		var button: Button = _actions[index]
		button.disabled = blocked or (index < 2 and not open)


# --- Persistence ------------------------------------------------------------


func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	return parsed if parsed is Dictionary else {}


## PRG.M1 / PRG.P1 / PRG.P3: Player Elo, Last mode, and recentSolved commit here.
## A failed write reaches EX.save-failure (S3) and the prior values are kept.
func _commit_save() -> void:
	var document := stream.save_document()  # carries GS.lastMode = puzzle
	if commit_failed or not _write_save(document):
		# S3: the write failed, so the prior committed values stand.
		stream.restore(committed)
		ui_state = S3
		_save_panel.visible = true
		_refresh_actions()
		return
	committed = document


func _save_last_mode() -> void:
	_commit_save()


func _write_save(document: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(document))
	file.close()
	return true


func _dismiss_save_failure() -> void:
	ui_state = S1
	_save_panel.visible = false
	_refresh_actions()
	_update_hud()


# --- Board input ------------------------------------------------------------


func _unhandled_input(event: InputEvent) -> void:
	if _is_autodrive() or screen != PUZZLE_PLAY:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_press_at(touch.position)
		else:
			_release_at(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_drag_moved = true
		view.drag_to(view.unit_at(drag.position))


func _press_at(screen_pos: Vector2) -> void:
	if view.is_motion_busy() or view.is_promo_open():
		return
	if ui_state == S2 or ui_state == S4:
		return
	var index := DemoBoardView.index_from_unit(view.unit_at(screen_pos))
	_drag_moved = false
	_press = index
	if index < 0:
		return
	# UI-puzzle-play C1: only the Solving side's pieces may be picked up.
	var board: PackedStringArray = stream.pos["board"]
	if board[index] != "" and DemoChessRules.piece_color(board[index]) == stream.solving_side:
		selection = index
		legal_to = DemoChessRules.legal_moves(stream.pos, index)
		view.start_drag(index)
		view.set_selection(index, _targets_of(legal_to, false), _targets_of(legal_to, true))
		_cue("select")  # SND.X1


func _release_at(screen_pos: Vector2) -> void:
	var dest := DemoBoardView.index_from_unit(view.unit_at(screen_pos))
	if view.is_promo_open():
		_pick_promo_at(view.unit_at(screen_pos))
		return
	if selection < 0 or _press < 0:
		_press = -1
		return
	var pressed := _press
	_press = -1
	if not _drag_moved and dest == pressed:
		return  # a plain tap keeps the selection
	for move in legal_to:
		if int(move["to"]) == dest:
			await _place(pressed, dest, str(move["promo"]))
			return
	if _drag_moved:
		view.clear_selection()
		selection = -1
		view.return_piece(pressed)
		view.flash_reject(dest if dest >= 0 else pressed)  # EX.rejected / PER.R8
		return
	if dest != pressed:
		# B8 / B9 / IN.deselect: pressing off a destination clears the selection.
		view.clear_selection()
		selection = -1


func _pick_promo_at(unit_pos: Vector2) -> void:
	var kind := view.promo_kind_at(unit_pos)
	if kind == "":
		return
	view.hide_promo_choice()
	await _place(pending_from, pending_to, kind)


## UI-puzzle-play C2 / C6 - the place is judged only after a promotion type commits.
func _place(from_index: int, to_index: int, promo: String) -> void:
	var landing := _landing_move(from_index, to_index, promo)
	var judged := stream.play(from_index, to_index, promo)
	if not bool(judged.get("ok", false)):
		# EX.rejected / S5: the piece rules refused the place. Not a Wrong move,
		# so the puzzle is not reset and nothing is dealt.
		view.flash_reject(to_index)
		return
	if bool(judged.get("promote", false)):
		# EX.promote / S4: the type is committed, then the move is judged.
		pending_from = from_index
		pending_to = to_index
		ui_state = S4
		view.show_promo_choice(to_index, stream.solving_side)
		view.clear_selection()
		selection = -1
		_refresh_actions()
		return
	await _apply_place(judged, landing)


func _apply_place(judged: Dictionary, landing: Dictionary) -> void:
	ui_state = S1
	selection = -1
	legal_to = []
	view.clear_selection()
	if str(judged.get("outcome", "")) == "wrong":
		# K2: a Wrong move returns the puzzle to its start and deals nothing.
		_draw_board()
		_cue("wrong")  # SND.X5
		_update_hud()
		_refresh_actions()
		return
	await view.move_piece(
		int(landing["from"]), int(landing["to"]), int(landing["capture"]), str(landing["promo"])
	)
	_cue("land")  # SND.X2: the settle cue ends with the travel (PHY.M1)
	if judged.has("reply"):
		var reply: Dictionary = judged["reply"]
		await view.move_piece(
			int(reply["from"]), int(reply["to"]), int(reply["capture"]), str(reply["promo"])
		)
		_cue("land")
	_update_hud()
	if str(judged.get("outcome", "")) == "outcome":
		_cue("end")  # SND.X4: END.W1 / L4 resolves
		await _after_ending()
	_refresh_actions()


## The legal move the place names, read before the stream applies it.
func _landing_move(from_index: int, to_index: int, promo: String) -> Dictionary:
	for move in DemoChessRules.legal_moves(stream.pos, from_index):
		if int(move["to"]) == to_index and (promo.is_empty() or str(move["promo"]) == promo):
			return move
	return {"from": from_index, "to": to_index, "capture": -1, "promo": promo}


func _targets_of(moves: Array, captures: bool) -> Array:
	var out: Array = []
	for move in moves:
		if captures == (int(move["capture"]) != -1):
			out.append(int(move["to"]))
	return out
