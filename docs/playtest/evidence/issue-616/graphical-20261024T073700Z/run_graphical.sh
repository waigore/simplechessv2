#!/usr/bin/env bash
# #616 acceptance — run the graphical drive in a rendered Godot session (re-recorded for #742).
#
# Screenshots are captured in-process from the real framebuffer (see drive_graphical.gd).
# On a host with no display this wraps the run in a virtual one (xvfb-run), which is a
# real rendered session on a software rasteriser — `ENV.2` graphical, and the manifest
# names the adapter the engine reports so the claim is checkable.
#
# Usage: run_graphical.sh [WORKTREE] [GODOT_BIN]
set -u
WT="${1:-$(pwd)}"
GODOT="${2:-${GODOT_BIN:-godot}}"
RUN_ID="graphical-20261024T073700Z"
EVID="$WT/docs/playtest/evidence/issue-616/$RUN_ID"
mkdir -p "$EVID/screenshots" "$EVID/logs"
LOG="$EVID/logs/graphical-drive.log"

# The drive is loaded from inside `game/` so `res://` class_name resolution works.
cp "$EVID/drive_graphical.gd" "$WT/game/zz_616_drive.gd"

DISPLAY_CMD=()
if [ -z "${DISPLAY:-}" ]; then
	DISPLAY_CMD=(xvfb-run -a -s "-screen 0 1920x1080x24")
fi

"${DISPLAY_CMD[@]}" "$GODOT" --path "$WT/game" --rendering-driver opengl3 -s res://zz_616_drive.gd \
	> "$LOG" 2>&1
CODE=$?
echo "exit=$CODE" | tee -a "$LOG"
rm -f "$WT/game/zz_616_drive.gd" "$WT/game/zz_616_drive.gd.uid"
grep -E "^STEP" "$LOG"
exit "$CODE"
