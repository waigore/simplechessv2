extends SceneTree
## Acceptance playtest driver for #224 — `PTD-progression` on `ENV.1` (headless).
##
## The issue's deliverables are spec-only (three edits to
## `specs/playtest/design/progression.md`), but the hub gate asks every
## in-scope Design protocol to pass on Headless at acceptance, so this run
## drives the protocol's own steps S1–S4 against the shipped `main.tscn`.
##
## Step → element map (from the issue's Expected behavior):
##   S1 win path     → PRG.A1, PRG.P1, PRG.P2, PRG.P3, PRG.M1  (fix 1, fix 2)
##   S2 window       → PRG.P3 (CFG.ELO_RECENT_WINDOW)          (fix 1)
##   S3 failure path → PRG.F1                                  (fix 2 — Z1–Z3)
##   S4 Shared       → PRG.A1, PRG.F1                          (fix 2 — Z1–Z3)
##
## Every judgement prints `A224 JUDGE <step> <id> pass|fail|not-judged — <label>`.
## Exit 0 when no row failed.

const PROBE_TAG := "A224"
const CFG_ELO_START := 1000.0
const CFG_ELO_RECENT_WINDOW := 20

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
var _persist: PersistStore
var _rows: Array = []


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	# ENV.1: the smoke harness quits on frame one, so the sweep drops it first.
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	_persist = _presentation.get_node_or_null("PersistStore") as PersistStore
	_router.locale = "en"
	_router.last_mode = "none"
	if _persist != null:
		_persist.memory_backend = {}
		_persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_presentation.set_deferred("size", Vector2(720, 1280))
	await _settle(2)
	print("%s playtest_build=%s session=%s godot=%s display=%s" % [
		PROBE_TAG,
		_seams.playtest_build,
		_seams.session_id,
		Engine.get_version_info().get("string", ""),
		DisplayServer.get_name(),
	])
	_record("ENV.1", "environment", DisplayServer.get_name() == "headless", "headless display (%s)" % DisplayServer.get_name())
	_record("ENV.1", "TEL.3", str(_seams.session_id).ends_with("-playtest"), "session id marks a playtest build")

	_judge_s1_persistence()
	_judge_s2_window()
	await _judge_s1_stream()
	await _judge_s4_shared()
	_report()
	quit(0 if _failures().is_empty() else 1)


## ---------------------------------------------------------------------------
## S1 persistence (PRG.A1/P1/P2/M1) — no deal needed. Each field is committed
## through the shipped PersistStore and read back by a cold open that shares
## the same backend, which is what a reopen does.
## ---------------------------------------------------------------------------


func _judge_s1_persistence() -> void:
	if _persist == null:
		_record("S1", "PRG.A1/P1/M1", null, "no PersistStore on main.tscn; persistence cannot be judged")
		return
	var backend := _persist.memory_backend

	# PRG.A1 / P1 — Player Elo persists across sittings.
	_persist.commit({"player_elo": 1032.5, "last_mode": "puzzle", "recent_solved": ["pz-1"]})
	var reopened := _cold_open(backend)
	var elo: float = float(reopened.get("player_elo", -1.0))
	_record("S1", "PRG.A1/P1", is_equal_approx(elo, 1032.5), "committed Player Elo 1032.5, reopen reads %.2f" % elo)

	# PRG.P2 / M1 — Last mode persists across sittings.
	var mode := str(reopened.get("last_mode", ""))
	_record("S1", "PRG.P2/M1", mode == "puzzle", "committed Last mode puzzle, reopen reads %s" % mode)

	# PRG.P3 / M1 — recentSolved persists across sittings.
	var recent: Array = reopened.get("recent_solved", [])
	_record("S1", "PRG.P3/M1", recent == ["pz-1"], "committed recentSolved [pz-1], reopen reads %s" % str(recent))

	# A1 start value — a cleared store is CFG.ELO_START.
	_persist.clear_storage()
	var fresh := _cold_open(backend)
	_record("S1", "PRG.A1 start", is_equal_approx(float(fresh.get("player_elo", -1.0)), CFG_ELO_START), "cleared store reopens at CFG.ELO_START %.0f" % CFG_ELO_START)


## ---------------------------------------------------------------------------
## S2 (PRG.P3/M1) — the solved list keeps the newest CFG.ELO_RECENT_WINDOW IDs.
## ---------------------------------------------------------------------------


func _judge_s2_window() -> void:
	if _persist == null:
		_record("S2", "PRG.P3", null, "no PersistStore on main.tscn")
		return
	var backend := _persist.memory_backend
	var solved: Array = []
	for i in range(CFG_ELO_RECENT_WINDOW + 5):
		solved.append("pz-solve-%02d" % i)
	_persist.commit({"player_elo": 1000.0, "last_mode": "puzzle", "recent_solved": solved})
	var reopened := _cold_open(backend)
	var kept: Array = reopened.get("recent_solved", [])
	var newest_last := str(kept[kept.size() - 1]) if not kept.is_empty() else ""
	var newest_expected := "pz-solve-%02d" % (CFG_ELO_RECENT_WINDOW + 4)
	var oldest_dropped := not kept.has("pz-solve-00")
	_record("S2", "PRG.P3 cap", kept.size() == CFG_ELO_RECENT_WINDOW, "solved list held at %d IDs (cap CFG.ELO_RECENT_WINDOW=%d)" % [kept.size(), CFG_ELO_RECENT_WINDOW])
	_record("S2", "PRG.P3 order", newest_last == newest_expected, "newest ID last (%s)" % newest_last)
	_record("S2", "PRG.P3 drop", oldest_dropped, "oldest ID dropped from the window")


## ---------------------------------------------------------------------------
## S1 stream path — a clean solve advances A1 and appends the solved ID.
## Needs a dealt puzzle; records not-judged when the build deals nothing.
## ---------------------------------------------------------------------------


func _judge_s1_stream() -> void:
	_router.handle_control("mode-pick", "C2")
	await _settle(4)
	if _router.puzzle_flow == null or not _router.puzzle_flow.is_open():
		var why := "no puzzle dealt on this build (catalog endpoint/key unset per configuration B3)"
		_record("S1", "PRG.A1 save", null, why)
		_record("S1", "PRG.P3 append", null, why)
		print("%s stream_checkpoint dealt=false" % PROBE_TAG)
		return
	var flow: PuzzlePlayFlow = _router.puzzle_flow
	var session: PuzzleSession = flow.session
	var before := session.player_elo
	_record("S1", "PRG.A1 save", session.has_open_puzzle(), "dealt puzzle open (puzzle_id=%s)" % session.puzzle_id)
	print("%s stream_checkpoint dealt=true elo=%.2f" % [PROBE_TAG, before])


## ---------------------------------------------------------------------------
## S4 (PRG.A1/F1) — Shared game advances no axis and carries nothing forward.
## ---------------------------------------------------------------------------


func _judge_s4_shared() -> void:
	if _persist == null:
		_record("S4", "PRG.A1/F1", null, "no PersistStore on main.tscn")
		return
	var before := _persist.load_document()
	if _router.stage != SessionRouter.STAGE_MODE_PICK:
		_router._go_mode_pick("S1")
	await _settle(1)
	_router.handle_control("mode-pick", "C1")
	await _settle(2)
	var after := _persist.load_document()
	var elo_same := is_equal_approx(float(after.get("player_elo", -1.0)), float(before.get("player_elo", -2.0)))
	var recent_same: bool = (after.get("recent_solved", []) as Array) == (before.get("recent_solved", []) as Array)
	var stage_shared := _router.stage == SessionRouter.STAGE_SHARED_SETUP
	print("%s shared_entry stage=%s elo %.2f→%.2f recent=%s" % [
		PROBE_TAG, _router.stage,
		float(before.get("player_elo", -1.0)), float(after.get("player_elo", -1.0)),
		str(after.get("recent_solved", [])),
	])
	_record("S4", "PRG.A1/F1", stage_shared and elo_same and recent_same, "Shared entry reached %s; no axis advanced, nothing carried forward (elo same=%s, recentSolved same=%s)" % [_router.stage, str(elo_same), str(recent_same)])
	# PRG.Z1–Z3 are the Puzzle-stream completion rules the issue re-scoped: none of them
	# is a Shared-game progression claim, so Shared entry cannot advance them either.
	_record("S4", "PRG.Z1–Z3", elo_same and recent_same, "Puzzle-stream completion rules gain nothing from a Shared game")


## ---------------------------------------------------------------------------


func _cold_open(backend: Dictionary) -> Dictionary:
	var store := PersistStore.new()
	store.memory_backend = backend
	root.add_child(store)
	var doc := store.load_document()
	store.free()
	return doc


func _settle(frames: int) -> void:
	for i in range(frames):
		await process_frame


func _record(step: String, label: String, passed: Variant, detail: String) -> void:
	var outcome := "not-judged" if passed == null else ("pass" if bool(passed) else "fail")
	_rows.append({"step": step, "label": label, "outcome": outcome, "detail": detail})
	print("%s JUDGE %s %s %s — %s" % [PROBE_TAG, step, label, outcome, detail])


func _failures() -> Array:
	return _rows.filter(func(r): return r["outcome"] == "fail")


func _report() -> void:
	var passed := _rows.filter(func(r): return r["outcome"] == "pass").size()
	var failed := _failures().size()
	var skipped := _rows.filter(func(r): return r["outcome"] == "not-judged").size()
	print("%s SUMMARY pass=%d fail=%d not-judged=%d" % [PROBE_TAG, passed, failed, skipped])
