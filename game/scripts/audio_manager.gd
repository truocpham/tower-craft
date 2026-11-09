class_name AudioManager
extends Node
## Plays generated sounds, looping music and optional voice cheers, each behind
## its own toggle in GameSettings. Voice uses DisplayServer.tts_speak and is
## off when the system has no text to speech voices.

var settings: GameSettings
var tts_available: bool = false
## Test hooks: what was last requested, regardless of audio hardware.
var last_sound: String = ""
var last_voice: String = ""
var sound_count: int = 0
var voice_count: int = 0
var _sfx: AudioStreamPlayer
var _music: AudioStreamPlayer
var _streams: Dictionary = {}
var _voice_id: String = ""
var _pick: int = 0


func _ready() -> void:
	_sfx = AudioStreamPlayer.new()
	_sfx.volume_db = -4.0
	add_child(_sfx)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -14.0
	add_child(_music)
	_streams["drop"] = SfxSynth.drop()
	_streams["thud"] = SfxSynth.thud()
	_music.stream = SfxSynth.music()
	tts_available = DisplayServer.tts_get_voices().size() > 0
	apply_settings()


## Call after changing a toggle.
func apply_settings() -> void:
	if settings == null or _music == null:
		return
	if settings.music_on and not _music.playing:
		_music.play()
	elif not settings.music_on and _music.playing:
		_music.stop()
	if not settings.voice_on and tts_available:
		DisplayServer.tts_stop()


func music_playing() -> bool:
	return _music != null and _music.playing


func _play(key: String, stream: AudioStream) -> void:
	if settings == null or not settings.sound_on:
		return
	last_sound = key
	sound_count += 1
	_sfx.stream = stream
	_sfx.play()


func play_drop() -> void:
	_play("drop", _streams.get("drop"))


func play_thud() -> void:
	_play("thud", _streams.get("thud"))


func play_chime(streak: int) -> void:
	var key := "chime%d" % clampi(streak, 1, SfxSynth.SCALE.size())
	if not _streams.has(key):
		_streams[key] = SfxSynth.chime(streak)
	_play(key, _streams[key])


## Speak a cheer with the child's name. milestone picks the bigger lines.
func cheer(milestone: bool) -> void:
	if settings == null or not settings.voice_on or not tts_available:
		return
	_pick += 1
	last_voice = Cheers.line(settings.player_name, milestone, _pick)
	voice_count += 1
	if _voice_id == "":
		var voices := DisplayServer.tts_get_voices_for_language("en")
		if voices.size() == 0:
			voices = PackedStringArray()
			for v in DisplayServer.tts_get_voices():
				voices.append(v["id"])
		if voices.size() > 0:
			_voice_id = voices[0]
	if _voice_id != "":
		DisplayServer.tts_speak(last_voice, _voice_id, 70, 1.15, 1.0, 0, true)
