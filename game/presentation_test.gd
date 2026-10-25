class_name PresentationTest
extends SceneTree

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	root.add_child(_presentation)
	_router.locale = "ja"
	_presentation.show_screen("loading", {})
	var loading := _presentation.get_node("LoadingLabel") as Label
	if not loading.visible or not loading.text.contains("読み込み"):
		_fail("EX.loading should show before the boot hook")
		return
	call_deferred("_after_boot")


func _after_boot() -> void:
	var loading := _presentation.get_node("LoadingLabel") as Label
	var mode_pick := _presentation.get_node("ScreenHost/ModePick") as ModePickPanel
	if loading.visible or not mode_pick.visible:
		_fail("mode-pick did not replace loading")
		return
	if _router.stage != "mode-pick":
		_fail("router stage")
		return
	if mode_pick.find_child("PuzzleStream", true, false) == null:
		_fail("mode-pick must offer UI-mode-pick.C2 Puzzle stream")
		return
	if not _exercise_pointers():
		return
	if not _exercise_screens():
		return
	_seams.set_seed(42)
	call_deferred("_after_seed")


func _after_seed() -> void:
	var mode_pick := _presentation.get_node("ScreenHost/ModePick") as ModePickPanel
	if _router.stage != "mode-pick" or not mode_pick.visible:
		_fail("seed did not return to mode-pick")
		return
	var dumped := _seams.dump_state()
	if int(dumped.get("seed", -1)) != 42:
		_fail("seed was not repeatable")
		return
	if not await _exercise_board_taps():
		return
	quit(0)


## #845 — the pointer leg of the tap→square check. The exported build plays the
## 1280×720 base through `canvas_items`/`expand` in a phone frame, so every touch
## below is pushed in frame pixels and reaches the presentation as canvas
## coordinates, exactly as the browser delivers it. CMP-presentation.R2 owns the
## conversion; this drives the real `_gui_input` path rather than the helper.
## The check reads what the board *paints* (its selection ring and its piece
## sprites), never the router: a router assertion would pass while the pointer
## path pointed at another square (#845 verify).
func _exercise_board_taps() -> bool:
	root.content_scale_size = Vector2i(1280, 720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.size = Vector2i(PlaytestSeams.VIEWPORT_PHONE_WIDTH, PlaytestSeams.VIEWPORT_PHONE_HEIGHT)
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	await process_frame
	await process_frame
	var board := _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
	if _router.stage != "shared-play" or board == null or not board.visible:
		return _fail("#845 could not reach shared play for the board-tap check")
	if root.get_final_transform() == Transform2D.IDENTITY:
		return _fail("#845 the release stretch is identity; the tap check would prove nothing")
	# A presentation that does not own the canvas origin must still hit right:
	# the control's own transform is part of the pointer→board conversion.
	_presentation.position = Vector2(0.0, 260.0)
	await process_frame
	await _tap_painted(board, "e2")
	var offset_select := _painted_selection(board)
	_presentation.position = Vector2.ZERO
	await process_frame
	# B8: the same square again deselects, so the next tap is a fresh select.
	await _tap_painted(board, "e2")
	var deselected := _painted_selection(board)
	await _tap_painted(board, "e2")
	var select := _painted_selection(board)
	await _tap_painted(board, "e4")
	# The commit is synchronous, but the moving piece is re-keyed on its settle
	# tween (BoardGeometry.SETTLE_S), so paint is read after it lands.
	await _settle_frames()
	var moved := _painted_kind_at(board, "e4", "pawn")
	var problem := ""
	if offset_select != "e2":
		problem = (
			"an offset presentation painted %s selected for a painted e2 tap"
			% _shown(offset_select)
		)
	elif not deselected.is_empty():
		problem = "a second painted e2 tap did not deselect (painted %s)" % _shown(deselected)
	elif select != "e2":
		problem = "a painted e2 tap painted %s selected" % _shown(select)
	elif not moved:
		problem = "a painted e4 tap did not paint the pawn on e4"
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i(0, 0)
	root.size = Vector2i(1280, 720)
	if not problem.is_empty():
		return _fail("#845 " + problem)
	return true


## Press and release at the painted centre of `square`, in frame pixels.
## The paint assertions read the board, not `_router.selected_piece`: the router
## belongs to `board_presentation.gd`, so asserting on it would pass while the
## pointer path pointed at another square (#845 verify).
func _tap_painted(board: BoardPresentation, square: String) -> void:
	var painted: Vector2 = (
		root.get_final_transform() * board.world_to_screen(board.framed_center(square))
	)
	var press := InputEventScreenTouch.new()
	press.pressed = true
	press.index = 1
	press.position = painted
	root.push_input(press)
	var release := InputEventScreenTouch.new()
	release.pressed = false
	release.index = 1
	release.position = painted
	root.push_input(release)
	await process_frame


## The square the board paints its selection ring on, "" when no ring shows.
func _painted_selection(board: BoardPresentation) -> String:
	var ring := board.get_node_or_null("World/Seat/Content/Overlays/Selection") as Line2D
	if ring == null or not ring.visible or ring.points.is_empty():
		return ""
	return BoardGeometry.square_at(ring.points[0] + Vector2(0.5, 0.5))


## Whether `square` paints a piece whose kind is `kind`.
func _painted_kind_at(board: BoardPresentation, square: String, kind: String) -> bool:
	var node := board.get_node_or_null("World/Seat/Content/Pieces/piece_%s" % square)
	return node != null and str(node.get_meta("piece_kind", "")) == kind


## Let the board's settle tween finish: a headless frame may be shorter than
## `BoardGeometry.SETTLE_S`, so count frames rather than await one.
func _settle_frames() -> void:
	var deadline := Time.get_ticks_msec() + 200
	while Time.get_ticks_msec() < deadline:
		await process_frame


func _shown(square: String) -> String:
	return square if not square.is_empty() else "nothing"


func _exercise_pointers() -> bool:
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.index = 1
	touch.position = Vector2(12, 34)
	_seams.record_input(true)
	_presentation.handle_gui_input(touch)
	var after_touch := _presentation.pointer_count
	var recorded := _log_size()
	_seams.replay_input(_seams.dump_state()["input_log"])
	var after_replay := _presentation.pointer_count
	var log_after := _log_size()
	_seams.pause()
	_presentation.handle_gui_input(touch)
	var while_paused := _presentation.pointer_count
	_seams.resume()
	var problem := ""
	if after_touch != 1 or recorded != 1:
		problem = "touch was not recorded"
	elif after_replay != 2 or log_after != 1:
		problem = "replay did not reach the control"
	elif while_paused != 2:
		problem = "paused touch was accepted"
	if not problem.is_empty():
		return _fail(problem)
	var right := InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	right.pressed = true
	right.position = Vector2(1, 1)
	_presentation.handle_gui_input(right)
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_A
	_presentation.handle_gui_input(key)
	var unsupported := _presentation.get_node("UnsupportedInput") as Label
	if not unsupported.visible:
		return _fail("EX.unsupported-input missing for key")
	var left := InputEventMouseButton.new()
	left.button_index = MOUSE_BUTTON_LEFT
	left.pressed = true
	left.position = Vector2(8, 9)
	_presentation.handle_gui_input(left)
	problem = ""
	if _presentation.pointer_count != 3:
		problem = "pointer was not received"
	elif str(_presentation.last_pointer.get("kind", "")) != "pointer":
		problem = "pointer kind"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _log_size() -> int:
	return (_seams.dump_state()["input_log"] as Array).size()


func _exercise_screens() -> bool:
	var loading := _presentation.get_node("LoadingLabel") as Label
	_router.locale = "zh-Hant"
	_presentation.show_screen("loading", {})
	var zh := loading.text
	var zh_visible := loading.visible
	_router.locale = "zz"
	_presentation.show_screen("loading", {})
	var fallback := loading.text
	_presentation.show_screen("not-a-screen", {})
	var jump_loading := _seams.jump("loading")
	var stage_after := _router.stage
	var unknown := _seams.jump("not-a-stage")
	var stage_unknown := _router.stage
	var problem := ""
	if not zh.contains("載入") or not zh_visible:
		problem = "zh-Hant loading copy"
	elif not fallback.contains("Loading"):
		problem = "locale fallback"
	elif jump_loading != OK or stage_after != "loading":
		problem = "jump loading"
	elif unknown != ERR_INVALID_PARAMETER or stage_unknown != "loading":
		problem = "unknown jump"
	if not problem.is_empty():
		return _fail(problem)
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
