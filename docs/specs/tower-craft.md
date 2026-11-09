---
status: active
milestone: M1
tickets: [1, 2, 3, 4, 5, 6, 10, 11, 14]
---

# Tower Craft

Full product spec with tuning tables: `spec/index.html` (v1.2). The prototype in `prototype/index.html` is the feel and art reference; it must match it at Hard difficulty.

## Problem

Children under 10 in the owner's family have no stacking game made for them. The owner wants a private, safe, one-tap game on an iPad Air, with no store release, ads, purchases or network.

## Users

- Children under 10, playing on an iPad Air by tapping.
- The parent, who sets difficulty, profiles and sound in a gated area, and installs the build from a Mac.

## Behaviours

- A house hangs from a crane hook and swings over a tower on a rope. A tap anywhere drops it. It lands and is judged perfect, partial or miss.
- Perfect: snaps to the tower centre at full width, streak +1. From the streak threshold, each perfect widens the house up to the full starting width.
- Partial: the house is trimmed to the overlap and the overhang tumbles away. Streak resets.
- Miss (no overlap): the whole house falls away and the run ends (one-miss game over, no hearts).
- Score is the number of houses stacked. The camera scrolls up with the tower; the sky shifts from day to space; clouds drift; the ground strip scrolls away.
- Three difficulty presets (Easy default, Normal, Hard = prototype) change tolerance, regrow, swing speed, growth and cap. Values come from `spec/index.html`.
- Profiles: one per child with a name, favourite house style, difficulty and separate best and recent scores (up to four). The name shows on the title screen and in cheers.
- Six house styles (Sunny, Rose, Mint, Sky, Clay, Mixed). Sunny is open; the rest unlock at best score 5, 10, 15, 25, 40. Cosmetic only.
- Feedback: soft sounds, a rising chime on perfect streaks, looping calm music, confetti on milestones, a smiling sun that reacts, optional voice cheers (text to speech) using the child's name.
- Parent area behind a 3-second press-and-hold: difficulty, profiles, music, sound, voice, break reminder (off by default), reset progress.
- Runs on iPad Air (portrait and landscape, safe areas), and on macOS, Windows and Linux for development and tests.
- No network access, ads, purchases, analytics or external links. All data stays on the device.

## Acceptance criteria

- AC-1: A Godot 4 project in `game/` opens and imports headless with no errors, and `tools/godot.sh --headless --path game -s res://tests/run_tests.gd` runs all unit tests and exits non-zero on failure.
- AC-2: All tuning values (three presets plus shared values) live in one data resource, not in scripts.
- AC-3: Landing logic returns perfect, partial or miss correctly for offsets around the tolerance and the miss boundary, and is covered by unit tests at several widths.
- AC-4: Regrow works: after the preset's streak count of perfects each perfect widens the house by the preset amount, capped at the starting width; any non-perfect landing resets the streak.
- AC-5: A swinging house hangs from a rope and hook; a tap, click or Space drops it and it falls under gravity and lands on the tower.
- AC-6: A partial landing trims the house to the overlap and the overhang falls away and leaves the screen.
- AC-7: A miss ends the run immediately with the tower still visible, then shows the run-complete screen.
- AC-8: The camera follows the tower top (about 60 percent of screen height), the sky gradient shifts with altitude, clouds drift and the ground strip scrolls away.
- AC-9: The house art matches the prototype's look (cornice, shuttered windows, door, laundry line, planters) in six palettes, drawn crisply at iPad resolution.
- AC-10: The game plays at the prototype's feel on Hard, and Easy is visibly gentler (wider perfect window, slower swing).
- AC-11: Profiles can be created and chosen; each keeps name, style, difficulty, best score and recent scores across restarts.
- AC-12: Styles unlock at best scores 5, 10, 15, 25 and 40, and locked styles show the score needed.
- AC-13: Settings, profile edits and reset progress are reachable only through a 3-second press-and-hold.
- AC-14: Title, game and run-complete screens exist, show the child's name, score, best and recent scores, and have buttons of at least 64 pt.
- AC-15: Sound effects, looping music, confetti on milestones, perfect pop-ups and optional voice cheers with the child's name work, with separate music, sound and voice toggles.
- AC-16: The game uses no network and has no ads, purchases, analytics or external links.
- AC-17: Project settings and docs let the owner export to iPad Air from a Mac: iOS export preset, orientation, safe areas, and `docs/BUILD_IPAD.md` with the steps, the free Apple ID 7-day reinstall, and Developer Mode.
- AC-18: The layout holds on iPad portrait, iPad landscape and a resized desktop window.
- AC-19: `README.md` is written in a short, scannable style (no emoji): one-line summary, TL;DR box, short bullets, one idea per section, single-action numbered steps. It covers what the game is, a quick start (install Godot, open the project, run the tests), the iPad install and weekly reinstall (linked to `docs/BUILD_IPAD.md`), the project layout, and what is done versus next.
- AC-20: `docs/BUILD_IPAD.md` uses the same style: short numbered single-action steps, with warnings and tips in callouts.
- AC-21: A ticket that changes how to run, test or build, or what is done, updates `README.md` in the same PR.

## Out of scope

App Store and TestFlight release, ads, purchases, accounts, online features, analytics, level modes, power-ups, controller support, any betting or multiplier mechanic, photo or custom-message personalization.

## Decisions

- 2026-11-09: 2D with Godot 4. Why: the approved prototype is a 2D side view and Godot runs on all three dev OSes.
- 2026-11-09: Prototype art is final art. Why: owner approved it.
- 2026-11-09: Private family build, no store release. Why: owner request; free Apple ID install with a weekly reinstall.
- 2026-11-09: Classic one-miss game over, no hearts. Why: owner choice.
- 2026-11-09: Personal touch is the child's name only. Why: owner choice.
- 2026-11-09: Targets iPad Air, built on a MacBook Pro M3 Pro. Why: owner's devices.
- 2026-11-09: README and the iPad guide use a short, scannable ADHD-friendly style without emoji, and each ticket keeps the README current. Why: owner choice, so the weekly reinstall and quick start are easy to find.
- 2026-11-09: Difficulty default is Easy; styles unlock by best score; no currency. Why: proposed defaults the owner accepted.
