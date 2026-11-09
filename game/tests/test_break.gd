extends TestCase
## Break reminder: the timer, the saved choice and the screen after a run.

const TMP := "user://test_break.json"


func test_timer_only_due_when_on_and_after_enough_play() -> void:
	var t := BreakTimer.new()
	t.configure(false, 10)
	t.step(10000.0, true)
	check(not t.is_due(), "off: never due")
	check(not t.run_ended(), "off: no break after a run")
	t.configure(true, 10)
	t.reset()
	t.step(599.0, true)
	check(not t.run_ended(), "not due before ten minutes")
	t.step(500.0, false)
	check(not t.run_ended(), "time off the play screen does not count")
	t.step(1.0, true)
	check(t.is_due() and t.run_ended(), "due at ten minutes")
	t.reset()
	check(not t.run_ended(), "reset clears it")


func test_options_and_default_in_tuning() -> void:
	var tun: Tuning = load("res://data/tuning.tres")
	check_eq(Array(tun.break_minutes_options), [10, 20, 30], "options")
	check_eq(tun.break_minutes_default, 20, "default")
	var s := ProfileStore.new(TMP)
	s.load_file()
	check_eq(s.settings["break_reminder"], false, "off by default")
	check_eq(s.settings["break_minutes"], 20, "20 by default")
	s.settings["break_reminder"] = true
	s.settings["break_minutes"] = 30
	s.save()
	var r := ProfileStore.new(TMP)
	r.load_file()
	check_eq(r.settings["break_minutes"], 30, "minutes saved")
	check_eq(r.settings["break_reminder"], true, "toggle saved")
	var f := FileAccess.open(TMP, FileAccess.WRITE)
	f.store_string('{"settings": {"break_minutes": 7}, "profiles": []}')
	f = null
	r.load_file()
	check_eq(r.settings["break_minutes"], 20, "unknown minutes fall back to default")
	DirAccess.remove_absolute(TMP)


func _main(on: bool, minutes: int) -> Node:
	DirAccess.remove_absolute(TMP)
	var seed_store := ProfileStore.new(TMP)
	seed_store.load_file()
	seed_store.settings["break_reminder"] = on
	seed_store.settings["break_minutes"] = minutes
	seed_store.save()
	var main: Node = load("res://scenes/main.tscn").instantiate()
	main.store_path = TMP
	main.settings = GameSettings.load_from("user://test_break.cfg")
	tree.root.add_child(main)
	return main


## Plays until the run ends by dropping off to the side.
func _end_run(main: Node) -> void:
	var sim: GameSim = main.sim
	var drops := 0
	while sim.state == GameSim.State.PLAY and drops < 40:
		sim.phase = PI / 2.0
		main.press()
		var n := 0
		while not sim.fall.is_empty() and n < 1000:
			main.advance(0.016)
			n += 1
		drops += 1
	for i in 80:
		main.advance(0.02)


func _texts(n: Node, out: Array) -> Array:
	if n is Label or n is Button:
		out.append(n.text)
	for c in n.get_children():
		_texts(c, out)
	return out


func _free(main: Node) -> void:
	tree.root.remove_child(main)
	main.free()
	DirAccess.remove_absolute(TMP)


func test_break_screen_only_after_run_ends() -> void:
	var main := _main(true, 10)
	await tree.process_frame
	main.start_play()
	main.break_timer.elapsed = 10 * 60.0 + 5.0
	main.advance(0.016)
	check_eq(main.screen, main.Screen.PLAY, "time is up but the run goes on")
	_end_run(main)
	await tree.process_frame
	check_eq(main.screen, main.Screen.BREAK, "break screen after run ends")
	var texts := _texts(main.shell, [])
	check("Time for a break!" in texts and "Keep playing" in texts and "Go home" in texts, "break screen text")
	main.keep_playing()
	check_eq(main.screen, main.Screen.PLAY, "keep playing starts a run")
	check(not main.break_timer.is_due(), "clock restarted")
	_free(main)


func test_no_break_screen_when_off() -> void:
	var main := _main(false, 10)
	await tree.process_frame
	main.start_play()
	main.break_timer.elapsed = 100000.0
	_end_run(main)
	await tree.process_frame
	check_eq(main.screen, main.Screen.OVER, "normal run complete screen")
	_free(main)


func test_go_home_from_break() -> void:
	var main := _main(true, 10)
	await tree.process_frame
	main.start_play()
	for i in 700:
		main.advance(1.0)
		if main.sim.state == GameSim.State.OVER:
			break
	_end_run(main)
	await tree.process_frame
	check_eq(main.screen, main.Screen.BREAK, "break after ten minutes of play time")
	main.break_home()
	check_eq(main.screen, main.Screen.START, "home")
	_free(main)
