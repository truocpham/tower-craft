extends TestCase

const TMP := "user://test_profiles.json"


func _fresh() -> ProfileStore:
	if FileAccess.file_exists(TMP):
		DirAccess.remove_absolute(TMP)
	var s := ProfileStore.new(TMP)
	s.load_file()
	return s


func test_first_run_has_one_default_profile() -> void:
	var s := _fresh()
	check_eq(s.profiles.size(), 1, "one profile")
	check_eq(s.current()["difficulty"], "easy", "Easy default")
	check_eq(s.current()["style"], "sunny", "Sunny default")
	check_eq(s.settings["break_reminder"], false, "break reminder off")


func test_unlock_thresholds() -> void:
	check(Styles.is_unlocked("sunny", 0), "sunny open")
	var want := {"rose": 5, "mint": 10, "sky": 15, "clay": 25, "mixed": 40}
	for k in want:
		check(not Styles.is_unlocked(k, want[k] - 1), "%s locked below %d" % [k, want[k]])
		check(Styles.is_unlocked(k, want[k]), "%s open at %d" % [k, want[k]])
		check_eq(Styles.threshold(k), want[k], "%s threshold" % k)
	check_eq(Styles.ORDER.size(), 6, "six styles")
	check_eq(Styles.newly_unlocked(4, 5), ["rose"], "rose at 5")
	check_eq(Styles.newly_unlocked(4, 16), ["rose", "mint", "sky"], "several at once")
	check_eq(Styles.newly_unlocked(5, 9), [], "none")


func test_save_and_reload() -> void:
	var s := _fresh()
	var id: int = s.current_id
	s.rename(id, "Mia")
	s.set_difficulty(id, "hard")
	s.record_run(id, 6)
	check(s.set_style(id, "rose"), "rose unlocked at 6")
	var b := s.add_profile("Leo")
	s.settings["break_reminder"] = true
	check(s.save(), "saved")
	var r := ProfileStore.new(TMP)
	r.load_file()
	check_eq(r.profiles.size(), 2, "two profiles")
	var p := r.find(id)
	check_eq(p["name"], "Mia")
	check_eq(p["difficulty"], "hard")
	check_eq(p["best"], 6)
	check_eq(p["recent"], [6])
	check_eq(p["style"], "rose")
	check_eq(r.find(b["id"])["name"], "Leo")
	check_eq(r.settings["break_reminder"], true)
	check_eq(r.current_id, id)


func test_locked_style_refused() -> void:
	var s := _fresh()
	check(not s.set_style(s.current_id, "mixed"), "mixed locked")
	check_eq(s.current()["style"], "sunny")


func test_max_four_and_keep_one() -> void:
	var s := _fresh()
	for i in 5:
		s.add_profile("P%d" % i)
	check_eq(s.profiles.size(), 4, "capped at four")
	check(s.add_profile("x").is_empty(), "fifth refused")
	while s.profiles.size() > 1:
		check(s.delete_profile(s.profiles[0]["id"]), "deleted")
	check(not s.delete_profile(s.profiles[0]["id"]), "last one stays")
	check_eq(s.current_id, s.profiles[0]["id"], "current stays valid")


func test_record_run_best_recent_unlock() -> void:
	var s := _fresh()
	var id: int = s.current_id
	var r := s.record_run(id, 3)
	check(r["new_best"], "first score is best")
	check_eq(r["unlocked"], [])
	r = s.record_run(id, 5)
	check_eq(r["unlocked"], ["rose"], "rose unlocked")
	r = s.record_run(id, 2)
	check(not r["new_best"], "lower is not best")
	for n in [1, 1, 1, 1]:
		s.record_run(id, n)
	check_eq(s.current()["recent"], [2, 1, 1, 1, 1], "last five kept")
	check_eq(s.current()["best"], 5)


func test_reset_progress() -> void:
	var s := _fresh()
	var id: int = s.current_id
	s.record_run(id, 12)
	s.set_style(id, "mint")
	s.reset_progress()
	check_eq(s.current()["best"], 0)
	check_eq(s.current()["recent"], [])
	check_eq(s.current()["style"], "sunny")


func test_names_cleaned_and_damaged_file() -> void:
	check_eq(ProfileStore.clean_name("   "), "Player")
	check_eq(ProfileStore.clean_name("Abcdefghijklmnopq").length(), ProfileStore.MAX_NAME)
	var f := FileAccess.open(TMP, FileAccess.WRITE)
	f.store_string("{not json")
	f.close()
	var s := ProfileStore.new(TMP)
	s.load_file()
	check_eq(s.profiles.size(), 1, "falls back to default")
	DirAccess.remove_absolute(TMP)


func test_wrongly_typed_fields_fall_back() -> void:
	var f := FileAccess.open(TMP, FileAccess.WRITE)
	f.store_string('{"current": "x", "settings": "no", "profiles": [{"id": "a", "name": 5, "style": [1], "difficulty": {}, "best": "9", "recent": "none"}, {"id": 1, "name": "Ok", "best": 7, "recent": [3, "x", 4.0]}, 12]}')
	f.close()
	var s := ProfileStore.new(TMP)
	s.load_file()
	check_eq(s.profiles.size(), 2, "bad entry kept with defaults, non-dict dropped")
	var a: Dictionary = s.profiles[0]
	check_eq(a["name"], "Player")
	check_eq(a["style"], "sunny")
	check_eq(a["difficulty"], "easy")
	check_eq(a["best"], 0)
	check_eq(a["recent"], [])
	check_eq(s.profiles[1]["recent"], [3, 4])
	check(s.profiles[0]["id"] != s.profiles[1]["id"], "unique ids")
	check(not s.current().is_empty(), "current valid")
	DirAccess.remove_absolute(TMP)
