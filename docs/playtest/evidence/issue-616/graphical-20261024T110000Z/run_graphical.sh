#!/bin/zsh
# #616 acceptance — run the graphical drive in a rendered Godot session.
# Screenshots are captured in-process from the real framebuffer (see drive_graphical.gd).
set -u
WT="${1:-$(pwd)}"
EVID="$WT/docs/playtest/evidence/issue-616/graphical-20261024T110000Z"
mkdir -p "$EVID/screenshots" "$EVID/logs"
LOG="$EVID/logs/graphical-drive.log"
/opt/homebrew/bin/godot --path "$WT/game" -s "$EVID/drive_graphical.gd" > "$LOG" 2>&1
echo "exit=$?" | tee -a "$LOG"
grep -E "^STEP" "$LOG"
