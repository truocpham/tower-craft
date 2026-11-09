extends TestCase
## Shell screens through the real scene, headless.

const TMP := "user://test_screens.json"


func _main(profiles: int = 1) -> Node:
	DirAccess.remove_absolute(TMP)
	var seed_store := ProfileStore.new(TMP)
	seed_store.load_file()
	seed_store.rename(seed_store.current_id, "Mia")
	for i in profiles - 1:
		seed_store.add_profile("Kid%d" % i)
	seed_store.save()
	var main: Node = load("res://scenes/main.tscn").instantiate()
	main.store_path = TMP
	main.settings = GameSettings.load_from("user://test_screens.cfg")
	tree.root.add_child(main)
	return main


func _free(main: Node) -> void:
	tree.root.remove_child(main)
	main.free()
	DirAccess.remove_absolute(TMP)


func _buttons(n: Node, out: Array) -> Array:
	if n is BaseButton:
		out.append(n)
	for c in n.get_children():
		_buttons(c, out)
	return out


func _labels(n: Node, out: Array) -> Array:
	if n is Label or n is Button:
		out.append(n.text)
	for c in n.get_children():
		_labels(c, out)
	return out


func _check_buttons(main: Node, where: String) -> void:
	var bs := _buttons(main.shell, [])
	check(bs.size() > 0, "%s has buttons" % where)
	for b in bs:
		check(b.custom_minimum_size.x >= 64.0 and b.custom_minimum_size.y >= 64.0, "%s button at least 64" % where)
		if b is KButton:
			check(b.icon_kind != "", "%s button has icon" % where)


func test_single_profile_skips_who_and_title_shows_name() -> void:
	var main := _main(1)
	await tree.process_frame
	check_eq(main.screen, main.Screen.START, "title first")
	var texts := _labels(main.shell, [])
	check("Hi, Mia!" in texts, "name on title")
	check("Best 0" in texts, "best on title")
	check("Best 5" in texts and "Best 40" in texts, "locked styles show needed score")
	_check_buttons(main, "title")
	_free(main)


func test_several_profiles_show_who() -> void:
	var main := _main(3)
	await tree.process_frame
	check_eq(main.screen, main.Screen.WHO, "who first")
	var texts := _labels(main.shell, [])
	check("Mia" in texts and "Kid0" in texts and "Kid1" in texts, "names shown")
	_check_buttons(main, "who")
	main.choose_profile(main.store.profiles[1]["id"])
	check_eq(main.screen, main.Screen.START)
	await tree.process_frame
	check("Hi, Kid0!" in _labels(main.shell, []), "chosen name on title")
	_free(main)


func test_run_complete_shows_and_saves() -> void:
	var main := _main(1)
	await tree.process_frame
	main.press()
	var sim: GameSim = main.sim
	for target in [0.0, 0.0, 0.0, 0.0, 0.0, 3.0]:
		sim.phase = asin(clampf(target / sim.amplitude(), -1.0, 1.0))
		main.press()
		var n := 0
		while not sim.fall.is_empty() and n < 1000:
			main.advance(0.016)
			n += 1
	for i in 80:
		main.advance(0.02)
	await tree.process_frame
	check_eq(main.screen, main.Screen.OVER)
	var texts := _labels(main.shell, [])
	check("New style: Rose!" in texts, "rose unlocked at five")
	check("New best 5!" in texts, "new best shown")
	check("Recent" in texts, "recent shown")
	_check_buttons(main, "complete")
	var reloaded := ProfileStore.new(TMP)
	reloaded.load_file()
	check_eq(reloaded.current()["best"], 5, "saved to disk")
	main.press()
	check_eq(main.screen, main.Screen.PLAY, "tap restarts")
	_free(main)


func test_parent_gate_needs_three_second_hold() -> void:
	var main := _main(1)
	await tree.process_frame
	var gates := []
	for n in main.shell.get_children():
		for c in n.get_children():
			if c is ParentGate:
				gates.append(c)
	check_eq(gates.size(), 1, "one corner gate on title")
	var g: ParentGate = gates[0]
	var opened := [false]
	g.opened.connect(func() -> void: opened[0] = true)
	g.begin_hold()
	g.advance(2.9)
	check(not opened[0], "not open at 2.9 s")
	g.cancel_hold()
	g.advance(1.0)
	check(not opened[0], "release resets")
	g.begin_hold()
	g.advance(2.0)
	g.advance(1.1)
	check(opened[0], "open after 3 s")
	check(g.size.x >= 64.0 and g.size.y >= 64.0, "gate is a big target")
	_free(main)


func test_parent_area_edits() -> void:
	var main := _main(1)
	await tree.process_frame
	main.open_parent()
	await tree.process_frame
	check_eq(main.screen, main.Screen.PARENT)
	var texts := _labels(main.shell, [])
	check("Easy" in texts, "Easy default")
	check("Music  On" in texts and "Sound  On" in texts and ("Voice  On" in texts or "Voice  Off" in texts) and "Break  Off" in texts, "toggles")
	_check_buttons(main, "parent")
	main.store.set_difficulty(main.store.current_id, "hard")
	main.close_parent()
	check_eq(main.difficulty, "hard", "difficulty applied")
	_free(main)


func _parent_column_width(size: Vector2i) -> float:
	var main := _main(1)
	tree.root.content_scale_size = Vector2i.ZERO
	tree.root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	tree.root.size = size
	await tree.process_frame
	main.open_parent()
	await tree.process_frame
	await tree.process_frame
	var w := -1.0
	for b in _buttons(main.shell, []):
		if b.text.begins_with("Reset scores"):
			w = (b.get_parent() as Control).size.x
	_free(main)
	return w


func test_parent_area_column_capped_on_wide_windows() -> void:
	var cap: float = load("res://data/tuning.tres").parent_column_max_width
	check(cap > 0.0, "cap set in tuning")
	var wide := await _parent_column_width(Vector2i(3400, 1920))
	check(wide > 0.0 and wide <= cap + 1.0, "wide window column capped (%s)" % wide)
	var narrow := await _parent_column_width(Vector2i(540, 960))
	check(narrow > 0.0 and narrow >= 540.0 - 81.0, "narrow window keeps full width (%s)" % narrow)


## Plays one perfect landing on a fresh run.
func _perfect(main: Node) -> void:
	main.press()
	var sim: GameSim = main.sim
	sim.phase = 0.0
	main.press()
	var n := 0
	while not sim.fall.is_empty() and n < 1000:
		main.advance(0.016)
		n += 1


func test_popup_hidden_on_title_and_menus() -> void:
	var main := _main(2)
	await tree.process_frame
	main.choose_profile(main.store.current_id)
	main.start_play()
	_perfect(main)
	main.confetti.burst(100.0, 100.0)
	check(main.pop_visible(), "pop-up shows after a perfect")
	main.go_home()
	check(not main.pop_visible(), "no pop-up on title")
	check_eq(main.confetti.pieces.size(), 0, "no confetti on title")
	check_eq(main.sun.joy, 0.0, "sun calm on title")
	main.start_play()
	_perfect(main)
	main.go_who()
	check(not main.pop_visible(), "no pop-up on who")
	main.start_play()
	_perfect(main)
	check(main.pop_visible(), "pop-up before new run")
	main.start_play()
	check(not main.pop_visible(), "new run clears pop-up")
	_free(main)


func test_popup_hidden_on_run_complete() -> void:
	var main := _main(1)
	await tree.process_frame
	main.press()
	var sim: GameSim = main.sim
	for target in [0.0, 0.0, 3.0]:
		sim.phase = asin(clampf(target / sim.amplitude(), -1.0, 1.0))
		main.press()
		var n := 0
		while not sim.fall.is_empty() and n < 1000:
			main.advance(0.016)
			n += 1
	# The pop-up normally expires before the run-complete delay ends, so hold it
	# (negative time) to prove the screen switch itself clears it.
	var n2 := 0
	while sim.state != GameSim.State.OVER and n2 < 1000:
		main.advance(0.016)
		n2 += 1
	main.pop_text = "PERFECT x1"
	main.pop_time = -5.0
	main.confetti.burst(100.0, 100.0)
	n2 = 0
	while not main._complete_shown and n2 < 1000:
		check(main.pop_visible(), "pop-up still showing before run complete")
		main.advance(0.02)
		n2 += 1
	check_eq(main.screen, main.Screen.OVER)
	check(not main.pop_visible(), "no pop-up on run complete")
	check_eq(main.confetti.pieces.size(), 0, "no confetti on run complete")
	_free(main)
