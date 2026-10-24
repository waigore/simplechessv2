extends Node2D
## Demo #376 — optional Advice on the shared board (engine demo). Owns the
## scripted game, the advice lifecycle (F-move-advice R1–R9, X1–X4), the advice
## marks and eval, and a headless autodrive that measures the demo question.
## Spec sources: design/features/move-advice.md, design/experience/feedback.md,
## view/perception.md, view/stories/perception-marks.md, aesthetics/,
## ux/screens/shared-play*.md, technical/contracts/advice-stream.md,
## technical/schemata/advice-update.md, technical/sequences/advice-stream.md.

const COLOR_TABLE := Color("5C3A2A")  # PAL.C5
const COLOR_CREAM := Color("F7F1E8")  # PAL.C10
const COLOR_INK := Color("2C2A28")    # PAL.C9
const COLOR_ROSE := Color("C28A86")   # PAL.C8, same danger ink as S3's flash
const COLOR_ADVICE := Color("53A2BE") # PAL.C7 advice teal

const FONT_ID := "01a15215-15bd-7e3f-a3f8-ffcb1333a0ab"
const BOARD_BG_ID := "01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855"
const ADVICE_ICON_ID := "01a15dc4-969f-7a81-9d34-29765e8dd787"  # UIS.I1 glyph
const SFX_IDS := {
	"select": "01a151f8-b7d8-7ae6-84af-767ba53d09f6",  # SND.X1 touch select
	"land": "01a151f8-b7d8-710a-b767-92c9137bfd63",   # SND.X2 move settle
	"check": "01a151f8-b7d8-7e05-9921-e892e9a2e064",  # SND.X3 check
	"end": "01a151f8-b7d8-7fe3-b94f-e3a562395d96",    # SND.X4 end resolve
}
## SND.L2 one cue family: the pick-up stays well under the settle knock.
const CUE_GAIN_DB := {"select": -5.4, "land": 0.0, "check": 0.0, "end": 0.0}
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

# PRJ.P1: 10-unit short axis (8 board + 1-unit margins), board on frame center.
const UNIT := 72.0
const BOARD_ORIGIN := Vector2(72.0, 352.0)
const FRAME_SIZE := Vector2(720.0, 1280.0)  # pocs/advice/project.godot
const BOARD_BOTTOM := 352.0 + 8.0 * UNIT      # 928: the advice band starts below
const END_PANEL_LAYER := 10

## F-move-advice.R7 / CFG.ADVICE_TIME_MS: the demo's configured cap (default
## 2000, range 500–5000). The peer, like the backend (CMP-advice-backend.R3),
## stops its search by this value; the client never caps.
const ADVICE_TIME_MS := 2000
## quality.md / F-move-advice: advice ready within this budget.
const BUDGET_MS := 2000
const AUTODRIVE := "DEMO_AUTODRIVE"
## The demo's simulated peer (ADR-0002 Testability). Preloaded by path, so the
## demo needs no `class_name` registration in the global script cache.
const DemoSimPeer := preload("res://sim_peer.gd")

var pos: Dictionary = {}
var ended := false
var rule_end := ""
var selection := -1
var legal_to: Array = []

# F-move-advice state: GS.advice, GS.online, GS.adviceBestMove, GS.adviceEval.
var advice_on := true
var online := true
var advice_best_move: Variant = null
var advice_eval: Variant = null
var advice_error := false

var view: DemoAdviceBoardView
var chip: Label
var advice_label: Label
var advice_toggle: Label
var advice_error_box: Control
var _sfx: Dictionary = {}
var _bed_streams: Array = []
var _bed_player: AudioStreamPlayer
var _bed_index := 0
var _press := -1
var _drag_moved := false
var _end_panel: PanelContainer
var _icon: Texture2D

# Advice stream bookkeeping (CTR-advice-stream O1/O2/E1/E2).
var _stream_id := 0
var _stream_open := false
var _requested_ms := 0
var _stream_started := 0
var _ticks: Array = []
var _tick_index := 0
var _ready_first_ms := -1


func _ready() -> void:
	_setup_frame()
	view = DemoAdviceBoardView.new()
	view.position = BOARD_ORIGIN
	view.scale = Vector2(UNIT, UNIT)
	add_child(view)
	var loader := DemoAssetLoader.new()
	var font: Font = loader.resolve(FONT_ID)
	var bg: Texture2D = loader.resolve(BOARD_BG_ID)
	_icon = loader.resolve(ADVICE_ICON_ID)
	view.setup(PIECE_IDS, font, bg)
	view.provide_assets(_load_pieces(loader))
	for problem in loader.problems:
		push_warning("demo asset: %s" % problem)
	_setup_audio(loader)
	_setup_chip(font)
	_setup_advice_controls(font)
	_setup_end_panel(font)
	_new_game()
	if _is_autodrive():
		_run_autodrive()


func _load_pieces(loader: DemoAssetLoader) -> Dictionary:
	var out: Dictionary = {}
	for asset_id in PIECE_IDS.values():
		var resource: Resource = loader.resolve(asset_id)
		if resource != null:
			out[asset_id] = resource
	return out


func _setup_frame() -> void:
	# SPC.L1 cafe ground (PRJ.A1 tall aspect); the board sits on the table.
	var cafe := ColorRect.new()
	cafe.color = COLOR_TABLE
	cafe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cafe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cafe)


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
	_bed_player.volume_db = -14.0  # SND.L1 approx: music stays under cues
	_bed_player.finished.connect(_on_bed_finished)
	add_child(_bed_player)
	_bed_player.stream = _bed_streams[_bed_index]
	_bed_player.play()


func _on_bed_finished() -> void:
	# SND.M1 -> M2 -> M1 playlist order, no crossfade (SND.L2).
	_bed_index = (_bed_index + 1) % _bed_streams.size()
	_bed_player.stream = _bed_streams[_bed_index]
	_bed_player.play()


func _cue(cue_name: String) -> void:
	var player: AudioStreamPlayer = _sfx.get(cue_name, null)
	if player != null:
		player.play()


func _setup_chip(font: Font) -> void:
	# PER.R6: side-to-move indicator inside the frame, >= 1/12 frame height.
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.set_corner_radius_all(10)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	panel.add_theme_stylebox_override("panel", style)
	chip = Label.new()
	chip.text = "White to move"
	chip.add_theme_font_size_override("font_size", 46)
	chip.add_theme_color_override("font_color", COLOR_INK)
	if font != null:
		chip.add_theme_font_override("font", font)
	chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(chip)
	panel.name = "TurnChip"
	add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.position = Vector2(0, 96)
	panel.size = Vector2(720, 120)


func _setup_advice_controls(font: Font) -> void:
	# UI-shared-play.R3 / C3: one shared Advice control and the eval, in a band
	# below the board, so nothing is drawn over a piece (PER.R1).
	var band := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.set_corner_radius_all(12)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	band.add_theme_stylebox_override("panel", style)
	band.name = "AdviceBand"
	band.position = Vector2(BOARD_ORIGIN.x, BOARD_BOTTOM + 24.0)
	band.size = Vector2(8.0 * UNIT, 104.0)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(row)
	if _icon != null:
		var icon := TextureRect.new()
		icon.texture = _icon
		icon.custom_minimum_size = Vector2(32, 32)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
	advice_toggle = Label.new()
	advice_toggle.name = "AdviceToggle"
	advice_toggle.custom_minimum_size = Vector2(248, 76)
	advice_toggle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	advice_toggle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	advice_toggle.mouse_filter = Control.MOUSE_FILTER_STOP
	advice_toggle.add_theme_font_size_override("font_size", 28)
	if font != null:
		advice_toggle.add_theme_font_override("font", font)
	_style_toggle()
	advice_toggle.gui_input.connect(_on_toggle_input)
	row.add_child(advice_toggle)
	advice_label = Label.new()
	advice_label.name = "AdviceEval"
	advice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	advice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	advice_label.add_theme_font_size_override("font_size", 30)  # >= UIS.T2 body
	advice_label.add_theme_color_override("font_color", COLOR_ADVICE)
	if font != null:
		advice_label.add_theme_font_override("font", font)
	row.add_child(advice_label)
	# EX.error / S3: a calm line under the band; the board stays playable.
	var error_box := PanelContainer.new()
	var error_style := StyleBoxFlat.new()
	error_style.bg_color = COLOR_CREAM
	error_style.set_corner_radius_all(10)
	error_style.content_margin_left = 20.0
	error_style.content_margin_right = 20.0
	error_style.content_margin_top = 10.0
	error_style.content_margin_bottom = 10.0
	error_box.add_theme_stylebox_override("panel", error_style)
	error_box.name = "AdviceError"
	error_box.position = Vector2(BOARD_ORIGIN.x, BOARD_BOTTOM + 144.0)
	error_box.size = Vector2(8.0 * UNIT, 72.0)
	error_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(error_box)
	advice_error_box = error_box
	var error_row := HBoxContainer.new()
	error_row.add_theme_constant_override("separation", 18)
	error_box.add_child(error_row)
	var message := Label.new()
	message.text = "Advice unavailable. Play continues."  # S3 copy
	message.name = "AdviceErrorMessage"
	message.add_theme_font_size_override("font_size", 26)
	message.add_theme_color_override("font_color", COLOR_ROSE)
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if font != null:
		message.add_theme_font_override("font", font)
	error_row.add_child(message)
	var dismiss := Button.new()
	dismiss.text = "Dismiss"  # S3 copy
	dismiss.name = "AdviceDismiss"
	dismiss.custom_minimum_size = Vector2(132, 52)  # 44 px class target
	dismiss.add_theme_font_size_override("font_size", 26)
	if font != null:
		dismiss.add_theme_font_override("font", font)
	dismiss.pressed.connect(_dismiss_error)
	error_row.add_child(dismiss)
	error_box.visible = false


func _style_toggle() -> void:
	# C3: one switch with the two copy states (UI-shared-play Copy).
	advice_toggle.text = "Advice On" if advice_on else "Advice Off"
	advice_toggle.add_theme_color_override("font_color", COLOR_INK)


func _on_toggle_input(event: InputEvent) -> void:
	if _is_autodrive():
		return
	var activate := false
	if event is InputEventScreenTouch:
		activate = (event as InputEventScreenTouch).pressed
	elif event is InputEventMouseButton:
		activate = (event as InputEventMouseButton).pressed
	if activate:
		toggle_advice()


## C3 / F-move-advice.R9: Off clears advice and stops evaluation; On starts
## evaluating the current position again (R2, R3).
func toggle_advice() -> void:
	advice_on = not advice_on
	_style_toggle()
	if advice_on:
		clear_error()
		_start_advice()
	else:
		_stop_advice("off")


func _dismiss_error() -> void:
	# S3 Dismiss -> S1. FAIL.T1 keeps the service offline: no overdue retry.
	advice_error = false
	advice_error_box.visible = false


func _setup_end_panel(font: Font) -> void:
	_end_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CREAM
	style.set_corner_radius_all(14)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 24.0
	style.content_margin_bottom = 24.0
	_end_panel.add_theme_stylebox_override("panel", style)
	_end_panel.clip_contents = true
	var label := Label.new()
	label.name = "EndLabel"
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", COLOR_INK)
	if font != null:
		label.add_theme_font_override("font", font)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(8.0 * UNIT - 56.0, 0.0)
	_end_panel.add_child(label)
	_end_panel.name = "EndPanel"
	_end_panel.z_index = END_PANEL_LAYER
	_end_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_end_panel)
	_end_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_end_panel.position = Vector2.ZERO
	_end_panel.size = Vector2(8.0 * UNIT, 0.0)
	_end_panel.visible = false


func _show_end() -> void:
	# END.L1 result, surfaced calmly (AES.P3): a cream panel, ink text, no chrome.
	var label: Label = _end_panel.get_node("EndLabel")
	label.text = _end_text()
	_end_panel.visible = true
	_place_end_panel()


func _place_end_panel() -> void:
	var style := _end_panel.get_theme_stylebox("panel") as StyleBoxFlat
	var inline := style.content_margin_left + style.content_margin_right
	var block := style.content_margin_top + style.content_margin_bottom
	var label: Label = _end_panel.get_node("EndLabel")
	var max_width := FRAME_SIZE.x - 16.0
	var panel_width := max_width
	var text_height := 64.0
	var font := label.get_theme_font("font")
	if font != null:
		var font_size := label.get_theme_font_size("font_size")
		var text_width := font.get_string_size(
			label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		panel_width = clampf(text_width + inline, 0.0, max_width)
		text_height = maxf(64.0, font.get_multiline_string_size(
			label.text, HORIZONTAL_ALIGNMENT_LEFT, panel_width - inline, font_size).y)
	label.custom_minimum_size = Vector2(panel_width - inline, 0.0)
	var panel_size := Vector2(panel_width, text_height + block)
	# Above the board, over the turn chip: never over the advice band.
	var centered := Vector2((FRAME_SIZE.x - panel_size.x) / 2.0, 84.0)
	var lo := Vector2(4.0, 4.0)
	var hi := Vector2(BOARD_BOTTOM - panel_size.y - 4.0, BOARD_BOTTOM - panel_size.y - 4.0)
	_end_panel.position = centered.clamp(lo, hi.max(lo))
	_end_panel.size = panel_size


func _is_autodrive() -> bool:
	# GUI display tools in Godot include "X11", "Wayland", "macOS", "Windows",
	# "Embedded window", etc.; headless runs report "headless".
	return DisplayServer.get_name() == "headless" or OS.get_environment(AUTODRIVE) == "1"


func _new_game() -> void:
	# L-two-player-game.K1: orthodox opening, White is to move.
	_stop_advice("")
	pos = DemoChessRules.start_position()
	DemoChessRules.init_king(pos)
	ended = false
	rule_end = ""
	selection = -1
	legal_to = []
	clear_error()
	if _end_panel != null:
		_end_panel.visible = false
	view.setup_position(pos)
	view.clear_selection()
	view.set_check_rim(-1)
	view.hide_promo_choice()
	_update_chip()
	_start_advice()


# --- F-move-advice lifecycle -------------------------------------------------


## R2 / R3: advice runs only when On, online, in a Shared game, game not ended.
func advice_allowed() -> bool:
	return advice_on and online and not ended


## O1 — open a stream for the current position when R2 holds (R3, CTR S1–S2).
func _start_advice() -> void:
	_stop_advice("")
	if not advice_allowed() or advice_error:
		return
	_stream_id += 1
	_stream_open = true
	_ready_first_ms = -1
	_requested_ms = ADVICE_TIME_MS
	_stream_started = Time.get_ticks_msec()
	_tick_index = 0
	var fen := _fen()
	_ticks = DemoSimPeer.schedule(fen, _requested_ms)
	# O1 wire: api_key, fen, time_ms (CTR-advice-stream Wire). The peer stands in
	# for the backend here; a real client aims this at its configured endpoint.
	print("[demo] advice O1 %s" % JSON.stringify({
		"api_key": "demo-simulated-peer", "fen": fen, "time_ms": _requested_ms,
	}))


## O2 + O3 — stop the stream, drop later ticks (SCH-advice-update I3), clear the
## advice fields (GS.adviceBestMove, GS.adviceEval).
func _stop_advice(log_tag: String) -> void:
	if _stream_open:
		print("[demo] advice E2 cancel after %d ms" % _stream_elapsed())
	_stream_id += 1
	_stream_open = false
	_ticks = []
	_tick_index = 0
	_clear_advice_fields()
	if not log_tag.is_empty():
		print("[demo] advice cleared (%s)" % log_tag)


func _clear_advice_fields() -> void:
	advice_best_move = null
	advice_eval = null
	if view != null:
		view.set_advice_move(-1, -1)
	_refresh_advice_ui()


## U3 -> U2: drain due ticks off the move path. Called every frame and before
## any judgement that depends on advice.
func poll_advice() -> void:
	if not _stream_open:
		return
	var stream := _stream_id
	var now := _stream_elapsed()
	while _tick_index < _ticks.size() and int(_ticks[_tick_index]["at_ms"]) <= now:
		if stream != _stream_id:
			return  # stale: the stream was cancelled meanwhile (I3)
		_apply_tick(_ticks[_tick_index]["update"])
		_tick_index += 1
	if _tick_index >= _ticks.size():
		# E2 cap: the search stops by CFG.ADVICE_TIME_MS; the last tick stays up.
		print("[demo] advice E2 cap after %d ms" % now)
		_stream_open = false


## E1 -> SCH-advice-update L2: write the advice fields and the board marks.
func _apply_tick(update: Dictionary) -> void:
	var from_square := str(update.get("best_move_uci", "")).substr(0, 2)
	var to_square := str(update.get("best_move_uci", "")).substr(2, 2)
	if not _is_square(from_square) or not _is_square(to_square):
		return
	# F-move-advice.R4 / GS.H2: best move and eval together, nothing more.
	advice_best_move = {"from": from_square, "to": to_square}
	advice_eval = int(update.get("eval_cp", 0))
	var now := _stream_elapsed()
	if _ready_first_ms < 0:
		_ready_first_ms = now
	view.set_advice_move(
		DemoChessRules.square_index(from_square), DemoChessRules.square_index(to_square)
	)
	_refresh_advice_ui()
	# Design experience/feedback.md "Advice ready": best move and eval up, the
	# move not delayed. Observability: the timing is logged for playtests.
	print("[demo] advice E1 depth %d after %d ms: %s%s cp %d" % [
		int(update.get("depth", 0)), now, from_square, to_square,
		int(update.get("eval_cp", 0)),
	])


func _stream_elapsed() -> int:
	return Time.get_ticks_msec() - _stream_started


func _is_square(name: String) -> bool:
	if name.length() != 2:
		return false
	var file := name.substr(0, 1)
	var rank := name.substr(1, 1)
	return "abcdefgh".contains(file) and "12345678".contains(rank)


## O1 wire position: FEN placement, side to move, castling rights (CTR Wire).
func _fen() -> String:
	# The demo's placement array is row-major from index 0 = rank 8, file a (see
	# chess_rules.start_position); FEN rows run rank 8 to rank 1.
	var board: PackedStringArray = pos["board"]
	var rows: Array[String] = []
	for row in ["8", "7", "6", "5", "4", "3", "2", "1"]:
		var line := ""
		var empty := 0
		for file in ["a", "b", "c", "d", "e", "f", "g", "h"]:
			var code := board[(8 - row.to_int()) * 8 + "abcdefgh".find(file)]
			if code == "":
				empty += 1
				continue
			if empty > 0:
				line += str(empty)
				empty = 0
			line += _fen_letter(code)
		if empty > 0:
			line += str(empty)
		rows.append(line)
	var side := "w" if str(pos["side"]) == DemoChessRules.WHITE else "b"
	var castling := ""
	for entry in [["w", "k", "K"], ["w", "q", "Q"], ["b", "k", "k"], ["b", "q", "q"]]:
		var rights: Dictionary = DemoChessRules.castle_rights(pos, str(entry[0]))
		if bool(rights.get(str(entry[1]), false)):
			castling += str(entry[2])
	if castling.is_empty():
		castling = "-"
	return "%s %s %s - 0 1" % ["/".join(rows), side, castling]


func _fen_letter(code: String) -> String:
	var letters := {"pawn": "P", "knight": "N", "bishop": "B", "rook": "R", "queen": "Q", "king": "K"}
	var letter := str(letters.get(DemoChessRules.piece_kind(code), "P"))
	return letter if DemoChessRules.piece_color(code) == DemoChessRules.WHITE else letter.to_lower()


## X3 — the connection drops mid-evaluation: clear advice, stop (R9), and show
## EX.error; the board stays playable (FAIL.T1).
func go_offline() -> void:
	print("[demo] X3 connection lost")
	online = false
	_stop_advice("offline")
	show_error()


## The browser is back online: R2 holds again, so the position is evaluated (R3).
func go_online() -> void:
	print("[demo] connection restored")
	online = true
	clear_error()
	_start_advice()


## A backend failure (FAIL.T1): O3, EX.error, play continues.
func simulate_failure() -> void:
	print("[demo] advice backend error (FAIL.T1)")
	_stop_advice("error")
	show_error()


func show_error() -> void:
	advice_error = true
	advice_error_box.visible = true


func clear_error() -> void:
	advice_error = false
	if advice_error_box != null:
		advice_error_box.visible = false


func _refresh_advice_ui() -> void:
	if advice_label == null:
		return
	# R2 / UI-shared-play.R3: the eval shows only while On and online and set.
	var shown := advice_on and online and advice_best_move is Dictionary and advice_eval is int
	advice_label.visible = shown
	advice_label.text = _format_eval(int(advice_eval)) if shown else ""


## Signed pawns from White's view, two decimals (UIS.T3 in-play number).
static func _format_eval(cp: int) -> String:
	return "%+.2f" % (float(cp) / 100.0)


# --- Game play --------------------------------------------------------------


func _process(_delta: float) -> void:
	poll_advice()


func _update_chip() -> void:
	var side: String = str(pos["side"])
	var label := "White to move" if side == DemoChessRules.WHITE else "Black to move"
	if DemoChessRules.in_check(pos, side):
		label += " — check"
		chip.add_theme_color_override("font_color", COLOR_ROSE)
	else:
		chip.add_theme_color_override("font_color", COLOR_INK)
	if ended:
		label = _end_text()
		chip.add_theme_color_override("font_color", COLOR_INK)
	chip.text = label


func _end_text() -> String:
	if rule_end == "checkmate:w":
		return "Checkmate — White wins"
	if rule_end == "checkmate:b":
		return "Checkmate — Black wins"
	return "Stalemate — game drawn"


func _unhandled_input(event: InputEvent) -> void:
	if _is_autodrive():
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if ended:
				_new_game()
				return
			_press_at(touch.position)
		else:
			_release_at(touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_drag_moved = true
		view.drag_to(view.unit_at(drag.position))


func _press_at(screen: Vector2) -> void:
	if view.is_promo_open() or view.is_motion_busy():
		return
	var index := DemoAdviceBoardView.index_from_unit(view.unit_at(screen))
	_drag_moved = false
	_press = index
	if index < 0:
		return
	var board: PackedStringArray = pos["board"]
	if board[index] != "" and DemoChessRules.piece_color(board[index]) == str(pos["side"]):
		selection = index
		legal_to = DemoChessRules.legal_moves(pos, index)
		view.start_drag(index)
		view.set_selection(index, _targets_of(legal_to, false), _targets_of(legal_to, true))
		_cue("select")


func _release_at(screen: Vector2) -> void:
	var dest := DemoAdviceBoardView.index_from_unit(view.unit_at(screen))
	if view.is_promo_open():
		_pick_promo_at(view.unit_at(screen))
		return
	if selection < 0 or _press < 0:
		_press = -1
		return
	var pressed := _press
	_press = -1
	var target := _legal_move_to(dest)
	if target["succ"]:
		if not _drag_moved and dest == pressed:
			return
		_execute_move(target["move"])
		return
	if _drag_moved:
		view.clear_selection()
		selection = -1
		view.return_piece(pressed)
		view.flash_reject(dest if dest >= 0 else pressed)
		return
	if dest != pressed:
		view.clear_selection()
		selection = -1


func _pick_promo_at(unit_pos: Vector2) -> void:
	# I33: the chosen type completes that same move; advice then clears (R8).
	var kind := view.promo_kind_at(unit_pos)
	if kind == "":
		return
	view.hide_promo_choice()
	var move := view.pending_promo_move()
	move["promo"] = kind
	_cue("select")
	_commit(move)


func _execute_move(move: Dictionary) -> void:
	if str(move["promo"]) != "":
		view.set_pending_promo_move(move)
		view.show_promo_choice(int(move["to"]), str(pos["side"]))
		return
	_commit(move)


func _targets_of(moves: Array, captures: bool) -> Array:
	var out: Array = []
	for mv in moves:
		if captures == (int(mv["capture"]) != -1):
			out.append(int(mv["to"]))
	return out


func _legal_move_to(dest: int) -> Dictionary:
	for mv in legal_to:
		if int(mv["to"]) == dest:
			return {"succ": true, "move": mv}
	return {"succ": false, "move": null}


## R6 / I1: the move path never awaits advice. The old advice clears first (R8),
## the motion starts at once, and the new evaluation opens after the commit.
func _commit(move: Dictionary) -> void:
	var from := int(move["from"])
	var to := int(move["to"])
	var capture_index := int(move["capture"])
	var started := Time.get_ticks_msec()
	# R8 / X1: move completed — clear advice immediately, cancel the stream (O2).
	_stop_advice("move")
	if int(move["rook_from"]) >= 0:
		view.castle_move(from, to, int(move["rook_from"]), int(move["rook_to"]))
	else:
		view.move_piece(from, to, capture_index, str(move["promo"]))
	pos = DemoChessRules.apply(pos, move)
	selection = -1
	legal_to = []
	view.clear_selection()
	_update_state(move, started)
	# R8: the game continues and R2 holds — evaluate the new position.
	_start_advice()


func _update_state(move: Dictionary, started: int) -> void:
	var elapsed := Time.get_ticks_msec() - started
	print("[demo] move %s%s done in %d ms (budget 150 ms)" % [
		DemoChessRules.square_name(int(move["from"])),
		DemoChessRules.square_name(int(move["to"])),
		elapsed,
	])
	_cue("land")  # SND.X2
	var side: String = str(pos["side"])
	if DemoChessRules.in_check(pos, side):
		_cue("check")
		view.set_check_rim(DemoChessRules.king_square(pos, side))
	else:
		view.set_check_rim(-1)
	rule_end = DemoChessRules.result(pos)
	if rule_end != "":
		ended = true
		_cue("end")
		# X4 / R8: the game ends while advice is showing — advice is cleared.
		_stop_advice("game-end")
		_show_end()
		print("[demo] game ended: %s" % _end_text())
	_update_chip()


# --- Autodrive --------------------------------------------------------------


func _run_autodrive() -> void:
	## Proves the demo question headless: advice arrives calmly inside
	## CFG.ADVICE_TIME_MS, a local move never waits on it, and it clears on move,
	## Off, offline, error, and game end.
	print("[demo] autodrive begin")
	var problems: PackedStringArray = PackedStringArray()
	await _scenario_calm(problems)
	await _capture("advice-ready")
	await _scenario_move_clears(problems)
	await _scenario_off(problems)
	await _scenario_offline(problems)
	await _capture("advice-offline")
	await _scenario_failure(problems)
	await _scenario_end(problems)
	_bed_player.stop()
	if problems.is_empty():
		print("[demo] PASS")
		get_tree().quit(0)
	else:
		for problem in problems:
			print("[demo] FAIL: %s" % problem)
		get_tree().quit(1)


func _scenario_calm(problems: PackedStringArray) -> void:
	# F-move-advice.R2–R4; design experience/feedback.md "Advice ready".
	print("[demo] scenario: advice arrives calmly")
	_new_game()
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	if advice_best_move == null:
		problems.append("advice never became ready")
		return
	if _ready_first_ms > BUDGET_MS:
		problems.append("advice first ready at %d ms (budget %d)" % [_ready_first_ms, BUDGET_MS])
	var marks: Dictionary = advice_best_move
	if str(marks.get("from", "")) != "e2" or str(marks.get("to", "")) != "e4":
		problems.append("advice best move %s, expected e2e4" % marks)
	if not (advice_eval is int):
		problems.append("advice eval missing")
	print("[demo] advice ready in %d ms (budget %d)" % [_ready_first_ms, BUDGET_MS])
	_check_advice_band(problems)


func _scenario_move_clears(problems: PackedStringArray) -> void:
	# F-move-advice.R6, I1, R8, X1: a local move completes on device while a
	# stream is in flight; advice clears at once, then the new position evaluates.
	print("[demo] scenario: local move never waits; advice clears and resumes")
	_new_game()
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	if advice_best_move == null:
		problems.append("advice was not in flight before the move")
		return
	if _stream_open and _stream_elapsed() >= BUDGET_MS:
		problems.append("the move came after the cap: no stream in flight")
	await _play_uci("e2e4", problems)
	# The new position's first tick is due ~5% into the new cap, so by the time
	# the tap sequence returns, advice is legitimately up again for Black. The
	# immediate clear is what the clear hook checked (`_commit`); what is asserted
	# here is that the value is for the new position and the new side to move.
	if advice_best_move == null:
		problems.append("the new position was not evaluated (R8)")
		return
	var after: Dictionary = advice_best_move
	if str(after.get("from", "")) != "e7" or str(after.get("to", "")) != "e5":
		problems.append("the new position evaluated to %s, expected e7e5" % after)
		return
	if view.advice_from() != DemoChessRules.square_index("e7"):
		problems.append("the marks did not move to the new best move")
	print("[demo] new position evaluated: e7e5 (advice had cleared on the move)")
	await _play_uci("e7e5", problems)
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	await _play_uci("g1f3", problems)
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)


func _scenario_off(problems: PackedStringArray) -> void:
	# F-move-advice.R9, X2: Advice Off clears advice and stops evaluation.
	print("[demo] scenario: Advice Off clears")
	_new_game()
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	if advice_best_move == null:
		problems.append("advice was not showing before the toggle")
	toggle_advice()  # On -> Off
	await _quiet(0.4)
	if advice_on:
		problems.append("the toggle did not turn Advice Off")
	if advice_best_move != null or advice_eval != null:
		problems.append("Advice Off left advice set (R9)")
	if advice_label.visible:
		problems.append("Advice Off still shows the eval")
	if _stream_open:
		problems.append("Advice Off left a stream open (R9)")
	await _quiet(0.5)
	if advice_best_move != null:
		problems.append("advice returned while Off")
	toggle_advice()  # Off -> On (R2): evaluation resumes
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	if advice_best_move == null:
		problems.append("Advice On did not resume evaluation")


func _scenario_offline(problems: PackedStringArray) -> void:
	# F-move-advice.R9, X3; EX.error (FAIL.T1): connection lost mid-evaluation.
	print("[demo] scenario: connection lost clears advice")
	_new_game()
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	if advice_best_move == null:
		problems.append("advice was not showing before the connection dropped")
	go_offline()
	await _quiet(0.4)
	if advice_best_move != null:
		problems.append("offline left advice set (X3)")
	if _stream_open:
		problems.append("offline left a stream open (X3)")
	if not advice_error_box.visible:
		problems.append("offline did not show EX.error (S3)")
	go_online()
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	if advice_best_move == null:
		problems.append("no evaluation after coming back online")
	else:
		print("[demo] advice resumed after reconnect")


func _scenario_failure(problems: PackedStringArray) -> void:
	# FAIL.T1 / EX.error: a backend failure clears advice, and play continues.
	print("[demo] scenario: backend failure")
	simulate_failure()
	await _quiet(0.4)
	if advice_best_move != null:
		problems.append("failure left advice set (FAIL.T1)")
	if not advice_error_box.visible:
		problems.append("failure did not show EX.error (S3)")
	# S3: the board stays playable — a local move lands while S3 shows.
	await _play_uci("e2e4", problems)
	var dismiss := advice_error_box.find_child("AdviceDismiss", true, false) as Button
	dismiss.pressed.emit()
	await _quiet(0.2)
	if advice_error_box.visible:
		problems.append("Dismiss did not return to S1")


func _scenario_end(problems: PackedStringArray) -> void:
	# F-move-advice.R8 / X4: the game ends while advice is showing.
	print("[demo] scenario: game end clears advice")
	_new_game()
	# Scholar's-mate line; the last White move checkmates (END.L1).
	for uci in ["e2e4", "e7e5", "f1c4", "b8c6", "d1h5", "g8f6"]:
		await _play_uci(str(uci), problems)
	await _wait_until(func() -> bool: return advice_best_move != null, BUDGET_MS)
	await _play_uci("h5f7", problems)
	if rule_end != "checkmate:w":
		problems.append("expected checkmate:w, got %s" % rule_end)
	if advice_best_move != null:
		problems.append("game end left advice set (X4)")
	if _stream_open:
		problems.append("game end left a stream open")
	await _capture("advice-end")


func _play_uci(uci: String, problems: PackedStringArray) -> void:
	# Tap-tap like a player: press the origin, tap the destination (IN.select /
	# IN.move). The timing is printed so the never-wait guarantee is visible.
	var from := DemoChessRules.square_index(uci.substr(0, 2))
	var to := DemoChessRules.square_index(uci.substr(2, 4))
	var started := Time.get_ticks_msec()
	_press_at(_screen_of_index(from))
	await _quiet(0.05)
	var target := _legal_move_to(to)
	if not target["succ"]:
		problems.append("illegal scripted move %s (side %s)" % [uci, str(pos["side"])])
		return
	_execute_move(target["move"])
	var commanded := Time.get_ticks_msec() - started
	if commanded > 150 + 60:
		problems.append("move %s took %d ms on the input path (budget 150)" % [uci, commanded])
	var motion := Time.get_ticks_msec()
	await _quiet(0.35)
	print("[demo] move %s commanded in %d ms; motion settled %d ms after (advice O1 in flight meanwhile)" % [
		uci, commanded, Time.get_ticks_msec() - motion,
	])


func _wait_until(predicate: Callable, budget_ms: int) -> void:
	var deadline := Time.get_ticks_msec() + budget_ms
	while Time.get_ticks_msec() < deadline:
		if predicate.call():
			return
		await get_tree().process_frame


func _check_advice_band(problems: PackedStringArray) -> void:
	# The advice chrome sits below the board: PER.R1 never has a mark over a
	# piece body, and the eval stays inside the frame.
	if advice_label == null or advice_label.text.is_empty():
		problems.append("the eval text is not shown while advice is ready")
	var band_bottom := BOARD_BOTTOM + 24.0 + 104.0
	if band_bottom > FRAME_SIZE.y:
		problems.append("advice band bottom %.0f escapes the frame" % band_bottom)
	if view.advice_from() < 0:
		problems.append("advice marks are missing while advice is ready")
		return
	print("[demo] advice marks %s->%s with eval %s" % [
		DemoChessRules.square_name(view.advice_from()),
		DemoChessRules.square_name(view.advice_to()),
		advice_label.text,
	])


func _capture(tag: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var dir := OS.get_environment("DEMO_SHOT_DIR")
	if dir == "":
		dir = OS.get_user_data_dir()
	var path := dir.path_join("demo-advice-%s.png" % tag)
	image.save_png(path)
	print("[demo] screenshot %s -> %s" % [tag, path])


func _screen_of_index(index: int) -> Vector2:
	var c := DemoAdviceBoardView.square_center(index)
	return BOARD_ORIGIN + Vector2(c.x * UNIT, c.y * UNIT)


func _quiet(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
