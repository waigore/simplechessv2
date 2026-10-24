extends SceneTree
## #655 branch-independent probe — the C5 / S1 leg (Expected behavior item 4), re-run
## after the `PuzzleSession.request_confirm` repair. Same observations as
## `review-20261024-probe2`, driven through `PuzzlePlayFlow.control` and through a real
## `SessionRouter` so the leave → mode-pick journey is measured, not inferred.

const LOG := "user://x655_probe3.log"

var _log: FileAccess


func _initialize() -> void:
	var log := FileAccess.open(LOG, FileAccess.WRITE)
	var Flow := preload("res://puzzle_play_flow.gd")
	var flow = Flow.new()
	flow.enter(null, "", "", null)
	log.store_line("X655 B5 endpoint=<> key_set=false is_available=%s" % flow.client.is_available())
	var session = flow.session
	log.store_line("X655 ENTERED state=%s has_puzzle=%s pid=<%s> elo=%.2f last_failure=<%s>" % [
		session.play_ui_state, session.has_open_puzzle(), session.puzzle_id,
		session.player_elo, flow.stream.last_failure,
	])
	log.flush()
	var entered: String = session.play_ui_state
	log.store_line("X655 PANEL_C5_GATE=%s" % (entered != "S2" and entered != "S4"))
	log.flush()
	flow.control("C5")
	var after: String = session.play_ui_state
	var kind := str(session.confirm_kind)
	log.store_line("X655 C5_ACTIVATED state=%s confirm_kind=<%s> confirm_shown=%s" % [
		after, kind, after == "S2",
	])
	log.flush()
	if after == "S2":
		flow.control("cancel")
		log.store_line("X655 CANCEL state=%s has_puzzle=%s" % [
			session.play_ui_state, session.has_open_puzzle(),
		])
	log.flush()
	var conforming: bool = after == "S2" and kind == "leave_confirm" \
		and str(session.play_ui_state) == "S1"
	log.store_line("X655_PROBE %s" % ("pass" if conforming else "fail"))
	_log = log
	_probe_router.call_deferred()



## J-puzzle-session S2 / NAV.T9 — C2 enters the stream, C5 confirms, Confirm returns to
## mode pick, driven through the shipped `SessionRouter` control entry. The node graph
## mirrors `persist_store_test._boot_router`: a parented PersistStore, AssetResolver and
## PlaytestSeams, booted so the router is in its mode-pick stage.
func _probe_router() -> void:
	var log := _log
	var parent := Node.new()
	root.add_child(parent)
	var persist := PersistStore.new()
	persist.name = "PersistStore"
	persist.memory_backend = {}
	var resolver := AssetResolver.new()
	resolver.name = "AssetResolver"
	var seams := PlaytestSeams.new()
	seams.name = "PlaytestSeams"
	seams.playtest_override = 1
	var router := SessionRouter.new()
	router.name = "SessionRouter"
	parent.add_child(persist)
	parent.add_child(resolver)
	parent.add_child(seams)
	parent.add_child(router)
	router.start()
	await resolver.boot_ready
	await process_frame
	var booted: String = router.stage
	router.handle_control("mode-pick", "C2")
	var entered_stage: String = router.stage
	var confirm_state := ""
	if router.puzzle_flow != null:
		router.handle_control("puzzle-play", "C5")
		confirm_state = str(router.puzzle_flow.session.play_ui_state)
	router.handle_control("puzzle-play", "confirm")
	var left_stage: String = router.stage
	var flow_gone := router.puzzle_flow == null
	log.store_line("X655 ROUTER booted=%s entered=%s C5=%s after_confirm=%s flow_left=%s" % [
		booted, entered_stage, confirm_state, left_stage, flow_gone,
	])
	var ok: bool = entered_stage == SessionRouter.STAGE_PUZZLE_PLAY \
		and confirm_state == "S2" and left_stage == SessionRouter.STAGE_MODE_PICK and flow_gone
	log.store_line("X655 ROUTER_JOURNEY %s" % ("pass" if ok else "fail"))
	log.flush()
	log.close()
	parent.free()
	quit(0)
