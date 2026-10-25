extends SceneTree
## Verification probe for #546 (SIT.6 / S13 / O12) — written by the verify pass,
## independent of the implementor's or acceptance run's probe.
##
## It drives the seam the way the debug-panel control does (a live window resize),
## then reads the seam report and the shipped mode-pick layout: every visible
## string's resolved font size, whether it is clipped, and whether any playtest
## chrome stands over the mode-pick panel. It adds no behaviour.
##
## Run on a graphical display (the engine only loads `res://`-relative paths, so
## copy the probe into `game/`, run it, then delete the copy):
##   cp docs/playtest/evidence/issue-546/headless-20261025T220000Z/probe/zz_verify546_probe.gd game/
##   godot --path game --script zz_verify546_probe.gd
##   rm game/zz_verify546_probe.gd game/zz_verify546_probe.gd.uid
## (log captured in ../logs/graphical-probe.log)

const OUT_DIR := "docs/playtest/evidence/issue-546/headless-20261025T220000Z/screenshots"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var seams: Node = main.get_node("PlaytestSeams")
	var panel: Node = main.get_node("ScreenHost/ModePick")
	(main as Presentation).show_screen(Presentation.MODE_PICK, {"ui_state": "S1"})
	await process_frame

	print("PROBE display=", DisplayServer.get_name())
	print("PROBE playtest_build=", seams.get("playtest_build"))
	print("PROBE window_before=", DisplayServer.window_get_size())
	print("PROBE content_scale_mode_before=", root.content_scale_mode)

	## AC1 — invalid input returns no report, and a repeated call is stable.
	var zero: Dictionary = seams.call("set_viewport", 0, 844, 1.0)
	print("PROBE invalid_input_report_empty=", zero.is_empty())
	var first: Dictionary = seams.call("set_viewport", 390, 844, 1.0)
	await _pump(20)
	var second: Dictionary = seams.call("set_viewport", 390, 844, 1.0)
	await _pump(20)
	print("PROBE idempotent=", JSON.stringify(first) == JSON.stringify(second))

	var frame_h := float(root.size.y)
	var need := int(round(float(UiChrome.BODY_PX) * frame_h / UiChrome.REFERENCE_FRAME_HEIGHT_PX))
	var report: Dictionary = seams.call("_last_viewport_report")
	print("PROBE report=", JSON.stringify(report))
	print("PROBE window_after=", DisplayServer.window_get_size())
	print("PROBE root_size=", root.size, " content_scale_size=", root.content_scale_size)
	print("PROBE uis_t2_need_px=", need)
	print("PROBE seam_body_text_px=", report.get("body_text_px", 0.0))
	print("PROBE mode_pick_text_scale=", panel.get("_text_scale"))

	_walk(panel, need)

	## #837 — no playtest chrome may stand over the panel the report names.
	var panel_rect: Rect2 = panel.get_global_rect()
	for node in _find_by_name(main, "PlaytestDebug"):
		var chrome := node as Control
		if chrome != null and chrome.is_visible_in_tree():
			var rect: Rect2 = chrome.get_global_rect()
			print(
				"PROBE chrome name=",
				chrome.name,
				" rect=",
				rect,
				" overlaps_panel=",
				rect.intersects(panel_rect),
				" overlap_area=",
				rect.intersection(panel_rect).get_area()
			)

	var img := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	img.save_png(OUT_DIR + "/s6-phone-390x844.png")
	print("PROBE screenshot=", OUT_DIR + "/s6-phone-390x844.png", " size=", img.get_size())
	quit(0)


func _find_by_name(node: Node, wanted: String) -> Array:
	var found: Array = []
	if node.name == wanted:
		found.append(node)
	for child in node.get_children():
		found.append_array(_find_by_name(child, wanted))
	return found


func _pump(frames: int) -> void:
	for i in frames:
		await process_frame


func _walk(node: Node, need: int) -> void:
	if node is Label or node is Button:
		_judge(node as Control, need)
	for child in node.get_children():
		_walk(child, need)


func _judge(control: Control, need: int) -> void:
	if not control.is_visible_in_tree():
		return
	var px := control.get_theme_font_size("font_size")
	var font := control.get_theme_font("font")
	var line_h := font.get_height(px)
	var text := _text_of(control)
	var text_w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	## A wrapping Label's box width is not a clip test: the title wraps to two
	## lines and its box grows. Clipping is judged vertically against the box the
	## layout gave the control; see `lines` / `visible_lines` in the focus probe in
	## `notes.md`. Buttons never wrap, so width is a clip test there.
	print(
		"PROBE text name=%s text=%s font_px=%d rect=%s line_h=%.1f text_w=%.1f clip_v=%s below_t2=%s"
		% [
			control.name,
			text.left(24),
			px,
			control.size,
			line_h,
			text_w,
			line_h > control.size.y + 0.5,
			px < need,
		]
	)


func _text_of(control: Control) -> String:
	if control is Label:
		return (control as Label).text
	if control is Button:
		return (control as Button).text
	return ""
