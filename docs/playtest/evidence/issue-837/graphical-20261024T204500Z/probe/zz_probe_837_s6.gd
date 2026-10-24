extends SceneTree
## Defect #837 probe — re-runs the acceptance that failed `PTU-mode-pick` S6 on
## #546 (`docs/playtest/evidence/issue-546/graphical-20261025T090000Z/`), on the
## branch that collapses the run's debug chrome. Throwaway harness: never committed.


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
	print("window_before=", DisplayServer.window_get_size())
	var start: Control = seams.get_node("PlaytestDebug/DebugPanel/ShowSeams")
	print("panel_expanded_before=", seams.get("_debug_collapsed"), " header_visible=", start.is_visible_in_tree())

	var button: Button = seams.get_node("PlaytestDebug/DebugPanel/Controls/SetViewport")
	button.pressed.emit()
	await _pump(20)

	var report: Dictionary = seams.call("_last_viewport_report")
	var frame_h := float(root.size.y)
	var need := int(round(float(UiChrome.BODY_PX) * frame_h / UiChrome.REFERENCE_FRAME_HEIGHT_PX))
	print("report=", JSON.stringify(report))
	print("window_after=", DisplayServer.window_get_size())
	print("screen_frame=", root.size, " content_scale_size=", root.content_scale_size)
	print("uis_t2_need_px_for_screen=", need)
	print("mode_pick._text_scale=", panel.get("_text_scale"))
	var header: Control = seams.get_node("PlaytestDebug/DebugPanel/ShowSeams")
	print("header_visible=", header.is_visible_in_tree(), " header_rect=", header.get_global_rect())
	var controls: Control = seams.get_node("PlaytestDebug/DebugPanel/Controls")
	print("controls_visible=", controls.is_visible_in_tree())
	print("panel_overlaps_mode_pick=", _overlaps(panel, header))

	var shot := "docs/playtest/evidence/issue-837/graphical-20261024T204500Z/screenshots/s6-phone-390x844.png"
	_walk(panel, need, panel)
	var img := root.get_texture().get_image()
	img.save_png(shot)
	print("screenshot=", shot, " size=", img.get_size())
	quit(0)


func _pump(frames: int) -> void:
	for i in frames:
		await process_frame


func _overlaps(judged: Control, chrome: Control) -> bool:
	if not chrome.is_visible_in_tree():
		return false
	return chrome.get_global_rect().intersects(judged.get_global_rect())


func _walk(node: Node, need: int, judged: Control) -> void:
	if node is Label or node is Button:
		_judge(node as Control, need, judged)
	for child in node.get_children():
		_walk(child, need, judged)


func _judge(control: Control, need: int, judged: Control) -> void:
	if not control.is_visible_in_tree():
		return
	var px := control.get_theme_font_size("font_size")
	var rect := control.get_global_rect()
	print(
		"name=%s font_px=%d rect=%s below_t2=%s" % [control.name, px, rect, str(px < need)]
	)
	## A control inside the judged panel must also stay inside the frame.
	if judged.get_global_rect().encloses(rect):
		print("  inside_mode_pick=true within_frame=true")
