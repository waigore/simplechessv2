class_name AdviceParameters
extends RefCounted
## CMP-session-router R7 / #892 — the deployment's `T9`/`T10` pair for this build
## (CFG.B3 / T9 / T10). A deploy act supplies `advice_parameters.json`; the pair it
## carries is the integration value `CMP-advice-client` R6 needs. A missing file, a
## non-object body, a malformed value, or a half-supplied pair is a miss, not an
## error: both values stay `""`, the absence default every no-backend build already
## has (CFG.B5, FAIL.T14). Reading never logs: a build without a backend is ordinary.

## A bare file name, not a `res://` path: the Web main pack is read-only, and a
## deploy-supplied file is read from the process path rather than from the pack.
const PARAMETERS_PATH := "advice_parameters.json"
const FIELD_ENDPOINT := "endpoint"
const FIELD_API_KEY := "api_key"


## The pair as `{endpoint, api_key}`, both stripped; both `""` when either is absent.
static func pair(path: String = PARAMETERS_PATH) -> Dictionary:
	var absent := {FIELD_ENDPOINT: "", FIELD_API_KEY: ""}
	if not FileAccess.file_exists(path):
		return absent
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return absent
	var endpoint := str((parsed as Dictionary).get(FIELD_ENDPOINT, "")).strip_edges()
	var api_key := str((parsed as Dictionary).get(FIELD_API_KEY, "")).strip_edges()
	# B5 — a half-supplied pair is a miss: carry neither half.
	if endpoint.is_empty() or api_key.is_empty():
		return absent
	return {FIELD_ENDPOINT: endpoint, FIELD_API_KEY: api_key}
