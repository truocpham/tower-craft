class_name BreakTimer
extends RefCounted
## Counts play time for the break reminder. It only becomes due after enough
## play, and a break is only offered once the current run has ended.

var enabled: bool = false
var limit_seconds: float = 0.0
var elapsed: float = 0.0


func configure(on: bool, minutes: int) -> void:
	enabled = on
	limit_seconds = minutes * 60.0


## Call every frame with whether a run is being played.
func step(delta: float, playing: bool) -> void:
	if enabled and playing:
		elapsed += delta


func is_due() -> bool:
	return enabled and limit_seconds > 0.0 and elapsed >= limit_seconds


## Call when a run has ended. True when the break screen should show now.
func run_ended() -> bool:
	return is_due()


func reset() -> void:
	elapsed = 0.0
