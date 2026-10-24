extends SceneTree
## #793 evidence probe — drives the real entry paths through `SessionRouter` and
## screenshots the prompt states, with the rects and the pixels inside each
## prompt's own drawn rect.
##
## Run on a display (never `--headless`, where the dummy renderer has no image):
##   godot --path game --script res://<this file> -- <out dir> <tag prefix>
## Copy this file into `<run>/probe/` after the run; it writes its log to stdout.

var _pres: Presentation
var _router: SessionRouter
var _dir := "user://probe"
var _prefix := "shot"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_dir = args[0]
	if args.size() > 1:
		_prefix = args[1]
	change_scene_to_file("res://main.tscn")
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(_dir)
	for _i in 120:
		await process_frame
	_pres = root.get_node("Presentation") as Presentation
	_router = _pres.get_node("SessionRouter") as SessionRouter
	## The harness stays: `SessionRouter` enters the confirmed control paths only
	## while its playtest seams are alive (the same build the defect was measured on).
	for _i in 30:
		await process_frame
	print(
		"ENV build=",
		ProjectSettings.get_setting("application/config/name"),
		" godot=",
		Engine.get_version_info()["string"]
	)
	print("ENV display=", DisplayServer.get_name(), " frame=", root.get_visible_rect().size)
	# S2 — puzzle stream, deal, Leave stream (C5).
	_router._go_mode_pick("S1")
	await _settle()
	_shot("01-mode-pick")
	_router.handle_control("mode-pick", "C2")
	await _settle()
	_deal()
	await _settle()
	_shot("02-puzzle-s1")
	_router.handle_control("puzzle-play", "C5")
	await _settle()
	print("DBG state after C5=", _router.puzzle_flow.ui_state() if _router.puzzle_flow else "none")
	await _present()
	_shot("03-puzzle-s2-leave-confirm", "StreamConfirm")
	_router.handle_control("puzzle-play", "cancel")
	await _settle()
	await _present()
	_shot("04-puzzle-s2-cancelled")
	# S3 — forced write failure on the next commit.
	var persist := _pres.get_node("PersistStore") as PersistStore
	persist.force_write_failure = true
	_router.handle_input_commit("b1", "b8", "")
	await _settle()
	persist.force_write_failure = false
	await _present()
	_shot("05-puzzle-s3-save-failure", "SaveFailure")
	# Control — shared-play resign prompt, placed the same way at the same band.
	_router.handle_control("puzzle-play", "dismiss")
	await _settle()
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	await _settle()
	_router.handle_control("shared-play", "C4")
	await _settle()
	_pres.show_screen(Presentation.SHARED_PLAY, _router._shared_play_state())
	await _settle()
	_shot("06-shared-play-resign-control", "ResignConfirm")
	quit(0)


func _settle() -> void:
	for _i in 30:
		await process_frame


## Repaint PuzzlePlay from the live flow state (the router's screen request in play).
func _present() -> void:
	var flow := _router.puzzle_flow
	if flow == null:
		return
	print("DBG present flow state=", flow.ui_state())
	_pres.show_screen(Presentation.PUZZLE_PLAY, flow.state())
	await _settle()


## The frames on screen are saved, then the same frame with the board hidden
## (`noboard`) so the prompt's own pixels are readable without the board under it.
func _shot(tag: String, node_name: String = "") -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.save_png("%s/%s-%s.png" % [_dir, _prefix, tag])
	print("SHOT %s" % ProjectSettings.globalize_path("%s/%s-%s.png" % [_dir, _prefix, tag]))
	var box: Control = null
	if not node_name.is_empty():
		# Resolve by path from its panel: `find_child` does not reach the prompt.
		box = _pres.get_node("ScreenHost/PuzzlePlay/" + node_name) as Control
		print(
			"RECT %s visible_in_tree=%s rect=%s"
			% [node_name, box.is_visible_in_tree(), box.get_global_rect()]
		)
		for label: String in _samples(box):
			var at: Vector2i = _samples(box)[label]
			print("  PROBE %s %s %s" % [label, at, img.get_pixelv(at)])
	var board := _pres.get_node("ScreenHost/BoardPresentation") as CanvasItem
	var board_was := board.visible
	board.visible = false
	await _settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/%s-%s-noboard.png" % [_dir, _prefix, tag])
	board.visible = board_was


## Points read off the prompt's own drawn rect: its centre, its corner, the
## message line, and the first control's centre.
func _samples(box: Control) -> Dictionary:
	var rect := box.get_global_rect()
	var msg := box.find_child("*Msg", true, false) as Control
	var button: Control = null
	for node: Node in box.find_children("*", "Button", true, false):
		button = node as Control
		break
	var out := {
		"centre": Vector2i(int(rect.get_center().x), int(rect.get_center().y)),
		"corner": Vector2i(int(rect.position.x) + 5, int(rect.position.y) + 5),
	}
	if msg != null:
		var msg_rect := msg.get_global_rect()
		out["copy_line"] = Vector2i(int(msg_rect.get_center().x), int(msg_rect.get_center().y))
	if button != null:
		var btn_rect := button.get_global_rect()
		out["control"] = Vector2i(int(btn_rect.get_center().x), int(btn_rect.get_center().y))
	return out


func _deal() -> void:
	var flow := _router.puzzle_flow
	if flow == null or flow.session == null:
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
