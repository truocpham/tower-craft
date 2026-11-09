extends TestCase
## Scripted run through the real scene, headless.


func test_scripted_run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(main)
	await tree.process_frame
	check_eq(main.screen, main.Screen.START, "start screen")
	main.press()
	check_eq(main.screen, main.Screen.PLAY, "playing")
	var sim: GameSim = main.sim
	# Three centered drops, then a trimmed one, then a miss.
	for target in [0.0, 0.0, 0.0, 0.5, 3.0]:
		sim.phase = asin(clampf(target / sim.amplitude(), -1.0, 1.0))
		main.press()
		var n := 0
		while not sim.fall.is_empty() and n < 1000:
			main.advance(0.016)
			n += 1
	check_eq(sim.score, 4, "four houses placed")
	check_eq(main.screen, main.Screen.OVER, "run ended on miss")
	for i in 80:
		main.advance(0.02)
	check(sim.game_over_ready())
	main.press()
	check_eq(main.screen, main.Screen.PLAY, "restarted")
	check_eq(main.sim.score, 0)
	tree.root.remove_child(main)
	main.free()
