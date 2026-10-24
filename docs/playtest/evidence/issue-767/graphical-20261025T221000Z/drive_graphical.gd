extends SceneTree
## #767 acceptance — graphical (`ENV.2`) run of the check cue built by this
## task's single gap row: `UI-shared-play.US2.7` (UX) judged on rendered frames,
## corroborating `PER.R6` `VS2.4` / `VS2.4b`.
##
## Same scenario as the headless run (`3.Qxf7+`, then `4.Kxf7`), driven through
## `SessionRouter.handle_input_commit` (the same play path the seats use) so the
## board and the R2 chrome render from production state. Screenshots are this
## process's own rendered framebuffer at 720 × 1280 (9:16, `CAM-board Web`); the
## host denies Screen Recording to the automation process (the #617/#753 method).

var pres: Control
var router: SessionRouter
var seams: PlaytestSeams
var board: BoardPresentation
var failures: Array[String] = []
var shots: Array = []
const OUT_DIR := "res://../docs/playtest/evidence/issue-767/graphical-20261025T221000Z"


func _initialize() -> void:
	_run.call_deferred()
	_watchdog()


func _watchdog() -> void:
	await create_timer(180.0).timeout
	print("STEP WATCHDOG_TIMEOUT")
	quit(3)


func log_line(s: String) -> void:
	print("STEP %s" % s)


func check(ok: bool, label: String) -> void:
	log_line("%s %s" % ["ok:" if ok else "FAIL:", label])
	if not ok:
		failures.append(label)


func _settle(frames: int = 10) -> void:
	for i in frames:
		await process_frame


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(720, 1280))
	var packed := load("res://main.tscn") as PackedScene
	pres = packed.instantiate() as Presentation
	var harness := pres.get_node("PlaytestHarness")
	pres.remove_child(harness)
	harness.free()
	router = pres.get_node("SessionRouter") as SessionRouter
	seams = pres.get_node("PlaytestSeams") as PlaytestSeams
	router.locale = "en"
	router.last_mode = "none"
	var persist := pres.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(pres)
	await _settle(120)
	board = pres.get_node("ScreenHost/BoardPresentation") as BoardPresentation
	seams.set_overlay(false, PackedStringArray())
	# The debug panel is a playtest affordance, not product chrome: hide it so the
	# rendered frames show the screen a player sees (DBG.4 overlay stays off).
	var debug_panel := seams.get_node_or_null("PlaytestDebug/DebugPanel") as Control
	if debug_panel != null:
		debug_panel.visible = false
	# ENV.2 / #708 — pin the frame to the window's own px (9:16, CAM-board Web) so
	# "1/12 frame height" is measured against the frame that renders.
	var applied: Dictionary = seams.set_viewport(720, 1280, 1.0)
	await _settle(60)
	log_line("frame applied=%s frame_h=%s viewport=%s window=%s" % [
		str(applied.get("applied")), str(applied.get("frame_height_px")),
		str(root.get_visible_rect().size), str(DisplayServer.window_get_size()),
	])
	log_line("boot godot=%s display=%s playtest_build=%s session=%s" % [
		Engine.get_version_info().string,
		DisplayServer.get_name(),
		str(PlaytestGate.is_playtest()),
		seams.session_id,
	])

	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")  # untimed
	await _settle(40)
	check(router.stage == "shared-play", "entered shared-play (stage=%s)" % router.stage)

	var play := pres.get_node("ScreenHost/SharedPlay") as SharedPlayPanel
	var chip := play.find_child("CheckChip", true, false) as PanelContainer
	var label := play.find_child("CheckCue", true, false) as Label
	var marks := board.get_node_or_null("World/Seat/Content/Overlays/CheckMarks") as CheckMarks
	if chip == null or label == null or marks == null:
		check(false, "PER.R6 check cue missing from the scene")
		_finish()
		return

	# ---- VS2.4b / US2.4: side to move, NOT in check
	await _settle(20)
	await _shot("01-ready-not-in-check")
	check(not chip.visible, "VS2.4b chip hidden when not in check")
	check(marks.get_child_count() == 0, "VS2.4b no board mark when not in check")
	var status := _find_label_with(play, "White to move")
	check(status != null, "R2 status label present")
	var frame_h := UiChrome.frame_height_of(pres)
	if status != null:
		log_line("status text='%s' rect=%s frame_h=%.0f floor=%.1f" % [
			status.text, str(status.get_global_rect()), frame_h, frame_h / 12.0
		])
		check(_in_frame(status), "VS2.4b side-to-move indicator inside the frame")
		check(
			status.get_global_rect().size.y >= frame_h / 12.0,
			"VS2.4b indicator >= 1/12 frame height (%.1f >= %.1f)" % [
				status.get_global_rect().size.y, frame_h / 12.0
			]
		)

	for move in [["e2", "e4"], ["e7", "e5"], ["d1", "h5"], ["b8", "c6"]]:
		var landed: bool = router.handle_input_commit(str(move[0]), str(move[1]))
		check(landed, "move %s-%s accepted" % [move[0], move[1]])
		await _settle(10)
	var gave_check: bool = router.handle_input_commit("h5", "f7")
	await _settle(30)
	await _shot("02-white-gives-check")
	check(gave_check, "3.Qxf7+ accepted")
	check(str(router.side_to_move()) == "black", "Black is side to move after the check")
	check(chip.visible and label.visible, "US2.7 R2 shows the check cue while in check")

	var style := chip.get_theme_stylebox("panel") as StyleBoxFlat
	var chip_bg := style.bg_color if style != null else Color.TRANSPARENT
	var rendered_rect := chip.get_global_rect()
	log_line("rendered chip rect=%s label rect=%s text='%s' lines=%d bg=%s border=%s ratio=%.2f frame_h=%.0f" % [
		str(rendered_rect), str(label.get_global_rect()), label.text, label.get_line_count(),
		chip_bg.to_html(false),
		style.border_color.to_html(false) if style != null else "-",
		_contrast_ratio(label.get_theme_color("font_color"), chip_bg),
		frame_h,
	])
	check(_in_frame(chip), "US2.7 the check cue is inside the frame")
	check(label.get_line_count() == 1, "US2.7 the word draws on one rendered line")
	check(rendered_rect.size.x + 0.5 >= label.get_combined_minimum_size().x, "US2.7 the chip fits the word")
	check(
		_contrast_ratio(label.get_theme_color("font_color"), chip_bg) >= 4.5,
		"PER.R6 check word >= 4.5:1"
	)
	log_line("board mark square='%s' strokes=%d" % [marks.marked_square, marks.get_child_count()])
	check(marks.marked_square == "e8", "PER.R6 the mark renders on the checked King (e8)")
	check(marks.get_child_count() == 2, "PER.R6 exactly one mark (2 L-frames)")
	# The mark must be in-frame and on the King's square on the rendered board.
	var king_px: Vector2 = board.world_to_screen(board.framed_center("e8"))
	var mark_px: Vector2 = board.world_to_screen(marks.position)
	log_line("king_square_px=%s mark_node_px=%s frame=%s" % [
		str(king_px), str(mark_px), str(Rect2(Vector2.ZERO, pres.size))
	])

	var verdict := seams.assert_telemetry([
		{"event": "shared.check", "outcome": "shown", "story_id": "UI-shared-play.US2"},
	])
	log_line("TEL verdict=%s matched=%s" % [
		str(verdict.get("verdict", "")), JSON.stringify(verdict.get("matched", []))
	])
	check(str(verdict.get("verdict", "")) == "pass", "TEL correlates shared.check shown -> UI-shared-play.US2")

	var answered: bool = router.handle_input_commit("e8", "f7")
	await _settle(30)
	await _shot("03-check-answered")
	check(answered, "4.Kxf7 accepted")
	check(not chip.visible and not label.visible, "US2.7 the cue clears when the check ends")
	check(marks.get_child_count() == 0, "PER.R6 the board mark clears when the check ends")

	# ---- a second cycle on the same build (repeatability)
	await _settle(10)
	_finish()


func _finish() -> void:
	log_line("SHOTS %s" % JSON.stringify(shots))
	log_line("FAILURES %s" % JSON.stringify(failures))
	log_line("DONE failures=%d" % failures.size())
	quit(0 if failures.is_empty() else 1)


func _find_label_with(node: Node, text: String) -> Label:
	for child in node.get_children():
		if child is Label and (child as Label).text == text:
			return child as Label
		var hit := _find_label_with(child, text)
		if hit != null:
			return hit
	return null


func _in_frame(control: Control) -> bool:
	return Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(control.get_global_rect())


func _shot(name: String) -> void:
	await _settle(10)
	var img := root.get_texture().get_image()
	if img == null:
		log_line("shot_failed %s no image" % name)
		failures.append("screenshot %s missing" % name)
		return
	var path := "%s/screenshots/%s.png" % [OUT_DIR, name]
	var err := img.save_png(path)
	shots.append(name)
	log_line("shot %s size=%s err=%d" % [name, str(img.get_size()), err])


static func _contrast_ratio(fg: Color, bg: Color) -> float:
	var a := _relative_luminance(fg)
	var b := _relative_luminance(bg)
	return (maxf(a, b) + 0.05) / (minf(a, b) + 0.05)


static func _relative_luminance(color: Color) -> float:
	return 0.2126 * _linear(color.r) + 0.7152 * _linear(color.g) + 0.0722 * _linear(color.b)


static func _linear(channel: float) -> float:
	if channel <= 0.03928:
		return channel / 12.92
	return pow((channel + 0.055) / 1.055, 2.4)
