class_name Landing
extends RefCounted
## Pure landing rules: no nodes. Widths and positions are in world units,
## full house width is 1.0 (see prototype land()).

enum Kind { PERFECT, PARTIAL, MISS }

## Overlap at or below this counts as a miss.
const MISS_OVERLAP := 0.04
const MAX_WIDTH := 1.0

var kind: Kind = Kind.MISS
## Center and width of the block that stays on the tower (PERFECT/PARTIAL).
var center: float = 0.0
var width: float = 0.0
## Interval [overhang_lo, overhang_hi] of the dropped house that falls off.
## For a MISS it is the whole dropped house.
var overhang_lo: float = 0.0
var overhang_hi: float = 0.0
## +1 when the dropped house is right of the top block, -1 when left.
var side: int = 0


## Evaluate a drop of a house (drop_center, drop_width) onto the top block.
static func evaluate(top_center: float, top_width: float, drop_center: float, drop_width: float, preset: DifficultyPreset) -> Landing:
	var r := Landing.new()
	var delta := drop_center - top_center
	r.side = 1 if delta > 0.0 else -1
	if absf(delta) < preset.perfect_tolerance:
		r.kind = Kind.PERFECT
		r.center = top_center
		r.width = drop_width
		r.side = 0
		return r
	var lo := maxf(drop_center - drop_width / 2.0, top_center - top_width / 2.0)
	var hi := minf(drop_center + drop_width / 2.0, top_center + top_width / 2.0)
	var overlap := hi - lo
	if overlap <= MISS_OVERLAP:
		r.kind = Kind.MISS
		r.overhang_lo = drop_center - drop_width / 2.0
		r.overhang_hi = drop_center + drop_width / 2.0
		return r
	r.kind = Kind.PARTIAL
	r.center = (lo + hi) / 2.0
	r.width = overlap
	if delta > 0.0:
		r.overhang_lo = hi
		r.overhang_hi = drop_center + drop_width / 2.0
	else:
		r.overhang_lo = drop_center - drop_width / 2.0
		r.overhang_hi = lo
	return r


## Tracks the perfect streak and applies regrow.
class Stack:
	extends RefCounted
	var preset: DifficultyPreset
	var streak: int = 0

	func _init(p: DifficultyPreset) -> void:
		preset = p

	## Apply a landing result: updates streak, and for a perfect landing
	## widens the result (capped at 1.0) once the streak reaches the preset count.
	func apply(r: Landing) -> Landing:
		if r.kind == Landing.Kind.PERFECT:
			streak += 1
			if streak >= preset.regrow_streak:
				r.width = minf(r.width + preset.regrow_amount, Landing.MAX_WIDTH)
		else:
			streak = 0
		return r

	func reset() -> void:
		streak = 0
