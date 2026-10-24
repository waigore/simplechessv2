extends SceneTree
## #795 acceptance — headless PTU-puzzle-play S6/C6: the four promotion options are
## named in the active locale, one line each, legible, inside R2, clear of R1, and
## each commits through the C6 control. Derived from the #333 probe's working entry
## path (mode-pick C2, DBG.3 deal, last-rank place). Throwaway harness.

var _main: Node
var _router: SessionRouter
var _panel: Node
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()
	_watchdog()


## A runtime error aborts the coroutine silently and Godot still exits 0, so
## completion — not the exit code alone — is what the runner checks.
func _watchdog() -> void:
	await create_timer(240.0).timeout
	print("STEP WATCHDOG_TIMEOUT")
	quit(3)


func _run() -> void:
	var scene := load("res://main.tscn") as PackedScene
	_main = scene.instantiate()
	# The headless smoke harness quits on boot; the drive replaces it (as #753 did).
	var harness := _main.get_node_or_null("PlaytestHarness")
	if harness != null:
		_main.remove_child(harness)
		harness.free()
	root.add_child(_main)
	await _pump(20)
	_router = _main.get_node("SessionRouter") as SessionRouter
	_panel = _main.get_node("ScreenHost/PuzzlePlay")

	(_router as Node).call("_go_mode_pick", "S1")
	await _pump(4)
	_router.handle_control("mode-pick", "C2")
	await _pump(6)
	_check(_router.stage == SessionRouter.STAGE_PUZZLE_PLAY, "c2 enters puzzle-play", _router.stage)

	for index in StringTable.LOCALES.size():
		print("LOCALE_START", StringTable.LOCALES[index])
		await _deal(StringTable.LOCALES[index])
		await _judge_names(StringTable.LOCALES[index])
		# The player's own locale path: mode-pick C4 cycles en → zh-Hant → ja → en.
		_router.call("_go_mode_pick", "S1")
		await _pump(4)
		_router.handle_control("mode-pick", "C4")
		await _pump(4)
		_router.handle_control("mode-pick", "C2")
		await _pump(6)

	# C6 — each option commits the piece it names (US3.1, US3.4, US3.8, US3.9).
	# The player's C6 gesture is a tap on the chooser sprite: Presentation's
	# pointer-up hit-tests the sprite through BoardPresentation, then commits
	# through SessionRouter.handle_promotion_commit (presentation.gd:751-756).
	for kind in PuzzleSession.PROMOTE_ORDER:
		await _deal("en")
		var flow: PuzzlePlayFlow = _router.puzzle_flow
		var before := flow.session.play_ui_state
		var board: Node = _main.find_child("BoardPresentation", true, false)
		var target := board.find_child("Promote_%s" % kind, true, false) as Node2D
		if target == null:
			_check(false, "chooser sprite present for %s" % kind)
			continue
		var world: Vector2 = target.position
		var hit := str(board.call("promotion_kind_at", world))
		var committed := _router.handle_promotion_commit(hit)
		await _pump(4)
		var after := flow.session.play_ui_state
		var chosen := str(flow.session.play_state().get("promote_to", ""))
		print(
			"commit tapped=", kind,
			" sprite_pos=", world,
			" hit=", hit,
			" committed=", committed,
			" state_before=", before,
			" after=", after
		)
		_check(hit == kind, "the %s sprite hit-tests as %s" % [kind, kind], hit)
		_check(committed, "tapping %s commits" % kind, str(committed))
		_check(after != "S4", "tapping %s leaves S4" % kind, "%s→%s" % [before, after])

	print("FAILURES=", JSON.stringify(_failures))
	quit(0 if _failures.is_empty() else 1)


func _pump(frames: int) -> void:
	for i in frames:
		await process_frame


func _check(ok: bool, label: String, detail: String = "") -> void:
	print("CHECK %s %s %s" % ["PASS" if ok else "FAIL", label, detail])
	if not ok:
		_failures.append(label + (" :: " + detail if not detail.is_empty() else ""))


## DBG.3 — deal the last-rank promotion fixture, then enter S4 by placing g7→g8.
func _deal(locale: String) -> void:
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	if flow == null or flow.session == null:
		_check(false, "no puzzle session to deal into")
		return
	if flow.session.has_open_puzzle():
		flow.session.leave()
	flow.session.deal([_promotion_record()])
	_router.screen_requested.emit(SessionRouter.STAGE_PUZZLE_PLAY, flow.state())
	await _pump(4)
	_router.handle_input_commit("g7", "g8", "")
	await _pump(6)
	_check(
		String(_panel.get("ui_state")) == "S4",
		"last-rank place enters S4 (%s)" % locale,
		String(_panel.get("ui_state"))
	)
	_check(
		_panel.get("locale") == locale and _router.get("locale") == locale,
		"router and panel locale are %s" % locale,
		"router=%s panel=%s" % [str(_router.get("locale")), str(_panel.get("locale"))]
	)

## S6/C6 — every option carries the locale's name, legible, on the strip, over no square.
func _judge_names(locale: String) -> void:
	var strip := (_panel.find_child("PuzzleChrome", true, false) as Control).get_global_rect()
	var board := (_main.find_child("BoardPresentation", true, false) as Control).get_global_rect()
	var row := _panel.find_child("PromotionRow", true, false) as Control
	_check(row != null and row.is_visible_in_tree(), "PromotionRow shown in S4 (%s)" % locale)
	_check(row != null and row.get_child_count() == 4, "PromotionRow holds four names (%s)" % locale)
	var texts: Array[String] = []
	for kind in PuzzleSession.PROMOTE_ORDER:
		var label := _panel.find_child("PromoteName%s" % kind.capitalize(), true, false) as Label
		if label == null:
			_check(false, "name present for %s (%s)" % [kind, locale])
			continue
		texts.append(label.text)
		var box := label.get_global_rect()
		var needed := label.get_combined_minimum_size()
		var detail := (
			"text=%s box=%s font=%d needed=%s"
			% [label.text, str(box.size), label.get_theme_font_size("font_size"), str(needed)]
		)
		_check(
			label.is_visible_in_tree() and label.text == StringTable.puzzle_play(kind, locale),
			"%s name reads its copy (%s)" % [kind, locale],
			detail
		)
		_check(label.autowrap_mode == TextServer.AUTOWRAP_OFF, "%s name does not wrap (%s)" % [kind, locale], detail)
		_check(
			label.get_theme_font_size("font_size") >= UiChrome.BODY_PX,
			"%s name is at least UIS.T2 (%s)" % [kind, locale],
			detail
		)
		_check(
			box.size.y + 0.5 >= needed.y and box.size.x + 0.5 >= needed.x,
			"%s name is not clipped (%s)" % [kind, locale],
			detail
		)
		_check(strip.encloses(box), "%s name sits inside R2 (%s)" % [kind, locale], detail)
		_check(not box.intersects(board), "%s name covers no square (%s)" % [kind, locale], detail)
	print("names[%s]=%s" % [locale, str(texts)])


func _promotion_record() -> Dictionary:
	return {
		"snapshot_id": PuzzleSession.SNAPSHOT_ID,
		"puzzle_id": "accept795-promote",
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
