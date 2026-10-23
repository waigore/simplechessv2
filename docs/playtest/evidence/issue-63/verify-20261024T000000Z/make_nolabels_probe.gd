extends SceneTree
## Verification-only probe (not committed, not part of the demo): loads the
## demo's main scene, waits for it to build, disables the coordinate labels and
## writes a labels-off frame with the same camera/frame settings.

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
