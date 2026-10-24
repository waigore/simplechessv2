#!/bin/sh
# List open issues with the given status label, ordered by priority
# (critical, high, then normal/unlabeled), then issue number within a tier.
# Prints JSON [{"number":N}, ...] for agent-orc issues.command.
# Usage: list-status-issues.sh status:pending-review
set -eu

STATUS_LABEL=${1:?usage: list-status-issues.sh status:LABEL}

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required" >&2
  exit 1
fi

gh issue list --state open --label "$STATUS_LABEL" --limit 100 --json number,labels \
  | jq '
      def tier:
        ([.labels[].name]
         | if any(. == "priority:critical") then 0
           elif any(. == "priority:high") then 1
           else 2 end);
      sort_by(tier, .number) | map({number})
    '
