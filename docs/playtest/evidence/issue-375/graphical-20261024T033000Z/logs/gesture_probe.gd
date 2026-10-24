extends SceneTree
## #375 AC6 / AC10 — the graphical `PTU-exceptions` S3 leg through real board
## gestures on the SHIPPED release scene graph, after the failed advice fetch has
## parked the client.
##
## The 2026-10-24 verify fail reported `g1f3` refused in S3. This drive repeats
## the sequence with real pointer gestures (press / move / release through
## `Presentation._accept_pointer`, the path `handle_gui_input` uses), after the
## park, on both sides of the board, and captures the board.
##
## Run from the repo root with a display (or xvfb-run):
##   godot --path game -s ../docs/playtest/evidence/issue-375/graphical-20261024T033000Z/logs/gesture_probe.gd
## Talk on stdout as `R375-G {}` JSON lines. Exit code is the failed checks.

const RELEASE_SCENE := "res://main_release.tscn"
const SHOTS := "res://../docs/playtest/evidence/issue-375/graphical-20261024T033000Z/screenshots"

var _presentation: Presentation
var _router: SessionRouter
var _checks := 0
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(name: String, ok: bool, detail: String = "") -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("R375-G ", JSON.stringify({"check": name, "ok": ok, "detail": detail}))


func _run() -> void:
	var root: Node = (load(RELEASE_SCENE) as PackedScene).instantiate()
	get_root().add_child(root)
	await _frames(3)
	_check("release_scene_has_no_seams", root.get_node_or_null("PlaytestSeams") == null)
	_router = root.get_node_or_null("SessionRouter") as SessionRouter
	_presentation = root.get_node_or_null("Presentation") as Presentation
	if _presentation == null and root is Presentation:
		_presentation = root as Presentation
	_check("router_present", _router != null)
	_check("presentation_present", _presentation != null)
	if _router == null or _presentation == null:
		await _finish()
		return
	# The release graph binds its art and font from L2; without the group the
	# board has no pieces and no readable copy. This probe plays the L2 role.
	var assets := _load_assets()
	_check("assets_loaded", not assets.is_empty(), str(assets.size()))
	_presentation.provide_assets(assets)
	await _frames(2)
	# Advice On against a port nobody listens on: the fetch fails on its own, the
	# way a stopped backend fails, so S3 is reached without a simulated peer.
	_router.advice_on = true
	_router.locale = "en"
	_router.last_mode = "none"
	_router.advice_endpoint = "http://127.0.0.1:1/advice"
	_router.advice_api_key = "graphical-probe"
	_presentation.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	_presentation.control_activate.emit("shared-setup", "C5")
	await _frames(3)
	_check("play_reached", _router.stage == SessionRouter.STAGE_SHARED_PLAY, _router.stage)
	_check(
		"board_gestures_live",
		_presentation.current_screen == _presentation.SHARED_PLAY,
		_presentation.current_screen
	)

	var session := _router.shared_session
	var error_up := await _wait_for(func() -> bool: return session.advice_error, 6000)
	_check("advice_error_raised", error_up, str(session.advice_error))
	# Let the park settle: the verify fail's refused `g1f3` came after the park.
	await _wait_ms(400)
	_check("service_parked_offline", not session.online, str(session.online))
	_check("client_parked", session.advice_client.failed(), str(session.advice_client.failed()))
	_check("ui_state_s3", _router.play_ui_state == SharedGameSession.UI_S3, _router.play_ui_state)
	_check("ex_error_panel_up", _panel_visible(), str(_panel_visible()))
	await _shot("s3-error")
	_check("side_to_move_before", _side() == "white", _side())
	# The presentation applies its loading transition on the play screen, which
	# disables its process mode for the fade; wait it out so a driven gesture
	# reaches the same handler a person's touch does.
	var fade := Time.get_ticks_msec()
	while _presentation.can_process() == false and Time.get_ticks_msec() - fade < 2000:
		await process_frame
	_check("presentation_live", _presentation.can_process(), "")
	_check("session_live", not _router.session_is_paused(), "")

	# The verify's own gesture, as a real pointer drag, after the park.
	_check("pointer_move_g1f3_in_s3", await _drag("g1", "f3"), "side now %s" % _side())
	_check("error_still_up_after_move", _panel_visible() and session.advice_error, "")
	_check("still_offline_after_move", not session.online, "")

	# The other side, same way: the board stays playable for both players.
	_check("pointer_move_g8f6_in_s3", await _drag("g8", "f6"), "side now %s" % _side())

	# A tap-select + tap-destination move (B10 elsewhere, B2/B3 here).
	_check("tap_move_e2e4_in_s3", await _tap_move("e2", "e4"), "side now %s" % _side())
	await _shot("s3-played")

	# Dismiss → S1, still offline (FAIL.T1), and play continues.
	var dismiss := _presentation.find_child("AdviceErrorDismiss", true, false) as Button
	_check("dismiss_present", dismiss != null, "")
	if dismiss != null:
		dismiss.pressed.emit()
		await _frames(3)
	_check(
		"dismiss_returns_s1",
		_router.play_ui_state == SharedGameSession.UI_S1,
		_router.play_ui_state
	)
	_check("panel_hidden_after_dismiss", not _panel_visible(), "")
	_check("pointer_move_d7d5_after_dismiss", await _drag("d7", "d5"), "side now %s" % _side())
	await _shot("after-dismiss")
	await _finish()


func _side() -> String:
	if _router == null or _router.shared_session == null:
		return ""
	return _router.shared_session.side_to_move()


func _panel_visible() -> bool:
	var box := _presentation.find_child("AdviceError", true, false) as Control
	return box != null and box.visible


## A real pointer drag between two squares; true when the side to move changed.
func _drag(from_square: String, to_square: String) -> bool:
	var before := _side()
	var a := _screen_of(from_square)
	var b := _screen_of(to_square)
	await _pointer(a, true)
	for step in 4:
		await _pointer(a.lerp(b, float(step + 1) / 4.0), false)
	await _pointer(b, false)
	await _frames(3)
	return _side() != before


## B2 then B3: a tap on the own piece, then a tap on the destination.
func _tap_move(from_square: String, to_square: String) -> bool:
	var before := _side()
	await _pointer(_screen_of(from_square), false)
	await _frames(2)
	await _pointer(_screen_of(to_square), false)
	await _frames(3)
	return _side() != before


func _pointer(screen: Vector2, down: bool) -> void:
	(
		_presentation
		. _accept_pointer(
			{
				"kind": "pointer",
				"pressed": down,
				"index": 0,
				"x": screen.x,
				"y": screen.y,
			}
		)
	)
	# One event per frame, so the screen can repaint between them the way a
	# finger's events arrive.
	await _frames(1)


func _screen_of(square: String) -> Vector2:
	return _board_node().world_to_screen(BoardGeometry.square_center(square))


## Piece and font resources by asset ID, the shape O5 carries: the resolver's
## play group plus every board piece ID and the UI fonts.
func _load_assets() -> Dictionary:
	var loader := AssetResolver.new()
	get_root().add_child(loader)
	var ids := PackedStringArray()
	for group_id in loader.resolve_group("play").keys():
		ids.append(str(group_id))
	for asset_id in BoardPresentation.PIECE_IDS.values():
		ids.append(str(asset_id))
	ids.append(BoardPresentation.BOARD_BG_ID)
	ids.append(UiChrome.FONT_LATIN)
	var out := loader.resolve_ids(ids)
	loader.queue_free()
	return out


func _board_node() -> BoardPresentation:
	var stack: Array[Node] = [get_root()]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is BoardPresentation:
			return node as BoardPresentation
		for child in node.get_children():
			stack.append(child)
	return null


func _shot(name: String) -> void:
	var path := "%s/%s.png" % [SHOTS, name]
	var image := get_root().get_texture().get_image()
	var err := image.save_png(path)
	print("R375-G ", JSON.stringify({"screenshot": name, "path": path, "err": err}))


func _wait_for(callable: Callable, timeout_ms: int) -> bool:
	var started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < timeout_ms:
		if callable.call():
			return true
		await process_frame
	return false


func _wait_ms(ms: int) -> void:
	var started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < ms:
		await process_frame


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


func _finish() -> void:
	print("R375-G ", JSON.stringify({"summary": {"checks": _checks, "failed": _failures}}))
	quit(_failures)
