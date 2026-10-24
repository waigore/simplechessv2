extends SceneTree
## Acceptance probe for #546 (SIT.6 / S13 / O12).
##
## Renders the shipped `main.tscn` in a graphical (`ENV.2`) session, drives the
## `SetViewport` panel control exactly as a playtest runner does, then names the
## font size every visible mode-pick label/button resolves to and whether it
## clears `UIS.T2` for the frame the screen renders into.
##
## It adds no behaviour; it only reads the shipped layout and the seam report.
## Delete it when the #546 defect closes.

const SCREEN := "mode-pick"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var seams := main.get_node("PlaytestSeams") as PlaytestSeams
	var panel := main.get_node("ScreenHost/ModePick") as ModePickPanel
	(main as Presentation).show_screen(Presentation.MODE_PICK, {"ui_state": "S1"})
	await process_frame

	print("display=", DisplayServer.get_name())
	print("playtest_build=", seams.playtest_build)

	# O12 exactly as the panel control drives it: a live resize of the running window.
	var button := seams.get_node("PlaytestDebug/DebugPanel/SetViewport") as Button
	button.pressed.emit()
	for i in 12:
		await process_frame

	var report := seams.last_viewport_report()
	var frame_h := float(root.size.y)
	var need := int(
		round(float(UiChrome.BODY_PX) * frame_h / UiChrome.REFERENCE_FRAME_HEIGHT_PX)
	)
	print("report=", JSON.stringify(report))
	print("screen_frame=", root.size, " content_scale=", root.content_scale_size)
	print("uis_t2_need_px_for_screen=", need)
	print("what_seam_claims_body_text_px=", report.get("body_text_px", 0))
	print("mode_pick._text_scale=", panel._text_scale)

	_walk(panel, need)
	quit(0)


func _walk(node: Node, need: int) -> void:
	if node is Label or node is Button:
		var control := node as Control
		if control.is_visible_in_tree():
			var px := control.get_theme_font_size("font_size")
			var line_h := control.get_theme_font("font").get_height(px)
			var clips := line_h > control.size.y + 0.5
			print(
				"name=%s font_px=%d own_h=%.0f resolves_frame=%.0f rect=%s clip=%s below_t2=%s"
				% [
					control.name,
					px,
					control.size.y,
					UiChrome.frame_height_of(control),
					control.size,
					clips,
					px < need,
				]
			)
	for child in node.get_children():
		_walk(child, need)
