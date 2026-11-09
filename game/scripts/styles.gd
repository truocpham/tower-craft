class_name Styles
extends RefCounted
## The six house styles and the best score that opens each one.

const ORDER := ["sunny", "rose", "mint", "sky", "clay", "mixed"]
const NAMES := {"sunny": "Sunny", "rose": "Rose", "mint": "Mint", "sky": "Sky", "clay": "Clay", "mixed": "Mixed"}
const THRESHOLDS := {"sunny": 0, "rose": 5, "mint": 10, "sky": 15, "clay": 25, "mixed": 40}


static func threshold(style: String) -> int:
	return THRESHOLDS.get(style, 0)


static func is_unlocked(style: String, best: int) -> bool:
	return THRESHOLDS.has(style) and best >= THRESHOLDS[style]


## Styles whose threshold is crossed when best goes from old_best to new_best.
static func newly_unlocked(old_best: int, new_best: int) -> Array:
	var out: Array = []
	for s in ORDER:
		if old_best < THRESHOLDS[s] and new_best >= THRESHOLDS[s]:
			out.append(s)
	return out


## Palette key used to draw a style's tile (Mixed shows the cream house).
static func art_key(style: String) -> String:
	return "cream" if style == "mixed" else style
