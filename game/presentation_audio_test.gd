class_name PresentationAudioTest
extends SceneTree
## #60 / #426 — cue mapping, X5 never plays, ambient at mode-pick ready, sound-off path.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var unit_err := _unit_audio()
	if not unit_err.is_empty():
		_fail(unit_err)
		return
	var err := await _integration_spine()
	if not err.is_empty():
		_fail(err)
		return
	quit(0)


func _unit_audio() -> String:
	var audio := PresentationAudio.new()
	root.add_child(audio)
	var select_stream := AudioStreamWAV.new()
	var move_stream := AudioStreamWAV.new()
	var check_stream := AudioStreamWAV.new()
	var end_stream := AudioStreamWAV.new()
	var m1 := AudioStreamWAV.new()
	var m2 := AudioStreamWAV.new()
	(
		audio
		. bind_assets(
			{
				SharedAudioCues.CUE_SELECT: select_stream,
				SharedAudioCues.CUE_MOVE: move_stream,
				SharedAudioCues.CUE_CHECK: check_stream,
				SharedAudioCues.CUE_END: end_stream,
				SharedAudioCues.BED_M1: m1,
				SharedAudioCues.BED_M2: m2,
			}
		)
	)
	var problem := ""
	audio.play_cue(SharedAudioCues.CUE_SELECT)
	if audio.last_cue_id != SharedAudioCues.CUE_SELECT or audio.cue_play_count != 1:
		problem = "X1 select cue"
	audio.play_cue(SharedAudioCues.CUE_MOVE)
	audio.play_cue(SharedAudioCues.CUE_CHECK)
	audio.play_cue(SharedAudioCues.CUE_END)
	if (
		problem.is_empty()
		and (audio.cue_play_count != 4 or audio.last_cue_id != SharedAudioCues.CUE_END)
	):
		problem = "X2–X4 cues"
	var before_unbound := audio.cue_play_count
	## Wave 2 X5 UUID — Wave 1 never binds or calls it; unbound stays silent.
	audio.play_cue("01a151f8-b7d8-759c-89c5-e1be5eecb2b2")
	audio.play_cue("missing-id")
	if problem.is_empty() and audio.cue_play_count != before_unbound:
		problem = "unbound / X5 must stay silent"
	if problem.is_empty() and audio.music_started:
		problem = "ambient must not start before O3 bed cue"
	audio.play_cue(SharedAudioCues.BED_M1)
	if problem.is_empty() and not audio.music_started:
		problem = "ambient M1 start via O3"
	if problem.is_empty() and audio.cue_play_count != before_unbound:
		problem = "bed O3 must not count as SFX cue"
	var bed_index := audio.music_bed_index
	audio.play_cue(SharedAudioCues.BED_M1)
	if problem.is_empty() and audio.music_bed_index != bed_index:
		problem = "ambient O3 must be idempotent"
	## M1 → M2 → M1 rotation on finished.
	if problem.is_empty():
		audio._on_music_finished()
		if audio.music_bed_index != 1:
			problem = "M1 finished must advance to M2"
	if problem.is_empty():
		audio._on_music_finished()
		if audio.music_bed_index != 0:
			problem = "M2 finished must return to M1"
	var silent := PresentationAudio.new()
	root.add_child(silent)
	silent.play_cue(SharedAudioCues.CUE_SELECT)
	silent.play_cue(SharedAudioCues.BED_M1)
	if problem.is_empty() and (silent.cue_play_count != 0 or silent.music_started):
		problem = "sound-off path must stay silent"
	return problem


func _integration_spine() -> String:
	var packed := load("res://main.tscn") as PackedScene
	var presentation := packed.instantiate() as Presentation
	var harness := presentation.get_node("PlaytestHarness")
	presentation.remove_child(harness)
	harness.free()
	var router := presentation.get_node("SessionRouter") as SessionRouter
	var resolver := presentation.get_node("AssetResolver") as AssetResolver
	var persist := presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(presentation)
	## Cold open (EX.loading) stays silent; Ambient starts only at mode-pick ready.
	var problem := ""
	var audio := presentation.get_node("PresentationAudio") as PresentationAudio
	if resolver.group_loaded("ambient"):
		problem = "ambient must not load on cold open"
	if problem.is_empty() and (audio == null or audio.music_started):
		problem = "music must stay off on cold open"
	await process_frame
	await process_frame
	if problem.is_empty() and router.stage != "mode-pick":
		problem = "mode pick not ready"
	if problem.is_empty() and (not resolver.group_loaded("ambient") or not audio.music_started):
		problem = "ambient and bed must start when mode pick is ready"
	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")
	await process_frame
	await process_frame
	if problem.is_empty() and router.stage != "shared-play":
		problem = "shared-play not entered"
	if problem.is_empty() and not resolver.group_loaded("play"):
		problem = "play group required for cues"
	if problem.is_empty() and (not resolver.group_loaded("ambient") or not audio.music_started):
		problem = "ambient and bed must stay through shared play"
	if problem.is_empty() and not audio.has_stream(SharedAudioCues.CUE_SELECT):
		problem = "X1 stream not bound from Play O5"
	if problem.is_empty() and not audio.has_stream(SharedAudioCues.BED_M1):
		problem = "M1 stream not bound from Ambient O5"
	var before := audio.cue_play_count if audio != null else 0
	if problem.is_empty():
		router.handle_input_commit("e2", "")
		if audio.last_cue_id != SharedAudioCues.CUE_SELECT or audio.cue_play_count != before + 1:
			problem = "select must play X1"
	if problem.is_empty():
		before = audio.cue_play_count
		router.handle_input_commit("e2", "e4")
		if audio.last_cue_id != SharedAudioCues.CUE_MOVE or audio.cue_play_count != before + 1:
			problem = "move must play X2"
	## Draw path: no end cue (stalemate / agreed draw not forced here — resign is loss).
	## Confirm draw ending via unit: END.D* must not raise cue_play_count when routed.
	if problem.is_empty():
		before = audio.cue_play_count
		## Direct O3 with no loss: router only cues END on loss; draw leaves count.
		if not router._is_loss_end("END.D1") and not router._is_loss_end("END.D5"):
			pass
		else:
			problem = "draw endings must not count as loss cues"
		if problem.is_empty() and audio.cue_play_count != before:
			problem = "draw check must not play a cue"
	if problem.is_empty():
		router.handle_control("shared-play", "C4")
		before = audio.cue_play_count
		router.handle_control("shared-play", "confirm")
		if audio.last_cue_id != SharedAudioCues.CUE_END or audio.cue_play_count != before + 1:
			problem = "resign must play X4"
	if problem.is_empty():
		router.handle_control("shared-result", "C2")
		await process_frame
		await process_frame
		if not resolver.group_loaded("ambient") or not audio.music_started:
			problem = "ambient must stay for the sitting after mode-pick return"
	return problem


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
