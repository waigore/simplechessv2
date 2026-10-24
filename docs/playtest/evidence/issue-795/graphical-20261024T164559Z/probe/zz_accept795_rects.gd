extends SceneTree
## #795 — S4: report the R2 strip, the board, and every C6 promotion name, then
## save the frame. Run once per frame size:
##   godot --path game --resolution 1280x720 --script res://_w795_shots.gd
## The file is throwaway (kept here as the probe record, not in `game/`).

var _main: Node


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate()
	root.add_child(_main)
	for i in 8:
		await process_frame
	var router := _main.get_node("SessionRouter") as SessionRouter
	router.call("_go_mode_pick", "S1")
	await process_frame
	router.handle_control("mode-pick", "C2")
	for i in 6:
		await process_frame
	var flow: PuzzlePlayFlow = router.puzzle_flow
	flow.session.deal([_rec()])
	router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, flow.state())
	for i in 4:
		await process_frame
	# A last-rank pawn place: the recorded opponent move `a8b8` leaves g7-g8 open.
	router.handle_input_commit("g7", "g8", "")
	for i in 12:
		await process_frame
	var panel: Node = _main.get_node("ScreenHost/PuzzlePlay")
	print("viewport=", root.size, " scale=", _main.text_scale(), " state=", flow.session.play_ui_state)
	var strip := (panel.find_child("PuzzleChrome", true, false) as Control).get_global_rect()
	var board := (_main.find_child("BoardPresentation", true, false) as Control).get_global_rect()
	print("strip=", strip, " board=", board)
	for kind in PuzzleSession.PROMOTE_ORDER:
		var label := panel.find_child("PromoteName%s" % kind.capitalize(), true, false) as Label
		var box := label.get_global_rect()
		print(
			kind,
			"=",
			box,
			" text=",
			label.text,
			" in_strip=",
			strip.encloses(box),
			" hits_board=",
			box.intersects(board)
		)
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	var out := "user://w795-s4-%x.png" % int(root.size.x)
	img.save_png(out)
	print("saved=", ProjectSettings.globalize_path(out))
	quit(0)


func _rec() -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": "probe795",
		"fen": "k7/6P1/8/8/8/8/8/7K b - - 0 1",
		"moves": ["a8b8", "g7g8q"],
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
