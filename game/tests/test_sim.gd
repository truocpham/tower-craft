extends TestCase

var t: Tuning = load("res://data/tuning.tres")


func _sim(diff: String = "hard") -> GameSim:
	var s := GameSim.new(t, diff)
	s.set_view(1080, 1920)
	return s


## Run until the in-flight house lands.
func _settle(s: GameSim) -> void:
	var n := 0
	while not s.fall.is_empty() and n < 1000:
		s.step(0.016)
		n += 1


func _drop_at(s: GameSim, x: float) -> void:
	# Place the swing so the house is released at x.
	s.phase = asin(clampf(x / s.amplitude(), -1.0, 1.0))
	check(s.drop(), "drop accepted")
	_settle(s)


func test_layout_unit() -> void:
	check_near(GameSim.layout_unit(1080, 1920, t), 240.0, "capped at 240 px")
	check_near(GameSim.layout_unit(600, 2000, t), 180.0, "30 percent of width")
	check_near(GameSim.layout_unit(2000, 500, t), 110.0, "22 percent of height")


func test_drop_falls_and_lands() -> void:
	var s := _sim()
	s.phase = 0.0
	check(s.drop())
	check(not s.drop(), "no second drop while falling")
	check(not s.fall.is_empty())
	_settle(s)
	check_eq(s.blocks.size(), 2, "block added")
	check_eq(s.score, 1)


func test_perfect_snaps() -> void:
	var s := _sim()
	_drop_at(s, 0.03)
	check_near(s.top_block()["cx"], 0.0, "snapped")
	check_eq(s.last_kind, "perfect")
	check(s.debris.is_empty())


func test_partial_trims_and_spawns_debris() -> void:
	var s := _sim()
	_drop_at(s, 0.4)
	check_eq(s.last_kind, "partial")
	check_near(s.top_block()["w"], 0.6, "trimmed width")
	check_near(s.top_block()["lo"], -0.1, "clip lo")
	check_near(s.top_block()["hi"], 0.5, "clip hi")
	check_eq(s.debris.size(), 1)
	check(s.debris[0]["vx"] > 0.0, "tumbles to the right")
	for i in 600:
		s.step(0.05)
	check(s.debris.is_empty(), "debris removed")


func test_miss_ends_run_immediately() -> void:
	var s := _sim()
	_drop_at(s, 1.5)
	check_eq(s.state, GameSim.State.OVER)
	check_eq(s.last_kind, "miss")
	check_eq(s.blocks.size(), 1, "tower unchanged")
	check_eq(s.score, 0)
	check(not s.game_over_ready())
	for i in 30:
		s.step(0.05)
	check(s.game_over_ready(), "game over after delay")


func test_camera_keeps_top_near_sixty_percent() -> void:
	var s := _sim()
	for i in 12:
		_drop_at(s, 0.0)
	for i in 400:
		s.step(0.016)
	var top_screen := s.ground_y() - (s.blocks.size() * t.stack_step_units - s.cam_y) * s.unit_px
	check(absf(top_screen / s.view_h - 0.6) < 0.01, "top at 60 percent, got %s" % str(top_screen / s.view_h))


func test_easy_gentler_than_hard() -> void:
	var e := _sim("easy")
	var h := _sim("hard")
	check(e.preset.perfect_tolerance > h.preset.perfect_tolerance, "wider perfect window")
	check(e.preset.swing_speed(20) < h.preset.swing_speed(20), "slower swing")
	_drop_at(e, 0.1)
	_drop_at(h, 0.1)
	check_eq(e.last_kind, "perfect", "easy forgives 0.1")
	check_eq(h.last_kind, "partial", "hard trims 0.1")


func test_regrow_after_streak() -> void:
	var s := _sim("hard")
	_drop_at(s, 0.4)
	var w: float = s.top_block()["w"]
	for i in 3:
		_drop_at(s, s.top_block()["cx"])
	check_near(s.top_block()["w"], w + 0.12, "regrown")
