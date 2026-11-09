class_name Cheers
extends RefCounted
## Short, kind cheer lines that include the child's name.

const MILESTONE := ["Great job, %s!", "Wow, %s! So tall!", "Hooray, %s!", "Amazing, %s!"]
const PERFECT := ["Perfect, %s!", "Nice one, %s!"]


static func line(child: String, milestone: bool, pick: int) -> String:
	var pool: Array = MILESTONE if milestone else PERFECT
	var nm := child.strip_edges()
	if nm == "":
		nm = "friend"
	return String(pool[absi(pick) % pool.size()]) % nm
