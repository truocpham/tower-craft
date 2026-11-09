# Tower Craft

A one-tap house-stacking game for children, built with Godot 4.7 or newer (2D) for iPad. Private family project, not for store release.

- `prototype/` approved browser prototype (feel reference)
- `spec/` product spec (HTML)
- `game/` Godot project
- `docs/ASSETS.md` asset notes (sounds are generated in code, nothing downloaded)

Audio: soft drop and thud sounds, a rising chime on each perfect, calm looping music, confetti at 5, 10, 20 and 50 houses, a smiling sun, and optional voice cheers with the child's name. Music, sound and voice toggles live in `GameSettings` (`user://settings.cfg`). Tests: `bash tools/godot.sh --headless --path game -s res://tests/run_tests.gd`.
