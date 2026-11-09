class_name ProfileStore
extends RefCounted
## Profiles and parent settings, saved as JSON in user://. Pure data: no nodes.

const DEFAULT_PATH := "user://tower_craft.json"
const MAX_PROFILES := 4
const MAX_NAME := 12
const RECENT_COUNT := 5
const DIFFICULTIES := ["easy", "normal", "hard"]

var path: String
## Each: {id, name, style, difficulty, best, recent (oldest first)}.
var profiles: Array = []
var current_id: int = -1
var settings: Dictionary = default_settings()
var _next_id: int = 1


static func default_settings() -> Dictionary:
	return {"break_reminder": false}


func _init(p: String = DEFAULT_PATH) -> void:
	path = p


## Loads from disk. A missing or damaged file gives one default profile.
func load_file() -> void:
	profiles.clear()
	settings = default_settings()
	current_id = -1
	_next_id = 1
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		var json := JSON.new()
		if f and json.parse(f.get_as_text()) == OK and json.data is Dictionary:
			_apply(json.data)
	if profiles.is_empty():
		add_profile("Player")
		current_id = profiles[0]["id"]
		save()


func _apply(data: Dictionary) -> void:
	var s = data.get("settings", {})
	if s is Dictionary:
		for k in settings:
			if s.get(k) is bool:
				settings[k] = s[k]
	var plist = data.get("profiles", [])
	if not plist is Array:
		return
	for p in plist:
		if not p is Dictionary or profiles.size() >= MAX_PROFILES:
			continue
		var recent: Array = []
		for r in p.get("recent", []):
			recent.append(int(r))
		var best := maxi(int(p.get("best", 0)), 0)
		var style := str(p.get("style", "sunny"))
		var diff := str(p.get("difficulty", "easy"))
		profiles.append({
			"id": int(p.get("id", _next_id)),
			"name": clean_name(str(p.get("name", ""))),
			"style": style if Styles.is_unlocked(style, best) else "sunny",
			"difficulty": diff if diff in DIFFICULTIES else "easy",
			"best": best,
			"recent": recent.slice(maxi(recent.size() - RECENT_COUNT, 0)),
		})
		_next_id = maxi(_next_id, profiles[-1]["id"] + 1)
	current_id = int(data.get("current", -1))
	if find(current_id).is_empty() and not profiles.is_empty():
		current_id = profiles[0]["id"]


func save() -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify({"version": 1, "current": current_id, "settings": settings, "profiles": profiles}))
	return true


static func clean_name(n: String) -> String:
	n = n.strip_edges().left(MAX_NAME)
	return n if n != "" else "Player"


func can_add() -> bool:
	return profiles.size() < MAX_PROFILES


## Returns the new profile, or {} when full.
func add_profile(n: String) -> Dictionary:
	if not can_add():
		return {}
	var p := {"id": _next_id, "name": clean_name(n), "style": "sunny", "difficulty": "easy", "best": 0, "recent": []}
	_next_id += 1
	profiles.append(p)
	if current_id < 0:
		current_id = p["id"]
	return p


func find(id: int) -> Dictionary:
	for p in profiles:
		if p["id"] == id:
			return p
	return {}


func current() -> Dictionary:
	return find(current_id)


func rename(id: int, n: String) -> void:
	var p := find(id)
	if not p.is_empty():
		p["name"] = clean_name(n)


## The last profile cannot be deleted. Returns true when removed.
func delete_profile(id: int) -> bool:
	if profiles.size() <= 1:
		return false
	for i in profiles.size():
		if profiles[i]["id"] == id:
			profiles.remove_at(i)
			if current_id == id:
				current_id = profiles[0]["id"]
			return true
	return false


func set_difficulty(id: int, d: String) -> void:
	var p := find(id)
	if not p.is_empty() and d in DIFFICULTIES:
		p["difficulty"] = d


## Picks a style; refused when still locked.
func set_style(id: int, style: String) -> bool:
	var p := find(id)
	if p.is_empty() or not Styles.is_unlocked(style, p["best"]):
		return false
	p["style"] = style
	return true


## Records a finished run. Returns {new_best, unlocked}.
func record_run(id: int, score: int) -> Dictionary:
	var p := find(id)
	if p.is_empty():
		return {"new_best": false, "unlocked": []}
	var old: int = p["best"]
	p["recent"].append(score)
	while p["recent"].size() > RECENT_COUNT:
		p["recent"].pop_front()
	p["best"] = maxi(old, score)
	return {"new_best": score > old, "unlocked": Styles.newly_unlocked(old, p["best"])}


## Clears best and recent scores for everyone; styles go back to Sunny.
func reset_progress() -> void:
	for p in profiles:
		p["best"] = 0
		p["recent"] = []
		p["style"] = "sunny"
