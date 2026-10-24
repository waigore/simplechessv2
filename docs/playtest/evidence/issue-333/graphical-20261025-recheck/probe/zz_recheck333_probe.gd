extends SceneTree
## Graphical re-check of #333 on current `main` (#793 / #794 / #795 re-run).
##
## Derived from docs/playtest/evidence/issue-333/graphical-20261024T150000Z/probe/.
## It adds no behaviour: it drives the shipped scene through the control path a player
## uses (mode-pick C2, panel buttons, board gestures through the router), reads the
## shipped state, samples frame times through the shipped `SIT.4` seam (O10), and
## writes screenshots. Throwaway harness, shipped inside the evidence folder it produced.

const SHOT_DIR := "/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/opencode/recheck333"

var _main: Node
var _seams: Node
var _router: SessionRouter
var _panel: PuzzlePlayPanel
var _presentation: Node
var _failures: Array[String] = []
var _timings: Array[Dictionary] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate()
	root.add_child(_main)
	await _pump(6)

	_seams = _main.get_node("PlaytestSeams")
	_router = _main.get_node("SessionRouter") as SessionRouter
	_presentation = _main
	_panel = _presentation.find_child("PuzzlePlay", true, false) as PuzzlePlayPanel

	print("display=", DisplayServer.get_name())
	print("playtest_build=", _seams.get("playtest_build"))
	print("session_id=", _seams.get("session_id"))
	print("main_size=", root.size)

	await _mode_pick_entry()
	await _screen_s1()
	await _frame_time_samples()
	await _leave_confirm_cancel_confirm()
	await _promotion_choice()
	await _refused_place()
	await _abandon_cue()
	await _save_failure()
	await _touch_targets()
	await _orientation()

	print("TIME_REPORTS=", JSON.stringify(_timings))
	print("FAILURES=", JSON.stringify(_failures))
	quit(0 if _failures.is_empty() else 1)


func _pump(frames: int) -> void:
	for i in frames:
		await process_frame


func _img() -> Image:
	return root.get_texture().get_image()


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var img := _img()
	img.save_png("%s/%s.png" % [SHOT_DIR, name])
	print("screenshot=", name, " size=", img.get_size())


func _check(ok: bool, label: String, detail: String = "") -> void:
	print("CHECK %s %s %s" % ["PASS" if ok else "FAIL", label, detail])
	if not ok:
		_failures.append(label + (" :: " + detail if not detail.is_empty() else ""))


## Pixels that differ inside `rect` between two grabs: a prompt that paints nothing
## scores 0 even though its node reports `visible=true` (#793).
func _diff_px(a: Image, b: Image, rect: Rect2) -> int:
	var r := Rect2i(
		Vector2i(maxi(0, int(rect.position.x)), maxi(0, int(rect.position.y))),
		Vector2i(int(rect.size.x), int(rect.size.y))
	)
	r = r.intersection(Rect2i(Vector2i.ZERO, a.get_size()))
	var count := 0
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if a.get_pixel(x, y) != b.get_pixel(x, y):
				count += 1
	return count


func _unique_colours(img: Image, rect: Rect2) -> int:
	var seen := {}
	var r := Rect2i(
		Vector2i(int(rect.position.x), int(rect.position.y)),
		Vector2i(int(rect.size.x), int(rect.size.y))
	)
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			seen[img.get_pixel(x, y).to_rgba32()] = true
	return seen.size()


## PTU-mode-pick S1/S3, PTU-navigation S2 — C2 row label and entry (NAV.T2).
func _mode_pick_entry() -> void:
	_router.call("_go_mode_pick", "S1")
	await _pump(6)
	var btn := _presentation.find_child("PuzzleStream", true, false) as Button
	_check(btn != null, "mode-pick S1 has C2 Puzzle stream")
	if btn == null:
		return
	var want := StringTable.mode_pick("puzzle", "en")
	_check(btn.text.begins_with(want), "C2 label is the mode-pick puzzle key", btn.text)
	_check(btn.size.y >= 44.0, "C2 is a 44px-class target", str(btn.size))
	await _shot("mode-pick-s1")
	_router.handle_control("mode-pick", "C2")
	await _pump(8)
	_check(
		_router.stage == SessionRouter.STAGE_PUZZLE_PLAY, "NAV.T2 C2 enters puzzle-play", _router.stage
	)
	_check(_panel != null and _panel.visible, "puzzle-play panel visible after C2")


## SIT.4 / PTU-puzzle-play S4 + P3 — frame times over a move, through the shipped seam
## (`start_measurement` / `measure`, O10). Three repeats; one sample is not evidence.
func _frame_time_samples() -> void:
	for i in 3:
		_deal(_mate_record())
		await _pump(4)
		var armed: Dictionary = _seams.call("start_measurement", "frame_times")
		if str(armed.get("status", "")) != "ok":
			_check(false, "SIT.4 window arms for the move", JSON.stringify(armed))
			return
		_router.handle_input_commit("b1", "", "")
		await _pump(1)
		_router.handle_input_commit("b1", "b8", "")
		await _pump(4)
		var report: Dictionary = _seams.call("measure", "frame_times")
		report["repeat"] = i + 1
		_timings.append(report)
		print(
			"time_repeat=",
			i + 1,
			" status=",
			report.get("status", ""),
			" samples=",
			report.get("sample_count", 0),
			" max_ms=",
			report.get("max_ms", 0.0)
		)
		_check(
			str(report.get("status", "")) == "ok" and int(report.get("sample_count", 0)) > 0,
			"SIT.4 frame-time report %d closed with samples" % (i + 1),
			JSON.stringify({"status": report.get("status"), "n": report.get("sample_count")})
		)
		if _router.stage == SessionRouter.STAGE_PUZZLE_PLAY:
			_router.handle_control("puzzle-play", "C5")
			await _pump(2)
			_router.handle_control("puzzle-play", "confirm")
			await _pump(4)
			_router.handle_control("mode-pick", "C2")
			await _pump(6)


func _deal(record: Dictionary) -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	if flow == null or flow.session == null:
		return
	if flow.session.has_open_puzzle():
		flow.session.leave()
	# Between attempts the cue window is down (K3 / cue-read path), so nothing
	# defers the next deal; a settled attempt keeps `advance()` for the cue read.
	flow.cue_key = ""
	var dealt: Dictionary = flow.session.deal([record])
	if not rec_ok(dealt):
		_check(false, "DBG.3 deal %s" % record.get("puzzle_id", "?"), str(dealt))
		return
	_router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, flow.state())


func _black_to_solve_record() -> Dictionary:
	var rec := _mate_record()
	rec["puzzle_id"] = "recheck333-orient-black"
	rec["fen"] = "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1"
	rec["moves"] = ["g8g7", "e1e8"]
	return rec


func rec_ok(result: Dictionary) -> bool:
	return bool(result.get("ok", false))


func _mate_record() -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": "recheck333-mate1",
		"fen": "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1",
		"moves": ["g8h8", "b1b8"],
		"rating": 1000,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": [],
		"game_url": "",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}


## PTU-puzzle-play S1/US2 — R1 + R2 + R3 on deal; #794's one-line R2 is measured.
func _screen_s1() -> void:
	_deal(_mate_record())
	await _pump(6)
	var elo := _panel.find_child("PlayerElo", true, false) as Label
	var cue := _panel.find_child("ResultCue", true, false) as Label
	var elo_copy := StringTable.puzzle_play("elo", "en")
	var want_elo := "%s %d" % [elo_copy, roundi(float(_panel.get("player_elo")))]
	_check(
		elo != null and elo.visible and elo.text == want_elo,
		"R2 shows playerElo (DIF.C1: no hand-set control)",
		elo.text if elo != null else "?"
	)
	if elo != null:
		print("r2_elo_rect=", elo.get_global_rect(), " text=", elo.text)
		_check(
			elo.size.x > elo.size.y,
			"#794 R2 Elo is one line, not a per-letter column",
			str(elo.size)
		)
		_check(
			elo.size.x >= elo.get_theme_font("font").get_string_size(elo.text, HORIZONTAL_ALIGNMENT_LEFT, -1, elo.get_theme_font_size("font_size")).x,
			"#794 R2 Elo text fits its box",
			str(elo.size)
		)
	_check(String(_panel.get("ui_state")) == "S1", "S1 play state on deal", str(_panel.get("ui_state")))
	print("solving_side=", _panel.get("solving_side"), " side_to_move=", _router.puzzle_flow.side_to_move())
	_check(cue != null, "R2 result cue node exists")
	await _shot("puzzle-play-s1")

	# CUES (#794): a cue renders on one line and carries the owner's copy.
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	_router.handle_input_commit("b1", "", "")
	await _pump(2)
	_router.handle_input_commit("b1", "b8", "")
	await _pump(4)
	var cue_text := StringTable.puzzle_play("cue_solved", "en")
	_check(String(_panel.get("cue_key")) == "cue_solved", "solved puzzle shows cue_solved", str(_panel.get("cue_key")))
	if cue != null:
		print("r2_cue_rect=", cue.get_global_rect(), " text=", cue.text)
		_check(cue.text == cue_text, "#794 result cue carries the owner copy", cue.text)
		_check(cue.size.x > cue.size.y, "#794 result cue is one line", str(cue.size))
	await _shot("puzzle-play-solved")


## PTU-puzzle-session S2/S3, PTU-navigation S2, PTU-exceptions S3 — leave confirm.
func _leave_confirm_cancel_confirm() -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	_deal(_mate_record())
	await _pump(4)
	var box := _panel.find_child("StreamConfirm", true, false) as Control
	_check(box != null, "S2 confirm node exists")
	if box == null:
		return
	var closed := _img()
	var rect := box.get_global_rect()
	print("confirm_box_rect=", rect)
	_router.handle_control("puzzle-play", "C5")
	await _pump(5)
	_check(String(_panel.get("ui_state")) == "S2", "C5 Leave asks confirm (S2)", str(_panel.get("ui_state")))
	var msg := _panel.find_child("StreamConfirmMsg", true, false) as Label
	print("stream_confirm_text=", msg.text if msg != null else "?")
	_check(
		msg != null and msg.text == StringTable.puzzle_play("leave_confirm", "en"),
		"S2 raises the named leave_confirm copy",
		msg.text if msg != null else "?"
	)
	await _shot("puzzle-play-s2-leave-confirm")
	var open_img := _img()
	var changed := _diff_px(closed, open_img, rect)
	print(
		"confirm_diff_px=", changed,
		" unique_colours_closed=", _unique_colours(closed, rect),
		" unique_colours_open=", _unique_colours(open_img, rect)
	)
	_check(changed > 0, "#793 the S2 confirm paints over the board", str(changed))
	_check(_unique_colours(open_img, rect) > 3, "#793 the S2 confirm draws text and a panel", str(_unique_colours(open_img, rect)))

	var elo_before := float(_panel.get("player_elo"))
	_panel.find_child("CancelStream", true, false).pressed.emit()
	await _pump(5)
	_check(_router.stage == SessionRouter.STAGE_PUZZLE_PLAY, "S2 cancel stays on puzzle-play", _router.stage)
	_check(String(_panel.get("ui_state")) == "S1", "S2 cancel returns to S1")
	_check(flow.session != null, "S2 cancel keeps the puzzle open")
	_check(
		is_equal_approx(float(_panel.get("player_elo")), elo_before),
		"S2 cancel does not score the open puzzle"
	)
	await _shot("puzzle-play-s2-cancelled")

	_router.handle_control("puzzle-play", "C5")
	await _pump(3)
	_panel.find_child("ConfirmStream", true, false).pressed.emit()
	await _pump(6)
	_check(_router.stage == SessionRouter.STAGE_MODE_PICK, "leave confirm → mode-pick", _router.stage)
	await _shot("mode-pick-after-leave")
	_router.handle_control("mode-pick", "C2")
	await _pump(8)
	_check(_router.stage == SessionRouter.STAGE_PUZZLE_PLAY, "C2 re-enters the stream")


## PTU-puzzle-play S6/US3 — S4 names (#795) and the C6 commit.
func _promotion_choice() -> void:
	var rec := _mate_record()
	rec["puzzle_id"] = "recheck333-promote"
	rec["fen"] = "k7/6P1/8/8/8/8/8/7K b - - 0 1"
	rec["moves"] = ["a8b8", "g7g8q"]
	_deal(rec)
	await _pump(4)
	var row := _panel.find_child("PromotionRow", true, false) as Control
	var closed := _img()
	_router.handle_input_commit("g7", "", "")
	await _pump(2)
	_router.handle_input_commit("g7", "g8", "")
	await _pump(5)
	_check(String(_panel.get("ui_state")) == "S4", "last-rank place enters S4", str(_panel.get("ui_state")))
	await _shot("puzzle-play-s4-promotion")
	var open_img := _img()
	# The chooser's own paint: each name's ink over the strip, closed → open.
	for kind in PuzzleSession.PROMOTE_ORDER:
		var nl := _panel.find_child("PromoteName%s" % kind.capitalize(), true, false) as Label
		if nl == null:
			continue
		var nr := nl.get_global_rect()
		var ink := _diff_px(closed, open_img, nr)
		print("promote_name_in_rect=", kind, " rect=", nr, " diff_px=", ink, " unique=", _unique_colours(open_img, nr))
		_check(ink > 0, "#795 the S4 %s label paints" % kind, str(ink))
	for kind in PuzzleSession.PROMOTE_ORDER:
		var name_label := _panel.find_child("PromoteName%s" % kind.capitalize(), true, false) as Label
		_check(name_label != null, "#795 %s name label exists" % kind)
		if name_label == null:
			continue
		print("promote_name=", kind, " rect=", name_label.get_global_rect(), " text=", name_label.text)
		_check(
			name_label.visible and not name_label.text.is_empty(),
			"#795 %s name is visible copy" % kind,
			name_label.text
		)
		_check(
			name_label.size.y > 0.0 and name_label.size.x >= name_label.get_theme_font("font").get_string_size(
				name_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, name_label.get_theme_font_size("font_size")
			).x,
			"#795 %s name is not clipped" % kind,
			str(name_label.size)
		)
	var committed: bool = _router.handle_promotion_commit("queen")
	await _pump(4)
	_check(committed, "C6 queen commit succeeds")
	await _shot("puzzle-play-after-promotion")


## PTU-puzzle-play S7 / PTU-exceptions S2 — rules-refused place → S5, no wrong cue.
func _refused_place() -> void:
	_deal(_mate_record())
	await _pump(4)
	_router.handle_input_commit("g1", "", "")
	await _pump(2)
	_router.handle_input_commit("g1", "g2", "")
	await _pump(4)
	print("refused_ui_state=", _panel.get("ui_state"), " cue=", _panel.get("cue_key"))
	_check(String(_panel.get("ui_state")) == "S5", "a refused place enters S5", str(_panel.get("ui_state")))
	_check(String(_panel.get("cue_key")) != "cue_wrong", "a refused place is not a wrong move")
	var status := _panel.find_child("PuzzleStatus", true, false) as Label
	if status != null:
		print("s5_status_text=", status.text, " rect=", status.get_global_rect())
	await _shot("puzzle-play-s5-refused")
	_router.finish_reject_flash()
	await _pump(3)


## PTU-puzzle-play S8 — confirm Abandon → cue_abandon (END.L6).
func _abandon_cue() -> void:
	var box := _panel.find_child("StreamConfirm", true, false) as Control
	var closed := _img() if box != null else null
	_router.handle_control("puzzle-play", "C4")
	await _pump(4)
	print("abandon_confirm_kind=", _panel.get("confirm_kind"))
	await _shot("puzzle-play-s2-abandon-confirm")
	if box != null:
		var rect := box.get_global_rect()
		var changed := _diff_px(closed, _img(), rect)
		_check(changed > 0, "#793 the Abandon confirm paints too", str(changed))
	_router.handle_control("puzzle-play", "confirm")
	await _pump(5)
	print("abandon_ui_state=", _panel.get("ui_state"), " cue=", _panel.get("cue_key"))
	_check(String(_panel.get("cue_key")) == "cue_abandon", "confirming Abandon shows cue_abandon", str(_panel.get("cue_key")))
	await _shot("puzzle-play-abandoned")


## EX.save-failure / PTU-exceptions — S3 paints, C1–C5 stay usable, Dismiss → S1.
func _save_failure() -> void:
	_deal(_mate_record())
	await _pump(4)
	var box := _panel.find_child("SaveFailure", true, false) as Control
	if box == null:
		_check(false, "S3 SaveFailure node exists")
		return
	var closed := _img()
	var rect := box.get_global_rect()
	print("save_box_rect=", rect)
	var store := _main.get_node("PersistStore") as PersistStore
	store.force_write_failure = true
	_router.handle_input_commit("b1", "", "")
	await _pump(2)
	_router.handle_input_commit("b1", "b8", "")
	await _pump(6)
	print("save_failure_visible=", box.visible, " ui_state=", _panel.get("ui_state"))
	_check(box.visible, "the store's write failure raises S3")
	await _shot("puzzle-play-s3-save-failure")
	var changed := _diff_px(closed, _img(), rect)
	print("save_diff_px=", changed, " unique_colours_open=", _unique_colours(_img(), rect))
	_check(changed > 0, "#793 the S3 save-failure prompt paints", str(changed))
	_check(_panel.control_available("C5"), "C5 stays usable in S3")
	_panel.find_child("DismissSave", true, false).pressed.emit()
	await _pump(5)
	await _shot("puzzle-play-after-dismiss")


## controls.md F1 — every control is a 44px-class touch target.
func _touch_targets() -> void:
	for node_name in ["Reveal", "Abandon", "LeaveStream", "ConfirmStream", "CancelStream", "DismissSave"]:
		var btn := _panel.find_child(node_name, true, false) as Button
		if btn == null:
			print("touch_target=", node_name, " missing")
			continue
		print("touch_target=", node_name, " size=", btn.size)
	for control_id in ["C3", "C4", "C5"]:
		var btn: Button = _panel.button_for(control_id)
		_check(btn != null and btn.size.y >= 44.0, "%s is a 44px-class target" % control_id, str(btn.size) if btn else "?")


## R1 orientation — CAM-board.M2: Solving side Black → 180°, White → 0°.
## Driven the way `game/puzzle_play_test.gd` deals: the presentation reads
## `state()["solving_side"]`, which the session already sets to the side to move
## after the record's opening move.
func _orientation() -> void:
	# White leg: the delivered record the screen is already showing is White to
	# solve (the mate fixture's own first move is Black's), so read that one.
	_router.handle_control("puzzle-play", "C5")
	await _pump(3)
	_router.handle_control("puzzle-play", "confirm")
	await _pump(5)
	_router.handle_control("mode-pick", "C2")
	await _pump(8)
	_deal(_mate_record())
	await _pump(6)
	var flow_w: PuzzlePlayFlow = _router.puzzle_flow
	var side_w := str(flow_w.session.play_state().get("solving_side", ""))
	var board_w := _presentation.find_child("BoardPresentation", true, false) as Node
	var seat_w := str(board_w.get("white_seat")) if board_w != null else "?"
	print("orientation_leg=white solving_side=", side_w, " white_seat=", seat_w)
	_check(side_w == "white", "R1 solving side is white (mate fixture)", side_w)
	_check(
		seat_w == BoardGeometry.SEAT_BOTTOM,
		"R1 board faces the solving side (white)",
		seat_w
	)
	await _shot("puzzle-play-orientation-white")
