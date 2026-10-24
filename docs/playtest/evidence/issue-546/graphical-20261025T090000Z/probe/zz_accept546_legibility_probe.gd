extends SceneTree
## Acceptance probe for #546 (SIT.6 / S13 / O12), re-measured on origin/main f1a62f0.
##
## Derived from the #708 acceptance probe
## (docs/playtest/evidence/issue-546/graphical-20261024T201500Z/probe/zz_accept546_probe.gd),
## adapted to current `main` (`_last_viewport_report`; typed Dictionary local).
##
## It adds no behaviour; it only reads the shipped layout and the seam report, then
## measures whether every visible string actually fits its control at the applied size.
## Throwaway harness: never committed.

const SCREEN := "mode-pick"


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

	print("display=", DisplayServer.get_name())
	print("playtest_build=", seams.playtest_build)
	print("window_before=", DisplayServer.window_get_size())

	# O12 exactly as the panel control drives it: a live resize of the running window.
	var button: Button = seams.get_node("PlaytestDebug/DebugPanel/SetViewport")
	button.pressed.emit()
	await _pump(20)

	var report: Dictionary = seams.call("_last_viewport_report")
	var frame_h := float(root.size.y)
	var need := int(round(float(UiChrome.BODY_PX) * frame_h / UiChrome.REFERENCE_FRAME_HEIGHT_PX))
	print("report=", JSON.stringify(report))
	print("window_after=", DisplayServer.window_get_size())
	print("screen_frame=", root.size, " content_scale_size=", root.content_scale_size)
	print("uis_t2_need_px_for_screen=", need)
	print("what_seam_claims_body_text_px=", report.get("body_text_px", 0))
	print("mode_pick._text_scale=", panel.get("_text_scale"))

	_walk(panel, need)
	await process_frame
	var img := root.get_texture().get_image()
	img.save_png("docs/playtest/evidence/issue-546/graphical-20261025T090000Z/screenshots/s6-phone-390x844.png")
	var shot := "docs/playtest/evidence/issue-546/graphical-20261025T090000Z/screenshots/s6-phone-390x844.png"
	print("screenshot=", shot, " size=", img.get_size())
	quit(0)


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
	var report := (
		"name=%s text=%s font_px=%d own_h=%.0f resolves_frame=%.0f rect=%s "
		+ "line_h=%.1f text_w=%.1f clip_v=%s clip_h=%s below_t2=%s fits_panel=%s"
	)
	print(
		(
			report
			% [
				control.name,
				text,
				px,
				control.size.y,
				UiChrome.frame_height_of(control),
				control.size,
				line_h,
				text_w,
				line_h > control.size.y + 0.5,
				text_w > control.size.x + 0.5,
				px < need,
				control.get_global_rect().size.x <= 390.5,
			]
		)
	)


func _text_of(control: Control) -> String:
	if control is Label:
		return (control as Label).text
	if control is Button:
		return (control as Button).text
	return ""
