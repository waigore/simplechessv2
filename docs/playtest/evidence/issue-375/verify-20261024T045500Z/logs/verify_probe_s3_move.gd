extends SceneTree

## Verify #375 — does the session refuse a local move while the advice service is
## parked offline by a failed fetch (S3)? Drives the shipped release graph the way
## the implementor's own gesture_probe does, then calls the gesture path the
## pointer path calls.

func _initialize() -> void:
	_run()


func _row(name: String, ok: bool, detail: String = "") -> void:
	print("V375 ", JSON.stringify({"check": name, "ok": ok, "detail": detail}))


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	var packed := load("res://main_release.tscn") as PackedScene
	var root_node: Node = packed.instantiate()
	root.add_child(root_node)
	await _frames(3)
	var router := root_node.get_node_or_null("SessionRouter") as SessionRouter
	var pres := root_node.get_node_or_null("Presentation") as Presentation
	if pres == null and root_node is Presentation:
		pres = root_node as Presentation
	_row("release_scene_has_no_seams", root_node.get_node_or_null("PlaytestSeams") == null)
	_row("router_present", router != null)
	_row("presentation_present", pres != null)
	router.advice_on = true
	router.locale = "en"
	router.last_mode = "none"
	router.advice_endpoint = "http://127.0.0.1:1/advice"
	router.advice_api_key = "verify-375-probe"
	pres.provide_assets(_assets())
	await _frames(2)
	pres.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	pres.control_activate.emit("shared-setup", "C5")
	await _frames(3)
	var session := router.shared_session
	var err_up := false
	for i in 400:
		await process_frame
		if session != null and session.advice_error:
			err_up = true
			break
	_row("advice_error_raised", err_up)
	_row("session_online", session.online)
	_row("session_advice_error", session.advice_error)
	_row("router_ui_state", router.play_ui_state == "S3", str(router.play_ui_state))
	_row("gestures_available", session.gestures_available())
	_row("can_place_g1f3", router.can_place("g1", "f3"))
	_row("handle_input_commit_g1f3", router.handle_input_commit("g1", "f3"), "side now %s" % router.side_to_move())
	var panel := pres.find_child("AdviceError", true, false) as Control
	_row("ex_error_panel_up", panel != null and panel.visible)
	quit(0)


func _assets() -> Dictionary:
	var loader := AssetResolver.new()
	root.add_child(loader)
	var ids := PackedStringArray()
	for group_id in loader.resolve_group("play").keys():
		ids.append(str(group_id))
	for asset_id in BoardPresentation.PIECE_IDS.values():
		ids.append(str(asset_id))
	ids.append(BoardPresentation.BOARD_BG_ID)
	ids.append(UiChrome.FONT_LATIN)
	var out: Dictionary = loader.resolve_ids(ids)
	loader.queue_free()
	return out
