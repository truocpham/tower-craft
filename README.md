# Tower Craft

A one-tap house-stacking game for children, made with Godot 4.7 for iPad.

> **TL;DR**
> - Tap to drop a house; stack them as high as you can.
> - Private family project, not for store release.
> - Run the tests: `bash tools/godot.sh --headless --path game -s res://tests/run_tests.gd`
> - On iPad with a free Apple ID the app **expires after 7 days**. Reinstall weekly. See [docs/BUILD_IPAD.md](docs/BUILD_IPAD.md).

## What the game is

- A crane swings a house. One tap drops it.
- Houses that land well stack; sloppy ones are trimmed or tumble.
- Soft sounds, calm music, confetti at 5, 10, 20 and 50 houses, and a smiling sun.
- Optional voice cheers with the child's name.
- Music, sound and voice are set in the parent area (`GameSettings`, `user://settings.cfg`).

## Screens

- **Who is playing:** big profile tiles, skipped with one profile.
- **Title:** child's name, live demo tower, Play, best score, six house styles.
- **Run complete:** score, best, last five, new style, Again and Home. Tap or Space also restarts.
- **Parent area:** hold the corner gear for 3 seconds. Difficulty (Easy default), players (up to four), music, sound, voice, break reminder, reset scores.
- **Styles:** Sunny is open. Rose, Mint, Sky, Clay and Mixed unlock at best 5, 10, 15, 25 and 40.
- **Saves:** profiles in `user://tower_craft.json`, sound toggles in `user://settings.cfg`.

## Quick start

1. Install Godot 4.7 (standard, not .NET) from godotengine.org.
2. Open `game/project.godot` in Godot, or run the game from the command line with `bash tools/godot.sh --path game`.
3. Run the tests:

```
bash tools/godot.sh --headless --path game -s res://tests/run_tests.gd
```

> **Tip:** In a fresh clone, run `bash tools/godot.sh --headless --path game --import` once before the tests.

> **Tip:** `tools/godot.sh` finds Godot on your PATH. If it does not, set `GODOT=/path/to/godot`.

## iPad install

- Build and install from a Mac with Xcode and a free Apple ID.
- Full steps: [docs/BUILD_IPAD.md](docs/BUILD_IPAD.md).

> **Warning:** Apps signed with a free Apple ID **expire after 7 days**. Reinstall from Xcode **every week**. Do not delete the app first, or saved profiles and scores are lost.

## Project layout

- `game/` Godot project (`scenes/`, `scripts/`, `data/`, `tests/`)
- `docs/` build guide (`BUILD_IPAD.md`), asset notes (`ASSETS.md`), spec (`specs/`)
- `tools/godot.sh` runs Godot from PATH, `$GODOT` or a usual install location
- `prototype/` approved browser prototype (feel reference)
- `spec/` product spec (HTML)

## Done and next

<!-- Update this list when a ticket changes state. -->

Done:

- [x] Project skeleton, tuning data and test runner (#1)
- [x] Landing logic and regrow (#2)
- [x] Playable core loop: crane, houses, drop, camera, backdrop (#3)
- [x] Sound, music, confetti, pop-ups and voice cheers (#5)
- [x] iPad export setup and build guide (#6)
- [x] Godot 4.7 alignment (#10)
- [x] README and iPad guide (#11)
- [x] Profiles, title, styles, run complete and parent area (#4, this PR)

Next:

- [x] Move leftover tuning literals into `tuning.tres` (#14)
- [ ] Ticket #18
