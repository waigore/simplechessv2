extends SceneTree
## Isolation for the "4 ObjectDB instances leaked at exit" warning: the shipped game with
## no acceptance drive attached, headless and graphical. Runs no protocol.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var presentation := packed.instantiate() as Presentation
	var harness := presentation.get_node_or_null("PlaytestHarness")
	if harness != null:
		presentation.remove_child(harness)
		harness.free()
	root.add_child(presentation)
	for index in 30:
		await process_frame
	print("BASE frames=30 quit")
	quit(0)
