extends SceneTree
## Acceptance probe for #432 — every draw ending plays no end cue; losses keep SND.X4.
## Independent of game/presentation_audio_test.gd: drives the real router control paths.

var _fails: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var presentation := packed.instantiate() as Presentation
	var harness := presentation.get_node("PlaytestHarness")
	presentation.remove_child(harness)
	harness.free()
	var router := presentation.get_node("SessionRouter") as SessionRouter
	var persist := presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(presentation)
	await process_frame
	await process_frame
	var audio := presentation.get_node("PresentationAudio") as PresentationAudio
	print("ACCEPT build=", str(ProjectSettings.get_setting("application/config/version", "?")))
	print("ACCEPT stage=", router.stage)

	# --- classification: draws are not loss ends, losses are ---
	for d in ["END.D1", "END.D2", "END.D3", "END.D4", "END.D5"]:
		var is_loss: bool = router._is_loss_end(d)
		print("ACCEPT classify ", d, " is_loss=", is_loss)
		if is_loss:
			_fails.append(d + " classified as loss")
	for l in ["END.L1", "END.L2", "END.L3"]:
		var is_loss_l: bool = router._is_loss_end(l)
		print("ACCEPT classify ", l, " is_loss=", is_loss_l)
		if not is_loss_l:
			_fails.append(l + " not classified as loss")

	# --- END.D2 accept-draw control path (C7) ---
	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")
	await process_frame
	await process_frame
	print("ACCEPT stage=", router.stage, " reason_before=", ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")))
	var waits := 0
	while not audio.has_stream(SharedAudioCues.CUE_END) and waits < 300:
		await process_frame
		waits += 1
	print("ACCEPT audio_ready=", audio.has_stream(SharedAudioCues.CUE_END), " waited_frames=", waits)
	router.handle_control("shared-play", "C5")
	router.handle_control("shared-play", "confirm")
	var before := audio.cue_play_count
	var last_before := audio.last_cue_id
	router.handle_control("shared-play", "C7")
	var after := audio.cue_play_count
	print("ACCEPT D2 accept-draw stage=", router.stage,
		" end_reason=", ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")),
		" cue_count=", before, "->", after, " last_cue=", audio.last_cue_id)
	if router.stage != "shared-result":
		_fails.append("D2 accept-draw did not reach shared-result")
	if ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")) != "END.D2":
		_fails.append("D2 accept-draw end reason is " + ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")))
	if after != before:
		_fails.append("D2 accept-draw played a cue (count " + str(before) + "->" + str(after) + ")")
	if audio.last_cue_id != last_before:
		_fails.append("D2 accept-draw changed last_cue to " + audio.last_cue_id)

	# --- control sanity: select X1 / move X2 still cue (audio plumbing live) ---
	router.handle_control("shared-result", "C1")
	router.handle_control("shared-setup", "C5")
	await process_frame
	print("ACCEPT sanity stage=", router.stage, " ui_state=", router.shared_session.play_ui_state,
		" gestures=", router.shared_session.gestures_available())
	before = audio.cue_play_count
	router.handle_input_commit("e2", "")
	print("ACCEPT sanity select cue_count=", before, "->", audio.cue_play_count, " last=", audio.last_cue_id)
	if audio.cue_play_count != before + 1 or audio.last_cue_id != SharedAudioCues.CUE_SELECT:
		_fails.append("select did not play X1 in probe")
	before = audio.cue_play_count
	router.handle_input_commit("e2", "e4")
	print("ACCEPT sanity move cue_count=", before, "->", audio.cue_play_count, " last=", audio.last_cue_id)
	if audio.cue_play_count != before + 1 or audio.last_cue_id != SharedAudioCues.CUE_MOVE:
		_fails.append("move did not play X2 in probe")

	# --- END.L2 resign control path keeps X4 ---
	router.handle_control("shared-result", "C1")
	router.handle_control("shared-setup", "C5")
	await process_frame
	before = audio.cue_play_count
	router.handle_control("shared-play", "C4")
	router.handle_control("shared-play", "confirm")
	after = audio.cue_play_count
	print("ACCEPT L2 resign stage=", router.stage, " end_reason=", ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")),
		" cue_count=", before, "->", after, " last_cue=", audio.last_cue_id)
	if router.stage != "shared-result":
		_fails.append("L2 resign did not reach shared-result")
	if after != before + 1 or audio.last_cue_id != SharedAudioCues.CUE_END:
		_fails.append("L2 resign did not play exactly one X4 end cue")

	# --- END.D5 real clock-expiry draw: K vs K (no possible mate) via blitz clock ---
	router.handle_control("shared-result", "C1")
	router.handle_control("shared-setup", "C2")
	print("ACCEPT D5 clock selected=", router.clock)
	router.handle_control("shared-setup", "C5")
	await process_frame
	router.shared_session.rules.load_position(
		[
			{"square": "e1", "color": ChessRules.SIDE_WHITE, "kind": ChessRules.KIND_KING},
			{"square": "e8", "color": ChessRules.SIDE_BLACK, "kind": ChessRules.KIND_KING},
		],
		ChessRules.SIDE_WHITE,
	)
	print("ACCEPT D5 mate_possible_for_black=", router.shared_session.rules.possible_checkmate(ChessRules.SIDE_BLACK))
	before = audio.cue_play_count
	var guard := 0
	while router.stage == "shared-play" and guard < 20000:
		router._process(1.0)
		guard += 1
	print("ACCEPT D5 expiry stage=", router.stage,
		" end_reason=", ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")),
		" cue_count=", before, "->", audio.cue_play_count, " last=", audio.last_cue_id,
		" ticks=", guard)
	if router.stage != "shared-result":
		_fails.append("D5 clock expiry did not reach shared-result")
	if ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")) != "END.D5":
		_fails.append("D5 case did not end as END.D5")
	if audio.cue_play_count != before:
		_fails.append("D5 clock-expiry draw played a cue")

	# --- END.D1 stalemate via move-commit path: K+Q vs K, Qg6?? no — use Qf7-f6 stalemate ---
	router.handle_control("shared-result", "C1")
	router.handle_control("shared-setup", "C5")
	await process_frame
	router.shared_session.rules.load_position(
		[
			{"square": "a8", "color": ChessRules.SIDE_BLACK, "kind": ChessRules.KIND_KING},
			{"square": "b6", "color": ChessRules.SIDE_WHITE, "kind": ChessRules.KIND_QUEEN},
			{"square": "c6", "color": ChessRules.SIDE_WHITE, "kind": ChessRules.KIND_KING},
		],
		ChessRules.SIDE_WHITE,
	)
	## Waiting king move Kc6–d6: Ka8 has no legal move and is not in check → stalemate.
	await process_frame
	before = audio.cue_play_count
	router.handle_input_commit("c6", "d6")
	await process_frame
	var end_cues := audio.cue_play_count - before
	print("ACCEPT D1 stalemate stage=", router.stage,
		" end_reason=", ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")),
		" total_cues_delta=", end_cues, " last=", audio.last_cue_id,
		" end_cue_played=", audio.last_cue_id == SharedAudioCues.CUE_END)
	if router.stage != "shared-result":
		_fails.append("D1 stalemate did not reach shared-result")
	if ((router.shared_session.play_state().get("game_ended", {}) as Dictionary).get("reason", "")) != "END.D1":
		_fails.append("D1 case did not end as END.D1")
	## The move itself cues X2; a draw must add no X4 end cue on top.
	if end_cues != 1 or audio.last_cue_id != SharedAudioCues.CUE_MOVE:
		_fails.append("D1 stalemate non-move cue present (delta " + str(end_cues) + ", last " + audio.last_cue_id + ")")

	if _fails.is_empty():
		print("ACCEPT PROBE PASS")
		quit(0)
	else:
		for f in _fails:
			print("ACCEPT PROBE FAIL: ", f)
		quit(1)
