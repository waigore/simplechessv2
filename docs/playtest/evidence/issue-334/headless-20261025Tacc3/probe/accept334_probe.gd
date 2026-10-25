extends SceneTree
## Throwaway acceptance probe for #334 (acceptance run, parallel id 3).
## Reads the shipped getters directly; it preloads `game/table.gd`, so it does not
## use `table_test.gd`'s helpers. Not part of any deliverable.

const Spec := preload("res://string_table.gd")

const SPEC_COPY := "res://../specs/ux/screens/puzzle-play.md"


func _initialize() -> void:
	var fails := 0
	var keys := PackedStringArray()
	var in_copy := false
	for line in FileAccess.get_file_as_string(SPEC_COPY).split("\n"):
		var row := line.strip_edges()
		if row.begins_with("## "):
			in_copy = row == "## Copy"
			continue
		if not in_copy or not row.begins_with("|"):
			continue
		var cell := row.split("|")[1].strip_edges().to_lower()
		if cell.is_empty() or cell == "key" or cell.contains("---"):
			continue
		keys.append(cell)
	var shipped: PackedStringArray = Spec.puzzle_play_keys()
	print("spec keys=%d shipped keys=%d" % [keys.size(), shipped.size()])
	for k in keys:
		if not shipped.has(k):
			print("MISSING IN TABLE: %s" % k)
			fails += 1
	for k in shipped:
		if not keys.has(k):
			print("EXTRA IN TABLE: %s" % k)
			fails += 1

	var varying := 0
	for loc in Spec.LOCALES:
		var line := "%s: " % loc
		for k in shipped:
			line += "%s=%s | " % [k, Spec.puzzle_play(k, loc)]
		print(line)
	print("mode-pick.puzzle: en=%s zh-Hant=%s ja=%s" % [
		Spec.mode_pick("puzzle", "en"),
		Spec.mode_pick("puzzle", "zh-Hant"),
		Spec.mode_pick("puzzle", "ja")])
	print("locale own names: %s %s %s" % [
		Spec.mode_pick("locale", "en"),
		Spec.mode_pick("locale", "zh-Hant"),
		Spec.mode_pick("locale", "ja")])
	for k in shipped:
		var en: String = Spec.puzzle_play(k, "en")
		var marked: bool = Spec.every_locale_row("puzzle-play", k)
		if marked:
			continue
		varying += 1
		for loc in ["zh-Hant", "ja"]:
			var v: String = Spec.puzzle_play(k, loc)
			if v.is_empty() or v == k:
				print("EMPTY/KEY-EQUAL %s in %s" % [k, loc])
				fails += 1
			if v == en:
				print("EN COPY %s in %s" % [k, loc])
				fails += 1
	print("varying keys=%d" % varying)
	var marked_rows: Array = Spec.EVERY_LOCALE_ROWS["puzzle-play"]
	print("marked rows on puzzle-play=%s" % str(marked_rows))
	var all_marked: Array = []
	for owner in Spec.EVERY_LOCALE_ROWS:
		for k in Spec.EVERY_LOCALE_ROWS[owner]:
			all_marked.append("%s.%s" % [owner, k])
	print("EVERY_LOCALE_ROWS total=%d %s" % [all_marked.size(), str(all_marked)])
	for k in marked_rows:
		for loc in Spec.LOCALES:
			if Spec.puzzle_play(k, loc) != Spec.puzzle_play(k, "en"):
				print("MARKED ROW NOT EN-EQUAL %s in %s" % [k, loc])
				fails += 1
	print("PROBE FAILS=%d" % fails)
	quit(1 if fails > 0 else 0)
