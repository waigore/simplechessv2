extends SceneTree

## Verify #375 probe (temporary; deleted after the run). Drives the play screen on
## the shipped release graph with a reachable advice backend, then reproduces the
## recorded pointer gesture from the implementor's own evidence log.

var _rows: Array = []


func _initialize() -> void:
	_run()


func _row(name: String, ok: bool, detail: String = "") -> void:
	print("V375 ", JSON.stringify({"check": name, "ok": ok, "detail": detail}))


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	var packed := load("res://main_release.tscn") as PackedScene
	var root_node := packed.instantiate()
	root.add_child(root_node)
	await _frames(3)
	var seams := root_node.find_child("PlaytestSeams", true, false)
	_row("release_graph_no_seams", seams == null)
	var router := _find(root_node, "SessionRouter")
	var pres := _find(root_node, "Presentation")
	_row("router_found", router != null)
	_row("presentation_found", pres != null)
	if router == null or pres == null:
		quit(1)
		return
	# Give L2 what the release graph asks for (O5), same as the evidence drives.
	router.advice_on = true
	router.locale = "en"
	router.last_mode = "none"
	router.advice_endpoint = "http://127.0.0.1:1/advice"
	router.advice_api_key = "verify-375-probe"
	pres.provide_assets(_assets())
	pres.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	pres.control_activate.emit("shared-setup", "C5")
	await _frames(3)
	_row("play_reached", router.stage == SessionRouter.STAGE_SHARED_PLAY, str(router.stage))
	_row("assets_loaded", true)
	# Fail the advice fetch on the shipped transport (closed port).
	for i in 200:
		await process_frame
		if router.shared_session != null and router.shared_session.advice_error:
			break
	_row("advice_error_raised", router.shared_session != null and router.shared_session.advice_error)
	_row("ui_state_s3", router.play_ui_state == "S3", router.play_ui_state)
	var panel_res := await _pointer_gesture(router, pres, "g1", "f3")
	_row("pointer_gesture_g1f3_in_s3", panel_res[0], panel_res[1])
	_row("ui_state_after_g1", router.play_ui_state == "S3", router.play_ui_state)
	_row("advice_error_survives_the_move", router.shared_session.advice_error)
	_row("board_still_playable", router.can_place("b8", "c6"), "black is to move")
	quit(0)


## The implementor's own gesture_probe shape: a tap on the own piece (press +
## release on g1, one frame apart), then a tap on the destination.
func _pointer_gesture(router: Node, pres: Node, from_sq: String, to_sq: String) -> Array:
	var board := _find(pres, "BoardPresentation")
	if board == null:
		return [false, "no board"]
	var a: Vector2 = board.world_to_screen(BoardGeometry.square_center(from_sq))
	var b: Vector2 = board.world_to_screen(BoardGeometry.square_center(to_sq))
	pres._accept_pointer({"kind": "pointer", "pressed": true, "index": 0, "x": a.x, "y": a.y})
	await _frames(1)
	pres._accept_pointer({"kind": "pointer", "pressed": false, "index": 0, "x": a.x, "y": a.y})
	await _frames(1)
	var selected := str(router.selected_piece)
	pres._accept_pointer({"kind": "pointer", "pressed": true, "index": 0, "x": b.x, "y": b.y})
	await _frames(1)
	pres._accept_pointer({"kind": "pointer", "pressed": false, "index": 0, "x": b.x, "y": b.y})
	await _frames(3)
	var detail := "selected_after_tap=%s side=%s" % [selected, str(router.side_to_move())]
	return [str(router.side_to_move()) == "black", detail]


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


func _find(from: Node, name: String) -> Node:
	if from == null:
		return null
	if from.name == name:
		return from
	for child in from.get_children():
		var hit := _find(child, name)
		if hit != null:
			return hit
	return null
