extends SceneTree
## Acceptance-only probe (not part of the demo, not committed as demo code): loads the
## demo's main scene, lets it build, hides the coordinate labels, and writes the same
## frame with the same camera settings. Diffing it against the autodrive exercise frame
## isolates the coordinate ink: every differing pixel in the margins is a label pixel, and
## its background is the rendered band underneath. Method copied from the verification
## run (docs/playtest/evidence/issue-63/verify-20261024T000000Z/make_nolabels_probe.gd).

func _initialize() -> void:
	print("[probe] initialize")
	var scene: Node = load("res://main.tscn").instantiate()
	root.add_child(scene)
	_run.call_deferred(scene)


func _run(scene: Node) -> void:
	for i in 200:
		await process_frame
	var view: Node = scene.get("view")
	if view == null:
		print("[probe] no DemoBoardView")
		quit(1)
		return
	var coords := view.get_node_or_null(NodePath("Coordinates"))
	if coords != null:
		coords.visible = false
		print("[probe] coordinates hidden")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var out := OS.get_environment("PROBE_OUT")
	if out == "":
		out = "user://nolabels.png"
	image.save_png(out)
	print("[probe] wrote %s" % out)
	quit(0)
