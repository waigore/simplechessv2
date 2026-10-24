extends SceneTree
## Acceptance probe for #546 (SIT.6 / S13 / O12) on origin/main aa16e09.
##
## Written from the shipped seam API and the shipped scene, not from any earlier
## acceptance harness. It drives O12 the way a runner does (the SetViewport panel
## control plus a direct call), then judges the RENDER: for every visible string on
## the mode-pick screen it reads the resolved font size and line layout, and it
## intersects each control's global rect with the playtest debug chrome so a string
## drawn under opaque chrome is not counted legible.
##
## Throwaway harness: it is copied into game/ only to run (Godot loads res:// scripts)
## and the copy is deleted afterwards.

const RUN_DIR := "docs/playtest/evidence/issue-546/graphical-20261025T220000Z"
const SHOT_NAME := "s6-phone-390x844.png"
const PHONE := Vector2i(390, 844)

var _failures := 0
var _capture_ok := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	var main := scene.instantiate() as Presentation
	root.add_child(main)
	await _pump(3)
	var seams: Node = main.get_node("PlaytestSeams")
	var panel: Control = main.get_node("ScreenHost/ModePick")

	print("display=", DisplayServer.get_name())
	print("playtest_build=", seams.playtest_build)
	print("window_before=", DisplayServer.window_get_size())
	print("content_scale_mode_before=", root.content_scale_mode)

	main.show_screen(Presentation.MODE_PICK, {"ui_state": "S1"})
	await _pump(2)

	# The runner path: press the debug-panel control, exactly as a graphical run does.
	var button: Button = seams.get_node("PlaytestDebug/DebugPanel/Controls/SetViewport")
	print("setviewport_control_present=", button != null)
	print("setviewport_control_label=", button.text)
	print("debug_panel_visible_before_press=", seams.call("_debug_panel_on_screen"))
	button.pressed.emit()
	await _pump(20)

	var report: Dictionary = seams.call("_last_viewport_report")
	var frame := root.size
	var need := int(round(float(UiChrome.BODY_PX) * frame.y / UiChrome.REFERENCE_FRAME_HEIGHT_PX))
	print("report_panel_path=", JSON.stringify(report))
	print("window_after=", DisplayServer.window_get_size())
	print("frame=", frame, " content_scale_size=", root.content_scale_size)
	print("uis_t2_need_px=", need)
	print("mode_pick_text_scale=", panel.get("_text_scale"))
	print("expected_text_scale=", frame.y / float(UiChrome.REFERENCE_FRAME_HEIGHT_PX))

	# Idempotence: the same call twice must not move anything.
	var again: Dictionary = seams.set_viewport(PHONE.x, PHONE.y, 1.0)
	print("report_second_call_identical=", JSON.stringify(again) == JSON.stringify(report))
	await _pump(2)

	# The argument must not be what gets reported (D2 / S13).
	seams.set_viewport(PHONE.x, PHONE.y, 4.0)
	await _pump(10)
	var argued: Dictionary = seams.call("_last_viewport_report")
	print("report_argument_scale=", JSON.stringify(argued))
	print(
		(
			"body_px_ignores_argument="
			+ str(argued.get("body_text_px", 0.0) == report.get("body_text_px", -1.0))
		)
	)

	await _pump(3)
	_judge_screen(panel, need, frame)
	await _capture()
	await _sanity_check(frame)

	# Release absence: a non-playtest build must expose no O12.
	seams.set("playtest_build", false)
	print("release_report=", JSON.stringify(seams.set_viewport(PHONE.x, PHONE.y, 1.0)))
	seams.set("playtest_build", true)

	print("probe_failures=", _failures)
	quit(0 if _failures == 0 else 1)


func _judge_screen(panel: Control, need: int, frame: Vector2) -> void:
	var chrome: Array[Rect2] = _chrome_rects(panel)
	for rect in chrome:
		print("chrome_rect=", rect)
	_walk(panel, need, frame, chrome)


func _chrome_rects(panel: Control) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var node := _find_debug_root(panel)
	if node == null:
		return rects
	for child in node.get_children():
		var control := child as Control
		if control != null and control.is_visible_in_tree():
			rects.append(control.get_global_rect())
	print("debug_chrome_root=", node.get_path(), " layer_rects=", rects.size())
	return rects


## The playtest chrome lives beside the screens under the presentation root.
func _find_debug_root(panel: Control) -> Node:
	var host := panel.get_parent()
	if host == null:
		return null
	var presentation := host.get_parent()
	if presentation == null:
		return null
	for child in presentation.get_children():
		if str(child.name).begins_with("PlaytestDebug"):
			return child
	return null


func _walk(node: Node, need: int, frame: Vector2, chrome: Array[Rect2]) -> void:
	if node is Label or node is Button:
		_judge(node as Control, need, frame, chrome)
	for child in node.get_children():
		_walk(child, need, frame, chrome)


func _judge(control: Control, need: int, frame: Vector2, chrome: Array[Rect2]) -> void:
	if not control.is_visible_in_tree():
		return
	var text := _text_of(control)
	if text.strip_edges() == "":
		return
	var px := control.get_theme_font_size("font_size")
	var lines_ok := true
	var line_count := 1
	var visible_lines := 1
	if control is Label:
		var label := control as Label
		line_count = label.get_line_count()
		visible_lines = label.get_visible_line_count()
		lines_ok = visible_lines >= line_count
	var rect := control.get_global_rect()
	var in_frame := (
		rect.position.x >= -0.5
		and rect.position.y >= -0.5
		and rect.end.x <= frame.x + 0.5
		and rect.end.y <= frame.y + 0.5
	)
	var overlap_area := 0.0
	for other in chrome:
		if other.intersects(rect):
			var hit := other.intersection(rect)
			overlap_area += hit.size.x * hit.size.y
	var covered_ratio := overlap_area / maxf(1.0, rect.size.x * rect.size.y)
	var below_t2 := px < need
	var ok := not below_t2 and lines_ok and in_frame and covered_ratio < 0.001
	if not ok:
		_failures += 1
	print(
		(
			(
				"name=%s text=%s font_px=%d need=%d below_t2=%s lines=%d/%d lines_ok=%s "
				+ "rect=%s in_frame=%s chrome_overlap=%.1f covered=%.3f VERDICT=%s"
			)
			% [
				control.name,
				text,
				px,
				need,
				below_t2,
				line_count,
				visible_lines,
				lines_ok,
				rect,
				in_frame,
				overlap_area,
				covered_ratio,
				"pass" if ok else "fail",
			]
		)
	)


## `--path game` makes a bare relative path resolve inside `game/`, so the shot is
## written there by name and moved to the run folder after the run (RUN_DIR is used
## only for the moved-from path's base directory creation).
func _capture() -> void:
	await process_frame
	await process_frame
	var img := root.get_texture().get_image()
	var path := "res://" + SHOT_NAME
	var err := img.save_png(path)
	print("screenshot_raw=", path, " size=", img.get_size(), " err=", err)
	_capture_ok = err == OK


## The capture must be the phone frame, not a blank or stretched surface, and the
## mode-pick column must sit inside it. Guards against a probe that judges a
## layout that was never painted.
func _sanity_check(frame: Vector2) -> void:
	var phone := int(frame.x) == PHONE.x and int(frame.y) == PHONE.y
	print("cap_ok=", _capture_ok)
	print("after_run: cp game/", SHOT_NAME, " ", RUN_DIR, "/screenshots/", SHOT_NAME)
	print("frame_is_phone=", phone)
	if not _capture_ok:
		_failures += 1
	if not phone:
		_failures += 1


func _pump(frames: int) -> void:
	for i in frames:
		await process_frame


func _text_of(control: Control) -> String:
	if control is Label:
		return (control as Label).text
	if control is Button:
		return (control as Button).text
	return ""
