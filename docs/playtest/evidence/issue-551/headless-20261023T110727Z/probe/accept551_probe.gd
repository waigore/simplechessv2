extends SceneTree
## Acceptance probe for #551 (independent of the PR's tests). Drives PuzzleSession
## through its player-facing verbs and judges the PTD-difficulty / PTD-game-state
## Elo stories against the numbers in specs/design/stories/.
##
## Run from a checkout of the accepted build:
##   godot --headless --path game --script res://_accept551_probe.gd
## after copying this file into `game/` (it uses the client's `class_name` globals,
## so it must sit in the client root while it runs; remove it afterwards).

var fails := 0


func _tel(event: String, outcome: String, story: String) -> void:
	print(JSON.stringify({"TEL.1": event, "TEL.2": int(Time.get_unix_time_from_system() * 1000.0), "TEL.3": "acc551-probe", "TEL.4": story, "TEL.5": outcome}))


func _judge(story: String, ok: bool, note: String) -> void:
	if not ok:
		fails += 1
	print("%s %s %s" % ["PASS" if ok else "FAIL", story, note])
	_tel("judge", "pass" if ok else "fail", story)


func _jdiy(got: float, want: float, label: String) -> void:
	_judge(label, absf(got - want) < 0.0001, "got %s want %s" % [got, want])


func _record(id: String, rating: int) -> Dictionary:
	return {"PuzzleId": id, "FEN": PuzzleSession.START_FEN, "Moves": ["e2e4", "e7e5"], "Rating": rating, "Themes": ["fork"]}


func _session(records: Array, elo: float) -> PuzzleSession:
	var session := PuzzleSession.new()
	session.player_elo = elo
	session.catalog = records
	return session


func _initialize() -> void:
	# PS1.1 / END.W1 — solve at equal ratings: 1000 + 20 × (1 − 0.5) = 1010.
	var win := _session([_record("w", 1000)], 1000.0)
	win.deal()
	win.place("e7", "e5")
	_jdiy(win.player_elo, 1010.0, "PS1.1 END.W1 equal ratings -> 1010")
	_judge("CFG.ELO_K", absf(win.elo_k - 20.0) < 0.0001, "session elo_k=%s (CFG.ELO_K default 20, range 10-40)" % win.elo_k)

	# PS1.2 / END.L6 — abandon via C4 at equal ratings: 990.
	var abandon := _session([_record("a", 1000)], 1000.0)
	abandon.deal()
	abandon.request_confirm("C4")
	abandon.confirm()
	_jdiy(abandon.player_elo, 990.0, "PS1.2 END.L6 abandon equal ratings -> 990")

	# END.L5 — reveal via C3 at equal ratings: 990.
	var reveal := _session([_record("r", 1000)], 1000.0)
	reveal.deal()
	reveal.request_confirm("C3")
	reveal.confirm()
	_jdiy(reveal.player_elo, 990.0, "PS1.3 END.L5 reveal equal ratings -> 990")

	# fields-persist PS1.7 — no cap at high Elo: 3000 -> 3010.
	var high := _session([_record("h", 3000)], 3000.0)
	high.deal()
	high.place("e7", "e5")
	_jdiy(high.player_elo, 3010.0, "fields-persist 3000 -> 3010 uncapped")

	# The shipped bug's numbers must be gone: K=32 would give 1016 and 984.
	_judge("DIF.Y1-K32", absf(win.player_elo - 1016.0) > 0.5 and absf(abandon.player_elo - 984.0) > 0.5, "no K=32 drift (win=%s abandon=%s)" % [win.player_elo, abandon.player_elo])

	# PTD-game-state P2 / fields-persist — committed Elo survives reopen; failed write keeps prior.
	var store := PersistStore.new()
	store.memory_backend = {}
	store.load_document()
	var first := PuzzleSession.new(ChessRules.new(), store)
	first.last_mode = "puzzle"
	first.player_elo = 3000.0
	first.catalog = [_record("p1", 3000)]
	first.deal()
	first.place("e7", "e5")
	var reopened := PuzzleSession.new(ChessRules.new(), store)
	reopened.restore(store.load_document())
	_jdiy(reopened.player_elo, 3010.0, "PTD-game-state.P2 reopen keeps committed 3010")
	_judge("GS.lastMode", reopened.last_mode == "puzzle", "reopen keeps lastMode=%s" % reopened.last_mode)
	_judge("GS.recentSolved", reopened.recent_solved == ["p1"], "reopen keeps recentSolved=%s" % [reopened.recent_solved])

	var failures: Array = []
	var held := PuzzleSession.new(ChessRules.new(), store)
	held.restore(store.load_document())
	held.catalog = [_record("p2", 3000)]
	held.deal()
	held.save_failed.connect(func() -> void: failures.append(true))
	store.force_write_failure = true
	held.reveal()
	_judge("EX.save-failure", not failures.is_empty(), "failed write raises save-failure (%d)" % failures.size())
	_jdiy(float(store.read_committed()["player_elo"]), 3010.0, "failed write leaves prior commit at 3010")

	print("PROBE_RESULT fails=%d" % fails)
	quit(0 if fails == 0 else 1)
