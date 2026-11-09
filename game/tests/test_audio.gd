extends TestCase
## Toggles, settings persistence, generated sounds, cheers, confetti and sun.

const TMP := "user://test_settings.cfg"


func _manager(s: GameSettings, tts: bool = true) -> AudioManager:
	var a := AudioManager.new()
	a.settings = s
	tree.root.add_child(a)
	await tree.process_frame
	a.tts_available = tts
	return a


func _drop(a: AudioManager) -> void:
	tree.root.remove_child(a)
	a.free()


func test_settings_round_trip() -> void:
	DirAccess.remove_absolute(TMP)
	var s := GameSettings.load_from(TMP)
	check(s.music_on and s.sound_on and s.voice_on, "defaults on")
	s.music_on = false
	s.voice_on = false
	s.player_name = "Mia"
	check_eq(s.save(), OK)
	var t := GameSettings.load_from(TMP)
	check(not t.music_on, "music saved off")
	check(t.sound_on, "sound still on")
	check(not t.voice_on, "voice saved off")
	check_eq(t.player_name, "Mia")
	DirAccess.remove_absolute(TMP)


func test_sound_toggle() -> void:
	var s := GameSettings.new()
	var a: AudioManager = await _manager(s)
	a.play_drop()
	check_eq(a.sound_count, 1, "plays when on")
	s.sound_on = false
	a.play_thud()
	a.play_chime(2)
	check_eq(a.sound_count, 1, "silent when off")
	_drop(a)


func test_music_toggle() -> void:
	var s := GameSettings.new()
	var a: AudioManager = await _manager(s)
	check(a._music.stream != null, "music generated")
	s.music_on = false
	a.apply_settings()
	check(not a.music_playing(), "music off")
	s.music_on = true
	a.apply_settings()
	# A player only reports playing with an audio driver; the headless dummy driver counts.
	check(a._music.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "music loops")
	_drop(a)


func test_voice_toggle_and_name() -> void:
	var s := GameSettings.new()
	s.player_name = "Mia"
	var a: AudioManager = await _manager(s)
	a.tts_available = false
	a.cheer(true)
	check_eq(a.voice_count, 0, "no tts means no voice")
	a.tts_available = true
	s.voice_on = false
	a.cheer(true)
	check_eq(a.voice_count, 0, "voice off")
	s.voice_on = true
	a._voice_id = "x"
	a.cheer(true)
	check_eq(a.voice_count, 1)
	check(a.last_voice.contains("Mia"), "cheer has the name: " + a.last_voice)
	_drop(a)


func test_cheer_lines() -> void:
	for i in 6:
		check(Cheers.line("Leo", i % 2 == 0, i).contains("Leo"), "name in line %d" % i)
	check(Cheers.line("", true, 0).contains("friend"), "fallback name")


func test_chime_rises() -> void:
	for i in range(1, 6):
		check(SfxSynth.chime_freq(i + 1) > SfxSynth.chime_freq(i), "pitch rises at %d" % i)
	check(SfxSynth.chime(1).data.size() > 1000, "chime has samples")
	check(SfxSynth.drop().data.size() > 1000, "drop has samples")
	check(SfxSynth.thud().data.size() > 1000, "thud has samples")


func test_confetti_and_sun() -> void:
	check(Confetti.is_milestone(5) and Confetti.is_milestone(10) and Confetti.is_milestone(20) and Confetti.is_milestone(50), "milestones")
	check(not Confetti.is_milestone(6), "not a milestone")
	var c := Confetti.new()
	c.burst(1080, 1920)
	check(c.pieces.size() > 0, "burst spawns")
	for i in 400:
		c.step(0.02)
	check_eq(c.pieces.size(), 0, "confetti ends")
	var sun := SmilingSun.new()
	sun.cheer()
	check_near(sun.joy, 1.0, "joy")
	for i in 100:
		sun.step(0.02)
	check_near(sun.joy, 0.0, "joy fades")


func test_scene_effects_on_perfects() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	main.settings = GameSettings.new()
	tree.root.add_child(main)
	await tree.process_frame
	main.press()
	var sim: GameSim = main.sim
	for k in 5:
		sim.phase = 0.0
		main.press()
		var n := 0
		while not sim.fall.is_empty() and n < 1000:
			main.advance(0.016)
			n += 1
	check_eq(sim.score, 5, "five perfect houses")
	check(main.confetti.pieces.size() > 0, "confetti at 5 houses")
	check(main.sun.joy > 0.0, "sun reacts")
	check(main.audio.last_sound.begins_with("chime"), "chime played")
	tree.root.remove_child(main)
	main.free()
