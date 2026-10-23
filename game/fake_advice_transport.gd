class_name FakeAdviceTransport
extends RefCounted
## Simulated advice peer for headless tests (ADR-0002 Testability). It offers the
## same surface AdviceClient uses from AdviceStreamTransport — `start`, `cancel`,
## `poll`, `is_finished` — records the O1 it was given, and lets a test push
## E1 / E2 by hand. No network, no Stockfish.
##
## It deliberately does not extend the real transport: the coverage build gives
## every main script the same private constant, so a main script that subclasses
## another one inherits a duplicate member.

## Every peer ever used, so a stale update can reach a retired one.
static var all_streams: Array = []
## Every O1 any peer received: one run's request log.
static var all_requests: Array = []
## O2 count across all peers.
static var all_cancels := 0

## Every O1 request this peer received, in order.
var requests: Array = []
## The endpoint the client aimed at.
var endpoint := ""
## How many times O2 was issued.
var cancels := 0
## When true the peer never answers: the move path must not wait on it.
var blocking := false

var _script: Array = []
var _messages: Array = []


func _init(script: Array = []) -> void:
	_script = script
	all_streams.append(self)


func start(url: String, message: Dictionary, _cap_ms: int) -> void:
	endpoint = url
	requests.append(message.duplicate(true))
	all_requests.append(message.duplicate(true))
	if blocking:
		return
	for entry in _script:
		var message_out: Dictionary = entry
		if message_out.has("reason"):
			push_end(str(message_out["reason"]))
		else:
			push_update(message_out)


func cancel() -> void:
	cancels += 1
	all_cancels += 1
	endpoint = ""


func poll() -> Array:
	var messages := _messages
	_messages = []
	return messages


func is_finished() -> bool:
	return false


func push_update(update: Dictionary) -> void:
	_messages.append({"kind": "update", "value": update})


func push_end(reason: String) -> void:
	_messages.append({"kind": "end", "value": {"reason": reason}})
