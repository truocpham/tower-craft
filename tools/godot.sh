#!/usr/bin/env bash
# Runs Godot 4 from PATH, $GODOT, or the usual install locations (Windows winget, macOS app, Linux).
set -e
if [ -n "$GODOT" ] && [ -x "$GODOT" ]; then exec "$GODOT" "$@"; fi
for c in godot godot4; do command -v "$c" >/dev/null 2>&1 && exec "$c" "$@"; done
W=$(find "$LOCALAPPDATA/Microsoft/WinGet/Packages" -iname 'Godot*console*.exe' 2>/dev/null | head -1)
if [ -n "$W" ]; then exec "$W" "$@"; fi
M="/Applications/Godot.app/Contents/MacOS/Godot"
if [ -x "$M" ]; then exec "$M" "$@"; fi
echo "Godot 4 not found. Install it or set GODOT=/path/to/godot" >&2; exit 127
