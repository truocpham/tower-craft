extends TestCase

var t: Tuning = load("res://data/tuning.tres")


func test_hard_matches_prototype() -> void:
	var h := t.hard
	check_near(h.perfect_tolerance, 0.07, "tolerance")
	check_eq(h.regrow_streak, 3, "streak")
	check_near(h.regrow_amount, 0.12, "regrow")
	check_near(h.swing_speed_start, 1.5, "start")
	check_near(h.swing_speed_growth, 0.045, "growth")
	check_near(h.swing_speed_cap, 3.5, "cap")
	check_near(h.swing_speed(0), 1.5, "speed 0")
	check_near(h.swing_speed(10), 1.95, "speed 10")
	check_near(h.swing_speed(1000), 3.5, "speed capped")


func test_normal_preset() -> void:
	var n := t.normal
	check_near(n.perfect_tolerance, 0.09)
	check_eq(n.regrow_streak, 3)
	check_near(n.regrow_amount, 0.12)
	check_near(n.swing_speed_start, 1.3)
	check_near(n.swing_speed_growth, 0.035)
	check_near(n.swing_speed_cap, 2.8)


func test_easy_preset() -> void:
	var e := t.easy
	check_near(e.perfect_tolerance, 0.12)
	check_eq(e.regrow_streak, 2)
	check_near(e.regrow_amount, 0.15)
	check_near(e.swing_speed_start, 1.1)
	check_near(e.swing_speed_growth, 0.025)
	check_near(e.swing_speed_cap, 2.2)


func test_shared_values() -> void:
	check_near(t.house_width_screen_fraction, 0.3)
	check_near(t.house_width_max_px, 240.0)
	check_near(t.house_width_max_height_fraction, 0.22)
	check_near(t.house_height_units, 1.15)
	check_near(t.stack_step_units, 1.06)
	check_near(t.swing_amplitude_units, 2.4)
	check_near(t.swing_amplitude_max_width_fraction, 0.42)
	check_near(t.gravity_units, 11.0)
	check_near(t.camera_tower_top_screen_fraction, 0.6)
	check_near(t.camera_ease_per_second, 3.5)


func test_preset_lookup() -> void:
	check(t.preset("hard") == t.hard, "hard lookup")
