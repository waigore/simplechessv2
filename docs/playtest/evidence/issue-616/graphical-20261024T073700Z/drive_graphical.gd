extends SceneTree
## #616 acceptance — graphical drive of the chrome surfaces (re-recorded for #742).
##
## Runs the real `main.tscn` in a rendered (non-headless) Godot session, drives every
## judged panel open through `SessionRouter` controls (never by forcing visibility),
## records the drawn `get_global_rect()` of the six panels at three frames, and captures
## the actual rendered framebuffer in-process (`root.get_texture().get_image()`).
##
## #742: this file differs from the superseded `graphical-20261024T110000Z` drive in
## exactly two ways, both so the folder cannot name an environment it did not run in:
##   1. `OUT_DIR` is this run's own folder, so the drive can never write into another
##      run's `screenshots/`.
##   2. the first log line records what the session actually is — `DisplayServer`,
##      video adapter, rendering method, and whether the session is headless — and the
##      drive FAILS instead of capturing if it runs headless.
##
## The 390x844 legibility frame is applied through `O12` (`set_viewport`), the seam the
## Web playtest build uses for `SIT.6`; the two desktop frames are the running window.

const RUN_ID := "graphical-20261024T073700Z"
const OUT_DIR := "res://../docs/playtest/evidence/issue-616/" + RUN_ID + "/screenshots"
const FRAMES := [Vector2i(1280, 720), Vector2i(1600, 900)]
const PHONE := Vector2i(390, 844)
const PANEL_TOPS := {
	"ScreenHost/ModePick": 80.0,
	"ScreenHost/SharedSetup": 60.0,
	"ScreenHost/SharedResult": 120.0,
}
const DIALOG_TOPS := {"ResignConfirm": 200.0, "StreamConfirm": 220.0, "SaveFailure": 220.0}

var pres: Presentation
var router: SessionRouter
var seams: PlaytestSeams
var shots: Array[String] = []
var fails := 0


## A fresh sitting for the part of the pass the previous one could not reach.
## `confirm` on the shared result and `Quit` on mode pick both end the session,
## and `handle_control` ignores every control after that (`session_ended`), so
## the puzzle screens need a new instance. It is fitted to the running viewport
## so nothing is re-applied after the frame was set (a re-applied size would emit
## `resized` and defeat the `#708` no-`resized` reflow path).
##
## One use per run: every sitting sets `force_write_failure` and the store clears
## it on the attempt. The flag is deliberately not reset afterwards, so it cannot
## fail the *next* commit (which would pop the save-failure dialog in the middle
## of the following frame's pass).
func _new_sitting() -> void:
	await _settle(10)
	if pres != null:
		pres.queue_free()
		await _settle(10)
	pres = (load("res://main.tscn") as PackedScene).instantiate() as Presentation
	pres.size = root.get_visible_rect().size
	root.add_child(pres)
	await _settle(60)
	router = pres.get_node("SessionRouter") as SessionRouter
	seams = pres.get_node("PlaytestSeams") as PlaytestSeams
	router.locale = "en"
	router.last_mode = "none"
	seams.set_overlay(false, PackedStringArray())
	await _settle(20)


func _initialize() -> void:
	_run.call_deferred()
	_watchdog()


func _watchdog() -> void:
	await create_timer(600.0).timeout
	log_line("WATCHDOG_TIMEOUT")
	quit(3)


func log_line(s: String) -> void:
	print("STEP %s" % s)


func _settle(frames: int = 20) -> void:
	for _i in frames:
		await process_frame


## #742 — the environment this session is, recorded from the engine rather than
## asserted in prose. `headless` is `ENV.1`; anything else is a rendered session.
func _environment() -> String:
	var adapter := RenderingServer.get_video_adapter_name()
	if adapter == "":
		adapter = "<none>"
	return (
		"display=%s adapter=%s api=%s method=%s headless=%s"
		% [
			DisplayServer.get_name(),
			adapter,
			RenderingServer.get_video_adapter_api_version(),
			ProjectSettings.get_setting("rendering/renderer/rendering_method", "?"),
			str(DisplayServer.get_name() == "headless"),
		]
	)


func _run() -> void:
	await _new_sitting()
	log_line("run_id=%s" % RUN_ID)
	log_line("env %s" % _environment())
	log_line(
		(
			"booted godot=%s display=%s window=%s frame=%s seams=%s"
			% [
				Engine.get_version_info().string,
				DisplayServer.get_name(),
				str(DisplayServer.window_get_size()),
				str(root.get_visible_rect().size),
				str(pres.has_node("PlaytestSeams")),
			]
		)
	)
	if DisplayServer.get_name() == "headless":
		log_line("FAIL headless session cannot produce ENV.2 graphical evidence")
		quit(1)
		return

	for frame: Vector2i in FRAMES:
		seams.set_viewport(frame.x, frame.y, 1.0)
		await _settle(30)
		await _drive_frame(frame, true, "w%d" % frame.x)

	var report := seams.set_viewport(PHONE.x, PHONE.y, 1.0)
	await _settle(60)
	log_line("O12 phone report=%s" % JSON.stringify(report))
	log_line(
		(
			"O12 phone viewport=%s window=%s"
			% [str(root.get_visible_rect().size), str(DisplayServer.window_get_size())]
		)
	)
	await _drive_frame(PHONE, true, "phone")
	await _capture_caps(PHONE)

	log_line("SHOTS %s" % JSON.stringify(shots))
	log_line("RESULT fails=%d" % fails)
	log_line("DONE")
	quit(0 if fails == 0 else 1)


## `O10` light: the render loop across the judged window, captured on the last
## frame, so the per-state screenshots are shown to have come from a live loop.
func _capture_caps(frame: Vector2i) -> void:
	await _settle(60)
	log_line(
		(
			"render fps=%.1f process_ms=%.2f draw_calls=%d frame=%s"
			% [
				Engine.get_frames_per_second(),
				Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
				RenderingServer.get_rendering_info(
					RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME
				),
				str(frame),
			]
		)
	)
	await _shot("caps-frame-%d" % Engine.get_frames_drawn())


## One full pass over the six panels at the current frame. `shoot` writes the
## rendered framebuffer for each judged state; it is off for a frame that only
## re-measures geometry rather than re-photographing the same layout.
func _drive_frame(frame: Vector2i, shoot: bool, tag: String) -> void:
	log_line(
		(
			"FRAME %s window=%s viewport=%s"
			% [tag, str(DisplayServer.window_get_size()), str(root.get_visible_rect().size)]
		)
	)
	router._go_mode_pick("S1")
	await _settle(30)
	_check(
		pres.get_node("ScreenHost/ModePick") as Control,
		PANEL_TOPS["ScreenHost/ModePick"],
		frame,
		"mode-pick"
	)
	if shoot:
		await _shot("%s-01-mode-pick" % tag)

	router.handle_control("mode-pick", "C1")
	await _settle(40)
	_check(
		pres.get_node("ScreenHost/SharedSetup") as Control,
		PANEL_TOPS["ScreenHost/SharedSetup"],
		frame,
		"shared-setup"
	)
	if shoot:
		await _shot("%s-02-shared-setup" % tag)

	router.clock = "untimed"
	router.handle_control("shared-setup", "C5")
	await _settle(60)
	router.handle_control("shared-play", "C4")
	await _settle(40)
	_check_if_visible(
		_child("SharedPlay", "ResignConfirm"), DIALOG_TOPS["ResignConfirm"], frame, "resign-confirm"
	)
	if shoot:
		await _shot("%s-03-resign-confirm" % tag)
	router.handle_control("shared-play", "cancel")
	await _settle(30)

	router.handle_control("shared-play", "C4")
	router.handle_control("shared-play", "confirm")
	await _settle(60)
	_check(
		pres.get_node("ScreenHost/SharedResult") as Control,
		PANEL_TOPS["ScreenHost/SharedResult"],
		frame,
		"shared-result"
	)
	if shoot:
		await _shot("%s-04-shared-result" % tag)

	await _new_sitting()
	router.handle_control("mode-pick", "C2")
	await _settle(60)
	_deal_fixture()
	await _settle(40)
	router.handle_control("puzzle-play", "C5")
	await _settle(40)
	_check_if_visible(
		_child("PuzzlePlay", "StreamConfirm"), DIALOG_TOPS["StreamConfirm"], frame, "stream-confirm"
	)
	if shoot:
		await _shot("%s-05-stream-confirm" % tag)
	router.handle_control("puzzle-play", "cancel")
	await _settle(30)

	await _new_sitting()
	router.handle_control("mode-pick", "C2")
	await _settle(60)
	_deal_fixture()
	await _settle(40)
	var persist := pres.get_node("PersistStore") as PersistStore
	persist.force_write_failure = true
	router.handle_input_commit("b1", "b8", "")
	await _settle(40)
	_check_if_visible(
		_child("PuzzlePlay", "SaveFailure"), DIALOG_TOPS["SaveFailure"], frame, "save-failure"
	)
	if shoot:
		await _shot("%s-06-save-failure" % tag)
	await _new_sitting()


func _check_if_visible(panel: Control, top: float, frame: Vector2i, screen: String) -> void:
	if panel == null:
		log_line("FAIL %s missing at %s" % [screen, str(frame)])
		fails += 1
		return
	if not panel.is_visible_in_tree():
		log_line("FAIL %s not visible at %s (player cannot see it)" % [screen, str(frame)])
		fails += 1
		return
	_check(panel, top, frame, screen)


func _check(panel: Control, top: float, frame: Vector2i, screen: String) -> void:
	if panel == null:
		log_line("FAIL %s panel missing at %s" % [screen, str(frame)])
		fails += 1
		return
	var parent_rect := (panel.get_parent() as Control).get_global_rect()
	var rect := panel.get_global_rect()
	var dx := absf(rect.get_center().x - parent_rect.get_center().x)
	var dy := absf(rect.position.y - parent_rect.position.y - top)
	var ok := dx <= 1.0 and dy <= 1.0
	if not ok:
		fails += 1
	log_line(
		(
			"%s %-14s rect=%s parent=%s centre_dx=%.1f top_dy=%.1f frame=%s"
			% [
				"ok" if ok else "FAIL",
				panel.name,
				str(rect),
				str(parent_rect),
				dx,
				dy,
				str(frame),
			]
		)
	)
	_report_controls(panel, parent_rect, screen, frame)
	_report_text(panel, screen, frame)


## UIS.T2 — every label and body string the panel ships must draw at least the
## smallest shipped size. The rendered font size is read from the theme override
## the chrome applies, scaled by the transform that draws it.
func _report_text(panel: Control, screen: String, frame: Vector2i) -> void:
	var content_scale := root.content_scale_factor
	var smallest := 1 << 30
	var label := ""
	for node: Node in panel.find_children("*", "Control", true, false):
		var control := node as Control
		if not control.is_visible_in_tree():
			continue
		var px := 0
		if control is Button:
			px = (control as Button).get_theme_font_size("font_size")
		elif control is Label:
			px = (control as Label).get_theme_font_size("font_size")
		if px <= 0:
			continue
		var drawn := int(round(float(px) * content_scale))
		if drawn < smallest:
			smallest = drawn
			label = control.name
	if smallest < (1 << 30):
		log_line(
			(
				"text screen=%s frame=%s smallest_px=%d control=%s scale=%.3f"
				% [screen, str(frame), smallest, label, content_scale]
			)
		)


func _report_controls(panel: Control, parent_rect: Rect2, screen: String, frame: Vector2i) -> void:
	var outside := 0
	var total := 0
	for node: Node in panel.find_children("*", "Control", true, false):
		var control := node as Control
		if not control.is_visible_in_tree():
			continue
		var r := control.get_global_rect()
		if r.size.x <= 0.0 or r.size.y <= 0.0:
			continue
		total += 1
		if r.position.x < parent_rect.position.x - 1.0 or r.end.x > parent_rect.end.x + 1.0:
			outside += 1
			log_line("  overflow %s %s within %s" % [control.name, str(r), screen])
	log_line(
		(
			"  controls screen=%s frame=%s total=%d outside_frame=%d"
			% [screen, str(frame), total, outside]
		)
	)


func _deal_fixture() -> void:
	var flow := router.puzzle_flow
	if flow == null or flow.session == null:
		log_line("deal_fixture no puzzle session")
		return
	(
		flow
		. session
		. deal(
			[
				{
					"snapshot_id": PuzzleSession.SNAPSHOT_ID,
					"puzzle_id": "mate1",
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
			]
		)
	)


func _child(panel_name: String, node_name: String) -> Control:
	var panel := pres.get_node("ScreenHost/" + panel_name) as Control
	return panel.find_child(node_name, true, false) as Control


func _shot(name: String) -> void:
	await _settle(20)
	var img := root.get_texture().get_image()
	if img == null:
		log_line("shot_failed %s no image" % name)
		fails += 1
		return
	var path := "%s/%s.png" % [OUT_DIR, name]
	var err := img.save_png(path)
	shots.append(name)
	log_line("shot %s size=%s err=%d path=%s" % [name, str(img.get_size()), err, path])
	log_line("  tree panel visible=%s" % str(_panel_visible()))


## Which chrome panel the capture should show. A capture that names a state the
## tree does not have is a broken grab, not a passing screenshot.
func _panel_visible() -> String:
	var seen := PackedStringArray()
	for path: String in PANEL_TOPS:
		var panel := pres.get_node_or_null(path) as Control
		if panel != null and panel.is_visible_in_tree():
			seen.append(path.get_slice("/", 1))
	for host: String in ["SharedPlay", "PuzzlePlay"]:
		for node_name: String in ["ResignConfirm", "StreamConfirm", "SaveFailure"]:
			var dialog := _child(host, node_name)
			if dialog != null and dialog.is_visible_in_tree():
				seen.append(node_name)
	return ",".join(seen) if not seen.is_empty() else "none"
