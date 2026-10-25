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
	if not await _exercise_promotion_choice():
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


## #868 — S4→render→C6 seam through the real screen. Enters Shared play, loads a
## last-rank fixture, and drives the chooser with painted taps only: no direct
## `show_promotion_choice()` call, no direct `commit_promotion()` call.
func _exercise_promotion_choice() -> bool:
	root.content_scale_size = Vector2i(1280, 720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.size = Vector2i(PlaytestSeams.VIEWPORT_PHONE_WIDTH, PlaytestSeams.VIEWPORT_PHONE_HEIGHT)
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	await process_frame
	await process_frame
	var board := _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
	var problem := ""
	if _router.stage != "shared-play" or board == null or not board.visible:
		problem = "could not reach shared play for the promotion check"
	elif root.get_final_transform() == Transform2D.IDENTITY:
		problem = "the release stretch is identity; the promotion tap would prove nothing"
	if problem.is_empty():
		problem = await _promotion_screen("white", "c7", "c8", "queen")
	if problem.is_empty():
		problem = await _promotion_screen("black", "c2", "c1", "queen")
	if problem.is_empty():
		problem = await _promotion_screen("white", "c7", "c8", "")
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i(0, 0)
	root.size = Vector2i(1280, 720)
	if not problem.is_empty():
		return _fail("#868 " + problem)
	return true


## Load a last-rank fixture and drive S4 with painted taps. `kind` is the sprite
## to tap; empty means tap the destination centre (IN.deselect) instead.
func _promotion_screen(color: String, origin: String, dest: String, kind: String) -> String:
	var board := _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
	var session := _router.shared_session
	var pieces: Array = [
		{"square": origin, "color": color, "kind": "pawn"},
	]
	if color == "white":
		pieces.append({"square": "e1", "color": "white", "kind": "king"})
		pieces.append({"square": "h8", "color": "black", "kind": "king"})
	else:
		pieces.append({"square": "a1", "color": "white", "kind": "king"})
		pieces.append({"square": "e8", "color": "black", "kind": "king"})
	session.rules.load_position(pieces, color)
	session._sync_active_to_side_to_move()
	session.selected_piece = origin
	session.play_ui_state = SharedGameSession.UI_S1
	_router._emit_play_screen()
	await process_frame
	await process_frame
	var label := "%s %s→%s" % [color, origin, dest]
	if _router.side_to_move() != color:
		return "%s: side to move is %s" % [label, _router.side_to_move()]
	if not _router.occupancy_at(origin).has("kind"):
		return "%s: fixture pawn missing on %s" % [label, origin]
	# B3: tap the empty destination while the pawn is selected → EX.promote (S4).
	await _tap_painted(board, dest)
	var problem := _first_problem(
		[
			[
				session.play_ui_state == "S4",
				"tap did not enter S4 (state %s)" % session.play_ui_state
			],
			[
				session.pending_promote_from == origin,
				"pending from %s" % session.pending_promote_from
			],
			[session.pending_promote_to == dest, "pending to %s" % session.pending_promote_to],
			[str(_router.occupancy_at(origin).get("kind", "")) == "pawn", "pawn left %s" % origin],
			[_router.occupancy_at(dest).is_empty(), "destination %s occupied" % dest],
		]
	)
	if not problem.is_empty():
		return "%s: %s" % [label, problem]
	problem = _chooser_sprites(board, dest, color)
	if not problem.is_empty():
		return "%s: %s" % [label, problem]
	if kind.is_empty():
		# IN.deselect: the destination centre sits between the four sprites.
		await _tap_world(board, board.framed_center(dest))
		problem = _first_problem(
			[
				[session.play_ui_state == "S1", "deselect left state %s" % session.play_ui_state],
				[
					session.pending_promote_to == "",
					"deselect kept pending %s" % session.pending_promote_to
				],
				[
					session.pending_promote_from == "",
					"deselect kept from %s" % session.pending_promote_from
				],
				[_router.occupancy_at(dest).is_empty(), "deselect placed on %s" % dest],
				[
					str(_router.occupancy_at(origin).get("kind", "")) == "pawn",
					"deselect moved the pawn"
				],
				[session.selected_piece == origin, "deselect lost the pawn selection"],
				[
					board.promotion_kind_at(board.framed_center(dest)) == "",
					"deselect left the overlay"
				],
			]
		)
		return _labelled(label, problem)
	# C6: a painted tap on the sprite must commit that kind.
	await _tap_promotion_sprite(board, dest, kind)
	var placed := _router.occupancy_at(dest)
	var placed_kind := str(placed.get("kind", "(nothing)"))
	problem = _first_problem(
		[
			[
				str(placed.get("kind", "")) == kind,
				"a tap on the %s sprite placed %s" % [kind, placed_kind]
			],
			[str(placed.get("color", "")) == color, "promoted color %s" % placed.get("color", "")],
			[_router.occupancy_at(origin).is_empty(), "origin %s still occupied" % origin],
			[_router.side_to_move() != color, "side to move did not pass"],
			[session.play_ui_state == "S1", "commit left state %s" % session.play_ui_state],
			[board.promotion_kind_at(board.framed_center(dest)) == "", "overlay not cleared"],
		]
	)
	return _labelled(label, problem)


## S4 — four sprites on the destination, in PROMOTE_ORDER, for `color`.
func _chooser_sprites(board: BoardPresentation, dest: String, color: String) -> String:
	var chooser := board.get_node_or_null("World/Seat/Content/Overlays/PromoteChoice")
	if chooser == null or not chooser.visible:
		return "no chooser overlay at %s" % dest
	var nodes: Array[Node2D] = []
	for child in chooser.get_children():
		var node := child as Node2D
		if node != null and node.is_visible_in_tree():
			nodes.append(node)
	var seen: Array = []
	for node in nodes:
		seen.append(str(node.get_meta("promote_kind", "")))
	if seen != SharedGameSession.PROMOTE_ORDER:
		return "chooser holds %s, not %s" % [seen, SharedGameSession.PROMOTE_ORDER]
	var centre := board.framed_center(dest)
	var offsets := _promote_offsets()
	for i in range(nodes.size()):
		var at: Vector2 = centre + (offsets[i] as Vector2)
		if not nodes[i].position.is_equal_approx(at):
			return "sprite %s off its 2×2 slot" % str(seen[i])
		if board.promotion_kind_at(at) != str(seen[i]):
			return (
				"a tap at the %s slot of the %s chooser hits another sprite" % [str(seen[i]), color]
			)
	return ""


## Tap `kind`'s sprite inside the chooser at `dest`.
func _tap_promotion_sprite(board: BoardPresentation, dest: String, kind: String) -> void:
	var index := maxi(SharedGameSession.PROMOTE_ORDER.find(kind), 0)
	await _tap_world(board, board.framed_center(dest) + _promote_offsets()[index])


## The 2×2 layout `BoardPresentation.show_promotion_choice()` paints.
func _promote_offsets() -> Array:
	return [
		Vector2(-0.28, -0.28),
		Vector2(0.28, -0.28),
		Vector2(-0.28, 0.28),
		Vector2(0.28, 0.28),
	]


## First failing `[ok, message]` pair, or "".
func _first_problem(checks: Array) -> String:
	for check in checks:
		var pair := check as Array
		if not bool(pair[0]):
			return str(pair[1])
	return ""


## Same as `_first_problem`, prefixed with the fixture label when it fails.
func _labelled(label: String, problem: String) -> String:
	return "" if problem.is_empty() else "%s: %s" % [label, problem]


## Press and release at the painted centre of `square`, in frame pixels.
## The paint assertions read the board, not `_router.selected_piece`: the router
## belongs to `board_presentation.gd`, so asserting on it would pass while the
## pointer path pointed at another square (#845 verify).
func _tap_painted(board: BoardPresentation, square: String) -> void:
	await _tap_world(board, board.framed_center(square))


## Press and release at `world` (board space, seat applied), in frame pixels.
func _tap_world(board: BoardPresentation, world: Vector2) -> void:
	var painted: Vector2 = root.get_final_transform() * board.world_to_screen(world)
	await _tap_frame(painted)


## Press and release at `at` in frame pixels.
func _tap_frame(at: Vector2) -> void:
	var press := InputEventScreenTouch.new()
	press.pressed = true
	press.index = 1
	press.position = at
	root.push_input(press)
	var release := InputEventScreenTouch.new()
	release.pressed = false
	release.index = 1
	release.position = at
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
