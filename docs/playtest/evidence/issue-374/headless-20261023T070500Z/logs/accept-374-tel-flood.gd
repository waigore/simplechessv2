extends SceneTree
## Observability side-check for #374: how often one advice failure is reported.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var session := SharedGameSession.new()
	var client := AdviceClient.new()
	client.configure("http://127.0.0.1:1/advice", "accept-key", -1)
	session.advice_client = client
	session.start_shared("untimed", 3, true)
	var events := 0
	var frames := 0
	while frames < 60:
		events += (session.advice_control("poll").get("events", []) as Array).size()
		frames += 1
		await process_frame
	print("FLOOD frames=", frames, " advice_error_events=", events, " online=", session.online)
	if events > 1:
		print("FLOOD FAIL: one failure is reported on every poll while offline")
		quit(1)
	else:
		print("FLOOD PASS")
		quit(0)
