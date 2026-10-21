class_name PresentationAudioTest
extends SceneTree
## #60 — cue mapping, X5 never plays, ambient after board playable, sound-off path.


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
	var fail_stream := AudioStreamWAV.new()
	var m1 := AudioStreamWAV.new()
	var m2 := AudioStreamWAV.new()
	(
		audio
		. bind_assets(
			{
				PresentationAudio.CUE_SELECT: select_stream,
				PresentationAudio.CUE_MOVE: move_stream,
				PresentationAudio.CUE_CHECK: check_stream,
				PresentationAudio.CUE_END: end_stream,
				PresentationAudio.CUE_PUZZLE_FAIL: fail_stream,
				PresentationAudio.BED_M1: m1,
				PresentationAudio.BED_M2: m2,
			}
		)
	)
	var problem := ""
	audio.play_cue(PresentationAudio.CUE_SELECT)
	if audio.last_cue_id != PresentationAudio.CUE_SELECT or audio.cue_play_count != 1:
		problem = "X1 select cue"
	audio.play_cue(PresentationAudio.CUE_MOVE)
	audio.play_cue(PresentationAudio.CUE_CHECK)
	audio.play_cue(PresentationAudio.CUE_END)
	if (
		problem.is_empty()
		and (audio.cue_play_count != 4 or audio.last_cue_id != PresentationAudio.CUE_END)
	):
		problem = "X2–X4 cues"
	var before_x5 := audio.cue_play_count
	audio.play_cue(PresentationAudio.CUE_PUZZLE_FAIL)
	audio.play_cue(PresentationAudio.BED_M1)
	audio.play_cue("missing-id")
	if problem.is_empty() and audio.cue_play_count != before_x5:
		problem = "X5 / unbound / bed must not use play_cue"
	if problem.is_empty() and audio.music_started:
		problem = "ambient must not start before start_ambient"
	audio.start_ambient()
	if problem.is_empty() and not audio.music_started:
		problem = "ambient M1 start"
	var bed_index := audio.music_bed_index
	audio.start_ambient()
	if problem.is_empty() and audio.music_bed_index != bed_index:
		problem = "start_ambient must be idempotent"
	var silent := PresentationAudio.new()
	root.add_child(silent)
	silent.play_cue(PresentationAudio.CUE_SELECT)
	silent.start_ambient()
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
	await process_frame
	await process_frame
	var problem := ""
	if resolver.group_loaded("ambient"):
		problem = "ambient must not load on cold open"
	var audio := presentation.get_node("PresentationAudio") as PresentationAudio
	if problem.is_empty() and (audio == null or audio.music_started):
		problem = "music must stay off on mode-pick"
	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")
	await process_frame
	await process_frame
	if problem.is_empty() and router.stage != "shared-play":
		problem = "shared-play not entered"
	if problem.is_empty() and not resolver.group_loaded("play"):
		problem = "play group required for cues"
	if problem.is_empty() and (not resolver.group_loaded("ambient") or not audio.music_started):
		problem = "ambient after board playable"
	if problem.is_empty() and not audio.has_stream(PresentationAudio.CUE_SELECT):
		problem = "X1 stream not bound from Play O5"
	if problem.is_empty() and not audio.has_stream(PresentationAudio.BED_M1):
		problem = "M1 stream not bound from Ambient O5"
	var before := audio.cue_play_count if audio != null else 0
	if problem.is_empty():
		router.handle_input_commit("e2", "")
		if audio.last_cue_id != PresentationAudio.CUE_SELECT or audio.cue_play_count != before + 1:
			problem = "select must play X1"
	if problem.is_empty():
		before = audio.cue_play_count
		router.handle_input_commit("e2", "e4")
		if audio.last_cue_id != PresentationAudio.CUE_MOVE or audio.cue_play_count != before + 1:
			problem = "move must play X2"
	if problem.is_empty():
		router.handle_control("shared-play", "C4")
		before = audio.cue_play_count
		router.handle_control("shared-play", "confirm")
		if audio.last_cue_id != PresentationAudio.CUE_END or audio.cue_play_count != before + 1:
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
