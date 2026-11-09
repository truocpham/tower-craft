class_name GameSettings
extends RefCounted
## Minimal persisted settings: sound toggles and the child's name. Ticket 4's
## parent area can edit these fields and call save().

const PATH := "user://settings.cfg"

var music_on: bool = true
var sound_on: bool = true
var voice_on: bool = true
var player_name: String = ""
var path: String = PATH


static func load_from(p: String = PATH) -> GameSettings:
	var s := GameSettings.new()
	s.path = p
	var cfg := ConfigFile.new()
	if cfg.load(p) == OK:
		s.music_on = bool(cfg.get_value("audio", "music", true))
		s.sound_on = bool(cfg.get_value("audio", "sound", true))
		s.voice_on = bool(cfg.get_value("audio", "voice", true))
		s.player_name = str(cfg.get_value("player", "name", ""))
	return s


func save() -> Error:
	var cfg := ConfigFile.new()
	cfg.load(path)  # keep keys other code may have written
	cfg.set_value("audio", "music", music_on)
	cfg.set_value("audio", "sound", sound_on)
	cfg.set_value("audio", "voice", voice_on)
	cfg.set_value("player", "name", player_name)
	return cfg.save(path)
