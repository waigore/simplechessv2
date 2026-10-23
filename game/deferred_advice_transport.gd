class_name DeferredAdviceTransport
extends RefCounted
## #559 simulated advice peer (ADR-0002 Testability) whose E1 is only readable on
## the poll that follows `start`. `FakeAdviceTransport` scripts its update into
## `start`, so timing it would read ~0 ms and always pass; here the client must
## return from `start` before any update exists, which is what makes
## `AdviceClient.elapsed_ms()` a real deferred delivery.
##
## No network and no Stockfish: production never constructs it.

## Every O1 request this peer received, in order.
var requests: Array = []
## How many times the client polled this peer.
var polls := 0
## How many messages this peer handed to the client.
var delivered := 0
## The endpoint the client aimed at; empty after O2.
var endpoint := ""

var _script: Array = []
var _readable: Array = []


func _init(script: Array = []) -> void:
	_script = script


func start(url: String, message: Dictionary, _cap_ms: int) -> void:
	endpoint = url
	requests.append(message.duplicate(true))
	# The E1 arrives with O1 but is not readable yet: it is released by the next
	# `poll()`, never inside `start`.
	_readable = []
	for entry in _script:
		var scripted: Dictionary = entry
		if scripted.has("reason"):
			_readable.append({"kind": "end", "value": {"reason": str(scripted["reason"])}})
		else:
			_readable.append({"kind": "update", "value": scripted.duplicate(true)})


func cancel() -> void:
	endpoint = ""
	_readable.clear()


func poll() -> Array:
	polls += 1
	var messages := _readable
	_readable = []
	delivered += messages.size()
	return messages


func is_finished() -> bool:
	return false
