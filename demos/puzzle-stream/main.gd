extends Node2D
## Demo #335 — puzzle stream at a cafe table (gameplay demo). Assembles the
## catalog stand-in (catalog_service.gd), the session (stream_session.gd), the
## board view (board_view.gd), the R2/R3 HUD, and a headless autodrive.
##
## Spec sources: design/loops/puzzle-stream (K1-K4, E1); design/difficulty
## (DIF.Y1, DIF.C1); design/end-conditions (W1, L4, L5, L6, P1);
## design/features/puzzle-catalog (R1-R5, I1-I3, X1, X2, D1); design/progression
## (A1, P1-P3, M1, F1, Z1); design/game-state (GS.puzzleId, GS.puzzleElo,
## GS.requiredSequence, GS.sequenceIndex, GS.solvingSide, GS.wrongMoveOnPuzzle,
## GS.playerElo, GS.recentSolved, GS.lastMode, GS.position, GS.sideToMove,
## GS.selectedPiece, GS.Q1); design/configuration (CFG.ELO_START, ELO_K,
## ELO_MATCH_RANGE, ELO_RECENT_WINDOW, ELO_BAND_WIDEN, CFG.K3);
## design/flows/mode-pick (P1, P3, T2, T4, U1); view/cameras/board (F1-F2, M2);
## view/perception (R1-R4, R6-R8); view/physics (M1-M5); view/spatial-model;
## view/projection (P1, V1); aesthetics (AES.P1-P3, SND.X1-X3, SND.X5, SND.M1-M2,
## SND.L1-L2, MOT.T1-T3, PAL.C11); ux/screens/puzzle-play (R1-R3, C1-C6,
## S1-S2, S4-S5) + puzzle-play-controls; ux/journeys/puzzle-session (N1-N2,
## S1-S2, B1); ux/screens/mode-pick (C2); ux/navigation (T2, T9); ux/exceptions
## (EX.confirm, EX.promote, EX.rejected). Excluded: EX.save-failure (S3) — the
## demo keeps Player Elo and history in memory only.

const COLOR_TABLE := Color("5C3A2A")  # PAL.C5
const COLOR_CREAM := Color("F7F1E8")  # PAL.C10
const COLOR_INK := Color("2C2A28")    # PAL.C9
const COLOR_ROSE := Color("C28A86")   # PAL.C8 refusal flash / negative cue

const FONT_ID := "01a15215-15bd-7e3f-a3f8-ffcb1333a0ab"
const BOARD_BG_ID := "01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855"
const SFX_IDS := {
	"select": "01a151f8-b7d8-7ae6-84af-767ba53d09f6",  # SND.X1 touch select
	"land": "01a151f8-b7d8-710a-b767-92c9137bfd63",    # SND.X2 move settle
	"check": "01a151f8-b7d8-7e05-9921-e892e9a2e064",   # SND.X3 check
	"fail": "01a151f8-b7d8-759c-89c5-e1be5eecb2b2",    # SND.X5 puzzle fail
}
const CUE_GAIN_DB := {
	"select": -5.4,  # SND.L2: pick-up reads under the settle knock (defect #427)
	"land": 0.0,
	"check": 0.0,
	"fail": 0.0,
}
const BED_IDS := [
	"01a15200-69b2-7d13-a30d-696fa4ff390b",            # SND.M1 bed A
	"01a15200-69b2-7964-a602-ad5b19583125",            # SND.M2 bed B
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

# SPC / PRJ.P1: 10-unit short axis, unit 72 px, board on the frame center.
const UNIT := 72.0
const BOARD_ORIGIN := Vector2(72.0, 352.0)
const FRAME_SIZE := Vector2(720.0, 1280.0)

# CFG designer tunables (configuration.md, difficulty.md).
const CFG := {
	"elo_start": 1000.0,
	"elo_k": 20.0,
	"elo_match_range": 100.0,
	"elo_band_widen": 50.0,
	"elo_recent_window": 20,
}

const AUTODRIVE := "DEMO_AUTODRIVE"

var service: DemoCatalogService
var session: DemoStreamSession

var view: DemoBoardView
var _sfx: Dictionary = {}
var _bed_streams: Array = []
var _bed_player: AudioStreamPlayer
var _bed_index := 0
var _font: Font

# R2 status, R3 stream actions, S2 confirm, and the two demo screens.
var _elo_label: Label
var _prompt_label: Label
var _cue_label: Label
var _reveal_button: Button
var _abandon_button: Button
var _leave_button: Button
var _confirm_panel: PanelContainer
var _confirm_label: Label
var _confirm_action := ""
var _mode_root: Control
var _play_root: Control

var _selection := -1
var _legal_to: Array = []
var _press := -1
var _drag_moved := false
var _pending_promo := ""
var _pending_move: Dictionary = {}
var _busy := false
var _animate := true
var _sections_done := 0
var _in_stream := false
var _entered_before := false


func _ready() -> void:
	_setup_frame()
	var loader := DemoAssetLoader.new()
	_font = loader.resolve(FONT_ID)
	_setup_view(loader)
	for problem in loader.problems:
		push_warning("demo asset: %s" % problem)
	_setup_audio(loader)
	service = DemoCatalogService.new()
	if not service.open():
		for problem in service.problems:
			push_warning("demo catalog: %s" % problem)
	session = DemoStreamSession.new()
	_build_mode_pick()
	_build_play_hud()
	if _is_autodrive():
		_run_autodrive()


func _setup_frame() -> void:
	# SPC.L1: the cafe-table ground behind the board; ZK.P1 quiet mahogany.
	var cafe := ColorRect.new()
	cafe.color = COLOR_TABLE
	cafe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cafe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cafe)
	# Interface surfaces sit on panels, not directly on the table (PAL.S3 / UIS.F1):
	# a cream strip carries R2 status above the board and R3 actions below it.
	var top := ColorRect.new()
	top.color = COLOR_CREAM
	top.position = Vector2.ZERO
	top.size = Vector2(FRAME_SIZE.x, 344.0)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)


func _setup_view(loader: DemoAssetLoader) -> void:
	view = DemoBoardView.new()
	view.position = BOARD_ORIGIN
	view.scale = Vector2(UNIT, UNIT)
	add_child(view)
	var bg: Texture2D = loader.resolve(BOARD_BG_ID)
	view.setup(PIECE_IDS, _font, bg)
	var pieces: Dictionary = {}
	for asset_id in PIECE_IDS.values():
		var resource: Resource = loader.resolve(asset_id)
		if resource != null:
			pieces[asset_id] = resource
	view.provide_assets(pieces)


func _setup_audio(loader: DemoAssetLoader) -> void:
	for cue_name in SFX_IDS:
		var player := AudioStreamPlayer.new()
		player.stream = loader.resolve(SFX_IDS[cue_name])
		player.volume_db = float(CUE_GAIN_DB.get(cue_name, 0.0))  # SND.L2 cue gains
		add_child(player)
		_sfx[cue_name] = player
	for bed_id in BED_IDS:
		_bed_streams.append(loader.resolve(bed_id))
	_bed_player = AudioStreamPlayer.new()
	_bed_player.volume_db = -14.0  # SND.L1: music stays under cues
	_bed_player.finished.connect(_on_bed_finished)
	add_child(_bed_player)
	if not _bed_streams.is_empty():
		_bed_player.stream = _bed_streams[_bed_index]
		if not _silent():
			_bed_player.play()


func _on_bed_finished() -> void:
	# SND.M1 -> M2 -> M1 playlist order, no crossfade (SND.L2).
	_bed_index = (_bed_index + 1) % _bed_streams.size()
	_bed_player.stream = _bed_streams[_bed_index]
	_bed_player.play()


func _stop_audio() -> void:
	# A headless quit with playbacks running leaks stream objects at exit.
	for cue_name in _sfx.keys():
		var player: AudioStreamPlayer = _sfx[cue_name]
		player.stop()
	if _bed_player != null:
		_bed_player.stop()


func _cue(cue_name: String) -> void:
	var player: AudioStreamPlayer = _sfx.get(cue_name, null)
	if player != null and player.stream != null and not _silent():
		player.play()


func _silent() -> bool:
	# The headless smoke runs the dummy audio driver; playing there only leaks
	# playback objects at exit.
	return DisplayServer.get_name() == "headless"


# --- Screens -----------------------------------------------------------------

func _build_mode_pick() -> void:
	# UI-mode-pick.C2 / NAV.T2. A minimal mode pick: the demo question is the
	# stream itself, so Shared game is a disabled stub.
	_mode_root = Control.new()
	_mode_root.name = "ModePick"
	_mode_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mode_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mode_root)
	var panel := _cream_panel()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(120.0, 440.0)
	panel.size = Vector2(480.0, 360.0)
	_mode_root.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 24)
	panel.add_child(column)
	column.add_child(_label("Puzzles", 54, COLOR_INK))
	column.add_child(_button("Puzzle stream", _on_mode_pick_stream))
	var shared := _button("Shared game (stub)", func() -> void: pass)
	shared.disabled = true
	column.add_child(shared)


func _build_play_hud() -> void:
	_play_root = Control.new()
	_play_root.name = "PuzzlePlay"
	_play_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_play_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_root.visible = false
	add_child(_play_root)
	# R2 Elo and status.
	var bottom := ColorRect.new()
	bottom.color = COLOR_CREAM
	bottom.position = Vector2(0.0, 952.0)
	bottom.size = Vector2(FRAME_SIZE.x, FRAME_SIZE.y - 952.0)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_root.add_child(bottom)
	_elo_label = _label("Elo 1000", 64, COLOR_INK)  # UIS.T3: Elo is an in-play number
	_elo_label.position = Vector2(0.0, 72.0)
	_elo_label.size = Vector2(FRAME_SIZE.x, 80.0)
	_elo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_play_root.add_child(_elo_label)
	_prompt_label = _label("Your move", 40, COLOR_INK)
	_prompt_label.position = Vector2(0.0, 176.0)
	_prompt_label.size = Vector2(FRAME_SIZE.x, 56.0)
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_play_root.add_child(_prompt_label)
	# The result cue sits below the board, inside the lower cream strip, so it
	# never overlaps the board's cafe margin (UI-puzzle-play R2 is a status row).
	_cue_label = _label("", 44, COLOR_INK)
	_cue_label.position = Vector2(0.0, 896.0)
	_cue_label.size = Vector2(FRAME_SIZE.x, 56.0)
	_cue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_play_root.add_child(_cue_label)
	# R3 stream actions.
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 18)
	actions.position = Vector2(24.0, 1000.0)
	actions.size = Vector2(FRAME_SIZE.x - 48.0, 96.0)
	_play_root.add_child(actions)
	_reveal_button = _button("Reveal", _on_reveal_pressed)
	_abandon_button = _button("Abandon", _on_abandon_pressed)
	_leave_button = _button("Leave stream", _on_leave_pressed)
	actions.add_child(_reveal_button)
	actions.add_child(_abandon_button)
	actions.add_child(_leave_button)
	_build_confirm()


func _build_confirm() -> void:
	# S2 EX.confirm: one named confirm for reveal / abandon / leave.
	_confirm_panel = _cream_panel()
	_confirm_panel.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_panel.position = Vector2(110.0, 520.0)
	_confirm_panel.size = Vector2(500.0, 260.0)
	_confirm_panel.visible = false
	_play_root.add_child(_confirm_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	_confirm_panel.add_child(column)
	_confirm_label = _label("", 40, COLOR_INK)
	column.add_child(_confirm_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	column.add_child(row)
	row.add_child(_button("Confirm", _on_confirm_pressed))
	row.add_child(_button("Cancel", _on_cancel_pressed))


func _cream_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.border_color = Color(COLOR_TABLE.r, COLOR_TABLE.g, COLOR_TABLE.b, 0.28)  # UIS.F1
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 20.0
	style.content_margin_bottom = 20.0
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if _font != null:
		label.add_theme_font_override("font", _font)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text: String, callback: Callable) -> Button:
	# UIS.F1: a cream panel face with the PAL.C5-family border; UIS.C2 ink text.
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", 38)
	if _font != null:
		button.add_theme_font_override("font", _font)
	button.custom_minimum_size = Vector2(196.0, 88.0)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, _panel_face())
	button.add_theme_color_override("font_color", COLOR_INK)
	button.add_theme_color_override("font_disabled_color",
		Color(COLOR_INK.r, COLOR_INK.g, COLOR_INK.b, 0.4))  # UIS.C5 disabled
	button.pressed.connect(callback)
	return button


func _panel_face() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.border_color = Color(COLOR_TABLE.r, COLOR_TABLE.g, COLOR_TABLE.b, 0.28)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style


# --- Stream entry, deal, present --------------------------------------------

func _on_mode_pick_stream() -> void:
	# FL-mode-pick.T2 / J-puzzle-session.S1: into puzzle play; PRG.P2 records the
	# last mode (in-memory only here).
	_enter_stream()


func _enter_stream() -> void:
	_in_stream = true
	if not _entered_before:
		# PRG.P1 / CFG.ELO_START: first-time Player Elo; PRG.P3 empty history.
		session.enter(float(CFG["elo_start"]), [])
		_entered_before = true
	_mode_root.visible = false
	_play_root.visible = true
	_deal_next()


func _deal_next() -> void:
	# K3: after a result (or on entry) exactly one puzzle is dealt.
	_update_elo()
	if not service.readable():
		# X2: host catalog cannot be read -> nothing dealt, Player Elo unchanged.
		_set_cue("No puzzle available")
		_update_buttons()
		return
	var record := service.deal(session.player_elo, session.recent_solved, CFG)
	if record.is_empty() or not session.open_puzzle(record):
		# X1 / no candidate: nothing is dealt.
		_set_cue("No puzzle available")
		_update_buttons()
		return
	_present()


func _present() -> void:
	# CAM-board.M2: Solving side Black faces the player (rotate 180°).
	view.set_orientation(session.solving_side == DemoChessRules.BLACK)
	view.setup_position(session.pos)
	view.clear_selection()
	_refresh_check()
	_selection = -1
	_legal_to = []
	_press = -1
	_pending_promo = ""
	_pending_move = {}
	_set_cue("")
	_update_prompt()
	_update_elo()
	_update_buttons()


func _update_elo() -> void:
	_elo_label.text = "Elo %d" % roundi(session.player_elo)


func _update_prompt() -> void:
	if session.open and not session.ended:
		_prompt_label.text = "Your move"
	else:
		_prompt_label.text = ""


func _update_buttons() -> void:
	var playing := _in_stream and session.open and not session.ended
	_reveal_button.disabled = not playing
	_abandon_button.disabled = not playing
	_leave_button.disabled = not _in_stream


func _set_cue(text: String) -> void:
	_cue_label.text = text
	var negative := text == "Wrong move" or text == "Failed" or text == "Abandoned"
	_cue_label.add_theme_color_override("font_color", COLOR_ROSE if negative else COLOR_INK)


func _refresh_check() -> void:
	# PER.R6: a king in check sits under a rose rim; SND.X3 plays.
	if not session.open:
		view.set_check_rim(-1)
		return
	var side := str(session.pos["side"])
	if DemoChessRules.in_check(session.pos, side):
		_cue("check")
		view.set_check_rim(DemoChessRules.king_square(session.pos, side))
	else:
		view.set_check_rim(-1)


# --- Input -------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if _is_autodrive() or not _in_stream or _busy:
		return
	if _confirm_panel.visible:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_press_at(touch.position)
		else:
			_release_at(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if view.is_promo_open() or not session.is_player_turn():
			return
		_drag_moved = true
		view.drag_to(view.unit_at(drag.position))


func _press_at(screen: Vector2) -> void:
	# C1 IN.select: select a solving-side piece and mark its legal places.
	if not session.is_player_turn() or view.is_promo_open() or view.is_motion_busy():
		return
	var index := view.index_from_unit(view.unit_at(screen))
	_drag_moved = false
	_press = index
	if index < 0:
		return
	var board: PackedStringArray = session.pos["board"]
	if board[index] != "" and DemoChessRules.piece_color(board[index]) == str(session.pos["side"]):
		_selection = index
		_legal_to = session.legal_from(index)
		view.start_drag(index)
		view.set_selection(index, _targets_of(_legal_to, false), _targets_of(_legal_to, true))
		_cue("select")


func _release_at(screen: Vector2) -> void:
	var dest := view.index_from_unit(view.unit_at(screen))
	if view.is_promo_open():
		_pick_promo_at(view.unit_at(screen))
		return
	if _selection < 0 or _press < 0:
		_press = -1
		return
	var pressed := _press
	_press = -1
	var target := _legal_move_to(dest)
	if target["succ"]:
		if not _drag_moved and dest == pressed:
			return  # a plain tap of the selected piece keeps the selection
		_execute_move(target["move"])
		return
	if _drag_moved:
		# S5 EX.rejected / PER.R8: a place the piece rules refuse, not a wrong
		# puzzle move.
		view.clear_selection()
		_selection = -1
		view.return_piece(pressed)
		view.flash_reject(dest if dest >= 0 else pressed)
		return
	if dest != pressed:
		# IN.deselect (B8/B9): pressing elsewhere deselects.
		view.clear_selection()
		_selection = -1


func _pick_promo_at(unit_pos: Vector2) -> void:
	# C6 / S4: the move is judged only after the promotion type is committed.
	var kind := view.promo_kind_at(unit_pos)
	if kind == "":
		return
	view.hide_promo_choice()
	_cue("select")
	_pending_promo = kind
	_finish_promoted_move()


func _execute_move(move: Dictionary) -> void:
	if str(move["promo"]) != "":
		_pending_move = move
		view.show_promo_choice(int(move["to"]), str(session.pos["side"]))
		return
	_commit_player_move(move)


func _finish_promoted_move() -> void:
	var move: Dictionary = _pending_move
	move["promo"] = _pending_promo
	_pending_promo = ""
	_commit_player_move(move)


func _targets_of(moves: Array, captures: bool) -> Array:
	var out: Array = []
	for move in moves:
		if captures == (int(move["capture"]) != -1):
			out.append(int(move["to"]))
	return out


func _legal_move_to(dest: int) -> Dictionary:
	for move in _legal_to:
		if int(move["to"]) == dest:
			return {"succ": true, "move": move}
	return {"succ": false, "move": null}


# --- Committing a solving-side move -----------------------------------------

func _commit_player_move(move: Dictionary) -> void:
	# C2: a legal place is judged by the puzzle (K2).
	_busy = true
	_selection = -1
	_legal_to = []
	view.clear_selection()
	if _animate:
		await _animate_move(move)
	_cue("land")
	var result := session.try_move(move)
	if bool(result["wrong"]):
		# K2: a Wrong move returns the puzzle to its start and deals nothing.
		_cue("fail")
		_set_cue("Wrong move")
		if _animate:
			await _quiet(0.5)
		_present()
		_cue("fail")
		_set_cue("Wrong move")
		_busy = false
		return
	if _animate:
		await _animate_replies(result["replies"])
	else:
		view.setup_position(session.pos)
	_refresh_check()
	_update_prompt()
	_update_buttons()
	if str(result["outcome"]) != "":
		await _finish(str(result["outcome"]))
	else:
		if _animate:
			await _quiet(0.25)
		_busy = false


func _animate_move(move: Dictionary) -> void:
	if int(move["rook_from"]) >= 0:
		await view.castle_move(int(move["from"]), int(move["to"]),
			int(move["rook_from"]), int(move["rook_to"]))
	else:
		await view.move_piece(int(move["from"]), int(move["to"]),
			int(move["capture"]), str(move["promo"]))


func _animate_replies(replies: Array) -> void:
	for reply in replies:
		if int(reply["rook_from"]) >= 0:
			await view.castle_move(int(reply["from"]), int(reply["to"]),
				int(reply["rook_from"]), int(reply["rook_to"]))
		else:
			await view.move_piece(int(reply["from"]), int(reply["to"]),
				int(reply["capture"]), str(reply["promo"]))
		_cue("land")


# --- Endings and scoring -----------------------------------------------------

func _finish(outcome: String) -> void:
	# K3: Player Elo updates once per outcome, then the next puzzle is dealt once.
	_busy = true
	var cue := "Failed"
	if outcome == "W1":
		cue = "Solved"
	elif outcome == "L6":
		cue = "Abandoned"
	# R2: the puzzle result is a status cue, not an end cue — SND.X4 stays with
	# shared-game endings (checkmate, resign, clock loss) per SND, so no cue here.
	_set_cue(cue)
	session.score(outcome)
	_update_elo()
	_update_buttons()
	if _animate:
		await _quiet(1.0)
	if not _in_stream:
		_busy = false
		return
	_deal_next()
	_busy = false


func _on_reveal_pressed() -> void:
	_open_confirm("reveal")


func _on_abandon_pressed() -> void:
	_open_confirm("abandon")


func _on_leave_pressed() -> void:
	_open_confirm("leave")


func _open_confirm(action: String) -> void:
	# S2: a named confirm; Cancel returns to S1.
	if action == "reveal" and not (session.open and not session.ended):
		return
	if action == "abandon" and not (session.open and not session.ended):
		return
	_confirm_action = action
	_confirm_label.text = _confirm_question(action)
	_confirm_panel.visible = true
	_update_buttons()


func _confirm_question(action: String) -> String:
	if action == "reveal":
		return "Reveal the solution?"
	if action == "abandon":
		return "Abandon this puzzle?"
	return "Leave the puzzle stream?"


func _on_cancel_pressed() -> void:
	_confirm_panel.visible = false
	_confirm_action = ""
	_update_buttons()


func _on_confirm_pressed() -> void:
	var action := _confirm_action
	_confirm_panel.visible = false
	_confirm_action = ""
	if action == "reveal":
		await _finish(session.reveal())
	elif action == "abandon":
		await _finish(session.abandon())
	elif action == "leave":
		_leave()


func _leave() -> void:
	# K4 / E1 / J-puzzle-session.N2 / NAV.T9: keep Player Elo, clear the open
	# puzzle unscored, and return to mode pick.
	session.leave()
	_in_stream = false
	if _bed_player != null:
		pass  # the bed keeps playing; leaving is calm, not a teardown
	_play_root.visible = false
	_mode_root.visible = true
	_busy = false


func _is_autodrive() -> bool:
	return DisplayServer.get_name() == "headless" or OS.get_environment(AUTODRIVE) == "1"


func _quiet(seconds: float) -> void:
	if seconds <= 0.0:
		return
	await get_tree().create_timer(seconds).timeout


# --- Autodrive (headless smoke) ---------------------------------------------

func _run_autodrive() -> void:
	## Drives the fixture slice, the deal ladder, sequence judging, wrong-move
	## reset, the four endings, scoring, and the calm leave; fails loudly.
	print("[demo] autodrive begin")
	# Headless runs skip the motion timers; a windowed autodrive keeps them, so
	# the animated move paths are exercised too.
	_animate = not _silent()
	var problems: PackedStringArray = PackedStringArray()
	_check_catalog(problems)
	_check_view(problems)
	await _check_stream(problems)
	_stop_audio()
	# A runtime error aborts a section before its sentinel, so an aborted run can
	# never report PASS.
	if _sections_done != 3:
		problems.append("only %d of 3 check sections ran to the end" % _sections_done)
	if problems.is_empty():
		print("[demo] PASS")
		get_tree().quit(0)
	else:
		for problem in problems:
			print("[demo] FAIL: %s" % problem)
		get_tree().quit(1)


func _capture(tag: String) -> void:
	# Windowed autodrive only: save the frame so a reviewer can see the surface.
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var dir := OS.get_environment("DEMO_SHOT_DIR")
	if dir == "":
		dir = OS.get_user_data_dir()
	var path := dir.path_join("demo-puzzle-stream-%s.png" % tag)
	image.save_png(path)
	print("[demo] screenshot %s -> %s" % [tag, path])


func _expect(problems: PackedStringArray, condition: bool, message: String) -> void:
	if not condition:
		problems.append(message)
	print("[demo] %s %s" % ["ok  " if condition else "FAIL", message])


func _append(problems: PackedStringArray, findings: Array) -> void:
	for finding in findings:
		problems.append(str(finding))


func _check_catalog(problems: PackedStringArray) -> void:
	_expect(problems, service.readable(), "F-puzzle-catalog: fixture slice readable")
	_expect(problems, service.records().size() == 4, "slice holds 4 recorded-format records")
	for record in service.records():
		var pid := str(record["puzzle_id"])
		_expect(problems, str(record["snapshot_id"]) == "2026-10-05", "%s F1 snapshot_id" % pid)
		_expect(problems, not str(record["fen"]).is_empty(), "%s F3 fen" % pid)
		_expect(problems, (record["moves"] as Array).size() >= 2, "%s F4/I2 moves length >= 2" % pid)
		var has_mate := (record["themes"] as Array).has("mateIn1")
		_expect(problems, bool(record["any_checkmate_wins"]) == has_mate,
			"%s F13/I3 any_checkmate_wins iff mateIn1" % pid)
	# X2: an unreadable host catalog deals nothing and leaves Player Elo alone.
	var dead := DemoCatalogService.new()
	_expect(problems, not dead.open("res://fixtures/missing-slice.txt"), "X2 unreadable slice opens false")
	_expect(problems, not dead.readable(), "X2 readable() stays false")
	_expect(problems, dead.deal(1000.0, [], CFG).is_empty(), "X2 deals nothing")
	var probe := DemoStreamSession.new()
	probe.enter(1000.0, [])
	_expect(problems, not probe.open_puzzle({}), "X2 no puzzle opened")
	_expect(problems, probe.puzzle_id == "", "X2 GS.puzzleId stays none")
	_expect(problems, absf(probe.player_elo - 1000.0) < 0.001, "X2 GS.playerElo unchanged")
	# X1: moves after the first would be empty -> the record is not dealt.
	var short_record: Dictionary = service.record_by_id("demo0001").duplicate()
	short_record["moves"] = ["a7a6"]
	_expect(problems, not probe.open_puzzle(short_record), "X1 a record with no required sequence is not dealt")
	_expect(problems, probe.puzzle_id == "" and probe.sequence.is_empty(),
		"X1 GS.puzzleId and GS.requiredSequence stay none")
	# DIF.Y1 / I1: in-band, prefer unsolved, then widen, then allow recent.
	var fresh := _ids(service.candidate_set(1000.0, [], CFG))
	_expect(problems, fresh.size() >= 2, "GS.Q1 candidate set has >= 2 at Player Elo 1000")
	_expect(problems, fresh.has("demo0001") and fresh.has("demo0002") and fresh.has("demo0004"),
		"I1 the three in-band puzzle ids are candidates")
	_expect(problems, not fresh.has("demo0003"), "I1 the 1150 id stays outside the 100 band")
	var pick := service.deal(1000.0, [], CFG)
	_expect(problems, fresh.has(str(pick["puzzle_id"])), "GS.Q1 dealt id is a candidate-set member")
	_expect(problems, absf(float(pick["rating"]) - 1000.0) <= 100.0, "I1 dealt within +/-100")
	var skip := _ids(service.candidate_set(1000.0, ["demo0001", "demo0004"], CFG))
	_expect(problems, skip == ["demo0002"], "PS2.1 recent ids are skipped")
	_expect(problems, str(service.deal(1000.0, ["demo0001", "demo0004"], CFG)["puzzle_id"]) == "demo0002",
		"PS2.1 the fresh in-band id is dealt")
	var widened := _ids(service.candidate_set(1000.0, ["demo0001", "demo0002", "demo0004"], CFG))
	_expect(problems, widened == ["demo0003"], "PS1.8 widen finds only the 1150 id")
	_expect(problems, float(service.deal(1000.0, ["demo0001", "demo0002", "demo0004"], CFG)["rating"]) == 1150.0,
		"PS1.8 widened deal is 1150")
	var recent := service.candidate_set(1000.0, ["demo0001", "demo0002", "demo0003", "demo0004"], CFG)
	_expect(problems, not recent.is_empty(), "PS1.4 allow-recent finds a puzzle")
	_expect(problems, absf(float(service.deal(
		1000.0, ["demo0001", "demo0002", "demo0003", "demo0004"], CFG)["rating"]) - 1000.0) <= 100.0,
		"PS1.4 recent deal still prefers the band")
	var members := _ids(service.candidate_set(1000.0, [], CFG))
	var deal1 := str(service.deal(1000.0, [], CFG)["puzzle_id"])
	var deal2 := str(service.deal(1000.0, [], CFG)["puzzle_id"])
	_expect(problems, members.has(deal1) and members.has(deal2), "GS.Q1 both deals are members (need not match)")
	_sections_done += 1


func _check_view(problems: PackedStringArray) -> void:
	# CAM-board.M2: rotation maps every square to its turned-over point and back.
	view.set_orientation(false)
	var a1_white := view.place_point(DemoChessRules.square_index("a1"))
	var h8_white := view.place_point(DemoChessRules.square_index("h8"))
	var white_ok := true
	for index in range(64):
		if view.index_from_unit(view.place_point(index)) != index:
			white_ok = false
	_expect(problems, white_ok, "CAM-board.M2 White orientation round-trips all 64 squares")
	view.set_orientation(true)
	var black_ok := true
	for index in range(64):
		if view.index_from_unit(view.place_point(index)) != index:
			black_ok = false
	_expect(problems, black_ok, "CAM-board.M2 Black orientation round-trips all 64 squares")
	_expect(problems, view.place_point(DemoChessRules.square_index("a1")).is_equal_approx(h8_white),
		"CAM-board.M2 a1 turns to h8")
	_expect(problems, view.place_point(DemoChessRules.square_index("h8")).is_equal_approx(a1_white),
		"CAM-board.M2 h8 turns to a1")
	_append(problems, view.measure_coord_labels())
	_append(problems, view.measure_piece_bodies())
	view.set_orientation(false)
	_sections_done += 1


func _check_stream(problems: PackedStringArray) -> void:
	# Pure session battery: sequence judging, wrong-move reset, endings, scoring.
	var probe := DemoStreamSession.new()
	probe.enter(1000.0, [])
	_expect(problems, probe.open_puzzle(service.record_by_id("demo0001")), "K1 opens demo0001")
	_expect(problems, probe.solving_side == "w", "PS1.1 solving side is the dealt side to move")
	_expect(problems, probe.sequence.size() == 3, "PS1.3 requiredSequence length 3")
	_expect(problems, probe.index == 0 and not probe.wrong_move, "PS1.3 index 0, no wrong move")
	_expect(problems, probe.puzzle_elo == 900.0, "PS1.3 puzzleElo 900")
	var first := probe.try_move(_move_for(probe, probe.next_step()))
	_expect(problems, first["replies"].size() == 1 and not bool(first["wrong"]),
		"PS2.2 the game plays the required reply at once")
	_expect(problems, probe.index == 2 and not probe.ended, "PS2.2 the player moves again")
	var second := probe.try_move(_move_for(probe, probe.next_step()))
	_expect(problems, second["outcome"] == "W1", "W1 completing the sequence solves")
	_expect(problems, probe.ended, "W1 the puzzle is ended")
	probe.score("W1")
	_expect(problems, absf(probe.player_elo - 1007.2) < 0.01, "DIF.Y1 W1 vs 900 -> 1007.2")
	_expect(problems, probe.recent_solved == ["demo0001"], "I3 recentSolved appends the solved id")
	# K2: a wrong move resets the puzzle and does not end the stream.
	probe.enter(1000.0, [])
	probe.open_puzzle(service.record_by_id("demo0001"))
	var start_board: PackedStringArray = probe.pos["board"]
	var wrong := _any_other_legal(probe)
	_expect(problems, not wrong.is_empty(), "a legal Wrong move exists in the presented position")
	var reset := probe.try_move(wrong)
	_expect(problems, bool(reset["wrong"]), "K2 the Wrong move is flagged")
	_expect(problems, probe.pos["board"] == start_board, "K2 the Wrong move resets the board to its start")
	_expect(problems, probe.index == 0, "K2 the Wrong move resets the index")
	_expect(problems, probe.wrong_move, "GS.wrongMoveOnPuzzle is true")
	_expect(problems, probe.puzzle_elo == 900.0, "PS1.6 puzzleElo holds through a Wrong move")
	_expect(problems, probe.open and not probe.ended, "K2 the Wrong move does not end the stream")
	_expect(problems, absf(probe.player_elo - 1000.0) < 0.001, "K2 the Wrong move updates no Elo")
	# L4: the sequence later completed after the Wrong move is a loss.
	var mid := probe.try_move(_move_for(probe, probe.next_step()))
	_expect(problems, not probe.ended, "L4 mid-sequence is not an ending")
	var after := probe.try_move(_move_for(probe, probe.next_step()))
	_expect(problems, after["outcome"] == "L4", "L4 sequence completed after a Wrong move")
	# R5: the mate-in-one accepts an alternate checkmating move.
	probe.enter(1000.0, [])
	probe.open_puzzle(service.record_by_id("demo0002"))
	var mates := _mating_moves(probe)
	_expect(problems, mates.size() >= 2, "R5 mate-in-one presented position has >= 2 mating moves")
	var alternate := _alternate_mate(probe, str(probe.sequence[0]))
	_expect(problems, not alternate.is_empty(), "R5 an alternate checkmating move exists")
	var mate_result := probe.try_move(alternate)
	_expect(problems, mate_result["outcome"] == "W1", "R5 the alternate mate completes the step")
	# L5 / L6 / leave.
	probe.enter(1000.0, [])
	probe.open_puzzle(service.record_by_id("demo0001"))
	_expect(problems, probe.reveal() == "L5", "L5 reveal the solution")
	probe.enter(1000.0, [])
	probe.open_puzzle(service.record_by_id("demo0001"))
	_expect(problems, probe.abandon() == "L6", "L6 abandon the puzzle")
	probe.score("L6")
	_expect(problems, absf(probe.player_elo - 987.2) < 0.01, "DIF.Y1 L6 vs 900 -> 987.2")
	probe.enter(1000.0, [])
	probe.open_puzzle(service.record_by_id("demo0001"))
	var kept := probe.player_elo
	probe.leave()
	_expect(problems, probe.puzzle_id == "" and probe.sequence.is_empty() and probe.solving_side == "",
		"PS1.5 leaving the stream clears the puzzle fields")
	_expect(problems, absf(probe.player_elo - kept) < 0.001, "K4 leaving keeps Player Elo, no score")
	# DIF.Y1 formula and the recent window.
	var even_win := DemoProgression.score(1000.0, 1000.0, "W1", "x", [], CFG)
	_expect(problems, absf(float(even_win["playerElo"]) - 1010.0) < 0.001, "PS1.1 even-Elo W1 -> 1010")
	var even_loss := DemoProgression.score(1000.0, 1000.0, "L6", "x", [], CFG)
	_expect(problems, absf(float(even_loss["playerElo"]) - 990.0) < 0.001, "PS1.2 even-Elo L6 -> 990")
	var history: Array = []
	for i in range(25):
		history.append("old%d" % i)
	var trimmed := DemoProgression.score(1000.0, 1000.0, "W1", "newest", history, CFG)
	_expect(problems, (trimmed["recentSolved"] as Array).size() == 20, "PS1.7 recent window trims to 20")
	_expect(problems, str((trimmed["recentSolved"] as Array)[19]) == "newest", "PS1.7 newest stays last")
	# The demo question, through the integrated view path.
	session.enter(float(CFG["elo_start"]), [])
	_in_stream = true
	_play_root.visible = true
	_mode_root.visible = false
	_deal_next()
	_expect(problems, session.puzzle_id == "demo0001", "stream deals at the player's level (demo0001 at 1000)")
	_update_buttons()
	_expect(problems, not _reveal_button.disabled and not _leave_button.disabled,
		"R3 actions are live while a puzzle is open")
	# PER.R3 / R4 at the played surface: select the knight and show its legal places.
	var knight_square := DemoChessRules.square_index("c5")
	_selection = knight_square
	_legal_to = session.legal_from(knight_square)
	view.set_selection(knight_square, _targets_of(_legal_to, false), _targets_of(_legal_to, true))
	_expect(problems, not _legal_to.is_empty(), "PER.R4 the solved-side knight has legal places marked")
	await _capture("deal-1")
	view.clear_selection()
	var elo_start := session.player_elo
	await _commit_uci(session.next_step())
	await _commit_uci(session.next_step())
	_expect(problems, session.player_elo > elo_start, "a solve drifts Player Elo up")
	_expect(problems, session.puzzle_id == "demo0002", "the stream continues with the in-band mate-in-one")
	_expect(problems, session.mate_in_one, "deal 2 is the mate-in-one record")
	_expect(problems, session.solving_side == "w", "deal 2 solving side")
	await _commit_move(_any_other_legal(session))
	_expect(problems, session.wrong_move, "stream Wrong move flagged")
	await _capture("wrong-move")
	_expect(problems, session.puzzle_id == "demo0002" and not session.ended,
		"a Wrong move resets without ending the stream")
	var before_leave := session.player_elo
	await _commit_uci(session.next_step())
	# L4: the sequence was completed after a Wrong move, so this one is a loss.
	_expect(problems, session.open and session.puzzle_id != "", "K3 the stream continues with the next deal")
	_expect(problems, session.player_elo < before_leave, "a Wrong-move loss drifts Elo down")
	var kept_on_leave := session.player_elo
	_leave()
	_expect(problems, not _in_stream, "leave returns to mode pick")
	_expect(problems, absf(session.player_elo - kept_on_leave) < 0.001,
		"leave keeps Player Elo and scores the open puzzle nothing")
	_sections_done += 1


func _commit_uci(text: String) -> void:
	await _commit_move(_move_for(session, text))


func _commit_move(move: Dictionary) -> void:
	if move.is_empty():
		return
	await _commit_player_move(move)


func _move_for(probe: DemoStreamSession, text: String) -> Dictionary:
	if text.length() < 4:
		return {}
	var from := DemoChessRules.square_index(text.substr(0, 2))
	var to := DemoChessRules.square_index(text.substr(2, 2))
	for move in DemoChessRules.legal_moves(probe.pos, from):
		if int(move["to"]) == to:
			return move
	return {}


func _any_other_legal(probe: DemoStreamSession) -> Dictionary:
	var expected := probe.next_step()
	for move in DemoChessRules.all_legal_moves(probe.pos):
		if DemoStreamSession.uci(move) == expected:
			continue
		if probe.mate_in_one and _is_mate(probe.pos, move):
			continue
		return move
	return {}


func _mating_moves(probe: DemoStreamSession) -> Array:
	var out: Array = []
	for move in DemoChessRules.all_legal_moves(probe.pos):
		if _is_mate(probe.pos, move):
			out.append(move)
	return out


func _alternate_mate(probe: DemoStreamSession, expected: String) -> Dictionary:
	for move in _mating_moves(probe):
		if DemoStreamSession.uci(move) != expected:
			return move
	return {}


func _is_mate(board: Dictionary, move: Dictionary) -> bool:
	var after := DemoChessRules.apply(board, move)
	var opponent := str(after["side"])
	return DemoChessRules.in_check(after, opponent) and not DemoChessRules.any_legal_move(after)


func _ids(records: Array) -> Array:
	var out: Array = []
	for record in records:
		out.append(str(record["puzzle_id"]))
	return out
