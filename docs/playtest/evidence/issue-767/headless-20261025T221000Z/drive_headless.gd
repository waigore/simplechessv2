extends SceneTree
## #767 acceptance — headless (`ENV.1`) run of the check cue this task's single
## gap row built: `UI-shared-play.US2.7` (UX) and `PER.R6` via `VS2.4` / `VS2.4b`
## (view — out of playtest scope, read here only to corroborate `US2.7`).
##
## Judges only what a headless session can judge: state, copy, colours,
## wrapping, telemetry. Screenshots are the graphical run's job.
##
## Scenario: untimed Shared game, both seats moved by their own controls, then
## `3.Qxf7+` puts White's check on Black's King, and `4.Kxf7` answers it.
##
## Prints `STEP` lines and exits non-zero when a judged expectation fails.

var pres: Control
var router: SessionRouter
var seams: PlaytestSeams
var failures: Array[String] = []
const OUT_DIR := "res://../docs/playtest/evidence/issue-767/headless-20261025T221000Z"


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
	pres.set_deferred("size", Vector2(720, 1280))
	await _settle(90)
	seams.set_overlay(false, PackedStringArray())

	log_line("boot frame=%s godot=%s display=%s playtest_build=%s session=%s" % [
		str(root.get_visible_rect().size),
		Engine.get_version_info().string,
		DisplayServer.get_name(),
		str(PlaytestGate.is_playtest()),
		seams.session_id,
	])

	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")  # untimed
	await _settle(30)
	check(router.stage == "shared-play", "entered shared-play (stage=%s)" % router.stage)

	var play := pres.get_node("ScreenHost/SharedPlay") as SharedPlayPanel
	var board := pres.get_node("ScreenHost/BoardPresentation") as BoardPresentation
	var chip := play.find_child("CheckChip", true, false) as PanelContainer
	var label := play.find_child("CheckCue", true, false) as Label
	var marks := board.get_node_or_null("World/Seat/Content/Overlays/CheckMarks") as CheckMarks
	var overlays := board.get_node_or_null("World/Seat/Content/Overlays")
	check(chip != null and label != null, "PER.R6 chip + word present in R2")
	check(marks != null, "PER.R6 CheckMarks node present in Overlays")
	if chip == null or label == null or marks == null:
		_finish()
		return
	log_line("overlays_children=%s" % JSON.stringify(_child_names(overlays)))

	# ---- VS2.4b / US2.4: side to move, NOT in check — no PAL.C8 hue
	await _shot("01-ready-not-in-check")
	check(not chip.visible, "VS2.4b chip hidden when not in check")
	check(marks.get_child_count() == 0, "VS2.4b no board mark when not in check")
	var status := play.find_child("Status", true, false) as Label
	if status == null:
		status = _find_label_with(play, "White to move")
	check(status != null, "R2 status label present")
	if status != null:
		var row := status.get_parent() as Control
		log_line("status text='%s' size=%s row_h=%s frame_h=%s" % [
			status.text, str(status.size), str(row.size.y if row != null else -1.0),
			str(pres.size.y),
		])
		check(_in_frame(status), "VS2.4b side-to-move indicator inside the frame")

	# ---- drive the seats by their own moves (S1/S2 of PTU-shared-play)
	for move in [["e2", "e4"], ["e7", "e5"], ["d1", "h5"], ["b8", "c6"]]:
		var landed: bool = router.handle_input_commit(str(move[0]), str(move[1]))
		check(landed, "move %s-%s accepted" % [move[0], move[1]])
		await _settle(4)
	# 3.Qxf7+ — the checking capture
	var gave_check: bool = router.handle_input_commit("h5", "f7")
	await _settle(10)
	await _shot("02-white-gives-check")
	check(gave_check, "3.Qxf7+ accepted")
	check(str(router.side_to_move()) == "black", "Black is side to move after the check")

	var style := chip.get_theme_stylebox("panel") as StyleBoxFlat
	var chip_bg := style.bg_color if style != null else Color.TRANSPARENT
	var petal := CheckMarks.COLOR_CHECK
	var ratio := _contrast_ratio(label.get_theme_color("font_color"), chip_bg)
	log_line("check cue chip=%s label='%s' lines=%d style=%s bg=%s border=%s border_w=%s ratio=%.2f" % [
		str(chip.size), label.text, label.get_line_count(),
		"flat" if style != null else "none",
		chip_bg.to_html(false),
		style.border_color.to_html(false) if style != null else "-",
		str(style.border_width_left) if style != null else "-",
		ratio,
	])
	log_line("board mark square='%s' strokes=%d color=%s" % [
		marks.marked_square, marks.get_child_count(), petal.to_html(false)
	])

	# ---- US2.7: R2 shows the word Check and the PAL.C8 mark
	check(chip.visible and label.visible, "US2.7 R2 shows the check cue while in check")
	check(label.text == StringTable.shared_play("check", "en"), "US2.7 the word is the localized 'check' copy")
	check(style != null and style.border_color == CheckMarks.COLOR_CHECK, "US2.7 chip keylined in PAL.C8")
	check(style != null and style.border_width_left >= 1.5, "UIS.I1 chip keyline >= 1.5 px")
	check(ratio >= 4.5, "PER.R6 check word >= 4.5:1 on its chip (%.2f)" % ratio)
	check(label.get_line_count() == 1, "PER.R6 check word draws on one line")
	check(_readable(chip, label), "PER.R6 chip sized to the word (chip %.1f >= text %.1f)" % [
		chip.size.x, label.get_combined_minimum_size().x
	])
	# ---- the mark itself, on the checked King
	check(marks.marked_square == "e8", "PER.R6 the mark sits on the checked King (e8), got '%s'" % marks.marked_square)
	check(marks.get_child_count() == 2, "PER.R6 exactly one mark (2 L-frames), got %d" % marks.get_child_count())
	# On-screen stroke width: one square step in world units, measured through the
	# board's own transform, gives the px-per-unit the render uses.
	var a_px: Vector2 = board.world_to_screen(marks.position + Vector2.ZERO)
	var b_px: Vector2 = board.world_to_screen(marks.position + Vector2(1.0, 0.0))
	var px_per_unit := (b_px - a_px).length()
	var colors_ok := true
	var widths_ok := true
	var stroke_px := 0.0
	for child in marks.get_children():
		var line := child as Line2D
		if line == null or line.default_color != CheckMarks.COLOR_CHECK or line.points.size() != 3:
			colors_ok = false
		if line != null:
			stroke_px = line.width * px_per_unit
			if stroke_px < 1.5:
				widths_ok = false
	log_line("mark px_per_unit=%.2f stroke=%.2f px" % [px_per_unit, stroke_px])
	check(colors_ok, "PER.R6 every L-frame is PAL.C8 (non-audio, not hue-only: L form)")
	check(widths_ok, "PAL.K9 / UIS.I1 stroke >= 1.5 px on screen (%.2f px)" % stroke_px)
	check(overlays != null and overlays.get_node_or_null("CheckMark") == null, "one check mark only (no duplicate CheckMark node)")

	# ---- TEL: the check cue's own row, with its story id
	var verdict := seams.assert_telemetry([
		{"event": "shared.check", "outcome": "shown", "story_id": "UI-shared-play.US2"},
	])
	log_line("TEL verdict=%s matched=%s missing=%s" % [
		str(verdict.get("verdict", "")),
		JSON.stringify(verdict.get("matched", [])),
		JSON.stringify(verdict.get("missing", [])),
	])
	check(str(verdict.get("verdict", "")) == "pass", "TEL correlates shared.check shown -> UI-shared-play.US2")

	# ---- the mark and the cue clear with the check (4.Kxf7)
	var answered: bool = router.handle_input_commit("e8", "f7")
	await _settle(10)
	await _shot("03-check-answered")
	check(answered, "4.Kxf7 accepted")
	check(not chip.visible and not label.visible, "US2.7 the cue clears when the check ends")
	check(marks.get_child_count() == 0, "PER.R6 the board mark clears when the check ends")
	check(router.shared_session != null and not router.shared_session._in_check_now(), "no side to move is in check")

	_finish()


func _finish() -> void:
	log_line("FAILURES %s" % JSON.stringify(failures))
	log_line("DONE failures=%d" % failures.size())
	quit(0 if failures.is_empty() else 1)


func _child_names(node: Node) -> Array:
	var names := []
	if node == null:
		return names
	for child in node.get_children():
		names.append(str(child.name))
	return names


func _find_label_with(node: Node, text: String) -> Label:
	for child in node.get_children():
		if child is Label and (child as Label).text == text:
			return child as Label
		var hit := _find_label_with(child, text)
		if hit != null:
			return hit
	return null


func _in_frame(control: Control) -> bool:
	var rect := control.get_global_rect()
	var frame := Rect2(Vector2.ZERO, pres.size)
	return frame.encloses(rect)


func _readable(chip: PanelContainer, label: Label) -> bool:
	var floor_px := label.get_combined_minimum_size().x
	return label.size.x + 0.5 >= floor_px and chip.size.x + 0.5 >= floor_px


func _shot(name: String) -> void:
	## Headless has no framebuffer to capture; the graphical run writes the images.
	log_line("shot_waiting %s (headless: no display, graphical run writes it)" % name)


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
