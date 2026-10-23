class_name ReleaseSceneTest
extends SceneTree
## CTR-playtest-drive.G2 / ADR-0004 — the release scene carries no playtest seams.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var problem := await _release_problem()
	if problem.is_empty():
		var playtest := (load("res://main.tscn") as PackedScene).instantiate()
		if playtest.get_node_or_null("PlaytestSeams") == null:
			problem = "playtest scene lost PlaytestSeams"
		playtest.free()
	if problem.is_empty():
		quit(0)
		return
	push_error(problem)
	quit(1)


func _release_problem() -> String:
	var packed := load("res://main_release.tscn") as PackedScene
	if packed == null:
		return "release scene missing or does not load"
	var host := packed.instantiate()
	root.add_child(host)
	await process_frame
	await process_frame
	var problem := _seam_problem(host)
	host.queue_free()
	await process_frame
	return problem


func _seam_problem(host: Node) -> String:
	var scene := _export_main_scene("Web Release")
	if scene != "res://main_release.tscn":
		return "the Web Release export starts at %s, not main_release.tscn" % scene
	if (
		host.get_node_or_null("PlaytestSeams") != null
		or host.get_node_or_null("PlaytestHarness") != null
	):
		return "release scene keeps a playtest seam node"
	if host.get_node_or_null("SessionRouter") == null:
		return "release scene loses SessionRouter"
	var router := host.get_node("SessionRouter")
	if router.session_is_paused():
		return "release session starts paused"
	if int(router.play_snapshot().get("seed", -1)) != 0:
		return "release snapshot seed is not 0"
	return ""


## The scene a preset exports at, read from the table `web_export.py` exports
## with (CTR-playtest-drive.G2). Empty when unset, unreadable, or missing the preset.
func _export_main_scene(preset: String) -> String:
	var table_path := OS.get_environment("CHESS_EXPORT_SCENES").strip_edges()
	if table_path.is_empty():
		return ""
	var table: Variant = JSON.parse_string(FileAccess.get_file_as_string(table_path))
	if typeof(table) != TYPE_DICTIONARY:
		return ""
	return str((table as Dictionary).get(preset, ""))
