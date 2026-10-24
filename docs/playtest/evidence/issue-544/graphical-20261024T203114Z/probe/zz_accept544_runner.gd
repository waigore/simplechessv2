extends SceneTree
## Headless runner for the #544 acceptance probe: boots `main.tscn`, then adds the
## probe node so the real PlaytestSeams / SessionRouter wiring is exercised.


func _initialize() -> void:
	var main: Node = load("res://main.tscn").instantiate()
	# The ENV.1 smoke harness quits on the first headless frame; the probe needs a
	# live session, so its `_ready` is never reached (main_release.tscn carries it neither).
	var harness := main.get_node_or_null("PlaytestHarness")
	if harness != null:
		harness.set_process(false)
		harness.process_mode = Node.PROCESS_MODE_DISABLED
		harness.set_script(null)
	root.add_child(main)
	var probe: Node = load("res://zz_accept544_probe4.gd").new()
	probe.name = "Accept544Probe"
	root.add_child(probe)
