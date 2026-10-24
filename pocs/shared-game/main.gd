extends Node2D
## Demo #63 — shared game at a cafe table (engine demo). Owns the rules engine,
## presentation, motion tracking, sound, and a scripted autodrive for headless
## smoke runs. Spec sources: specs/design/entities/pieces.md,
## design/loops/two-player-game.md, design/end-conditions.md, view/spatial-model,
## view/projection, view/cameras/board.md, view/physics.md, view/perception.md,
## aesthetics/{aesthetics,palette,motion,sound}.md.

const COLOR_TABLE := Color("5C3A2A")  # PAL.C5
const COLOR_CREAM := Color("F7F1E8")  # PAL.C10
const COLOR_INK := Color("2C2A28")    # PAL.C9
const COLOR_ROSE := Color("C28A86")   # PAL.C8 chip tint on check

const FONT_ID := "01a15215-15bd-7e3f-a3f8-ffcb1333a0ab"
const BOARD_BG_ID := "01a14f8e-1cfa-7e93-bc94-ef0e7b4e3855"
const SFX_IDS := {
	"select": "01a151f8-b7d8-7ae6-84af-767ba53d09f6",  # SND.X1 touch select
	"land": "01a151f8-b7d8-710a-b767-92c9137bfd63",   # SND.X2 move settle
	"check": "01a151f8-b7d8-7e05-9921-e892e9a2e064",  # SND.X3 check
	"end": "01a151f8-b7d8-7fe3-b94f-e3a562395d96",    # SND.X4 end resolve
}
## Per-cue gain (SND.L2): one soft family of wood taps. The select cue is the
## same touch family as the settle knock, only lighter — PBX 0 dB, the pick-up
## at -5.4 dB so its peak lands ~1.5 dB under the settle cue's and its first
## 60 ms ~3 dB under it, instead of the +4.6 dB / -4.3 dB that read as a harsh
## snap (defect #427 item 2). The other cues already follow the settle cue.
const CUE_GAIN_DB := {
	"select": -5.4,
	"land": 0.0,
	"check": 0.0,
	"end": 0.0,
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

# PRJ.P1: 10-unit short axis (8 board + 1-unit margins), board on frame center.
const UNIT := 72.0
const BOARD_ORIGIN := Vector2(72.0, 352.0)
const FRAME_SIZE := Vector2(720.0, 1280.0)  # pocs/shared-game/project.godot

# End panel (END.L1 calm result): an in-board overlay above every board layer.
const END_PANEL_LAYER := 10  # above board_view pieces (3, 6 in motion) and overlays (5)
const END_PANEL_MARGIN := 4.0  # keep the panel inside the frame even when clamped

const AUTODRIVE := "DEMO_AUTODRIVE"

var pos: Dictionary = {}
var ended := false
var rule_end := ""
var selection := -1
var legal_to: Array = []
var _pending_promo := ""
var _pending_move: Dictionary = {}

var view: DemoBoardView
var chip: Label
var _sfx: Dictionary = {}
var _bed_streams: Array = []
var _bed_player: AudioStreamPlayer
var _bed_index := 0
var _press := -1
var _drag_moved := false
var _end_panel: PanelContainer

# Scripted exercise: a refused bad drop (PHY.M5/PER.R8), capture breaks (PHY.M2),
# a check (I7/PER.R6), and a capture promotion morph (PHY.M3). Every "move" entry
# is a legal UCI move in the line below. Castling (PHY.M4) and en passant are
# implemented in chess_rules.gd but not scripted here.
const EXERCISE := [
	{"bad_drop": ["f1", "c3"]},
	{"move": "e2e4"}, {"move": "e7e5"},
	{"move": "f1c4"}, {"move": "b8c6"},
	{"move": "g1f3"}, {"move": "g7g6"},
	{"move": "h2h4"}, {"move": "f8g7"},
	{"move": "h4h5"}, {"move": "d7d6"},
	{"move": "h5g6"}, {"move": "g8h6"},
	{"move": "g6h7"}, {"move": "h6g8"},
	{"move": "h7g8"}, {"move": "h8g8"},
]
# The ending: Qxf7# (scholar's mate), one game ending (L1/loop E1).
const MATE := [
	{"move": "e2e4"}, {"move": "e7e5"},
	{"move": "f1c4"}, {"move": "b8c6"},
	{"move": "d1h5"}, {"move": "g8f6"},
	{"move": "h5f7"},
]


func _ready() -> void:
	_setup_frame()
	view = DemoBoardView.new()
	view.position = BOARD_ORIGIN
	view.scale = Vector2(UNIT, UNIT)
	add_child(view)
	var loader := DemoAssetLoader.new()
	var font: Font = loader.resolve(FONT_ID)
	var bg: Texture2D = loader.resolve(BOARD_BG_ID)
	view.setup(PIECE_IDS, font, bg)
	view.provide_assets(_load_pieces(loader))
	for problem in loader.problems:
		push_warning("demo asset: %s" % problem)
	_setup_audio(loader)
	_setup_chip(font)
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
	# SPC.L1 cafe ground extends the 10-unit backdrop band (PRJ.A1 tall aspect).
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
	_end_panel.clip_contents = true  # the text never draws past the panel
	var label := Label.new()
	label.name = "EndLabel"
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", COLOR_INK)
	if font != null:
		label.add_theme_font_override("font", font)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Pin the wrap width: until laid out the label is 1 px wide, and a text
	# change then wraps it one character per line (a 1400 px tall panel).
	label.custom_minimum_size = Vector2(8.0 * UNIT - 56.0, 0.0)
	_end_panel.add_child(label)
	_end_panel.name = "EndPanel"
	_end_panel.z_index = END_PANEL_LAYER
	# Taps fall through to the board so a tap starts the next game (K3-like);
	# the label must not swallow them either.
	_end_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_end_panel)
	# Top-left anchor: _place_end_panel() sets the rect directly, so a CENTER
	# preset can never resize the panel through stale anchor offsets. The
	# width must be real at build time: an autowrapped label in a zero-width
	# panel locks to a 1 px wrap (one character per line).
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
	# A calm band across the board (END.L1) that never exceeds the 8-unit board
	# width and stays clamped inside the frame. An autowrapped label reports its
	# minimum size at a 1 px wrap (one character per line), so the panel is
	# measured from the text at its real width, never from that minimum.
	var style := _end_panel.get_theme_stylebox("panel") as StyleBoxFlat
	var inline := style.content_margin_left + style.content_margin_right
	var block := style.content_margin_top + style.content_margin_bottom
	var label: Label = _end_panel.get_node("EndLabel")
	var max_width := FRAME_SIZE.x - 2.0 * END_PANEL_MARGIN  # full frame when needed
	var panel_width := max_width
	var text_height := 64.0
	var font := label.get_theme_font("font")
	if font != null:
		var font_size := label.get_theme_font_size("font_size")
		var text_width := font.get_string_size(
			label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		# Short results stay on one line; long ones wrap inside the frame.
		panel_width = clampf(text_width + inline, 0.0, max_width)
		text_height = maxf(64.0, font.get_multiline_string_size(
			label.text, HORIZONTAL_ALIGNMENT_LEFT, panel_width - inline, font_size).y)
	# Match the label's pinned wrap width to this panel (see _setup_end_panel).
	label.custom_minimum_size = Vector2(panel_width - inline, 0.0)
	var panel_size := Vector2(panel_width, text_height + block)
	var centered := (FRAME_SIZE - panel_size) / 2.0
	var lo := Vector2.ONE * END_PANEL_MARGIN
	var hi := (FRAME_SIZE - panel_size - lo).max(lo)
	_end_panel.position = centered.clamp(lo, hi)
	_end_panel.size = panel_size


func _is_autodrive() -> bool:
	# GUI display tools in Godot include "X11", "Wayland", "macOS", "Windows",
	# "Embedded window", etc.; headless runs report "headless". A real window
	# with DEMO_AUTODRIVE=1 drives the same script.
	return DisplayServer.get_name() == "headless" or OS.get_environment(AUTODRIVE) == "1"


func _new_game() -> void:
	# L-two-player-game.K1: orthodox opening, White is to move.
	pos = DemoChessRules.start_position()
	DemoChessRules.init_king(pos)
	ended = false
	rule_end = ""
	selection = -1
	legal_to = []
	_pending_promo = ""
	_pending_move = {}
	if _end_panel != null:
		_end_panel.visible = false
	view.setup_position(pos)
	view.clear_selection()
	view.set_check_rim(-1)
	view.hide_promo_choice()
	_update_chip()


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
				_new_game()  # K3-like: begin another game after the result
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
	var index := DemoBoardView.index_from_unit(view.unit_at(screen))
	_drag_moved = false
	_press = index
	if index < 0:
		return
	# I11: only the side to move may move; an illegal attempt changes nothing.
	var board: PackedStringArray = pos["board"]
	if board[index] != "" and DemoChessRules.piece_color(board[index]) == str(pos["side"]):
		selection = index
		legal_to = DemoChessRules.legal_moves(pos, index)
		view.start_drag(index)
		view.set_selection(index, _targets_of(legal_to, false), _targets_of(legal_to, true))
		_cue("select")  # SND.X1 on piece selection


func _release_at(screen: Vector2) -> void:
	var dest := DemoBoardView.index_from_unit(view.unit_at(screen))
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
			return  # a plain tap of the selected piece keeps the selection
		_execute_move(target["move"])  # B10: tap or drop on a legal destination
		return
	if _drag_moved:
		# B11/PHY.M5: a bad drop returns and deselects; the square flashes (PER.R8).
		view.clear_selection()
		selection = -1
		view.return_piece(pressed)
		view.flash_reject(dest if dest >= 0 else pressed)
		return
	if dest != pressed:
		# B8/B9: pressing a non-destination square deselects (IN.deselect).
		view.clear_selection()
		selection = -1


func _pick_promo_at(unit_pos: Vector2) -> void:
	# I33: the player picks the promotion type; the move then completes (I34).
	var kind := view.promo_kind_at(unit_pos)
	if kind == "":
		return
	view.hide_promo_choice()
	_cue("select")
	_pending_promo = kind
	_finish_promoted_move()


func _execute_move(move: Dictionary) -> void:
	# I33/I34: a promotion waits for the chosen type before it completes.
	var promo := str(move["promo"])
	if promo != "":
		_pending_move = move
		view.show_promo_choice(int(move["to"]), str(pos["side"]))
		if _pending_promo != "":
			_finish_promoted_move()
		return
	_commit(move, promo)


func _finish_promoted_move() -> void:
	var move: Dictionary = _pending_move
	move["promo"] = _pending_promo
	_pending_promo = ""
	_commit(move, str(move["promo"]))


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


func _commit(move: Dictionary, promo: String) -> void:
	var from := int(move["from"])
	var to := int(move["to"])
	var capture_index := int(move["capture"])
	var started := Time.get_ticks_msec()
	if int(move["rook_from"]) >= 0:
		# PHY.M4: king and rook travel concurrently on their own end squares.
		view.castle_move(from, to, int(move["rook_from"]), int(move["rook_to"]))
	else:
		view.move_piece(from, to, capture_index, promo)
	pos = DemoChessRules.apply(pos, move)
	selection = -1
	legal_to = []
	view.clear_selection()
	_update_state(move, started)


func _update_state(move: Dictionary, started: int) -> void:
	var elapsed := Time.get_ticks_msec() - started
	print("[demo] move %s%s done in %d ms (budget 150 ms)" % [
		DemoChessRules.square_name(int(move["from"])),
		DemoChessRules.square_name(int(move["to"])),
		elapsed,
	])
	_cue("land")  # SND.X2: the settle cue ends with the travel (PHY.M1)
	var side: String = str(pos["side"])
	if DemoChessRules.in_check(pos, side):
		# I7 + PER.R6: persistent PAL.C8 rim on the checked king side; SND.X3.
		_cue("check")
		view.set_check_rim(DemoChessRules.king_square(pos, side))
	else:
		view.set_check_rim(-1)
	rule_end = DemoChessRules.result(pos)
	if rule_end != "":
		ended = true
		_cue("end")  # SND.X4: the end cue (L1/E1 resolve)
		_show_end()
		print("[demo] game ended: %s" % _end_text())
	_update_chip()


func _run_autodrive() -> void:
	## Headless exercise + checkmate ending; fails loudly on a scripted illegal move.
	print("[demo] autodrive begin")
	var problems: PackedStringArray = PackedStringArray()
	# FRM.P1/P2: every body drawn inside the SPC.E1 extent, King tallest.
	problems.append_array(_body_problems())
	# PER.R7: every coordinate label inside its band, so none of its ink lands
	# on the 1.28:1 table margin (defect #592), at the UIS.T2 size (defect #427
	# rework: the face had been shrunk to 6.5 px to fit the band).
	problems.append_array(view.measure_typography())
	problems.append_array(view.measure_coord_labels())
	await _run_scenarios(EXERCISE, problems, "exercise")
	print("[demo] exercise complete")
	await _capture("exercise")
	# PER.R7 rendered ink: before a mate ends the game, because the end panel and
	# its resolve cue stay out of this probe.
	problems.append_array(await _rendered_coord_problems())
	_new_game()
	await _run_scenarios(MATE, problems, "mate")
	if rule_end != "checkmate:w":
		problems.append(String("expected checkmate:w, got %s" % rule_end))
	print("[demo] travelled budget: every command completed as scripted")
	_check_end_panel(problems)
	await _capture("mate")
	_bed_player.stop()
	if problems.is_empty():
		print("[demo] PASS")
		get_tree().quit(0)
	else:
		for problem in problems:
			print("[demo] FAIL: %s" % problem)
		get_tree().quit(1)


func _rendered_coord_problems() -> Array:
	# PER.R7, measured on rendered pixels: hide everything but the board and its
	# coordinates, then assert the cream ink lands in the two wooden bands and
	# never inside the 8x8. The graphical autodrive measures the frame itself; a
	# headless run has no framebuffer, so with DEMO_COORD_PROBE=1 it renders the
	# board into a SubViewport and measures that image.
	if DisplayServer.get_name() == "headless":
		if OS.get_environment("DEMO_COORD_PROBE") != "1":
			print("[demo] rendered coordinate probe skipped: headless; set DEMO_COORD_PROBE=1 to render it")
			return []
		return await _offscreen_coord_problems()
	var chip_panel := chip.get_parent() as CanvasItem
	var restore: Array = []
	for node in [chip_panel, _end_panel]:
		if node != null and node.visible:
			node.visible = false
			restore.append(node)
	view.set_coord_probe_visibility(true)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	view.set_coord_probe_visibility(false)
	for node in restore:
		(node as CanvasItem).visible = true
	return view.coord_ink_problems(image)


## A headless build runs the dummy renderer, so it cannot read a texture back. The
## probe then writes the board's drawing instead — the glyph boxes of every
## coordinate label in frame pixels (the font size is final, so these are the ink
## boxes the renderer gets) and the drawn coordinate bands — and the evidence
## tooling (docs/playtest/evidence/issue-63/check_coord_probe.py) applies the same
## PER.R7 rules to it. The graphical autodrive measures real pixels instead.
func _offscreen_coord_problems() -> Array:
	var path := OS.get_environment("DEMO_COORD_PROBE_OUT")
	if path == "":
		path = "user://demo-shared-game-coord-probe.txt"
	var coords := view.get_node_or_null(NodePath("Coordinates")) as Control
	if coords == null:
		return ["coordinate labels are not built"]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ["coordinate probe cannot write %s" % path]
	# The label node maps its canvas pixels into board units (`scale`) and sits at
	# `position` in the board's units; the board maps units into the frame.
	var to_frame := view.get_global_transform() * Transform2D(0.0, coords.position) \
		* Transform2D(0.0, Vector2.ZERO).scaled(coords.scale)
	file.store_line("frame %.1f %.1f" % [FRAME_SIZE.x, FRAME_SIZE.y])
	file.store_line("square %.1f %.1f %.1f %.1f" % [
		BOARD_ORIGIN.x, BOARD_ORIGIN.y, BOARD_ORIGIN.x + 8.0 * UNIT, BOARD_ORIGIN.y + 8.0 * UNIT,
	])
	for spot in DemoBoardView.CoordLabels.spots():
		var text: String = spot["text"]
		var at: Vector2 = to_frame * (spot["at"] as Vector2)
		var box := DemoBoardView.CoordLabels.text_rect(
			view.font_resource, text, at, coords.font_px * to_frame.get_scale().y)
		file.store_line("ink %s %s %.3f %.3f %.3f %.3f" % [
			text, spot["band"], box.position.x, box.position.y, box.end.x, box.end.y,
		])
	for band_name in ["BevelLipLeftInk", "BevelLipBottomInk"]:
		var band := view.get_node_or_null(NodePath(band_name)) as Polygon2D
		if band == null:
			continue
		var poly := band.get_global_transform() * band.polygon
		var lo := Vector2(INF, INF)
		var hi := Vector2(-INF, -INF)
		for point in poly:
			lo = Vector2(minf(lo.x, point.x), minf(lo.y, point.y))
			hi = Vector2(maxf(hi.x, point.x), maxf(hi.y, point.y))
		file.store_line("band %s %.3f %.3f %.3f %.3f" % [band_name, lo.x, lo.y, hi.x, hi.y])
	file.close()
	print("[demo] coordinate probe drawing written to %s" % path)
	return []


func _body_problems() -> PackedStringArray:
	# SPC.E1 / FRM.P1-P2: the measured body extents, as printed for the record.
	var out: PackedStringArray = PackedStringArray()
	for problem in view.measure_piece_bodies():
		out.append(str(problem))
	return out


func _check_end_panel(problems: PackedStringArray) -> void:
	# The end panel is an in-board overlay: inside the frame, clear of the
	# player-side margins, and above every board layer (defect #456).
	var rect := Rect2(_end_panel.position, _end_panel.size)
	if not Rect2(Vector2.ZERO, FRAME_SIZE).encloses(rect):
		problems.append("end panel %s escapes the %s frame" % [rect, FRAME_SIZE])
	var board_bottom := BOARD_ORIGIN.y + 8.0 * UNIT
	var margin_top := rect.position.y - BOARD_ORIGIN.y
	var margin_bottom := board_bottom - rect.end.y
	if minf(margin_top, margin_bottom) < UNIT:
		problems.append("end panel %s enters a player-side margin (top %.0f, bottom %.0f)" % [
			rect, margin_top, margin_bottom,
		])
	if rect.size.x > FRAME_SIZE.x - 2.0 * END_PANEL_MARGIN:
		problems.append("end panel width %.0f exceeds the frame inset" % rect.size.x)
	var top_board_layer := 6  # a piece mid-travel (board_view.gd move_piece)
	for node in view.get_children():
		if node is Node2D:
			top_board_layer = maxi(top_board_layer, (node as Node2D).z_index)
	if _end_panel.z_index <= top_board_layer:
		problems.append("end panel z %d draws under the board (layer %d)" % [
			_end_panel.z_index, top_board_layer,
		])
	var label: Label = _end_panel.get_node("EndLabel")
	if label.size.x > rect.size.x + 0.5 or label.size.y > rect.size.y + 0.5:
		problems.append("end label %s overflows its panel %s" % [label.size, rect.size])
	print("[demo] end panel %s inside the frame; margins %.0f/%.0f; z %d" % [
		rect, margin_top, margin_bottom, _end_panel.z_index,
	])


func _capture(tag: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var frame := get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var dir := OS.get_environment("DEMO_SHOT_DIR")
	if dir == "":
		dir = OS.get_user_data_dir()
	var path := dir.path_join("demo-shared-game-%s.png" % tag)
	image.save_png(path)
	print("[demo] screenshot %s -> %s" % [tag, path])



func _run_scenarios(commands: Array, problems: PackedStringArray, label: String) -> void:
	for command in commands:
		await _run_command(command, problems, label)


func _run_command(command: Dictionary, problems: PackedStringArray, label: String) -> void:
	if command.has("bad_drop"):
		var squares: Array = command["bad_drop"]
		await _bad_drop(str(squares[0]), str(squares[1]))
		return
	var uci := str(command["move"])
	var from := DemoChessRules.square_index(uci.substr(0, 2))
	var to := DemoChessRules.square_index(uci.substr(2, 4))
	var matches := DemoChessRules.legal_moves(pos, from).filter(func(mv: Dictionary) -> bool:
		return int(mv["to"]) == to and int(mv["from"]) == from
	)
	if matches.is_empty():
		problems.append(String("illegal scripted %s move %s (side %s)" % [label, uci, str(pos["side"])]))
		print("[demo] FAIL illegal scripted move %s; stop" % uci)
		return
	var move: Dictionary = matches[0]
	var board_before: PackedStringArray = pos["board"].duplicate()
	if str(move["promo"]) != "":
		# Scripted promotion opens the chooser and picks the queen like a player,
		# so the chooser is dismissed too (leaving it open swallowed the move
		# after the promotion).
		_press_at(_screen_of_index(from))
		await _quiet(0.3)
		_execute_move(move)  # opens the chooser (I33)
		await _quiet(0.45)
		view.hide_promo_choice()
		_pending_promo = "q"
		_finish_promoted_move()
	else:
		_press_at(_screen_of_index(from))
		await _quiet(0.35)
		if int(move["rook_from"]) >= 0:
			_commit(move, "")
		else:
			var target := _legal_move_to(to)
			if target["succ"]:
				_execute_move(target["move"])
	await _quiet(0.8)
	# A scripted move that never reached the board must fail the run, not pass
	# silently (input gating such as a still-open chooser used to swallow one).
	if pos["board"] == board_before:
		problems.append(String("scripted %s move %s never executed" % [label, uci]))
		print("[demo] FAIL scripted move %s had no effect" % uci)


func _bad_drop(from_name: String, to_name: String) -> void:
	var from := DemoChessRules.square_index(from_name)
	var to := DemoChessRules.square_index(to_name)
	_press_at(_screen_of_index(from))
	await _quiet(0.3)
	view.drag_to(view.unit_at(_screen_of_index(to)))
	_drag_moved = true
	await _quiet(0.3)
	_release_at(_screen_of_index(to))
	await _quiet(0.6)
	print("[demo] refused bad drop %s -> %s (PHY.M5 return + PER.R8 flash)" % [from_name, to_name])
	selection = -1


func _screen_of_index(index: int) -> Vector2:
	var c := DemoBoardView.square_center(index)
	return BOARD_ORIGIN + Vector2(c.x * UNIT, c.y * UNIT)


func _quiet(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
