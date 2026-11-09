extends TestCase

var t: Tuning = load("res://data/tuning.tres")


func _presets() -> Array:
	return [t.easy, t.normal, t.hard]


func test_perfect_just_inside_all_presets() -> void:
	for p in _presets():
		for s in [-1.0, 1.0]:
			var r := Landing.evaluate(0.3, 0.8, 0.3 + s * (p.perfect_tolerance - 0.001), 0.8, p)
			check_eq(r.kind, Landing.Kind.PERFECT, "inside")
			check_near(r.center, 0.3, "snap")
			check_near(r.width, 0.8, "full width")


func test_partial_just_outside_all_presets() -> void:
	for p in _presets():
		for s in [-1.0, 1.0]:
			var r := Landing.evaluate(0.0, 0.8, s * (p.perfect_tolerance + 0.001), 0.8, p)
			check_eq(r.kind, Landing.Kind.PARTIAL, "outside")
			check_near(r.width, 0.8 - (p.perfect_tolerance + 0.001), "trimmed")


func test_partial_right_side() -> void:
	var r := Landing.evaluate(0.0, 0.8, 0.3, 0.8, t.hard)
	check_eq(r.kind, Landing.Kind.PARTIAL)
	check_near(r.width, 0.5, "width")
	check_near(r.center, 0.15, "center")
	check_near(r.overhang_lo, 0.4, "lo")
	check_near(r.overhang_hi, 0.7, "hi")
	check_eq(r.side, 1)


func test_partial_left_side() -> void:
	var r := Landing.evaluate(0.0, 0.8, -0.3, 0.8, t.hard)
	check_eq(r.kind, Landing.Kind.PARTIAL)
	check_near(r.width, 0.5, "width")
	check_near(r.center, -0.15, "center")
	check_near(r.overhang_lo, -0.7, "lo")
	check_near(r.overhang_hi, -0.4, "hi")
	check_eq(r.side, -1)


func test_miss_boundary() -> void:
	# overlap exactly 0.04 -> miss (offset 0.76 with widths 0.8)
	var r := Landing.evaluate(0.0, 0.5, 0.461, 0.5, t.hard)
	check_eq(r.kind, Landing.Kind.MISS, "overlap 0.04 is miss")
	r = Landing.evaluate(0.0, 0.5, -0.461, 0.5, t.hard)
	check_eq(r.kind, Landing.Kind.MISS, "left miss")
	r = Landing.evaluate(0.0, 0.5, 0.459, 0.5, t.hard)
	check_eq(r.kind, Landing.Kind.PARTIAL, "overlap just over 0.04 is partial")
	r = Landing.evaluate(0.0, 0.8, 2.0, 0.8, t.hard)
	check_eq(r.kind, Landing.Kind.MISS, "no overlap")


func test_regrow_at_streak_and_cap() -> void:
	for p in _presets():
		var st := Landing.Stack.new(p)
		var last: Landing
		for i in range(p.regrow_streak):
			last = st.apply(Landing.evaluate(0.0, 0.5, 0.0, 0.5, p))
			if i < p.regrow_streak - 1:
				check_near(last.width, 0.5, "no regrow yet")
		check_eq(st.streak, p.regrow_streak)
		check_near(last.width, 0.5 + p.regrow_amount, "regrown")
		var capped := st.apply(Landing.evaluate(0.0, 0.95, 0.0, 0.95, p))
		check_near(capped.width, 1.0, "capped at 1.0")


func test_streak_reset_on_non_perfect() -> void:
	var p: DifficultyPreset = t.normal
	var st := Landing.Stack.new(p)
	st.apply(Landing.evaluate(0.0, 0.5, 0.0, 0.5, p))
	st.apply(Landing.evaluate(0.0, 0.5, 0.0, 0.5, p))
	check_eq(st.streak, 2)
	st.apply(Landing.evaluate(0.0, 0.5, 0.2, 0.5, p))
	check_eq(st.streak, 0, "partial resets")
	st.apply(Landing.evaluate(0.0, 0.5, 0.0, 0.5, p))
	st.apply(Landing.evaluate(0.0, 0.5, 5.0, 0.5, p))
	check_eq(st.streak, 0, "miss resets")


func test_swing_speed_per_preset() -> void:
	check_near(t.easy.swing_speed(4), 1.2)
	check_near(t.normal.swing_speed(4), 1.44)
	check_near(t.hard.swing_speed(4), 1.68)
	check_near(t.easy.swing_speed(1000), 2.2)
	check_near(t.normal.swing_speed(1000), 2.8)
	check_near(t.hard.swing_speed(1000), 3.5)
