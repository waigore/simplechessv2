class_name AdviceParameters
extends RefCounted
## CMP-session-router R7 / CFG.B3 (#892) — reads the deployment-supplied `T9`/`T10`
## pair from one bare-named `advice_parameters.json`, kept out of the router so a
## missing file is still the `""` default (CFG.B5) without engine logging.

## The one file name both presets read at boot. A bare name, not a `res://` route:
## a deploy supplies it, nothing in the tree or the pack carries it, and an absent
## file is the `""` default (CFG.B5).
const FILENAME := "advice_parameters.json"


## The `[endpoint, api_key]` pair, or two empty strings. A pair that is not both
## present and non-empty is no pair, so half of one leaves the `""` default.
static func read(path: String = FILENAME) -> Array:
	var parameters := _parse(path)
	var endpoint_value: Variant = parameters.get("endpoint", "")
	var key_value: Variant = parameters.get("api_key", "")
	if not endpoint_value is String or not key_value is String:
		return ["", ""]
	var endpoint := str(endpoint_value).strip_edges()
	var api_key := str(key_value).strip_edges()
	if endpoint.is_empty() or api_key.is_empty():
		return ["", ""]
	return [endpoint, api_key]


## Any miss — no file, no parse, not an object — is `{}`, never a warning or an
## engine error (`JSON.parse_string` writes one to the log, so the instance parser
## is used and its error is read instead).
static func _parse(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	return json.data if json.data is Dictionary else {}
