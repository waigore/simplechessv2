extends SceneTree
## Acceptance probe for #794 — puzzle-play R2 must read on one line (Elo + all four cues).
## Drives the shipped scene through the real C2 control, injects deals via the test's DBG.3
## path (the seams build's catalog peer answers no read), measures every R2 label, and
## writes the frames. Throwaway harness; kept inside the evidence folder it produced.
##
##   godot --path game --resolution 1280x720 --script res://zz_accept794_probe.gd

const SHOT_DIR := "/tmp/opencode/accept794"
const MATE_FEN := "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1"
const MATE_OPPONENT_MOVE := "g8h8"
const MATE_RECORDED_MOVE := "b1b8"
const MATE_NON_MATING_MOVE := "b1b7"

var _main: Node
var _router: SessionRouter
var _panel: Node
var _shots := 0
var _problems: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate()
	# The harness quits the tree on a headless playtest boot (SEQ-playtest-headless-smoke);
	# drop it so the probe can drive the same build in both environments, as the test suite does.
	if DisplayServer.get_name() == "headless":
		var harness := _main.get_node_or_null("PlaytestHarness")
		if harness != null:
			_main.remove_child(harness)
			harness.free()
	root.add_child(_main)
	await _pump(8)
	_router = _main.get_node("SessionRouter") as SessionRouter
	_panel = _main.get_node("ScreenHost/PuzzlePlay")

	print("display=", DisplayServer.get_name())
	if _main.get_node_or_null("PlaytestHarness") != null:
		print(
			"viewport=", root.size,
			" playtest_build=", _main.get_node("PlaytestSeams").get("playtest_build")
		)
		print("session_id=", _main.get_node("PlaytestSeams").get("session_id"))
	print("build_fix_present=", _panel.has_method("_style_r2_line_labels"))

	# Real entry path: mode pick C2 → puzzle-play.
	_router.call("_go_mode_pick", "S1")
	await process_frame
	_router.handle_control("mode-pick", "C2")
	await _pump(6)
	if _router.stage != SessionRouter.STAGE_PUZZLE_PLAY:
		_problems.append("C2 did not enter puzzle-play")

	# Deal 1 — a mate-in-one: R2 Elo on deal, then cue_solved on a solve.
	_deal(_record("probe794", 1000, MATE_FEN, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE]))
	await _pump(6)
	print("state=on-deal text=", _ser(_elo_text()), " cue=", _ser(_cue_text()))
	_judge("PlayerElo (on deal)", "PlayerElo")
	_judge("ResultCue (on deal)", "ResultCue")
	await _shoot("r2-1280x720-on-deal.png")

	_router.handle_input_commit(MATE_RECORDED_MOVE.substr(0, 2), MATE_RECORDED_MOVE.substr(2, 2), "")
	await _pump(10)
	print("state=solved text=", _ser(_elo_text()), " cue=", _ser(_cue_text()))
	_judge("cue_solved", "ResultCue")
	await _shoot("r2-1280x720-solved.png")

	# Deal 2 — a non-mating place: cue_wrong.
	_deal(_record("probe794b", 1000, MATE_FEN, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE]))
	await _pump(6)
	_router.handle_input_commit(MATE_NON_MATING_MOVE.substr(0, 2), MATE_NON_MATING_MOVE.substr(2, 2), "")
	await _pump(8)
	print("state=wrong text=", _ser(_elo_text()), " cue=", _ser(_cue_text()))
	_judge("cue_wrong", "ResultCue")
	await _shoot("r2-1280x720-wrong.png")

	# Deal 3 — Reveal (C3 → confirm): cue_failed.
	_deal(_record("probe794c", 1000, MATE_FEN, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE]))
	await _pump(6)
	_router.handle_control("puzzle-play", "C3")
	await _pump(4)
	_router.handle_control("puzzle-play", "confirm")
	await _pump(8)
	print("state=failed text=", _ser(_elo_text()), " cue=", _ser(_cue_text()))
	_judge("cue_failed", "ResultCue")
	await _shoot("r2-1280x720-failed.png")

	# Deal 4 — Abandon (C4 → confirm → END.L6): cue_abandon.
	_deal(_record("probe794d", 1000, MATE_FEN, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE]))
	await _pump(6)
	_router.handle_control("puzzle-play", "C4")
	await _pump(4)
	_router.handle_control("puzzle-play", "confirm")
	await _pump(6)
	print("state=abandon text=", _ser(_elo_text()), " cue=", _ser(_cue_text()))
	_judge("cue_abandon", "ResultCue")
	await _shoot("r2-1280x720-abandoned.png")

	# Deal 5 — Leave (C5 → confirm) still returns to mode pick.
	_deal(_record("probe794e", 1000, MATE_FEN, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE]))
	await _pump(6)
	_router.handle_control("puzzle-play", "C5")
	await _pump(4)
	_router.handle_control("puzzle-play", "confirm")
	await _pump(6)
	var stage_after_abandon := _router.stage
	print("state=leave-returned_to_mode_pick=", stage_after_abandon == "mode-pick")
	if stage_after_abandon != "mode-pick":
		_problems.append("C5 leave did not return to mode pick")
	_router.handle_control("mode-pick", "C2")
	await _pump(6)
	_deal(_record("probe794f", 1000, MATE_FEN, [MATE_OPPONENT_MOVE, MATE_RECORDED_MOVE]))
	await _pump(6)

	# R3 / board regression: the R2 row must not displace the strip or the board.
	var strip := (_panel.find_child("PuzzleChrome", true, false) as Control).get_global_rect()
	var board := (_main.find_child("BoardPresentation", true, false) as Control).get_global_rect()
	print("strip=", strip, " board=", board)
	if strip.intersects(board):
		_problems.append("R3 strip overlaps the board")

	# S13 reflow: restyle at another text scale and re-measure Elo.
	_panel.call("_style_all")
	await _pump(4)
	_judge("PlayerElo (after _style_all reflow)", "PlayerElo")

	print("PROBLEMS=", _problems.size() if not _problems.is_empty() else 0)
	for p in _problems:
		print("  PROBLEM: ", p)
	print("VERDICT=", "pass" if _problems.is_empty() else "fail")
	quit(0)


## Measure one R2 label exactly as the defect defines it: one line, nothing per letter.
func _judge(what: String, node_name: String) -> void:
	var label := _panel.find_child(node_name, true, false) as Label
	if label == null:
		_problems.append("%s: label missing" % what)
		return
	var rect := label.get_global_rect()
	var minimum := label.get_combined_minimum_size()
	var font := label.get_theme_font("font")
	var px := label.get_theme_font_size("font_size")
	var need := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, px)
	print(
		"  ", what, " text=", _ser(label.text), " rect=", rect, " min=", minimum,
		" autowrap=", label.autowrap_mode, " align=", label.horizontal_alignment,
		" text_need=", need, " one_line=", rect.size.y <= px * 2.0,
		" wide_enough=", rect.size.x >= need.x
	)
	if label.autowrap_mode != TextServer.AUTOWRAP_OFF:
		_problems.append("%s: autowrap is %d, not off" % [what, label.autowrap_mode])
	if label.text.is_empty():
		return
	if rect.size.y > px * 2.0:
		_problems.append("%s: %.0f px tall for a %.0f px font (wrapped)" % [what, rect.size.y, px])
	if rect.size.x < need.x:
		_problems.append("%s: %.0f px wide, text needs %.0f" % [what, rect.size.x, need.x])
	if rect.size.x <= 2.0:
		_problems.append("%s: one letter wide (%.0f px)" % [what, rect.size.x])


func _elo_text() -> String:
	var label := _panel.find_child("PlayerElo", true, false) as Label
	return "" if label == null else label.text


func _cue_text() -> String:
	var label := _panel.find_child("ResultCue", true, false) as Label
	return "" if label == null else label.text


func _ser(s: String) -> String:
	return "\"%s\"" % s


func _shoot(name: String) -> void:
	# Headless has no renderer, so `frame_post_draw` never fires; the graphical run owns images.
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png("%s/%s" % [SHOT_DIR, name])
	_shots += 1


func _pump(n: int) -> void:
	for i in n:
		await process_frame


func _deal(rec: Dictionary) -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	if flow.session.has_open_puzzle():
		flow.session.leave()
	flow.session.deal([rec])
	_router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, flow.state())


func _record(id: String, rating: int, fen: String, moves: Array) -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": id,
		"fen": fen,
		"moves": moves,
		"rating": rating,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": [],
		"game_url": "",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}
