#!/bin/zsh
# #767 acceptance — run the graphical drive in a rendered Godot session.
# Screenshots are captured in-process from the real framebuffer (see drive_graphical.gd).
set -u
WT="${1:-$(pwd)}"
EVID="$WT/docs/playtest/evidence/issue-767/graphical-20261025T221000Z"
mkdir -p "$EVID/screenshots" "$EVID/logs"
LOG="$EVID/logs/drive.log"
/opt/homebrew/bin/godot --path "$WT/game" -s "$EVID/drive_graphical.gd" > "$LOG" 2>&1
echo "exit=$?" | tee -a "$LOG"
grep -E "^STEP" "$LOG"
