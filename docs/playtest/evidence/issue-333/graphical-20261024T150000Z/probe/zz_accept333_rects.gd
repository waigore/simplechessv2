extends SceneTree
## Rect probe for #333: where do R2 (EloAndStatus), the cue, and the S2 confirm box
## actually land in the shipped layout at the run's frame size?

var _main: Node
var _router: SessionRouter


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate()
	root.add_child(_main)
	for i in 8:
		await process_frame
	_router = _main.get_node("SessionRouter") as SessionRouter
	print("viewport=", root.size, " content_scale=", root.content_scale_size)
	_router.call("_go_mode_pick", "S1")
	await process_frame
	_router.handle_control("mode-pick", "C2")
	for i in 6:
		await process_frame
	var panel: Node = _main.get_node("ScreenHost/PuzzlePlay")
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	flow.session.deal([_rec()])
	_router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, flow.state())
	for i in 4:
		await process_frame

	for path in [
		"EloAndStatus", "PlayerElo", "ResultCue", "PuzzleChrome", "StreamActions", "Reveal"
	]:
		var n := panel.find_child(path, true, false)
		if n == null:
			print(path, "=MISSING")
			continue
		var c := n as Control
		print(
			path,
			" rect=",
			c.get_global_rect(),
			" min=",
			c.get_combined_minimum_size(),
			" visible=",
			c.is_visible_in_tree()
		)

	# Raise the leave confirm and report the dialog geometry too.
	_router.handle_control("puzzle-play", "C5")
	for i in 4:
		await process_frame
	var box := panel.find_child("StreamConfirm", true, false) as Control
	var msg := panel.find_child("StreamConfirmMsg", true, false) as Control
	var ok := panel.find_child("ConfirmStream", true, false) as Control
	print("StreamConfirm rect=", box.get_global_rect(), " visible=", box.is_visible_in_tree())
	print("StreamConfirmMsg rect=", msg.get_global_rect(), " text=", (msg as Label).text)
	print("ConfirmStream rect=", ok.get_global_rect(), " visible=", ok.is_visible_in_tree())
	var board: Node = _main.get_node("ScreenHost/SharedPlay")
	print("panel_index=", panel.get_index(), " z_as_relative=", panel.z_as_relative, " z=", panel.z_index)
	quit(0)


func _rec() -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": "probe",
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
