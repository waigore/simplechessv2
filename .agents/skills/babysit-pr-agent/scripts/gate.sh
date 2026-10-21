#!/bin/sh
# Exit 0 and print PR numbers when a same-repo open PR is conflicted, behind
# its base, or has a failing check. Exit 1 when none. Stdout is optional;
# agent-orc treats only the exit code as the gate.
set -eu

nums=$(
  gh pr list --state open --limit 50 \
    --json number,isCrossRepository,mergeable,mergeStateStatus,statusCheckRollup \
    --jq '
      map(select(.isCrossRepository == false) | select(
        .mergeable == "CONFLICTING"
        or .mergeStateStatus == "DIRTY"
        or .mergeStateStatus == "BEHIND"
        or any(.statusCheckRollup[]?;
          .conclusion == "FAILURE"
          or .conclusion == "CANCELLED"
          or .conclusion == "TIMED_OUT"
          or .conclusion == "STARTUP_FAILURE"
          or .state == "FAILURE"
          or .state == "ERROR"
        )
      )) | .[].number
    '
)

if [ -z "$nums" ]; then
  exit 1
fi

printf '%s\n' "$nums"
exit 0
